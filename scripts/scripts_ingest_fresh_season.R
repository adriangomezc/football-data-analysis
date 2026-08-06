# =========================================================
# scripts_ingest_fresh_season.R
# [OPCIONAL / MANUAL] Incorporar la temporada 2025-26 (u otra más reciente)
# =========================================================
#
# QUÉ HACE
# Transforma un CSV de estadísticas de jugadores de una temporada reciente
# (por defecto, pensado para el dataset de Kaggle "Football Players Stats
# 2025-2026" de hubertsidorowicz, que se actualiza semanalmente a partir de
# FBref) al esquema canónico de 'data/All_Players_1992-2025.csv', para que
# pueda simplemente concatenarse con los datos existentes y el resto del
# pipeline (scripts_padj_metrics.R, scripts_scouting.R, ...) funcione sin
# tocar una sola línea más.
#
# POR QUÉ ES UN SCRIPT APARTE Y OPCIONAL (léelo antes de ejecutar)
# 1. Kaggle exige una cuenta y, para descargas por API, un token personal
#    (kaggle.json) — no es algo que se pueda automatizar sin tus
#    credenciales, así que la descarga del CSV la haces tú a mano desde
#    https://www.kaggle.com/datasets/hubertsidorowicz/football-players-stats-2025-2026
# 2. No he podido probar este script contra el CSV real de Kaggle: mi
#    entorno de desarrollo no tiene acceso a kaggle.com (requiere sesión
#    autenticada). Por eso el script es deliberadamente defensivo: detecta
#    las columnas por patrones en vez de asumir nombres fijos, imprime
#    exactamente qué encontró y qué no, y se detiene con un mensaje
#    accionable si algo no cuadra, en lugar de fallar en silencio o generar
#    números incorrectos.
# 3. Si el CSV de Kaggle no tiene alguna columna con un patrón reconocible,
#    edita 'column_patterns' más abajo añadiendo el nombre exacto que
#    encuentres al imprimir colnames(raw) — es la única parte que debería
#    hacer falta tocar.
#
# CÓMO USAR EL RESULTADO
# Genera 'data/processed/fresh_season_harmonized.csv' con las mismas
# columnas que necesita el resto del pipeline. Para incorporarlo:
#   raw_data <- bind_rows(
#     read.csv("data/All_Players_1992-2025.csv"),
#     read.csv("data/processed/fresh_season_harmonized.csv")
#   )
# sustituyendo esa unión en scripts_padj_metrics.R y scripts_scouting.R (o,
# más simple, generar un nuevo 'data/All_Players_1992-2026.csv' con
# write.csv() sobre ese bind_rows y apuntar ahí las rutas de lectura).

suppressPackageStartupMessages(library(dplyr))

# =========================================================
# 1. CONFIGURACIÓN — AJUSTA ESTO
# =========================================================

input_path <- "data/raw/kaggle_2025_2026_players.csv"  # <- cambia a tu ruta descargada
season_label <- "2025-2026"                             # <- etiqueta a asignar a esta temporada

if (!file.exists(input_path)) {
  stop(paste0(
    "\n[INFO] No se encuentra '", input_path, "'.\n",
    "1. Descarga el CSV desde:\n",
    "   https://www.kaggle.com/datasets/hubertsidorowicz/football-players-stats-2025-2026\n",
    "2. Guárdalo en esa ruta (o cambia 'input_path' arriba).\n",
    "3. Vuelve a ejecutar este script."
  ), call. = FALSE)
}

raw <- read.csv(input_path, check.names = FALSE, stringsAsFactors = FALSE)
cat(sprintf("Leído '%s': %d filas, %d columnas.\n", input_path, nrow(raw), ncol(raw)))
cat("Columnas disponibles:\n")
print(colnames(raw))

# =========================================================
# 2. DETECCIÓN DEFENSIVA DE COLUMNAS
# =========================================================
# Para cada campo que el resto del pipeline necesita, una lista de patrones
# candidatos (case-insensitive) a buscar en colnames(raw), en orden de
# preferencia. El primero que haga match gana.

column_patterns <- list(
  Player   = c("^player$", "^name$"),
  Squad    = c("^squad$", "^team$", "^club$"),
  League   = c("^league$", "^comp$", "^competition$"),
  Pos      = c("^pos$", "^position$"),
  Age      = c("^age$"),
  Min      = c("^min$", "^minutes$", "^minutes.played$"),
  X90s     = c("^90s$", "^x90s$", "^nineties$"),
  Pass     = c("^pass$", "^passes.attempted$", "^att\\b.*pass", "^att$"),
  Cmp      = c("^cmp$", "^passes.completed$", "^pass.*cmp$"),
  `Cmp.`   = c("^cmp%$", "^cmp\\.$", "^pass.*completion", "^pass.*%$"),
  Crs      = c("^crs$", "^crosses$"),
  PrgR     = c("^prgr$", "^progressive.*receiv", "^prg.*rec"),
  `Att.3rd` = c("^att 3rd$", "^att\\.3rd$", "^touches.*att.*3rd", "^att.*third"),
  PrgP     = c("^prgp$", "^progressive.*pass(es)?$", "^prg.*pass(es)?$"),
  PrgC     = c("^prgc$", "^progressive.*carr", "^prg.*carr"),
  KP       = c("^kp$", "^key.*pass(es)?$"),
  Tkl      = c("^tkl$", "^tackles$"),
  Int      = c("^int$", "^interceptions$"),
  Recov    = c("^recov$", "^recoveries$", "^ball.*recover")
)

find_column <- function(raw, patterns, canonical_name) {
  cn <- colnames(raw)
  for (p in patterns) {
    hit <- grep(p, cn, ignore.case = TRUE, perl = TRUE, value = TRUE)
    if (length(hit) >= 1) return(hit[1])
  }
  cat(sprintf(
    "  [NO ENCONTRADO] '%s' — ningún patrón (%s) hizo match.\n",
    canonical_name, paste(patterns, collapse = " | ")
  ))
  NA_character_
}

cat("\nMapeo de columnas detectado:\n")
resolved <- sapply(names(column_patterns), function(field) {
  hit <- find_column(raw, column_patterns[[field]], field)
  cat(sprintf("  %-10s -> %s\n", field, ifelse(is.na(hit), "???", hit)))
  hit
})

missing_fields <- names(resolved)[is.na(resolved)]
if (length(missing_fields) > 0) {
  stop(paste0(
    "\n[ERROR] No se pudieron mapear estas columnas: ", paste(missing_fields, collapse = ", "),
    "\nRevisa colnames(raw) (impreso arriba) y añade el patrón que corresponda ",
    "en 'column_patterns' dentro de este script."
  ), call. = FALSE)
}

# =========================================================
# 3. CONSTRUIR EL CSV CANÓNICO
# =========================================================

harmonized <- raw %>%
  transmute(
    Player   = .data[[resolved["Player"]]],
    Squad    = .data[[resolved["Squad"]]],
    League   = .data[[resolved["League"]]],
    Pos      = .data[[resolved["Pos"]]],
    Age      = as.numeric(.data[[resolved["Age"]]]),
    Season   = season_label,
    Min      = as.numeric(.data[[resolved["Min"]]]),
    X90s     = as.numeric(.data[[resolved["X90s"]]]),
    Pass     = as.numeric(.data[[resolved["Pass"]]]),
    Cmp      = as.numeric(.data[[resolved["Cmp"]]]),
    `Cmp.`   = as.numeric(.data[[resolved["Cmp."]]]),
    Crs      = as.numeric(.data[[resolved["Crs"]]]),
    PrgR     = as.numeric(.data[[resolved["PrgR"]]]),
    `Att.3rd` = as.numeric(.data[[resolved["Att.3rd"]]]),
    PrgP     = as.numeric(.data[[resolved["PrgP"]]]),
    PrgC     = as.numeric(.data[[resolved["PrgC"]]]),
    KP       = as.numeric(.data[[resolved["KP"]]]),
    Tkl      = as.numeric(.data[[resolved["Tkl"]]]),
    Int      = as.numeric(.data[[resolved["Int"]]]),
    Recov    = as.numeric(.data[[resolved["Recov"]]])
  )

# Si 'Cmp%' venía como fracción (0-1) en vez de porcentaje (0-100), lo
# reescalamos: el resto del pipeline asume 0-100 (as.numeric(Cmp.) / 100).
if (max(harmonized$`Cmp.`, na.rm = TRUE) <= 1.5) {
  cat("\n[AVISO] 'Cmp%' parece estar en fracción (0-1); reescalando a 0-100.\n")
  harmonized$`Cmp.` <- harmonized$`Cmp.` * 100
}

n_before <- nrow(harmonized)
harmonized <- harmonized %>% filter(!is.na(Min), Min > 0)
if (nrow(harmonized) < n_before) {
  cat(sprintf("Descartadas %d filas sin minutos válidos.\n", n_before - nrow(harmonized)))
}

dir.create("data/processed", recursive = TRUE, showWarnings = FALSE)
write.csv(harmonized, "data/processed/fresh_season_harmonized.csv", row.names = FALSE)

cat(sprintf(
  "\nGuardado data/processed/fresh_season_harmonized.csv: %d jugadores, temporada %s.\n",
  nrow(harmonized), season_label
))
cat("Revisa una muestra antes de fusionarlo con el dataset principal:\n")
print(head(harmonized, 5))

cat("\nPara incorporarlo al pipeline, une este CSV con data/All_Players_1992-2025.csv\n")
cat("(mismas columnas) y apunta run_all.R al fichero combinado. Ver cabecera de\n")
cat("este script para el snippet exacto.\n")
