library(tidyverse)
library(viridis)
library(ggrepel)
library(cluster)

# Load data
df <- read.csv("data/player_stats_2024_2025.csv")

# Feature engineering
df_scouting <- df %>%
  filter(Pos == "DF") %>%
  filter(Age <= 28) %>%
  filter(Min >= 900) %>%
  filter(Crs <= 15) %>%
  mutate(
    PrgP_90 = (PrgP / Min) * 90,
    PrgC_90 = (PrgC / Min) * 90,
    KP_90   = (KP / Min) * 90,
    Def_Actions_90 = ((Tkl + Int + Recov) / Min) * 90,
    Progression_90 = PrgP_90 + PrgC_90
  ) %>%
  drop_na()

# Scaling
pca_data <- df_scouting %>%
  select(Progression_90, Def_Actions_90, KP_90, Cmp.)

pca_scaled <- scale(pca_data)

# K selection (elbow + silhouette)
set.seed(123)
wss <- sapply(2:8, function(k) {
  kmeans(pca_scaled, centers = k, nstart = 25)$tot.withinss
})

sil <- sapply(2:8, function(k) {
  km <- kmeans(pca_scaled, centers = k, nstart = 25)
  ss <- silhouette(km$cluster, dist(pca_scaled))
  mean(ss[, 3])
})

k_opt <- which.max(sil) + 1

# Final k-means
set.seed(123)
km_res <- kmeans(pca_scaled, centers = k_opt, nstart = 25)

# PCA + explained variance
pca_res <- prcomp(pca_scaled, center = TRUE, scale. = TRUE)
pca_var <- summary(pca_res)$importance[2, 1:2] * 100
pc1_var <- round(pca_var[1], 1)
pc2_var <- round(pca_var[2], 1)

df_pca <- as.data.frame(pca_res$x[, 1:2])
df_pca$Cluster <- factor(km_res$cluster)

# Merge cluster labels
df_clusters <- df_scouting %>%
  mutate(Cluster = factor(km_res$cluster))

write.csv(df_clusters, "outputs/clustered_defenders.csv", row.names = FALSE)

# Cluster interpretation
cluster_profiles <- df_clusters %>%
  group_by(Cluster) %>%
  summarise(
    Progression_90 = mean(Progression_90),
    Def_Actions_90 = mean(Def_Actions_90),
    KP_90 = mean(KP_90),
    Cmp = mean(Cmp.)
  ) %>%
  arrange(desc(Progression_90))

write.csv(cluster_profiles, "outputs/cluster_profiles.csv", row.names = FALSE)

# PCA plot
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
# Tactical labels for clusters
# -----------------------------
cluster_labels <- c(
  "1" = "Progressive enforcers",
  "2" = "Low involvement defenders"
)

df_clusters <- df_clusters %>%
  mutate(Cluster_Label = cluster_labels[as.character(Cluster)])

write.csv(df_clusters, "outputs/clustered_defenders_labeled.csv", row.names = FALSE)

cluster_profiles <- cluster_profiles %>%
  mutate(Cluster_Label = cluster_labels[as.character(Cluster)])

write.csv(cluster_profiles, "outputs/cluster_profiles_labeled.csv", row.names = FALSE)