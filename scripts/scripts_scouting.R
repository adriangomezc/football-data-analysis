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
    progressive_passes_per90_raw = PrgP * 90 / Min,
    progressive_carries_per90_raw = PrgC * 90 / Min,
    key_passes_per90_raw = KP * 90 / Min,
    tackles_per90_raw = Tkl * 90 / Min,
    interceptions_per90_raw = Int * 90 / Min,
    recoveries_per90_raw = Recov * 90 / Min,
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
# Se usan las tasas SIN encoger: el QC debe mirar lo observado tal cual,
# antes de cualquier ajuste estadístico posterior.

qc_vars <- cb_current_form %>%
  select(progressive_passes_per90_raw, progressive_carries_per90_raw, key_passes_per90_raw,
         tackles_per90_raw, interceptions_per90_raw, recoveries_per90_raw, pass_completion)

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
# 3.6 SHRINKAGE EMPÍRICO-BAYESIANO (Poisson-Gamma) DE LAS TASAS POR 90
# =========================================================
# Problema: un jugador con 900 minutos (10 partidos) y otro con 3420 (38
# partidos) pueden tener la misma tasa observada por 90, pero la del primero
# es una estimación muchísimo más ruidosa. Tratarlas como igual de fiables es
# estadísticamente incorrecto.
#
# Solución: el ejemplo canónico de conjugación bayesiana. Cada conteo de
# temporada (PrgP, PrgC, KP, Tkl, Int, Recov) se modela como
#   Count_i ~ Poisson(lambda_i * exposure_i),  exposure_i = Min_i / 90
# con un prior Gamma sobre lambda_i estimado empíricamente de toda la
# población. Un modelo binomial-negativo (MASS::glm.nb) con intercept y
# offset(log(exposure)) es exactamente la marginal de ese mixture: su media
# ajustada (mu) es la media poblacional de la tasa, y su parámetro de
# dispersión (theta) es la forma del Gamma. Por conjugación, la media de la
# posterior para el jugador i es:
#   lambda_i_shrunk = (theta + Count_i) / (theta / mu + exposure_i)
# que encoge hacia la media poblacional en proporción INVERSA a exposure_i:
# a menos minutos, más encogimiento. Es el mismo mecanismo que las medias de
# bateo en béisbol de Efron & Morris (1975), aplicado aquí a tackles en vez
# de home runs.

shrink_rate_nb <- function(count, minutes, label) {
  exposure <- minutes / 90
  fit <- MASS::glm.nb(count ~ offset(log(exposure)))
  mu <- exp(unname(coef(fit)["(Intercept)"]))
  theta <- fit$theta
  shrunk <- (theta + count) / (theta / mu + exposure)
  cat(sprintf("  %-22s mu (media poblacional/90) = %.3f   theta = %.2f\n", label, mu, theta))
  shrunk
}

cat("\nShrinkage empírico-bayesiano (Poisson-Gamma vía MASS::glm.nb):\n")
cb_current_form <- cb_current_form %>%
  mutate(
    progressive_passes_per90 = shrink_rate_nb(PrgP, Min, "progressive_passes"),
    progressive_carries_per90 = shrink_rate_nb(PrgC, Min, "progressive_carries"),
    key_passes_per90 = shrink_rate_nb(KP, Min, "key_passes"),
    tackles_per90 = shrink_rate_nb(Tkl, Min, "tackles"),
    interceptions_per90 = shrink_rate_nb(Int, Min, "interceptions"),
    recoveries_per90 = shrink_rate_nb(Recov, Min, "recoveries")
  )

# Diagnóstico: el encogimiento debe ser mayor en el cuartil de menos minutos
# que en el de más minutos. Si no lo fuera, algo estaría mal en el ajuste.
exposure_quartile <- ntile(cb_current_form$Min, 4)
shrink_metrics <- c("progressive_passes", "progressive_carries", "key_passes",
                    "tackles", "interceptions", "recoveries")

shrinkage_diag <- bind_rows(lapply(shrink_metrics, function(m) {
  shrunk_col <- cb_current_form[[paste0(m, "_per90")]]
  raw_col <- cb_current_form[[paste0(m, "_per90_raw")]]
  tibble(
    metric = m,
    exposure_quartile = exposure_quartile,
    abs_shrink = abs(shrunk_col - raw_col)
  )
})) %>%
  group_by(metric, exposure_quartile) %>%
  summarise(mean_abs_shrink = round(mean(abs_shrink, na.rm = TRUE), 4), .groups = "drop") %>%
  arrange(metric, exposure_quartile)

cat("\nMagnitud media del encogimiento por cuartil de minutos jugados (Q1 = menos minutos):\n")
print(shrinkage_diag)
write.csv(shrinkage_diag, "outputs/tables/shrinkage_diagnostics.csv", row.names = FALSE)

# =========================================================
# 4. PCA EMPIRICAL WEIGHTING (Restaurado y reproducible)
# =========================================================
# A partir de aquí, progression_index y defending_score se construyen con
# las tasas YA ENCOGIDAS: es la mejor estimación disponible de la tasa real
# de cada jugador, no el conteo bruto de una muestra de tamaño desigual.

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
# 5.6 ANÁLISIS DE SENSIBILIDAD: ¿CUÁNTO IMPORTA LA ELECCIÓN CONCRETA DE PESOS?
# =========================================================
# 40/30/10/20 es una decisión del analista, no un ajuste estadístico. Para
# cuantificar cuánto pesa esa decisión concreta sobre el ranking final, se
# perturba en un muestreo Dirichlet centrado en los pesos originales
# (Dirichlet es el prior conjugado natural de un vector de proporciones que
# suman 1: la generalización multivariante de Beta) y se recalcula el
# ranking en cada réplica. Construcción estándar: si X_k ~ Gamma(alpha_k, 1)
# independientes, entonces X_k / sum(X) ~ Dirichlet(alpha).

set.seed(123)
n_reps <- 2000
base_w <- c(progression = 0.4, defending = 0.3, pass = 0.1, age = 0.2)
concentration <- 20  # mas alto = perturbaciones mas ajustadas a los pesos originales

original_order <- order(-scored_data$scouting_score)
original_top10 <- scored_data$Player[original_order][1:10]

spearman_reps <- numeric(n_reps)
top10_overlap_reps <- numeric(n_reps)
top10_retention <- matrix(FALSE, nrow = n_reps, ncol = 10)

for (i in seq_len(n_reps)) {
  raw_gamma <- rgamma(4, shape = concentration * base_w)
  w_perturbed <- raw_gamma / sum(raw_gamma)

  score_perturbed <- (scored_data$progression_index * w_perturbed[1]) +
    (scored_data$defending_score * w_perturbed[2]) +
    ((scored_data$pass_completion / 100) * w_perturbed[3]) +
    (scored_data$age_score * w_perturbed[4])

  spearman_reps[i] <- cor(scored_data$scouting_score, score_perturbed, method = "spearman")

  perturbed_top10 <- scored_data$Player[order(-score_perturbed)][1:10]
  top10_overlap_reps[i] <- length(intersect(original_top10, perturbed_top10)) / 10
  top10_retention[i, ] <- original_top10 %in% perturbed_top10
}

cat(sprintf(
  "\nAnálisis de sensibilidad de pesos (%d réplicas Dirichlet, concentración=%d):\n",
  n_reps, concentration
))
cat(sprintf("  Correlación de Spearman vs. ranking original: mediana=%.3f, RIC=[%.3f, %.3f]\n",
           median(spearman_reps), quantile(spearman_reps, 0.25), quantile(spearman_reps, 0.75)))
cat(sprintf("  Solapamiento medio del Top-10: %.1f%% (de 10 jugadores)\n",
           100 * mean(top10_overlap_reps)))

player_retention <- data.frame(
  Player = original_top10,
  original_scouting_score = round(scored_data$scouting_score[match(original_top10, scored_data$Player)], 3),
  pct_top10_retention = round(100 * colMeans(top10_retention), 1)
) %>% arrange(desc(pct_top10_retention))

cat("\nEstabilidad individual del Top-10 original bajo reponderación:\n")
print(player_retention)

write.csv(player_retention, "outputs/tables/weight_sensitivity_top10.csv", row.names = FALSE)
write.csv(
  data.frame(replication = seq_len(n_reps), spearman_corr = spearman_reps, top10_overlap = top10_overlap_reps),
  "outputs/tables/weight_sensitivity_replications.csv", row.names = FALSE
)

p_sensitivity <- ggplot(data.frame(spearman_reps = spearman_reps), aes(x = spearman_reps)) +
  geom_histogram(bins = 40, fill = "#4C72B0", alpha = 0.85) +
  geom_vline(xintercept = median(spearman_reps), linetype = "dashed", color = "grey30") +
  theme_minimal(base_size = 13) +
  labs(
    title    = "Weight sensitivity: how much does the 40/30/10/20 choice matter?",
    subtitle = sprintf("Spearman correlation vs. the original ranking across %d Dirichlet-perturbed weight sets", n_reps),
    x        = "Spearman correlation with the original ranking",
    y        = "Replications"
  )

ggsave("outputs/figures/weight_sensitivity.png", p_sensitivity, width = 9, height = 6, dpi = 200)

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

# =========================================================
# 7. DIAGNÓSTICO: CURVA DE EDAD EMPÍRICA (GAM) vs. LA FUNCIÓN ESCALÓN
# =========================================================
# age_score es una función escalón fijada a mano (24/28/31/33). Como
# diagnóstico -no como reajuste del pipeline, para no encadenar otro cambio
# más sobre scouting_score en la misma pasada- se ajusta un GAM (mgcv,
# asignatura de Modelos de Suavizado) sobre TODO el pool de centrales
# filtrados (jugador-temporada, sin deduplicar por jugador: más datos que
# los 407 usados en el resto del pipeline).
#
# Primera versión (combinando progresión + defensa en un único "output"):
# R2 ajustado = 0.003, prácticamente sin señal. Antes de concluir que la
# edad no importa, se separan los dos tipos de output: progresivos y
# defensivos probablemente envejecen de forma distinta (un central que deja
# de ganar duelos por velocidad puede seguir siendo un buen distribuidor), y
# mezclarlos en una sola variable puede estar anulando ambas señales.

age_diag_data <- cb_filtered_data %>%
  mutate(
    progression_raw = (PrgP + PrgC + KP) * 90 / Min,
    defensive_raw = (Tkl + Int + Recov) * 90 / Min
  ) %>%
  filter(!is.na(Age), !is.na(progression_raw), !is.na(defensive_raw))

fit_age_gam <- function(outcome, data, label) {
  gam_fit <- mgcv::gam(data[[outcome]] ~ s(Age, k = 6), data = data)
  grid <- data.frame(Age = seq(min(data$Age), max(data$Age), by = 0.5))
  pred <- predict(gam_fit, newdata = grid, se.fit = TRUE)
  grid$fitted <- pred$fit
  grid$lower <- pred$fit - 1.96 * pred$se.fit
  grid$upper <- pred$fit + 1.96 * pred$se.fit
  grid$outcome <- label
  s <- summary(gam_fit)
  cat(sprintf(
    "  %-12s pico empirico Age = %.1f | edf = %.2f | R2 ajustado = %.3f | p(s(Age)) = %.4f\n",
    label, grid$Age[which.max(grid$fitted)], s$edf, s$r.sq, s$s.table[1, "p-value"]
  ))
  grid
}

cat("\nGAM curva de edad, output separado por tipo:\n")
grid_prog <- fit_age_gam("progression_raw", age_diag_data, "Progression")
grid_def <- fit_age_gam("defensive_raw", age_diag_data, "Defensive")

points_long <- bind_rows(
  age_diag_data %>% transmute(Age, value = progression_raw, outcome = "Progression"),
  age_diag_data %>% transmute(Age, value = defensive_raw, outcome = "Defensive")
)
grid_long <- bind_rows(grid_prog, grid_def)

write.csv(grid_long, "outputs/tables/age_curve_gam.csv", row.names = FALSE)

age_breakpoints <- data.frame(Age = c(24, 28, 31, 33))

p_age_gam <- ggplot(grid_long, aes(x = Age, y = fitted)) +
  geom_point(data = points_long, aes(x = Age, y = value), inherit.aes = FALSE, alpha = 0.10, size = 1) +
  geom_ribbon(aes(ymin = lower, ymax = upper), fill = "#4C72B0", alpha = 0.25) +
  geom_line(color = "#4C72B0", linewidth = 1) +
  geom_vline(data = age_breakpoints, aes(xintercept = Age), linetype = "dashed", color = "grey40") +
  facet_wrap(~outcome, scales = "free_y") +
  theme_minimal(base_size = 13) +
  labs(
    title    = "Empirical age curve (GAM) vs. the hand-coded step function",
    subtitle = "Dashed lines: current step breakpoints (24 / 28 / 31 / 33)",
    x        = "Age",
    y        = "Raw actions per 90",
    caption  = sprintf("n = %d player-seasons (not deduplicated by player) | GAM: mgcv::gam(output ~ s(Age, k=6)) per panel",
                       nrow(age_diag_data))
  )

ggsave("outputs/figures/age_curve_gam.png", p_age_gam, width = 11, height = 6.5, dpi = 200)

cat("Figura guardada en outputs/figures/age_curve_gam.png\n")