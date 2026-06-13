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

if (file.exists("outputs/tables/padj_defensive_metrics.csv")) {
  # CORRECCIÓN: Apuntamos al archivo maestro correcto
  data <- read.csv("outputs/tables/padj_defensive_metrics.csv")
  cat("Datos PAdj cargados correctamente.\n")
} else {
  stop("[ERROR FATAL] No se detectó el archivo PAdj. Ejecuta scripts_padj_metrics.R primero para generar el contexto táctico.")
}

# =========================================================
# FEATURE ENGINEERING
# =========================================================

data <- data %>%
  mutate(
    build_up_score = pass_completion + progressive_passes_per90 + progression_index,
    defensive_score = padj_tackles + padj_interceptions
  )

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
# PCA VISUALIZATION
# =========================================================

pca <- prcomp(scaled_features)

pca_data <- data.frame(
  PC1 = pca$x[,1],
  PC2 = pca$x[,2],
  Player = data_clean$Player,
  cluster = data_clean$cluster
)

p <- ggplot(
  pca_data,
  aes(
    x = PC1,
    y = PC2,
    color = cluster
  )
) +
  geom_point(size = 4, alpha = 0.8) +
  geom_text_repel(
    aes(label = Player),
    size = 3,
    max.overlaps = 20
  ) +
  theme_minimal() +
  labs(
    title = "Centre-Back Tactical Archetypes",
    subtitle = "K-Means Clustering with PCA Projection",
    x = "Principal Component 1",
    y = "Principal Component 2"
  )

ggsave("outputs/figures/cluster_pca_visualization.png", p, width = 11, height = 8)

# =========================================================
# CLUSTER PROFILES
# =========================================================

cluster_profiles <- data_clean %>%
  group_by(cluster) %>%
  summarise(
    players = n(),
    progressive_passes = mean(progressive_passes_per90, na.rm = TRUE),
    carries = mean(progressive_carries_per90, na.rm = TRUE), 
    xT = mean(progression_index, na.rm = TRUE),                       
    interceptions = mean(padj_interceptions, na.rm = TRUE),
    tackles = mean(padj_tackles, na.rm = TRUE),
    passing = mean(pass_completion, na.rm = TRUE)            
  )
# =========================================================
# DYNAMIC ROLE ASSIGNMENT (Data-Driven K-Means)
# =========================================================

# 1. Calculamos los centroides matemáticos de cada cluster
cluster_logic <- data_clean %>%
  group_by(cluster) %>%
  summarise(
    mean_prog = mean(progression_index, na.rm = TRUE),
    mean_def = mean(padj_tackles + padj_interceptions, na.rm = TRUE),
    .groups = 'drop'
  ) %>%
  mutate(
    # 2. Asignamos el rol detectando los máximos y mínimos relativos
    role_profile = case_when(
      mean_prog == max(mean_prog) ~ "Elite Progressive Distributor",
      mean_def == max(mean_def) ~ "High-Intensity Ball-Winner",
      mean_prog == min(mean_prog) ~ "Limited / Reactive Defender",
      TRUE ~ "Standard Build-up Distributor"
    )
  )

# 3. Unimos los nombres dinámicos de vuelta al dataset principal
data_clean <- data_clean %>%
  select(-any_of("role_profile")) %>% # Evitar duplicados si se corre dos veces
  left_join(cluster_logic %>% select(cluster, role_profile), by = "cluster")

# =========================================================
# RADAR-STYLE SUMMARY TABLE
# =========================================================

cluster_summary <- data_clean %>%
  select(
    Player,
    League,
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
# SCATTERPLOT: PROGRESSION VS DEFENDING
# =========================================================

p1 <- ggplot(
  data,
  aes(
    progression_index, # ¡Actualizado!
    defending_score,
    color = role_profile,
    size = scouting_score
  )
) +
  geom_point(alpha = 0.75) +
  theme_minimal() +
  labs(
    title = "Defender Archetypes (Pure CB)",
    x = "Progression Index (PCA Weighted)",
    y = "Defending Score"
  )

ggsave(
  "outputs/figures/defender_archetypes.png",
  p1,
  width = 10,
  height = 7
)

# =========================================================
# AGE VS SCOUTING VALUE
# =========================================================

p2 <- ggplot(
  data,
  aes(Age, scouting_score, color = role_profile)
) +
  geom_point(size = 3, alpha = 0.75) +
  theme_minimal() +
  labs(
    title = "Recruitment Value by Age",
    x = "Age",
    y = "Scouting Score"
  )

ggsave(
  "outputs/figures/recruitment_value.png",
  p2,
  width = 10,
  height = 7
)
