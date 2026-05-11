# =============================
# scripts/clustering.R
# =============================

library(tidyverse)
library(viridis)
library(ggrepel)
library(cluster)
library(factoextra)
library(fmsb)
library(corrplot)
library(scales)

# -----------------------------
# Load data
# -----------------------------

df <- read.csv("data/player_stats_2024_2025.csv")

# -----------------------------
# Feature engineering
# -----------------------------

df_scouting <- df %>%
  
  filter(Pos == "DF") %>%
  filter(Age <= 28) %>%
  filter(Min >= 900) %>%
  filter(Crs <= 15) %>%
  
  mutate(
    
    PrgP_90 = (PrgP / Min) * 90,
    PrgC_90 = (PrgC / Min) * 90,
    
    KP_90 = (KP / Min) * 90,
    
    Tkl_90 = (Tkl / Min) * 90,
    Int_90 = (Int / Min) * 90,
    Recov_90 = (Recov / Min) * 90,
    
    Defensive_Intensity =
      (0.45 * Tkl_90) +
      (0.30 * Int_90) +
      (0.25 * Recov_90),
    
    Ball_Progression =
      (0.70 * PrgP_90) +
      (0.30 * PrgC_90),
    
    Creative_Involvement =
      KP_90,
    
    Passing_Security =
      Cmp.,
    
    Progressive_Defender_Index =
      (0.6 * Ball_Progression) +
      (0.4 * Passing_Security),
    
    Defensive_Aggression =
      Tkl_90 + Int_90,
    
    Ball_Retention =
      Passing_Security * Recov_90
    
  ) %>%
  
  drop_na()

# -----------------------------
# PCA data
# -----------------------------

pca_data <- df_scouting %>%
  select(
    Ball_Progression,
    Defensive_Intensity,
    Creative_Involvement,
    Passing_Security,
    Progressive_Defender_Index,
    Defensive_Aggression,
    Ball_Retention
  )

# -----------------------------
# Scaling
# -----------------------------

pca_scaled <- scale(pca_data)

# -----------------------------
# Optimal k selection
# -----------------------------

candidate_k <- 2:8

sil_scores <- sapply(candidate_k, function(k) {
  
  km <- kmeans(
    pca_scaled,
    centers = k,
    nstart = 25
  )
  
  ss <- silhouette(
    km$cluster,
    dist(pca_scaled)
  )
  
  mean(ss[, 3])
  
})

k_opt <- candidate_k[which.max(sil_scores)]

cat("\nOptimal k selected:", k_opt, "\n")

# -----------------------------
# Final clustering
# -----------------------------

set.seed(123)

km_res <- kmeans(
  pca_scaled,
  centers = k_opt,
  nstart = 25
)

# -----------------------------
# PCA
# -----------------------------

pca_res <- prcomp(
  pca_scaled,
  center = TRUE,
  scale. = TRUE
)

pca_var <- summary(pca_res)$importance[2, 1:2] * 100

pc1_var <- round(pca_var[1], 1)
pc2_var <- round(pca_var[2], 1)

df_pca <- as.data.frame(pca_res$x[, 1:2])

df_pca$Cluster <- factor(km_res$cluster)

# -----------------------------
# Merge clusters
# -----------------------------

df_clusters <- cbind(df_scouting, df_pca) %>%
  mutate(
    Cluster_Label = ifelse(Cluster == 1, "Progressive distributors", "Conservative defenders")
  )

# -----------------------------
# Cluster profiles
# -----------------------------

cluster_profiles <- df_clusters %>%
  group_by(Cluster) %>%
  summarise(
    
    n_players = n(),
    
    Ball_Progression =
      mean(Ball_Progression),
    
    Defensive_Intensity =
      mean(Defensive_Intensity),
    
    Creative_Involvement =
      mean(Creative_Involvement),
    
    Passing_Security =
      mean(Passing_Security),
    
    Mean_Age =
      mean(Age)
    
  )

# -----------------------------
# Export data
# -----------------------------

write.csv(
  df_clusters,
  "outputs/clustered_defenders.csv",
  row.names = FALSE
)

write.csv(
  cluster_profiles,
  "outputs/cluster_profiles.csv",
  row.names = FALSE
)

# -----------------------------
# PCA cluster plot
# -----------------------------

plot2 <- ggplot(
  df_pca,
  aes(
    x = PC1,
    y = PC2,
    color = factor(km_res$cluster)
  )
) +
  
  geom_point(
    alpha = 0.85,
    size = 2.5
  ) +
  
  scale_color_viridis_d() +
  
  labs(
    title = "PCA clustering of centre-back profiles",
    
    subtitle = paste0(
      "K-means clustering (k = ",
      k_opt,
      ") | PC1 ",
      pc1_var,
      "% variance | PC2 ",
      pc2_var,
      "% variance"
    ),
    
    x = "PC1",
    y = "PC2",
    color = "Cluster"
  ) +
  
  theme_minimal(base_size = 13)

ggsave(
  "outputs/pca_clusters.png",
  plot2,
  width = 9,
  height = 6,
  dpi = 300
)

# -----------------------------
# PCA biplot
# -----------------------------

biplot <- fviz_pca_biplot(
  pca_res,
  
  geom.ind = "point",
  
  habillage = km_res$cluster,
  
  addEllipses = TRUE,
  
  label = "var",
  
  col.var = "black",
  
  repel = TRUE
) +
  
  scale_color_viridis_d() +
  
  labs(
    title = "PCA biplot of centre-back archetypes",
    
    subtitle = paste0(
      "PC1: ",
      pc1_var,
      "% variance | PC2: ",
      pc2_var,
      "% variance"
    )
  ) +
  
  theme_minimal(base_size = 13)

ggsave(
  "outputs/pca_biplot.png",
  biplot,
  width = 10,
  height = 7,
  dpi = 300
)

# -----------------------------
# Correlation heatmap
# -----------------------------

corr_matrix <- cor(
  pca_data,
  use = "pairwise.complete.obs"
)

png(
  "outputs/correlation_heatmap.png",
  width = 900,
  height = 700
)

corrplot(
  corr_matrix,
  method = "color",
  type = "upper",
  addCoef.col = "black",
  tl.cex = 1,
  number.cex = 0.7
)

dev.off()

# -----------------------------
# Cluster Validation: Silhouette Plot
# -----------------------------

sil_plot <- fviz_nbclust(pca_scaled, kmeans, method = "silhouette") +
  theme_minimal(base_size = 13) +
  labs(
    title = "Optimal number of clusters",
    subtitle = "Silhouette method validation"
  )

ggsave(
  "outputs/silhouette_plot.png",
  sil_plot,
  width = 8,
  height = 6,
  dpi = 300
)

# -----------------------------
# Standardised Profiles Heatmap (Replaces Radar)
# -----------------------------

radar_data <- df_clusters %>%
  group_by(Cluster_Label) %>%
  summarise(
    Ball_Progression = mean(Ball_Progression),
    Defensive_Intensity = mean(Defensive_Intensity),
    Creative_Involvement = mean(Creative_Involvement),
    Passing_Security = mean(Passing_Security)
  )

heatmap_data <- radar_data %>%
  column_to_rownames("Cluster_Label") %>%
  scale() %>%
  as.data.frame() %>%
  rownames_to_column("Cluster_Label") %>%
  pivot_longer(
    cols = -Cluster_Label, 
    names_to = "Metric", 
    values_to = "Z_Score"
  )

heatmap_plot <- ggplot(heatmap_data, aes(x = Metric, y = Cluster_Label, fill = Z_Score)) +
  geom_tile(color = "white", linewidth = 1) +
  scale_fill_viridis_c(option = "mako", name = "Z-Score") +
  theme_minimal(base_size = 13) +
  theme(
    axis.text.x = element_text(angle = 15, hjust = 1, face = "bold"),
    axis.text.y = element_text(face = "bold"),
    panel.grid = element_blank()
  ) +
  labs(
    title = "Tactical Profiles: Standardised Means by Cluster",
    x = NULL,
    y = NULL
  )

ggsave(
  "outputs/cluster_heatmap.png",
  heatmap_plot,
  width = 9,
  height = 5,
  dpi = 300
)