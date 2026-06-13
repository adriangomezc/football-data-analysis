# =========================================================
# scripts_padj_metrics.R
# Contexto Táctico: Generación del Diccionario de Posesión
# =========================================================

source("scripts/setup_packages.R")
dir.create("data/processed", recursive = TRUE, showWarnings = FALSE)

# 1. Leer TODOS los datos para calcular la posesión real de la liga
raw_data <- read.csv("data/All_Players_1992-2025.csv") %>%
  filter(as.numeric(substr(Season, 1, 4)) >= 2023)

# 2. Pases del equipo
team_stats <- raw_data %>%
  group_by(League, Squad) %>%
  summarise(
    team_passes_per90 = sum(Pass, na.rm = TRUE) / (sum(X90s, na.rm = TRUE) / 11),
    .groups = 'drop'
  )

# 3. Pases medios de la liga (Nuestro proxy del rival)
league_stats <- team_stats %>%
  group_by(League) %>%
  summarise(league_avg_passes_per90 = mean(team_passes_per90, na.rm = TRUE), .groups = 'drop')

# 4. Cálculo de la estimación y multiplicador logístico
team_possession_df <- team_stats %>%
  left_join(league_stats, by = "League") %>%
  mutate(
    estimated_possession_proxy = (team_passes_per90 / (team_passes_per90 + league_avg_passes_per90)) * 100,
    padj_multiplier = 2 / (1 + exp(-0.1 * (estimated_possession_proxy - 50)))
  ) %>%
  select(Squad, estimated_possession_proxy, padj_multiplier)

# 5. Exportar solo el diccionario de posesión
write.csv(team_possession_df, "data/processed/team_possession_proxy.csv", row.names = FALSE)
cat("Diccionario de posesión (PAdj proxy) generado con éxito.\n")