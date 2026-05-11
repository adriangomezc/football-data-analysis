library(tidyverse)
library(ggrepel)
library(viridis)
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
    # Per 90 metrics
    PrgP_90 = (PrgP / Min) * 90,
    PrgC_90 = (PrgC / Min) * 90,
    KP_90   = (KP / Min) * 90,

    Tkl_90   = (Tkl / Min) * 90,
    Int_90   = (Int / Min) * 90,
    Recov_90 = (Recov / Min) * 90,

    # Composite metrics
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

    # Final weighted score
    Modern_CB_Score =
      (0.40 * Ball_Progression) +
      (0.35 * Defensive_Intensity) +
      (0.15 * Creative_Involvement) +
      (0.10 * Passing_Security)
  ) %>%
  drop_na()

# -----------------------------
# PCA input data
# -----------------------------
pca_data <- df_scouting %>%
  select(
    Ball_Progression,
    Defensive_Intensity,
    Creative_Involvement,
    Passing_Security
  )

pca_scaled <- scale(pca_data)

# -----------------------------
# Correlation heatmap
# -----------------------------
corr_matrix <- cor(pca_data, use = "pairwise.complete.obs")

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
# Optimal cluster selection
# -----------------------------
set.seed(123)

# Elbow
elbow_plot <- fviz_nbclust(
  pca_scaled,
  kmeans,
  method = "wss"
) +
  labs(title = "Elbow method for optimal k") +
  theme_minimal(base_size = 13)

ggsave(
  "outputs/elbow_method.png",
  elbow_plot,
  width = 7,
  height = 5,
  dpi = 300
)

# Silhouette
silhouette_plot <- fviz_nbclust(
  pca_scaled,
  kmeans,
  method = "silhouette"
) +
  labs(title = "Silhouette analysis for optimal k") +
  theme_minimal(base_size = 13)

ggsave(
  "outputs/silhouette_method.png",
  silhouette_plot,
  width = 7,
  height = 5,
  dpi = 300
)

# Gap statistic
gap_stat <- clusGap(
  pca_scaled,
  FUN = kmeans,
  nstart = 25,
  K.max = 8,
  B = 50
)

gap_plot <- fviz_gap_stat(gap_stat) +
  labs(title = "Gap statistic") +
  theme_minimal(base_size = 13)

ggsave(
  "outputs/gap_statistic.png",
  gap_plot,
  width = 7,
  height = 5,
  dpi = 300
)

k_opt <- which.max(gap_stat$Tab[, "gap"])

# -----------------------------
# Final k-means
# -----------------------------
set.seed(123)
km_res <- kmeans(pca_scaled, centers = k_opt, nstart = 25)

# -----------------------------
# PCA + explained variance
# -----------------------------
pca_res <- prcomp(pca_scaled, center = TRUE, scale. = TRUE)
pca_var <- summary(pca_res)$importance[2, 1:2] * 100
pc1_var <- round(pca_var[1], 1)
pc2_var <- round(pca_var[2], 1)

df_pca <- as.data.frame(pca_res$x[, 1:2])
df_pca$Cluster <- factor(km_res$cluster)

# -----------------------------
# Merge cluster labels
# -----------------------------
df_clusters <- df_scouting %>%
  mutate(Cluster = factor(km_res$cluster))

cluster_profiles <- df_clusters %>%
  group_by(Cluster) %>%
  summarise(
    n_players = n(),
    Ball_Progression = mean(Ball_Progression),
    Defensive_Intensity = mean(Defensive_Intensity),
    Creative_Involvement = mean(Creative_Involvement),
    Passing_Security = mean(Passing_Security),
    Mean_Age = mean(Age)
  ) %>%
  mutate(
    Cluster_Label = case_when(
      Ball_Progression == max(Ball_Progression)
      ~ "Progressive distributors",
      Defensive_Intensity == max(Defensive_Intensity)
      ~ "Defensive enforcers",
      TRUE
      ~ "Balanced centre-backs"
    )
  )

df_clusters <- df_clusters %>%
  left_join(
    cluster_profiles %>% select(Cluster, Cluster_Label),
    by = "Cluster"
  )

write.csv(df_clusters, "outputs/clustered_defenders.csv", row.names = FALSE)
write.csv(cluster_profiles, "outputs/cluster_profiles.csv", row.names = FALSE)

# -----------------------------
# PCA plot
# -----------------------------
plot2 <- ggplot(df_pca, aes(x = PC1, y = PC2, color = Cluster)) +
  geom_point(alpha = 0.85, size = 2) +
  scale_color_viridis_d() +
  labs(
    title = "PCA clustering of centre-back profiles",
    subtitle = paste0(
      "K-means clustering (k = ", k_opt,
      ") | PC1 ", pc1_var, "%, PC2 ", pc2_var, "%"
    ),
    x = "PC1",
    y = "PC2"
  ) +
  theme_minimal(base_size = 12)

ggsave("outputs/pca_clusters.png", plot2, width = 9, height = 6, dpi = 300)

# -----------------------------
# PCA biplot
# -----------------------------
while (dev.cur() > 1) dev.off()

cluster_palette <- viridis::viridis(length(levels(factor(km_res$cluster))))

biplot <- fviz_pca_biplot(
  pca_res,
  geom.ind = "point",
  habillage = factor(km_res$cluster),
  addEllipses = FALSE,
  label = "var",
  col.var = "black",
  repel = TRUE,
  palette = cluster_palette
) +
  labs(
    title = "PCA biplot of centre-back archetypes",
    subtitle = paste0(
      "PC1: ", pc1_var,
      "% variance | PC2: ",
      pc2_var, "% variance"
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
# Radar chart for cluster profiles
# -----------------------------

library(fmsb)

radar_data <- cluster_profiles %>%
  select(
    Ball_Progression,
    Defensive_Intensity,
    Creative_Involvement,
    Passing_Security
  )

# Convert rownames
radar_df <- as.data.frame(radar_data)

rownames(radar_df) <- cluster_profiles$Cluster_Label

# Add max/min rows REQUIRED by fmsb
radar_plot <- rbind(
  rep(
    max(radar_df) * 1.2,
    ncol(radar_df)
  ),
  rep(
    min(radar_df) * 0.8,
    ncol(radar_df)
  ),
  radar_df
)

png(
  "outputs/cluster_radar.png",
  width = 1000,
  height = 800
)

radarchart(
  radar_plot,
  axistype = 1,
  
  pcol = viridis(nrow(radar_df)),
  pfcol = scales::alpha(
    viridis(nrow(radar_df)),
    0.25
  ),
  
  plwd = 3,
  plty = 1,
  
  cglcol = "grey80",
  cglty = 1,
  axislabcol = "grey30",
  
  vlcex = 1.1,
  
  title = "Tactical cluster profiles"
)

legend(
  "topright",
  legend = rownames(radar_df),
  col = viridis(nrow(radar_df)),
  lty = 1,
  lwd = 3,
  bty = "n",
  cex = 1
)

dev.off()