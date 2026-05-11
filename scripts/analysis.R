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
