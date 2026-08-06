# =========================================================
# scripts_clustering.R
# Tactical Archetype Clustering for Centre-Back Profiling
# =========================================================

source("scripts/setup_packages.R")

dir.create("outputs/figures", recursive = TRUE, showWarnings = FALSE)
dir.create("outputs/tables", recursive = TRUE, showWarnings = FALSE)

# =========================================================
# LOAD DATA
# =========================================================

if (!file.exists("outputs/tables/padj_defensive_metrics.csv")) {
  stop("[ERROR FATAL] No se detectó el archivo PAdj. Ejecuta scripts_padj_metrics.R y scripts_scouting.R primero.")
}

data <- read.csv("outputs/tables/padj_defensive_metrics.csv")
cat("Datos PAdj cargados correctamente.\n")

# =========================================================
# CLUSTERING FEATURES
# =========================================================

# 1. Definimos las variables de interés
vars_clustering <- c("progressive_passes_per90", "progressive_carries_per90",
                     "padj_tackles", "padj_interceptions", "progression_index")

# 2. Identificamos qué filas de la tabla original NO tienen NAs en esas columnas específicas
complete_rows <- complete.cases(data[, vars_clustering])

# 3. Filtramos ambas tablas usando exactamente el mismo índice lógico
data_clean <- data[complete_rows, ]
clustering_data <- data_clean[, vars_clustering]

# Contexto de la muestra (se reutiliza en los subtítulos de las figuras)
n_players   <- nrow(data_clean)
season_span <- paste(sort(unique(data_clean$Season)), collapse = " + ")
# Los pies van en inglés: las figuras las comparten README.md y README.es.md.
# Se parten en dos líneas: en una sola, el texto desborda el ancho del lienzo.
fig_caption <- sprintf(
  "n = %d pure centre-backs | Europe's big-five leagues\nMost recent qualifying season per player (%s)",
  n_players, season_span
)

# =========================================================
# SCALING
# =========================================================

scaled_features <- scale(clustering_data)

# =========================================================
# SELECCIÓN DE K: MÉTODO DEL CODO + MÉTODO DE LA SILUETA
# =========================================================
# k=4 no se fija a priori sin contraste: se compara primero contra los dos
# criterios estándar (WSS / codo, y ancho de silueta medio). silhouette()
# viene del paquete 'cluster' (recommended, se instala con R).

k_range <- 2:8

wss_by_k <- sapply(k_range, function(k) {
  set.seed(123)
  kmeans(scaled_features, centers = k, nstart = 50)$tot.withinss
})

sil_by_k <- sapply(k_range, function(k) {
  set.seed(123)
  km <- kmeans(scaled_features, centers = k, nstart = 50)
  mean(cluster::silhouette(km$cluster, dist(scaled_features))[, 3])
})

k_selection <- data.frame(k = k_range, wss = round(wss_by_k, 1),
                          mean_silhouette = round(sil_by_k, 4))
cat("Selección de k - método del codo y de la silueta:\n")
print(k_selection)
write.csv(k_selection, "outputs/tables/cluster_k_selection.csv", row.names = FALSE)

k_optimo_silueta <- k_range[which.max(sil_by_k)]
cat(sprintf("k que maximiza la silueta media: %d (silueta = %.3f)\n",
           k_optimo_silueta, max(sil_by_k)))

# DECISIÓN: se mantiene k=4 salvo que el criterio estadístico apunte a una
# estructura claramente mejor. k=2-3 suele colapsar la separación
# progresión/defensa en un único eje (progresivo vs. limitado), perdiendo la
# granularidad táctica de cuatro roles que sostiene el resto del informe.
# Se documenta explícitamente el trade-off en vez de ocultarlo.
k_clusters <- 4
cat(sprintf(
  "Se elige k=%d (silueta = %.3f) frente al óptimo estadístico k=%d (silueta = %.3f):\n",
  k_clusters, sil_by_k[k_range == k_clusters], k_optimo_silueta, max(sil_by_k)
))
cat("prioriza la granularidad táctica (4 roles interpretables) sobre el máximo absoluto de silueta.\n")

# Los paneles van en inglés (misma convención que el resto de figuras, que se
# insertan en README.md y README.es.md por igual). El orden se fija a mano:
# WSS primero (introducción pedagógica habitual), silueta después.
k_selection_long <- k_selection %>%
  pivot_longer(cols = c(wss, mean_silhouette), names_to = "metodo", values_to = "valor") %>%
  mutate(metodo = factor(
    recode(metodo,
      wss = "Elbow method (WSS)",
      mean_silhouette = "Silhouette method (mean width)"
    ),
    levels = c("Elbow method (WSS)", "Silhouette method (mean width)")
  ))

p_k <- ggplot(k_selection_long, aes(x = k, y = valor)) +
  geom_line(color = "#4C72B0", linewidth = 0.8) +
  geom_point(size = 2.5, color = "#4C72B0") +
  geom_vline(xintercept = k_clusters, linetype = "dashed", color = "grey40") +
  facet_wrap(~metodo, scales = "free_y") +
  scale_x_continuous(breaks = k_range) +
  theme_minimal(base_size = 12) +
  labs(
    title    = "K selection diagnostics",
    subtitle = sprintf("Dashed line: k = %d, the value used in the pipeline", k_clusters),
    x        = "Number of clusters (k)",
    y        = NULL,
    caption  = fig_caption
  )

ggsave("outputs/figures/cluster_k_selection.png", p_k, width = 10, height = 5, dpi = 200)

# =========================================================
# K-MEANS FINAL
# =========================================================

set.seed(123)
kmeans_model <- kmeans(
  scaled_features,
  centers = k_clusters,
  nstart = 50
)

data_clean$cluster <- as.factor(kmeans_model$cluster)

# =========================================================
# VALIDACIÓN CRUZADA DE MÉTODO: K-MEANS VS. CLUSTERING JERÁRQUICO
# =========================================================
# Si un algoritmo completamente distinto (jerárquico aglomerativo, enlace de
# Ward) recupera aproximadamente la misma partición, es evidencia de que los
# 4 arquetipos son una estructura real de los datos y no un artefacto de
# K-Means. Se reporta también la correlación cofenética (bondad del propio
# dendrograma) y el Índice de Rand Ajustado (Hubert & Arabie, 1985) entre
# ambas particiones, calculado a mano a partir de la tabla de contingencia
# para no depender de un paquete adicional (mclust) solo para un número.

dist_matrix <- dist(scaled_features, method = "euclidean")
hc_model <- hclust(dist_matrix, method = "ward.D2")
hc_clusters <- cutree(hc_model, k = k_clusters)

cophenetic_cor <- cor(dist_matrix, cophenetic(hc_model))
cat(sprintf("Correlacion cofenetica del dendrograma (ward.D2): %.3f\n", cophenetic_cor))

agreement_table <- table(KMeans = kmeans_model$cluster, Jerarquico = hc_clusters)
cat("Tabla de contingencia K-Means vs. Jerarquico:\n")
print(agreement_table)

adjusted_rand_index <- function(tab) {
  n <- sum(tab)
  sum_comb <- function(x) sum(choose(x, 2))
  index_sum <- sum_comb(as.vector(tab))
  expected  <- sum_comb(rowSums(tab)) * sum_comb(colSums(tab)) / choose(n, 2)
  max_index <- 0.5 * (sum_comb(rowSums(tab)) + sum_comb(colSums(tab)))
  (index_sum - expected) / (max_index - expected)
}

ari_value <- adjusted_rand_index(agreement_table)
row_max_agreement <- sum(apply(agreement_table, 1, max)) / sum(agreement_table) * 100

cat(sprintf("Acuerdo simple (moda por fila): %.1f%%\n", row_max_agreement))
cat(sprintf("Indice de Rand Ajustado (K-Means vs. Jerarquico): %.3f\n", ari_value))

write.csv(
  as.data.frame.matrix(agreement_table),
  "outputs/tables/kmeans_vs_hierarchical_agreement.csv"
)

# =========================================================
# DYNAMIC ROLE ASSIGNMENT (Data-Driven K-Means)
# =========================================================

# 1. Calculamos los centroides matemáticos de cada cluster
cluster_logic <- data_clean %>%
  group_by(cluster) %>%
  summarise(
    mean_prog = mean(progression_index, na.rm = TRUE),
    mean_def  = mean(padj_tackles + padj_interceptions, na.rm = TRUE),
    .groups = 'drop'
  )

# 2. Asignación secuencial por eliminación: garantiza cuatro etiquetas distintas
#    aunque un mismo cluster lidere a la vez en progresión y en volumen defensivo.
assign_roles <- function(profiles) {
  pending <- profiles
  roles   <- character(0)
  ids     <- character(0)

  take <- function(idx, label) {
    ids   <<- c(ids, as.character(pending$cluster[idx]))
    roles <<- c(roles, label)
    pending <<- pending[-idx, ]
  }

  take(which.max(pending$mean_prog), "Elite Progressive Distributor")
  take(which.max(pending$mean_def),  "High-Intensity Ball-Winner")
  take(which.min(pending$mean_prog), "Limited / Reactive Defender")
  take(1L,                           "Standard Build-up Distributor")

  data.frame(cluster = ids, role_profile = roles, stringsAsFactors = FALSE)
}

role_map <- assign_roles(cluster_logic)

# 3. Unimos los nombres dinámicos de vuelta al dataset principal
data_clean <- data_clean %>%
  select(-any_of("role_profile")) %>% # Evitar duplicados si se corre dos veces
  mutate(cluster_chr = as.character(cluster)) %>%
  left_join(role_map, by = c("cluster_chr" = "cluster")) %>%
  select(-cluster_chr)

cat("Roles asignados dinámicamente:\n")
print(table(data_clean$role_profile))

# =========================================================
# CLUSTER PROFILES
# =========================================================

cluster_profiles <- data_clean %>%
  group_by(cluster, role_profile) %>%
  summarise(
    players               = n(),
    progressive_passes    = mean(progressive_passes_per90, na.rm = TRUE),
    progressive_carries   = mean(progressive_carries_per90, na.rm = TRUE),
    progression_index     = mean(progression_index, na.rm = TRUE),
    padj_interceptions    = mean(padj_interceptions, na.rm = TRUE),
    padj_tackles          = mean(padj_tackles, na.rm = TRUE),
    padj_recoveries       = mean(padj_recoveries, na.rm = TRUE),
    defending_score       = mean(defending_score, na.rm = TRUE),
    pass_completion       = mean(pass_completion, na.rm = TRUE),
    age                   = mean(Age, na.rm = TRUE),
    scouting_score        = mean(scouting_score, na.rm = TRUE),
    .groups = 'drop'
  ) %>%
  arrange(desc(progression_index))

write.csv(cluster_profiles, "outputs/tables/cluster_profiles.csv", row.names = FALSE)

# =========================================================
# RADAR-STYLE SUMMARY TABLE
# =========================================================

cluster_summary <- data_clean %>%
  select(
    Player,
    Squad,
    League,
    Season,
    Age,
    cluster,
    role_profile,            # ¡El algoritmo ahora decide el rol!
    scouting_score,          # ¡La nota maestra ya trae el PAdj integrado!
    progression_index,
    padj_interceptions,
    padj_tackles
  ) %>%
  arrange(desc(scouting_score))

write.csv(cluster_summary, "outputs/tables/final_scouting_dashboard.csv", row.names = FALSE)

cat("Clustering analysis completed successfully.\n")

# =========================================================
# PCA VISUALIZATION
# =========================================================

pca <- prcomp(scaled_features)
var_explained <- round(100 * summary(pca)$importance[2, 1:2], 1)

pca_data <- data.frame(
  PC1            = pca$x[, 1],
  PC2            = pca$x[, 2],
  Player         = data_clean$Player,
  role_profile   = data_clean$role_profile,
  scouting_score = data_clean$scouting_score
)

# Etiquetamos solo el top 15 por scouting score: con 400 nombres la figura es ilegible
pca_labels <- pca_data %>% slice_max(scouting_score, n = 15)

p <- ggplot(pca_data, aes(x = PC1, y = PC2, color = role_profile)) +
  geom_point(size = 3, alpha = 0.75) +
  geom_text_repel(
    data = pca_labels,
    aes(label = Player),
    size = 3.4,
    min.segment.length = 0,
    box.padding = 0.6,
    max.overlaps = Inf,
    seed = 123,
    show.legend = FALSE
  ) +
  theme_minimal(base_size = 13) +
  theme(legend.position = "bottom", legend.title = element_blank()) +
  labs(
    title    = "Centre-Back Tactical Archetypes",
    subtitle = sprintf("K-Means clustering (k = %d) projected onto the first two principal components", k_clusters),
    x        = sprintf("Principal Component 1 (%.1f%% var.)", var_explained[1]),
    y        = sprintf("Principal Component 2 (%.1f%% var.)", var_explained[2]),
    caption  = paste0(fig_caption, "\nLabelled: top 15 by scouting score")
  )

ggsave("outputs/figures/cluster_pca_visualization.png", p,
       width = 11, height = 8, dpi = 200)

# =========================================================
# SCATTERPLOT: PROGRESSION VS DEFENDING
# =========================================================

p1 <- ggplot(
  data_clean,  # tabla que ya incorpora los roles asignados
  aes(
    x     = progression_index,
    y     = defending_score,
    color = role_profile,
    size  = scouting_score
  )
) +
  geom_point(alpha = 0.75) +
  theme_minimal(base_size = 13) +
  theme(legend.position = "right") +
  labs(
    title    = "Defender Archetypes (Pure CB)",
    subtitle = "Ball progression vs possession-adjusted defensive output",
    x        = "Progression Index (PCA Weighted)",
    y        = "Defending Score (PAdj tackles + interceptions + recoveries)",
    color    = NULL,
    size     = "Scouting score",
    caption  = fig_caption
  )

ggsave("outputs/figures/defender_archetypes.png", p1,
       width = 10, height = 7, dpi = 200)

# =========================================================
# AGE VS SCOUTING VALUE
# =========================================================

p2 <- ggplot(
  data_clean,
  aes(
    x     = Age,
    y     = scouting_score,
    color = role_profile
  )
) +
  geom_point(size = 3, alpha = 0.75) +
  theme_minimal(base_size = 13) +
  theme(legend.position = "right") +
  labs(
    color    = NULL,
    title    = "Recruitment Value by Age",
    subtitle = "U-24 profiles in the upper band are the market-inefficiency candidates",
    x        = "Age",
    y        = "Scouting Score",
    caption  = fig_caption
  )

ggsave("outputs/figures/recruitment_value.png", p2,
       width = 10, height = 7, dpi = 200)

cat("Figuras exportadas en outputs/figures/.\n")
