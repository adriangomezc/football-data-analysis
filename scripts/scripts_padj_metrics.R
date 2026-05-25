source("scripts/setup_packages.R")

dir.create("outputs/tables", recursive = TRUE, showWarnings = FALSE)

data <- read.csv("data/processed/defenders_processed.csv")

# =========================
# POSSESSION ADJUSTMENT
# =========================
raw_data <- read.csv("data/All_Players_1992-2025.csv")
# 1. Calcular pases por 90 minutos para cada equipo
team_stats <- raw_data %>%
  group_by(League, Squad) %>%
  summarise(
    team_total_passes = sum(Pass, na.rm = TRUE),
    # Dividimos entre 11 porque X90s suma los minutos de los 11 jugadores
    team_total_90s = sum(X90s, na.rm = TRUE) / 11, 
    team_passes_per90 = team_total_passes / team_total_90s,
    .groups = 'drop'
  )

# 2. Calcular la media de pases por 90 de cada liga (proxy del rival)
league_stats <- team_stats %>%
  group_by(League) %>%
  summarise(
    league_avg_passes_per90 = mean(team_passes_per90, na.rm = TRUE),
    .groups = 'drop'
  )

# 3. Unir y calcular el % de posesión real de cada equipo
team_possession_df <- team_stats %>%
  left_join(league_stats, by = "League") %>%
  mutate(
    # Fórmula del Proxy de Posesión:
    team_possession = (team_passes_per90 / (team_passes_per90 + league_avg_passes_per90)) * 100,
    opponent_possession = 100 - team_possession
  ) %>%
  select(Squad, team_possession, opponent_possession)

# 4. Inyectar la posesión en tus datos filtrados y calcular el PAdj REAL
data_padj <- data %>%
  left_join(team_possession_df, by = "Squad") %>%
  mutate(
    # Si un equipo domina el 65% de posesión, su rival tiene el 35%. 
    # (35 / 50) = 0.7. El jugador defiende "menos tiempo", así que le sumamos mérito 
    # dividiendo sus tackles entre 0.7 (su valor subirá).
    padj_tackles = tackles_per90 / (opponent_possession / 50),
    padj_interceptions = interceptions_per90 / (opponent_possession / 50),
    padj_recoveries = recoveries_per90 / (opponent_possession / 50) # Opcional
  )

# Comprobación rápida para ver si funciona bien:
data_padj %>%
  select(Player, Squad, team_possession, tackles_per90, padj_tackles) %>%
  head()

# =========================
# SAVE OUTPUT
# =========================

write.csv(
  data_padj,
  "outputs/tables/padj_defensive_metrics.csv",
  row.names = FALSE
)

# =========================
# VISUALIZATION
# =========================

p <- ggplot(
  data_padj,
  aes(
    x = padj_interceptions,
    y = padj_tackles,
    color = League
  )
) +
  geom_point(size = 3, alpha = 0.8) +
  geom_text_repel(
    aes(label = Player),
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
