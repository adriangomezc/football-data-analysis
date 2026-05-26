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
  data <- read.csv("outputs/tables/padj_defensive_metrics.csv")
  cat("Pipeline integrado con éxito: Cargados datos con ajuste de posesión real.\n")
} else {
  data <- read.csv("data/processed/defenders_processed.csv")
  data$team_possession <- 50
  data$opponent_possession <- 50
  data$padj_tackles <- data$tackles_per90
  data$padj_interceptions <- data$interceptions_per90
  cat("⚠️ WARNING: No se detectó el archivo PAdj. Usando baseline temporal.\n")
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

clustering_data <- data %>%
  select(
    progressive_passes_per90,
    progressive_carries_per90,
    padj_tackles,         
    padj_interceptions,
    progression_index
  ) %>%
  filter(complete.cases(.))
# Remove missing values
complete_rows <- complete.cases(clustering_data)

clustering_data <- clustering_data[complete_rows, ]
data_clean <- data[complete_rows, ]

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

write.csv(cluster_profiles, "outputs/tables/cluster_profiles.csv", row.names = FALSE)

# =========================================================
# RADAR-STYLE SUMMARY TABLE
# =========================================================

# CÁMBIALO A ESTO (sin Won. al final):
cluster_summary <- data_clean %>%
  select(
    Player,  
    cluster,
    League,  
    Age,     
    progressive_passes_per90,
    progressive_carries_per90, 
    progression_index,                  
    padj_interceptions,
    padj_tackles
  )

write.csv(cluster_summary, "outputs/tables/player_cluster_assignments.csv", row.names = FALSE)

cat("Clustering analysis completed successfully.\n")