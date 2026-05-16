source("scripts/setup_packages.R")

dir.create("outputs/tables", recursive = TRUE, showWarnings = FALSE)

data <- read.csv("data/processed/defenders_processed.csv")

# =========================
# FEATURES
# =========================

features <- data %>%
  select(
    progressive_passes_per90,
    carries_per90,
    aerial_duels_won_pct,
    padj_interceptions,
    padj_tackles,
    xT_per90
  )

features_scaled <- scale(features)

# =========================
# COSINE SIMILARITY
# =========================

similarity_matrix <- proxy::simil(
  features_scaled,
  method = "cosine"
)

similarity_matrix <- as.matrix(similarity_matrix)

rownames(similarity_matrix) <- data$player
colnames(similarity_matrix) <- data$player

# =========================
# FIND SIMILAR PLAYERS
# =========================

target_player <- "Ruben Dias"

similar_players <- data.frame(
  player = colnames(similarity_matrix),
  similarity =
    similarity_matrix[target_player, ]
)

similar_players <- similar_players %>%
  filter(player != target_player) %>%
  arrange(desc(similarity)) %>%
  slice(1:10)

write.csv(
  similar_players,
  "outputs/tables/player_similarity_results.csv",
  row.names = FALSE
)

# =========================
# VISUALIZATION
# =========================

p <- ggplot(
  similar_players,
  aes(
    x = reorder(player, similarity),
    y = similarity
  )
) +
  geom_col() +
  coord_flip() +
  theme_minimal() +
  labs(
    title = paste(
      "Most Similar Players to",
      target_player
    ),
    x = "",
    y = "Cosine Similarity"
  )

ggsave(
  "outputs/figures/player_similarity.png",
  p,
  width = 10,
  height = 7
)
