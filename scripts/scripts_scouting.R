# =============================
# scripts/scouting.R
# =============================

library(tidyverse)
library(ggrepel)
library(viridis)

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
    
    KP_90 = (KP / Min) * 90,
    
    Tkl_90 = (Tkl / Min) * 90,
    Int_90 = (Int / Min) * 90,
    Recov_90 = (Recov / Min) * 90,
    
    # Composite variables
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
      Passing_Security * Recov_90,
    
    # Final score
    Modern_CB_Score =
      (0.40 * Ball_Progression) +
      (0.35 * Defensive_Intensity) +
      (0.15 * Creative_Involvement) +
      (0.10 * Passing_Security)
    
  ) %>%
  
  arrange(desc(Modern_CB_Score))

# -----------------------------
# Export top players
# -----------------------------

top_players <- df_scouting %>%
  select(
    Player,
    Squad,
    Age,
    Ball_Progression,
    Defensive_Intensity,
    Creative_Involvement,
    Passing_Security,
    Modern_CB_Score
  ) %>%
  head(15)

write.csv(
  top_players,
  "outputs/top15_modern_cb.csv",
  row.names = FALSE
)

# -----------------------------
# Visualization
# -----------------------------

plot1 <- ggplot(
  df_scouting,
  aes(
    x = Defensive_Intensity,
    y = Ball_Progression
  )
) +
  
  geom_point(
    aes(
      color = Modern_CB_Score,
      size = Creative_Involvement
    ),
    alpha = 0.85
  ) +
  
  geom_smooth(
    method = "lm",
    se = FALSE,
    linewidth = 0.7,
    color = "grey40",
    linetype = "dashed"
  ) +
  
  geom_text_repel(
    data = top_players,
    aes(label = Player),
    size = 3.5,
    fontface = "bold",
    max.overlaps = 20
  ) +
  
  scale_color_viridis_c(
    option = "E",
    name = "Composite score"
  ) +
  
  labs(
    title = "Modern centre-back profiling",
    subtitle =
      "Multivariate scouting framework using progression and defensive intensity",
    
    x = "Defensive intensity",
    y = "Ball progression",
    size = "Creative involvement"
  ) +
  
  theme_minimal(base_size = 13) +
  
  theme(
    legend.position = "bottom",
    plot.title = element_text(
      face = "bold",
      size = 18
    ),
    panel.grid.minor = element_blank()
  )

ggsave(
  "outputs/modern_cb_scouting.png",
  plot1,
  width = 10,
  height = 7,
  dpi = 300
)