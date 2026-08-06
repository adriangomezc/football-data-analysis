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

# NOTA METODOLÓGICA: cada jugador entra con su temporada válida MÁS RECIENTE.
# Esto prioriza el estado de forma actual, pero implica que la muestra final
# mezcla temporadas y no es un corte transversal de una única campaña.
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
# 3.5 CONTROL DE CALIDAD MULTIVARIANTE: DISTANCIA DE MAHALANOBIS
# =========================================================
# Screening de outliers multivariantes sobre las variables que alimentan el
# scouting_score (no solo univariante: un jugador puede ser normal en cada
# métrica por separado y aun así ser una combinación atípica de todas ellas).
# Criterio: D² de Mahalanobis vs. el límite k + 3*sqrt(2k) (regla práctica
# para el chi-cuadrado con k grados de libertad). NO se elimina a nadie:
# es un diagnóstico de transparencia, no un filtro adicional silencioso.

qc_vars <- cb_current_form %>%
  select(progressive_passes_per90, progressive_carries_per90, key_passes_per90,
         tackles_per90, interceptions_per90, recoveries_per90, pass_completion)

qc_complete <- complete.cases(qc_vars)
qc_matrix <- as.matrix(qc_vars[qc_complete, ])
k_qc <- ncol(qc_matrix)
mahal_d2 <- mahalanobis(qc_matrix, colMeans(qc_matrix), cov(qc_matrix))
mahal_cutoff <- k_qc + 3 * sqrt(2 * k_qc)

outliers_mahal <- cb_current_form[qc_complete, ] %>%
  mutate(mahalanobis_d2 = mahal_d2) %>%
  filter(mahalanobis_d2 > mahal_cutoff) %>%
  select(Player, Squad, Season, mahalanobis_d2) %>%
  arrange(desc(mahalanobis_d2))

cat(sprintf(
  "\nQC Mahalanobis: %d de %d jugadores superan el límite D² > %.1f (k=%d variables).\n",
  nrow(outliers_mahal), sum(qc_complete), mahal_cutoff, k_qc
))
if (nrow(outliers_mahal) > 0) {
  print(outliers_mahal)
  write.csv(outliers_mahal, "outputs/tables/qc_mahalanobis_outliers.csv", row.names = FALSE)
  cat("Se guardan como diagnóstico en outputs/tables/qc_mahalanobis_outliers.csv.\n")
  cat("No se eliminan del análisis: son perfiles estadísticamente atípicos, no errores confirmados.\n")
}

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

# Varianza explicada: justifica usar SOLO los loadings de PC1 como pesos.
# Si PC1 no dominara claramente, resumir las 3 variables en un único eje
# perdería información real que viviría en PC2/PC3.
pca_var_explained <- summary(pca_prog)$importance[2, ] * 100
cat("Varianza explicada por componente (PCA de progresión):\n")
print(round(pca_var_explained, 1))

write.csv(
  data.frame(
    component = names(pca_var_explained),
    pct_variance_explained = round(as.numeric(pca_var_explained), 2)
  ),
  "outputs/tables/pca_variance_explained.csv",
  row.names = FALSE
)

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
# 5.5 MULTICOLINEALIDAD (VIF)
# =========================================================
# car::vif() necesita un lm() ajustado, pero el valor de VIF de cada
# predictor depende solo de la estructura de correlación ENTRE predictores,
# no de la respuesta. Por eso usamos el propio índice compuesto (que por
# construcción es la combinación lineal de esas variables) como respuesta
# auxiliar: es el mecanismo estándar para obtener el VIF de un conjunto de
# variables que no tiene un "outcome" natural propio. R² ~ 1 es esperado y
# no invalida el diagnóstico. Regla de sus apuntes: VIF > 10 colinealidad
# alta, VIF > 30 severa.

compute_vif_block <- function(formula, data, block_name) {
  # suppressWarnings: 'essentially perfect fit' es esperado (y = combinación
  # lineal exacta de los x) y no afecta al VIF, que solo depende de las
  # correlaciones entre predictores. car::vif() reutiliza summary.lm()
  # internamente, así que el aviso puede saltar también ahí.
  mod <- suppressWarnings(lm(formula, data = data))
  vif_vals <- suppressWarnings(car::vif(mod))
  data.frame(
    block = block_name,
    variable = names(vif_vals),
    VIF = round(as.numeric(vif_vals), 2)
  )
}

vif_progression <- compute_vif_block(
  progression_index ~ progressive_passes_per90 + progressive_carries_per90 + key_passes_per90,
  scored_data, "Inputs del progression_index"
)

vif_defending <- compute_vif_block(
  defending_score ~ padj_tackles + padj_interceptions + padj_recoveries,
  scored_data, "Inputs del defending_score (PAdj)"
)

vif_composite <- compute_vif_block(
  scouting_score ~ progression_index + defending_score + pass_completion + age_score,
  scored_data, "Pilares del scouting_score"
)

vif_diagnostics <- bind_rows(vif_progression, vif_defending, vif_composite) %>%
  mutate(colinealidad = case_when(
    VIF > 30 ~ "severa",
    VIF > 10 ~ "alta",
    TRUE     ~ "aceptable"
  ))

cat("\nDiagnóstico de multicolinealidad (VIF):\n")
print(vif_diagnostics)
write.csv(vif_diagnostics, "outputs/tables/vif_diagnostics.csv", row.names = FALSE)

# =========================================================
# 6. EXPORT PROCESSED DATA FOR PIPELINE
# =========================================================

# Exportamos el dataset maestro unificado
write.csv(scored_data, "outputs/tables/padj_defensive_metrics.csv", row.names = FALSE)
write.csv(scored_data, "data/processed/defenders_processed.csv", row.names = FALSE)

# =========================================================
# OUTPUT TABLES (Bug de la variable 'data' corregido)
# =========================================================

# Se incluye 'Season' en todos los rankings: la muestra mezcla campañas y sin
# esa columna las tablas no son interpretables de forma inequívoca.

top_targets <- scored_data %>%
  arrange(desc(scouting_score)) %>%
  select(Player, Squad, League, Season, Age, scouting_score, progression_index, defending_score, pass_completion) %>%
  head(25)
write.csv(top_targets, "outputs/tables/top_recruitment_targets.csv", row.names = FALSE)

market_targets <- scored_data %>%
  filter(Age <= 24, scouting_score >= quantile(scouting_score, 0.80, na.rm = TRUE)) %>%
  arrange(desc(scouting_score)) %>%
  select(Player, Squad, League, Season, Age, scouting_score)
write.csv(market_targets, "outputs/tables/market_inefficiency_targets.csv", row.names = FALSE)

prog_ranking <- scored_data %>%
  arrange(desc(progression_index)) %>%
  select(Player, Squad, League, Season, progression_index, progressive_passes_per90, progressive_carries_per90) %>%
  head(20)
# NOTA: se llama 'progression_ranking' y no 'xt_proxy' a propósito. xT
# (Expected Threat) es un modelo concreto de valor de posesión por zona del
# campo (Karun Singh); esto es una suma ponderada por PCA de tres métricas
# de conteo, un índice de progresión, no una implementación de xT.
write.csv(prog_ranking, "outputs/tables/progression_ranking.csv", row.names = FALSE)

defensive_ranking <- scored_data %>%
  arrange(desc(defending_score)) %>%
  select(Player, Squad, League, Season, defending_score, padj_tackles, padj_interceptions, padj_recoveries) %>%
  head(20)
write.csv(defensive_ranking, "outputs/tables/defensive_ranking.csv", row.names = FALSE)

# =========================================================
# SAMPLE FUNNEL (trazabilidad de la muestra final)
# =========================================================

cat("\n========================================\n")
cat("EMBUDO DE LA MUESTRA\n")
cat("========================================\n")
cat(sprintf("  Jugador-temporada desde 2023-24 ........ %5d\n", nrow(raw_data)))
cat(sprintf("  Pos. DF pura y >= 900 minutos .......... %5d\n", nrow(base_defenders)))
cat(sprintf("  Tras filtros posicionales .............. %5d\n", nrow(cb_filtered_data)))
cat(sprintf("  Temporada mas reciente por jugador ..... %5d\n", nrow(scored_data)))
cat("  Reparto por temporada:\n")
print(table(scored_data$Season))
cat("========================================\n")
cat("SCOUTING ANALYSIS COMPLETED\n")
cat("========================================\n")