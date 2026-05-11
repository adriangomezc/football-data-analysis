library(tidyverse)
library(ggrepel)
library(viridis)

df <- read.csv("data/player_stats_2024_2025.csv")

# -----------------------------
# Data filtering
# -----------------------------

df_scouting <- df %>%
  
  # Only defenders
  filter(Pos == "DF") %>%
  
  # Under 28
  filter(Age <= 28) %>%
  
  # Minimum minutes played
  filter(Min >= 900) %>%
  
  # Anti-fullback filter
  filter(Crs <= 15) %>%
  
  # Per 90 metrics
  mutate(
    PrgP_90 = (PrgP / Min) * 90,
    PrgC_90 = (PrgC / Min) * 90,
    KP_90 = (KP / Min) * 90,
    
    Def_Actions_90 = ((Tkl + Int + Recov) / Min) * 90,
    
    Progression_90 = PrgP_90 + PrgC_90,
    
    Modern_CB_Score =
      (0.45 * Progression_90) +
      (0.35 * Def_Actions_90) +
      (0.20 * KP_90)
  ) %>%
  
  arrange(desc(Modern_CB_Score))

# Top 10 players

top_players <- df_scouting %>%
  select(Player, Squad, Age,
         Progression_90,
         Def_Actions_90,
         Modern_CB_Score) %>%
  head(10)

print(top_players)

# -----------------------------
# Visualization
# -----------------------------

mean_x <- mean(df_scouting$Def_Actions_90, na.rm = TRUE)
mean_y <- mean(df_scouting$Progression_90, na.rm = TRUE)

plot <- ggplot(df_scouting,
               aes(x = Def_Actions_90,
                   y = Progression_90)) +
  
  annotate("rect",
           xmin = mean_x,
           xmax = Inf,
           ymin = mean_y,
           ymax = Inf,
           fill = "darkgreen",
           alpha = 0.08) +
  
  geom_point(aes(color = Modern_CB_Score),
             size = 3,
             alpha = 0.8) +
  
  geom_vline(xintercept = mean_x,
             linetype = "dashed",
             color = "grey50") +
  
  geom_hline(yintercept = mean_y,
             linetype = "dashed",
             color = "grey50") +
  
  geom_text_repel(
    data = top_players,
    aes(label = Player),
    size = 3.5,
    fontface = "bold",
    max.overlaps = 20
  ) +
  
  scale_color_viridis_c(
    option = "E",
    name = "Score"
  ) +
  
  labs(
    title = "Identifying modern ball-playing centre-backs",
    
    subtitle = "Players under 28 with more than 900 minutes played",
    
    x = "Defensive actions per 90",
    
    y = "Progression per 90"
  ) +
  
  theme_bw(base_size = 12) +
  
  theme(
    legend.position = "bottom",
    
    plot.title = element_text(face = "bold"),
    
    panel.grid.minor = element_blank()
  )

plot

ggsave(
  filename = "outputs/modern_cb_scouting.png",
  plot = plot,
  width = 10,
  height = 7,
  dpi = 300
)
