source("scripts/setup_packages.R")

dir.create("outputs/tables", recursive = TRUE, showWarnings = FALSE)

data <- read.csv("data/processed/defenders_processed.csv")

# =========================
# POSSESSION ADJUSTMENT
# =========================

data <- data %>%
  mutate(
    opponent_possession = 100 - team_possession,
    
    padj_tackles =
      tackles_per90 / (opponent_possession / 50),
    
    padj_interceptions =
      interceptions_per90 / (opponent_possession / 50),
    
    padj_blocks =
      blocks_per90 / (opponent_possession / 50)
  )

# =========================
# SAVE OUTPUT
# =========================

write.csv(
  data,
  "outputs/tables/padj_defensive_metrics.csv",
  row.names = FALSE
)

# =========================
# VISUALIZATION
# =========================

p <- ggplot(
  data,
  aes(
    x = padj_interceptions,
    y = padj_tackles,
    color = league
  )
) +
  geom_point(size = 3, alpha = 0.8) +
  geom_text_repel(
    aes(label = player),
    size = 3
  ) +
  theme_minimal() +
  labs(
    title = "Possession-Adjusted Defensive Metrics",
    x = "PAdj Interceptions",
    y = "PAdj Tackles"
  )

ggsave(
  "outputs/figures/padj_defensive_profile.png",
  p,
  width = 10,
  height = 7
)
