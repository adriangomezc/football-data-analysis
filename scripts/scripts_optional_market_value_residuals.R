# =========================================================
# scripts_optional_market_value_residuals.R
# [OPCIONAL / MANUAL] Ineficiencias de mercado por RESIDUO, no por percentil
# =========================================================
#
# QUÉ RESUELVE
# 'market_inefficiency_targets.csv' actual define "ineficiencia" como
# "sub-24 y por encima del percentil 80 de scouting_score" — un corte
# arbitrario que no dice nada sobre si el mercado YA conoce a ese jugador.
# La revisión de julio de 2026 de este proyecto encontró que casi todos los
# nombres de esa lista (Calafiori, Seidu, Singo...) ya habían sido fichados
# por clubes reales por sumas de siete cifras antes o durante la misma
# temporada analizada — no eran ineficiencias, eran jugadores que el
# mercado ya había valorado correctamente.
#
# Este script sustituye ese criterio por uno real: se regresa el valor de
# mercado observado (Transfermarkt) contra el scouting_score, la edad y la
# liga, y se identifica a los jugadores cuyo valor de mercado real es
# estadísticamente INFERIOR a lo que su rendimiento predice — el residuo
# positivo de una regresión de valoración es una definición de
# "infravalorado" mucho más defendible que un percentil sobre una sola
# variable.
#
# POR QUÉ ES UN SCRIPT APARTE Y OPCIONAL (léelo antes de ejecutar)
# 1. Depende de transfermarkt.com vía worldfootballR (tm_player_market_values,
#    player_dictionary_mapping). Mi entorno de desarrollo no solo no puede
#    completar la petición (como con FBref, bloqueado por Cloudflare):
#    directamente NO RESUELVE el dominio transfermarkt.com por DNS, una
#    restricción de red distinta y más fuerte que la de FBref. No he podido
#    ejecutar ESTE script ni una sola vez de extremo a extremo.
# 2. Lo que sí he verificado (sin poder ejecutarlo) es que las funciones
#    existen en la versión instalada de worldfootballR y su firma exacta
#    (tools::Rd_db) — no que devuelvan lo que documentan, ni el formato
#    exacto de sus columnas de salida.
# 3. player_dictionary_mapping() cubre los jugadores del Big-5 desde
#    2017-18, así que el cruce FBref <-> Transfermarkt debería funcionar
#    para toda la ventana de este proyecto (2023-24 en adelante) — pero,
#    de nuevo, no verificado en vivo.
# 4. Requiere que scripts_scouting.R se haya ejecutado antes (lee
#    outputs/tables/padj_defensive_metrics.csv).
#
# CÓMO EJECUTARLO
#   Rscript scripts/scripts_scouting.R   # si no lo has corrido ya
#   Rscript scripts/scripts_optional_market_value_residuals.R

if (!requireNamespace("worldfootballR", quietly = TRUE)) {
  stop('Instala primero: install.packages("worldfootballR")', call. = FALSE)
}
suppressPackageStartupMessages(library(dplyr))

if (!file.exists("outputs/tables/padj_defensive_metrics.csv")) {
  stop("[ERROR FATAL] Ejecuta scripts_scouting.R primero.", call. = FALSE)
}
scored_data <- read.csv("outputs/tables/padj_defensive_metrics.csv")

dir.create("outputs/tables", recursive = TRUE, showWarnings = FALSE)
dir.create("outputs/figures", recursive = TRUE, showWarnings = FALSE)

# =========================================================
# 1. DESCARGAR VALORES DE MERCADO (Transfermarkt, vía worldfootballR)
# =========================================================

leagues_tm <- data.frame(
  country_name = c("Spain", "England", "Italy", "Germany", "France"),
  League       = c("La Liga", "Premier League", "Serie A", "Bundesliga", "Ligue 1"),
  stringsAsFactors = FALSE
)

# start_year = año de INICIO de temporada (2024 para "2024-2025"), al
# revés que season_end_year en fb_season_team_stats — confirmar contra la
# temporada real disponible al ejecutar esto.
seasons_tm <- c(2023, 2024)

cat("Descargando valores de mercado de Transfermarkt (puede tardar varios minutos)...\n")
cat("Si ves 'Could not resolve host' o timeouts, Transfermarkt está bloqueando o\n")
cat("tu red no puede alcanzarlo. Prueba desde otra conexión.\n\n")

market_values_raw <- list()
for (i in seq_len(nrow(leagues_tm))) {
  for (yr in seasons_tm) {
    key <- paste(leagues_tm$country_name[i], yr)
    cat(sprintf("  %s, temporada iniciada en %d...\n", leagues_tm$country_name[i], yr))
    res <- tryCatch(
      worldfootballR::tm_player_market_values(
        country_name = leagues_tm$country_name[i], start_year = yr
      ),
      error = function(e) {
        cat(sprintf("  [AVISO] Fallo: %s\n", conditionMessage(e)))
        NULL
      }
    )
    if (!is.null(res) && nrow(res) > 0) {
      res$League <- leagues_tm$League[i]
      market_values_raw[[key]] <- res
    }
  }
}

if (length(market_values_raw) == 0) {
  stop(paste0(
    "\n[ERROR] No se pudo descargar ningún valor de mercado. Lo más probable ",
    "es que Transfermarkt esté bloqueando la conexión, o que la firma de ",
    "tm_player_market_values() haya cambiado (worldfootballR está archivado ",
    "por su autor desde sept. 2025 y puede haber roto compatibilidad con ",
    "cambios recientes del sitio). Revisa https://jaseziv.github.io/worldfootballR/ ",
    "para el estado actual del paquete."
  ), call. = FALSE)
}

market_values <- bind_rows(market_values_raw)
cat(sprintf("\nDescargados %d registros de valor de mercado.\n", nrow(market_values)))
cat("Columnas devueltas (verifica que 'player_market_value_euro' y 'player_name' existen):\n")
print(colnames(market_values))

# Nombres de columna esperados según la documentación del paquete en el
# momento de escribir esto; si el paquete ha cambiado, ajusta aquí.
name_col <- intersect(c("player_name", "PlayerName", "Player"), colnames(market_values))[1]
value_col <- intersect(c("player_market_value_euro", "PlayerMarketValue", "market_value"),
                       colnames(market_values))[1]

if (is.na(name_col) || is.na(value_col)) {
  stop(paste0(
    "\n[ERROR] No se identifican las columnas de nombre/valor en el resultado ",
    "de tm_player_market_values(). Columnas disponibles arriba: ajusta ",
    "'name_col'/'value_col' en este script a mano."
  ), call. = FALSE)
}

market_values_clean <- market_values %>%
  transmute(
    Player = .data[[name_col]],
    League,
    market_value_eur = as.numeric(.data[[value_col]])
  ) %>%
  filter(!is.na(market_value_eur), market_value_eur > 0) %>%
  distinct(Player, League, .keep_all = TRUE)

write.csv(market_values_clean, "data/processed/market_values_raw.csv", row.names = FALSE)

# =========================================================
# 2. UNIR CON EL SCOUTING SCORE
# =========================================================
# Join simple por nombre de jugador. FBref y Transfermarkt no siempre
# escriben el nombre igual (acentos, orden nombre/apellido, apodos); los no
# emparejados se listan explícitamente en vez de desaparecer en silencio.

merged <- scored_data %>%
  inner_join(market_values_clean, by = c("Player", "League"))

unmatched <- scored_data %>%
  anti_join(market_values_clean, by = c("Player", "League"))

cat(sprintf(
  "\nCruce FBref <-> Transfermarkt: %d de %d jugadores emparejados (%d sin emparejar).\n",
  nrow(merged), nrow(scored_data), nrow(unmatched)
))
if (nrow(unmatched) > 0) {
  write.csv(unmatched %>% select(Player, Squad, League),
           "outputs/tables/market_value_unmatched_players.csv", row.names = FALSE)
  cat("Jugadores sin emparejar guardados en outputs/tables/market_value_unmatched_players.csv\n")
  cat("(revísalos a mano: normalmente son diferencias de nomenclatura, no ausencia real de dato).\n")
}

if (nrow(merged) < 30) {
  stop(paste0(
    "\n[ERROR] Muy pocos jugadores emparejados (", nrow(merged), ") para una ",
    "regresión fiable. Revisa el join por nombre antes de continuar."
  ), call. = FALSE)
}

# =========================================================
# 3. MODELO DE VALORACIÓN: log(valor de mercado) ~ rendimiento + edad + liga
# =========================================================
# El residuo positivo = el jugador vale, por rendimiento medido, más de lo
# que el mercado le está pagando ahora mismo. Es la definición estándar de
# "infravalorado" en econometría de valoración (regresión hedónica), mucho
# más defendible que un corte de percentil sobre una sola variable.

valuation_model <- lm(
  log(market_value_eur) ~ scouting_score + Age + I(Age^2) + League,
  data = merged
)

cat("\nModelo de valoración (log valor de mercado ~ scouting_score + edad + liga):\n")
print(summary(valuation_model))

merged$predicted_log_value <- predict(valuation_model)
merged$predicted_value_eur <- exp(merged$predicted_log_value)
merged$valuation_residual <- log(merged$market_value_eur) - merged$predicted_log_value

undervalued <- merged %>%
  arrange(desc(valuation_residual)) %>%
  select(Player, Squad, League, Age, scouting_score, market_value_eur,
         predicted_value_eur, valuation_residual) %>%
  mutate(
    market_value_eur = round(market_value_eur),
    predicted_value_eur = round(predicted_value_eur),
    valuation_residual = round(valuation_residual, 3)
  )

write.csv(undervalued, "outputs/tables/market_inefficiency_residuals.csv", row.names = FALSE)

cat("\nTop 15 infravalorados por residuo (valor real muy por debajo del predicho):\n")
print(head(undervalued, 15))

# =========================================================
# 4. FIGURA: VALOR PREDICHO VS. VALOR REAL
# =========================================================

suppressPackageStartupMessages(library(ggplot2))

p_valuation <- ggplot(merged, aes(x = predicted_value_eur / 1e6, y = market_value_eur / 1e6)) +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed", color = "grey50") +
  geom_point(aes(color = valuation_residual), alpha = 0.75, size = 2.5) +
  scale_color_gradient2(low = "#C44E52", mid = "grey85", high = "#4C72B0", midpoint = 0) +
  theme_minimal(base_size = 13) +
  labs(
    title    = "Predicted vs. actual market value",
    subtitle = "Below the diagonal: priced under what performance predicts (candidate market inefficiencies)",
    x        = "Predicted value from performance (EUR M)",
    y        = "Actual Transfermarkt value (EUR M)",
    color    = "Residual"
  )

ggsave("outputs/figures/market_value_residuals.png", p_valuation, width = 9, height = 7, dpi = 200)

cat("\nGuardado outputs/tables/market_inefficiency_residuals.csv y\n")
cat("outputs/figures/market_value_residuals.png\n")
