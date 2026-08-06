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
fig_caption <- sprintf(
  "n = %d pure centre-backs | Europe's big-five leagues | most recent qualifying season per player (%s)",
  n_players, season_span
)

# =========================================================
# SCALING & K-MEANS
# =========================================================

scaled_features <- scale(clustering_data)

set.seed(123)
k_clusters <- 4

kmeans_model <- kmeans(
  scaled_features,
  centers = k_clusters,
  nstart = 50
)

data_clean$cluster <- as.factor(kmeans_model$cluster)

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
    subtitle = "K-Means clustering (k = 4) projected onto the first two principal components",
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
