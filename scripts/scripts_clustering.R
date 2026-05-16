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

data <- read.csv("data/processed/defenders_processed.csv")

# =========================================================
# FEATURE ENGINEERING
# =========================================================

data <- data %>%
  mutate(
    
    # Possession-adjusted defending
    opponent_possession = 100 - team_possession,
    
    padj_tackles =
      tackles_per90 / (opponent_possession / 50),
    
    padj_interceptions =
      interceptions_per90 / (opponent_possession / 50),
    
    padj_blocks =
      blocks_per90 / (opponent_possession / 50),
    
    # Progressive contribution
    progression_score =
      progressive_passes_per90 +
      carries_per90,
    
    # Defensive dominance
    defensive_score =
      padj_tackles +
      padj_interceptions +
      aerial_duels_won_pct,
    
    # Ball-playing profile
    build_up_score =
      pass_completion_pct +
      progressive_passes_per90 +
      xT_per90
  )

# =========================================================
# CLUSTERING FEATURES
# =========================================================

clustering_data <- data %>%
  select(
    progressive_passes_per90,
    carries_per90,
    xT_per90,
    padj_interceptions,
    padj_tackles,
    aerial_duels_won_pct,
    pass_completion_pct,
    blocks_per90
  )

# Remove missing values
complete_rows <- complete.cases(clustering_data)

clustering_data <- clustering_data[complete_rows, ]
data_clean <- data[complete_rows, ]

# =========================================================
# SCALING
# =========================================================

scaled_features <- scale(clustering_data)

# =========================================================
# ELBOW METHOD
# =========================================================

png(
  "outputs/figures/elbow_method.png",
  width = 900,
  height = 700
)

fviz_nbclust(
  scaled_features,
  kmeans,
  method = "wss"
) +
  theme_minimal() +
  labs(
    title = "Optimal Number of Clusters"
  )

dev.off()

# =========================================================
# K-MEANS CLUSTERING
# =========================================================

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
  player = data_clean$player,
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
    aes(label = player),
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

ggsave(
  "outputs/figures/cluster_pca_visualization.png",
  p,
  width = 11,
  height = 8
)

# =========================================================
# CLUSTER PROFILES
# =========================================================

cluster_profiles <- data_clean %>%
  group_by(cluster) %>%
  summarise(
    
    players = n(),
    
    progressive_passes =
      mean(progressive_passes_per90, na.rm = TRUE),
    
    carries =
      mean(carries_per90, na.rm = TRUE),
    
    xT =
      mean(xT_per90, na.rm = TRUE),
    
    interceptions =
      mean(padj_interceptions, na.rm = TRUE),
    
    tackles =
      mean(padj_tackles, na.rm = TRUE),
    
    aerial_duels =
      mean(aerial_duels_won_pct, na.rm = TRUE),
    
    passing =
      mean(pass_completion_pct, na.rm = TRUE)
  )

write.csv(
  cluster_profiles,
  "outputs/tables/cluster_profiles.csv",
  row.names = FALSE
)

# =========================================================
# RADAR-STYLE SUMMARY TABLE
# =========================================================

cluster_summary <- data_clean %>%
  select(
    player,
    cluster,
    league,
    age,
    progressive_passes_per90,
    carries_per90,
    xT_per90,
    padj_interceptions,
    padj_tackles,
    aerial_duels_won_pct
  )

write.csv(
  cluster_summary,
  "outputs/tables/player_cluster_assignments.csv",
  row.names = FALSE
)

# =========================================================
# CLUSTER INTERPRETATION
# =========================================================

cluster_labels <- data.frame(
  cluster = c(1,2,3,4),
  archetype = c(
    "Ball-Playing Defender",
    "Aggressive Duelist",
    "Deep Defensive Anchor",
    "Progressive Hybrid"
  )
)

write.csv(
  cluster_labels,
  "outputs/tables/cluster_archetypes.csv",
  row.names = FALSE
)

# =========================================================
# SILHOUETTE ANALYSIS
# =========================================================

sil <- silhouette(
  kmeans_model$cluster,
  dist(scaled_features)
)

png(
  "outputs/figures/silhouette_analysis.png",
  width = 900,
  height = 700
)

fviz_silhouette(sil) +
  theme_minimal()

dev.off()

# =========================================================
# CORRELATION MATRIX
# =========================================================

png(
  "outputs/figures/feature_correlation_matrix.png",
  width = 1000,
  height = 900
)

corrplot(
  cor(clustering_data),
  method = "color",
  type = "upper",
  tl.cex = 0.9
)

dev.off()

cat("Clustering analysis completed successfully.\n")
