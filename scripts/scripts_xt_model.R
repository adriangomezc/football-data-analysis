source("scripts/setup_packages.R")

dir.create("outputs/tables", recursive = TRUE, showWarnings = FALSE)

events <- read.csv("data/raw/events.csv")

# =========================
# SIMPLE xT GRID
# =========================

x_bins <- 12
y_bins <- 8

events <- events %>%
  mutate(
    start_zone_x = cut(x, breaks = x_bins, labels = FALSE),
    start_zone_y = cut(y, breaks = y_bins, labels = FALSE),
    
    end_zone_x = cut(end_x, breaks = x_bins, labels = FALSE),
    end_zone_y = cut(end_y, breaks = y_bins, labels = FALSE)
  )

# SIMPLE THREAT MODEL
events <- events %>%
  mutate(
    start_threat =
      (start_zone_x / x_bins) * 0.7 +
      (start_zone_y / y_bins) * 0.3,
    
    end_threat =
      (end_zone_x / x_bins) * 0.7 +
      (end_zone_y / y_bins) * 0.3,
    
    xT_added = end_threat - start_threat
  )

# =========================
# PLAYER AGGREGATION
# =========================

player_xt <- events %>%
  group_by(player) %>%
  summarise(
    total_xT = sum(xT_added, na.rm = TRUE),
    mean_xT = mean(xT_added, na.rm = TRUE),
    progressive_actions = sum(xT_added > 0),
    actions = n()
  ) %>%
  arrange(desc(total_xT))

write.csv(
  player_xt,
  "outputs/tables/player_xt_metrics.csv",
  row.names = FALSE
)

# =========================
# VISUALIZATION
# =========================

p <- ggplot(
  player_xt %>% top_n(20, total_xT),
  aes(
    x = reorder(player, total_xT),
    y = total_xT
  )
) +
  geom_col() +
  coord_flip() +
  theme_minimal() +
  labs(
    title = "Top Players by Expected Threat Added",
    x = "",
    y = "Total xT"
  )

ggsave(
  "outputs/figures/top_xt_players.png",
  p,
  width = 10,
  height = 7
)
