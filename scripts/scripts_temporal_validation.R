# =========================================================
# scripts_temporal_validation.R
# Validación predictiva fuera de muestra (train 2023-24 / test 2024-25)
# =========================================================
# Pregunta: ¿el scouting_score, calculado SOLO con datos de 2023-24, predice
# algo observable en la temporada siguiente? Partición Train/Test temporal
# (no k-fold: aquí el orden temporal importa y una partición aleatoria
# filtraría información del futuro al pasado).
#
# Outcome: retained = ¿jugó >= 900 minutos en 2024-25? (glm binomial logit).
# Es una validación deliberadamente honesta: se reportan los resultados
# tal cual salen, incluidos los no significativos, con la interpretación
# de por qué tienen sentido.

source("scripts/setup_packages.R")

dir.create("outputs/figures", recursive = TRUE, showWarnings = FALSE)
dir.create("outputs/tables", recursive = TRUE, showWarnings = FALSE)

if (!file.exists("data/processed/team_possession_proxy.csv")) {
  stop("[ERROR FATAL] Ejecuta scripts_padj_metrics.R primero.")
}

# =========================================================
# 1. TRAIN: reconstruir el scoring usando SOLO la temporada 2023-2024
# =========================================================
# Se recalculan los pesos del PCA únicamente sobre el train para no filtrar
# información de 2024-25 al modelo (mismo criterio que 'partición Train/Test'
# de sus prácticas de Modelos Lineales).

raw_data <- read.csv("data/All_Players_1992-2025.csv") %>%
  filter(as.numeric(substr(Season, 1, 4)) >= 2023)

base_defenders <- raw_data %>%
  filter(grepl("DF", Pos), !grepl("MF", Pos), !grepl("FW", Pos), Min >= 900) %>%
  mutate(
    crosses_per90 = Crs * 90 / Min,
    prg_received_per90 = PrgR * 90 / Min,
    touches_att_3rd_per90 = Att.3rd * 90 / Min
  )

umbral_prg_rec <- quantile(base_defenders$prg_received_per90, 0.75, na.rm = TRUE)
umbral_touches_att <- quantile(base_defenders$touches_att_3rd_per90, 0.75, na.rm = TRUE)

cb_all <- base_defenders %>%
  filter(crosses_per90 < 0.8, prg_received_per90 < umbral_prg_rec,
         touches_att_3rd_per90 < umbral_touches_att)

train <- cb_all %>%
  filter(Season == "2023-2024") %>%
  arrange(desc(Min)) %>%
  distinct(Player, .keep_all = TRUE) %>%   # transferencias a mitad de temporada -> nos quedamos con el club de más minutos
  mutate(
    progressive_passes_per90 = PrgP * 90 / Min,
    progressive_carries_per90 = PrgC * 90 / Min,
    key_passes_per90 = KP * 90 / Min,
    tackles_per90 = Tkl * 90 / Min,
    interceptions_per90 = Int * 90 / Min,
    recoveries_per90 = Recov * 90 / Min,
    pass_completion = as.numeric(Cmp.)
  )

cat(sprintf("Train (centrales, temporada 2023-2024): %d jugadores\n", nrow(train)))

progression_vars_train <- train %>%
  select(progressive_passes_per90, progressive_carries_per90, key_passes_per90)
pca_train <- prcomp(progression_vars_train[complete.cases(progression_vars_train), ], scale. = TRUE)
w_train <- abs(pca_train$rotation[, 1]) / sum(abs(pca_train$rotation[, 1]))
cat("Pesos PCA reestimados SOLO en train (2023-24):\n")
print(round(w_train, 3))

possession_dict <- read.csv("data/processed/team_possession_proxy.csv")

train <- train %>%
  left_join(possession_dict, by = "Squad") %>%
  mutate(
    padj_tackles = tackles_per90 * padj_multiplier,
    padj_interceptions = interceptions_per90 * padj_multiplier,
    padj_recoveries = recoveries_per90 * padj_multiplier,
    progression_index = (progressive_passes_per90 * w_train[1]) +
      (progressive_carries_per90 * w_train[2]) + (key_passes_per90 * w_train[3]),
    defending_score = padj_tackles + padj_interceptions + padj_recoveries,
    age_score = case_when(
      Age <= 24 ~ 1.00, Age <= 28 ~ 0.95, Age <= 31 ~ 0.85, Age <= 33 ~ 0.70, TRUE ~ 0.50
    ),
    scouting_score = (progression_index * 0.4) + (defending_score * 0.3) +
      ((pass_completion / 100) * 0.1) + (age_score * 0.2)
  )

# =========================================================
# 2. TEST: ¿jugó >= 900 minutos en 2024-2025? (cualquier club/posición)
# =========================================================
# Outcome deliberadamente simple: continuidad como profesional relevante en
# el año siguiente, no "acierto de fichaje" (no tenemos datos de valor de
# mercado ni de traspasos). Se documenta esta limitación en el informe.

min_2425 <- raw_data %>%
  filter(Season == "2024-2025") %>%
  group_by(Player) %>%
  summarise(Min_2024_25 = max(Min, na.rm = TRUE), .groups = "drop")

val <- train %>%
  left_join(min_2425, by = "Player") %>%
  mutate(
    Min_2024_25 = ifelse(is.na(Min_2024_25), 0, Min_2024_25),
    retained = as.integer(Min_2024_25 >= 900)
  )

cat(sprintf(
  "\nOutcome de validacion: %d jugadores, tasa de retencion = %.1f%% (%d de %d jugaron >=900' en 2024-25)\n",
  nrow(val), 100 * mean(val$retained), sum(val$retained), nrow(val)
))

# =========================================================
# 3. MODELOS: GLM binomial logit, cadena anidada null -> score -> componentes
# =========================================================

mod_null <- glm(retained ~ 1, data = val, family = binomial(link = "logit"))
mod_score <- glm(retained ~ scouting_score, data = val, family = binomial(link = "logit"))
mod_components <- glm(
  retained ~ progression_index + defending_score + pass_completion + age_score,
  data = val, family = binomial(link = "logit")
)

cat("\n--- Modelo nulo ---\n")
print(summary(mod_null)$coefficients)
cat(sprintf("AIC = %.2f\n", AIC(mod_null)))

cat("\n--- retained ~ scouting_score ---\n")
print(summary(mod_score)$coefficients)
cat(sprintf("AIC = %.2f\n", AIC(mod_score)))

or_score <- exp(coef(mod_score)["scouting_score"])
ci_score <- exp(confint(mod_score, "scouting_score"))
cat(sprintf("Odds Ratio (scouting_score) = %.3f  IC95%% [%.3f, %.3f]\n",
           or_score, ci_score[1], ci_score[2]))

cat("\n--- retained ~ progression_index + defending_score + pass_completion + age_score ---\n")
print(summary(mod_components)$coefficients)
cat(sprintf("AIC = %.2f\n", AIC(mod_components)))

or_components <- exp(coef(mod_components))
cat("Odds Ratios (modelo de componentes):\n")
print(round(or_components, 3))

# Test de Razón de Verosimilitud (LRT), cadena anidada
cat("\n--- Test de Razon de Verosimilitud (LRT) ---\n")
lrt_null_vs_score <- anova(mod_null, mod_score, test = "LRT")
lrt_score_vs_components <- anova(mod_score, mod_components, test = "LRT")
print(lrt_null_vs_score)
print(lrt_score_vs_components)

mcfadden_r2 <- 1 - as.numeric(logLik(mod_score)) / as.numeric(logLik(mod_null))
cat(sprintf("\nPseudo-R2 de McFadden (retained ~ scouting_score) = %.4f\n", mcfadden_r2))

# =========================================================
# 4. VALIDACIÓN SECUNDARIA: entre los retenidos, ¿el score se asocia con MÁS minutos?
# =========================================================

retained_players <- val %>% filter(retained == 1)
# exact = FALSE: hay empates en minutos/score (valores repetidos), así que el
# p-valor exacto no está definido; R usa la aproximación normal estándar.
spearman_test <- cor.test(retained_players$scouting_score, retained_players$Min_2024_25,
                          method = "spearman", exact = FALSE)
cat(sprintf(
  "\nCorrelacion de Spearman (scouting_score vs minutos 2024-25 | retenidos): rho = %.3f, p = %.3f, n = %d\n",
  spearman_test$estimate, spearman_test$p.value, nrow(retained_players)
))

# =========================================================
# 5. DESCRIPTIVO COMPLEMENTARIO: tasa de retención por arquetipo
# =========================================================
# Requiere los roles ya asignados por scripts_clustering.R. Si no existen
# (por ejemplo, se ejecuta este script de forma aislada), se omite sin error.

retention_by_role <- NULL
if (file.exists("outputs/tables/final_scouting_dashboard.csv")) {
  roles <- read.csv("outputs/tables/final_scouting_dashboard.csv") %>%
    select(Player, role_profile)
  retention_by_role <- val %>%
    inner_join(roles, by = "Player") %>%
    group_by(role_profile) %>%
    summarise(n = n(), retention_rate = round(mean(retained) * 100, 1), .groups = "drop") %>%
    arrange(desc(retention_rate))
  cat("\nTasa de retencion por arquetipo (descriptivo, no causal):\n")
  print(retention_by_role)
}

# =========================================================
# 6. EXPORTAR RESULTADOS
# =========================================================

results_table <- bind_rows(
  # Etiqueta 'intercept_only' y no 'null': la cadena literal "null" es un
  # valor centinela de NA por defecto en pandas y puede leerse como vacío.
  data.frame(model = "intercept_only", term = "(Intercept)",
             estimate = coef(mod_null), OR = exp(coef(mod_null)),
             p_value = summary(mod_null)$coefficients[, 4], AIC = AIC(mod_null)),
  data.frame(model = "scouting_score", term = names(coef(mod_score)),
             estimate = coef(mod_score), OR = exp(coef(mod_score)),
             p_value = summary(mod_score)$coefficients[, 4], AIC = AIC(mod_score)),
  data.frame(model = "4_components", term = names(coef(mod_components)),
             estimate = coef(mod_components), OR = exp(coef(mod_components)),
             p_value = summary(mod_components)$coefficients[, 4], AIC = AIC(mod_components))
) %>%
  mutate(across(c(estimate, OR, p_value, AIC), ~ round(.x, 4)))

write.csv(results_table, "outputs/tables/temporal_validation_results.csv", row.names = FALSE)
write.csv(
  val %>% select(Player, Squad, Season, Age, scouting_score, progression_index,
                 defending_score, pass_completion, age_score, Min_2024_25, retained),
  "outputs/tables/temporal_validation_predictions.csv", row.names = FALSE
)
if (!is.null(retention_by_role)) {
  write.csv(retention_by_role, "outputs/tables/temporal_validation_retention_by_role.csv",
            row.names = FALSE)
}

# =========================================================
# 7. FIGURA: curva logística scouting_score -> P(retenido)
# =========================================================

p_val <- ggplot(val, aes(x = scouting_score, y = retained)) +
  geom_jitter(height = 0.04, width = 0, alpha = 0.35, size = 2, color = "#4C72B0") +
  geom_smooth(method = "glm", method.args = list(family = "binomial"),
             color = "#C44E52", fill = "#C44E52", alpha = 0.15) +
  scale_y_continuous(breaks = c(0, 1), labels = c("No retained", "Retained (>=900')")) +
  theme_minimal(base_size = 13) +
  labs(
    title    = "Temporal validation: does the 2023-24 score predict 2024-25 continuity?",
    subtitle = sprintf(
      "OR = %.2f (95%% CI %.2f-%.2f) | p = %.2f | not statistically significant",
      or_score, ci_score[1], ci_score[2], summary(mod_score)$coefficients["scouting_score", 4]
    ),
    x = "scouting_score (train, 2023-24 only)",
    y = "P(played >= 900 min in 2024-25)",
    caption = sprintf("n = %d centre-backs active in 2023-24, followed into 2024-25", nrow(val))
  )

ggsave("outputs/figures/temporal_validation.png", p_val, width = 9, height = 6, dpi = 200)

cat("\n========================================\n")
cat("VALIDACION TEMPORAL COMPLETADA\n")
cat("========================================\n")
