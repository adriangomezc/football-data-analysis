# =========================================================
# scripts_scouting.R
# Advanced Recruitment and Scouting Analytics
# =========================================================

source("scripts/setup_packages.R")

dir.create("outputs/figures", recursive = TRUE, showWarnings = FALSE)
dir.create("outputs/tables", recursive = TRUE, showWarnings = FALSE)
dir.create("data/processed", recursive = TRUE, showWarnings = FALSE)

# =========================================================
# 1. LOAD DATA
# =========================================================

raw_data <- read.csv("data/All_Players_1992-2025.csv") %>%
  filter(as.numeric(substr(Season, 1, 4)) >= 2023)

# =========================================================
# 2. FILTER DEFENDERS (Aislando a los centrales puros)
# =========================================================

# 1. Primero filtramos la base de defensores con minutos mínimos
base_defenders <- raw_data %>%
  filter(   
    grepl("DF", Pos), 
    !grepl("MF", Pos),
    !grepl("FW", Pos),
    Min >= 900
  ) %>%
  mutate(
    crosses_per90 = Crs * 90 / Min,
    prg_received_per90 = PrgR * 90 / Min,
    touches_att_3rd_per90 = Att.3rd * 90 / Min
  )

# 2. AHORA calculamos los umbrales SOLO sobre los defensas reales.
# Usamos el cuantil 0.75 para aislar y eliminar al 25% superior (los laterales muy ofensivos)
umbral_prg_rec <- quantile(base_defenders$prg_received_per90, 0.75, na.rm = TRUE)
umbral_touches_att <- quantile(base_defenders$touches_att_3rd_per90, 0.75, na.rm = TRUE)

# 3. Aplicamos el filtro táctico final para quedarnos con los centrales puros
cb_filtered_data <- base_defenders %>%
  filter(
    crosses_per90 < 0.8,
    prg_received_per90 < umbral_prg_rec,
    touches_att_3rd_per90 < umbral_touches_att
  )

# =========================================================
# 3. ISOLATE CURRENT FORM & FEATURE ENGINEERING
# =========================================================

cb_current_form <- cb_filtered_data %>%
  arrange(Player, desc(Season)) %>%
  group_by(Player) %>%
  slice(1) %>%
  ungroup() %>%
  mutate(
    progressive_passes_per90 = PrgP * 90 / Min,
    progressive_carries_per90 = PrgC * 90 / Min,
    key_passes_per90 = KP * 90 / Min,
    tackles_per90 = Tkl * 90 / Min,
    interceptions_per90 = Int * 90 / Min,
    recoveries_per90 = Recov * 90 / Min,
    pass_completion = as.numeric(Cmp.)
  )

# =========================================================
# 4. PCA EMPIRICAL WEIGHTING (Restaurado y reproducible)
# =========================================================

progression_vars <- cb_current_form %>% 
  select(progressive_passes_per90, progressive_carries_per90, key_passes_per90)

# Verificación de NAs antes del PCA por seguridad
pca_prog <- prcomp(progression_vars[complete.cases(progression_vars), ], scale. = TRUE)
raw_loadings <- abs(pca_prog$rotation[, 1])
prog_weights <- raw_loadings / sum(raw_loadings)

cat("Pesos dinámicos del PCA extraídos correctamente:\n")
print(round(prog_weights, 3))

# =========================================================
# 5. PADJ INJECTION & COMPOSITE SCORES (100% Coherente)
# =========================================================

# Cargar el diccionario de posesión generado previamente
if (!file.exists("data/processed/team_possession_proxy.csv")) {
  stop("[ERROR FATAL] Ejecuta scripts_padj_metrics.R primero para generar la posesión.")
}
possession_dict <- read.csv("data/processed/team_possession_proxy.csv")

scored_data <- cb_current_form %>%
  left_join(possession_dict, by = "Squad") %>%
  mutate(
    # 1. Aplicamos el multiplicador PAdj a las métricas defensivas
    padj_tackles = tackles_per90 * padj_multiplier,
    padj_interceptions = interceptions_per90 * padj_multiplier,
    padj_recoveries = recoveries_per90 * padj_multiplier,
    
    # 2. Inyectamos los pesos generados por el PCA
    progression_index = (progressive_passes_per90 * prog_weights[1]) + 
      (progressive_carries_per90 * prog_weights[2]) + 
      (key_passes_per90 * prog_weights[3]),
    
    # 3. ¡El Defending Score AHORA SÍ usa las métricas PAdj!
    defending_score = padj_tackles + padj_interceptions + padj_recoveries,
    
    age_score = case_when(
      Age <= 24 ~ 1.00,
      Age <= 28 ~ 0.95,
      Age <= 31 ~ 0.85,
      Age <= 33 ~ 0.70,
      TRUE ~ 0.50
    ),
    
    scouting_score = (progression_index * 0.4) + (defending_score * 0.3) + 
      ((pass_completion / 100) * 0.1) + (age_score * 0.2)
  )

# =========================================================
# 6. EXPORT PROCESSED DATA FOR PIPELINE
# =========================================================

# Exportamos el dataset maestro unificado
write.csv(scored_data, "outputs/tables/padj_defensive_metrics.csv", row.names = FALSE)
write.csv(scored_data, "data/processed/defenders_processed.csv", row.names = FALSE)

# =========================================================
# OUTPUT TABLES (Bug de la variable 'data' corregido)
# =========================================================

top_targets <- scored_data %>%
  arrange(desc(scouting_score)) %>%
  select(Player, Squad, League, Age, scouting_score, progression_index, defending_score, pass_completion) %>%
  head(25)
write.csv(top_targets, "outputs/tables/top_recruitment_targets.csv", row.names = FALSE)

market_targets <- scored_data %>%
  filter(Age <= 24, scouting_score >= quantile(scouting_score, 0.80, na.rm = TRUE)) %>%
  arrange(desc(scouting_score)) %>%
  select(Player, Squad, League, Age, scouting_score)
write.csv(market_targets, "outputs/tables/market_inefficiency_targets.csv", row.names = FALSE)

prog_ranking <- scored_data %>%
  arrange(desc(progression_index)) %>%
  select(Player, Squad, League, progression_index, progressive_passes_per90, progressive_carries_per90) %>%
  head(20)
write.csv(prog_ranking, "outputs/tables/xt_proxy_ranking.csv", row.names = FALSE)

defensive_ranking <- scored_data %>%
  arrange(desc(defending_score)) %>%
  select(Player, Squad, League, defending_score, padj_tackles, padj_interceptions, padj_recoveries) %>%
  head(20)
write.csv(defensive_ranking, "outputs/tables/defensive_ranking.csv", row.names = FALSE)

cat("\n========================================\n")
cat("SCOUTING ANALYSIS COMPLETED\n")
cat("========================================\n")