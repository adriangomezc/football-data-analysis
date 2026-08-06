# =========================================================
# scripts_optional_real_possession.R
# [OPCIONAL / MANUAL] Sustituir el proxy de posesión por el dato REAL de FBref
# =========================================================
#
# QUÉ HACE
# El resto del pipeline ESTIMA la posesión de cada equipo a partir de su
# volumen de pases frente a la media de la liga (ver scripts_padj_metrics.R).
# FBref publica la posesión real por equipo y temporada; este script la
# descarga con el paquete worldfootballR y genera un sustituto directo del
# diccionario de posesión, sin tocar el resto de la lógica del pipeline.
#
# POR QUÉ ES UN SCRIPT APARTE Y OPCIONAL (léelo antes de ejecutar)
# 1. Depende de scrapear FBref en vivo. FBref protege el sitio con Cloudflare
#    y bloquea IPs de centros de datos / entornos en la nube con un 403 -
#    NO puede ejecutarse desde un sandbox o CI, solo desde tu máquina.
# 2. Es lento (varias peticiones HTTP con pausa obligatoria entre ellas) y
#    depende de que FBref no haya cambiado el HTML de sus tablas, algo que
#    ya ha pasado antes y rompe el scraping sin previo aviso.
# 3. No he podido ejecutar ESTE script de extremo a extremo yo mismo (mi
#    entorno de desarrollo no tiene acceso a fbref.com). Sí he verificado
#    contra la documentación del paquete (fb_season_team_stats) que la
#    firma de la función y los stat_type son correctos, pero el nombre
#    exacto de la columna de posesión en el data frame de salida no lo he
#    podido confirmar en vivo - por eso el script la busca dinámicamente
#    en vez de asumir un nombre fijo, y falla con un mensaje claro si no
#    la encuentra.
#
# CÓMO USAR EL RESULTADO
# Genera 'data/processed/team_possession_real.csv' con las mismas columnas
# que 'team_possession_proxy.csv' (Squad, estimated_possession_proxy ->
# aquí posesión real, padj_multiplier). Para usarlo en el pipeline, cambia
# en scripts_scouting.R y scripts_padj_metrics.R la ruta leída de
# 'data/processed/team_possession_proxy.csv' a
# 'data/processed/team_possession_real.csv' (o renombra el archivo), y
# vuelve a correr run_all.R. Todos los números aguas abajo (scouting_score,
# clustering, validación temporal) se recalculan solos con el dato real.

if (!requireNamespace("worldfootballR", quietly = TRUE)) {
  stop(paste0(
    "\n[INFO] Este script es opcional y necesita el paquete worldfootballR ",
    "(no forma parte de setup_packages.R a propósito, porque no lo necesita ",
    "el resto del pipeline).\nInstálalo con: ",
    'install.packages("worldfootballR")\n'
  ), call. = FALSE)
}

suppressPackageStartupMessages(library(dplyr))

dir.create("data/processed", recursive = TRUE, showWarnings = FALSE)

# Big-5: código de país (formato worldfootballR), género, primera división
leagues <- data.frame(
  country = c("ESP", "ENG", "ITA", "GER", "FRA"),
  League  = c("La Liga", "Premier League", "Serie A", "Bundesliga", "Ligue 1"),
  stringsAsFactors = FALSE
)

# season_end_year: el AÑO EN QUE TERMINA la temporada.
# "2023-2024" -> 2024 | "2024-2025" -> 2025 (coherente con el resto del pipeline)
seasons <- data.frame(
  Season          = c("2023-2024", "2024-2025"),
  season_end_year = c(2024, 2025),
  stringsAsFactors = FALSE
)

cat("Descargando posesión real de FBref (esto puede tardar varios minutos)...\n")
cat("Si ves un error 403 / 'Forbidden', FBref está bloqueando tu conexión.\n\n")

raw_possession <- list()

for (i in seq_len(nrow(leagues))) {
  for (j in seq_len(nrow(seasons))) {
    country <- leagues$country[i]
    league_name <- leagues$League[i]
    season_end_year <- seasons$season_end_year[j]
    season_label <- seasons$Season[j]

    cat(sprintf("  %s (%s)...\n", league_name, season_label))

    result <- tryCatch({
      worldfootballR::fb_season_team_stats(
        country = country, gender = "M", season_end_year = season_end_year,
        tier = "1st", stat_type = "possession"
      )
    }, error = function(e) {
      cat(sprintf(
        "  [AVISO] Fallo al descargar %s %s: %s\n  Salto esta combinación, revisa tu conexión o vuelve a intentarlo más tarde.\n",
        league_name, season_label, conditionMessage(e)
      ))
      NULL
    })

    if (!is.null(result) && nrow(result) > 0) {
      result$League <- league_name
      result$Season <- season_label
      raw_possession[[paste(country, season_end_year)]] <- result
    }
  }
}

if (length(raw_possession) == 0) {
  stop(paste0(
    "\n[ERROR] No se pudo descargar ninguna tabla de posesión. ",
    "Lo más probable es que FBref esté bloqueando la conexión desde este ",
    "entorno. Prueba desde tu máquina personal con conexión residencial ",
    "normal, y espera unos segundos entre reintentos."
  ), call. = FALSE)
}

possession_raw <- bind_rows(raw_possession)

# La columna de posesión no tiene un nombre 100% garantizado entre versiones
# del paquete (históricamente 'Poss' o 'Poss_Percentage_Team_Poss_'). La
# buscamos dinámicamente: primera columna numérica cuyo nombre contenga
# "poss" y cuyos valores parezcan un porcentaje (0-100).
poss_col_candidates <- names(possession_raw)[
  grepl("poss", names(possession_raw), ignore.case = TRUE)
]
poss_col <- NULL
for (col in poss_col_candidates) {
  vals <- suppressWarnings(as.numeric(possession_raw[[col]]))
  if (all(is.na(vals)) ) next
  if (max(vals, na.rm = TRUE) <= 100 && min(vals, na.rm = TRUE) >= 0) {
    poss_col <- col
    break
  }
}

if (is.null(poss_col)) {
  stop(paste0(
    "\n[ERROR] No se ha podido identificar automáticamente la columna de ",
    "posesión (%) en la tabla descargada. Columnas disponibles:\n  ",
    paste(names(possession_raw), collapse = ", "),
    "\nAbre 'possession_raw' en una sesión interactiva, localiza la columna ",
    "correcta a mano y ajusta 'poss_col' en este script."
  ), call. = FALSE)
}

cat(sprintf("\nColumna de posesión detectada: '%s'\n", poss_col))

squad_col <- if ("Squad" %in% names(possession_raw)) "Squad" else names(possession_raw)[1]

team_possession_real <- possession_raw %>%
  transmute(
    Squad = .data[[squad_col]],
    League,
    Season,
    real_possession_pct = suppressWarnings(as.numeric(.data[[poss_col]]))
  ) %>%
  filter(!is.na(real_possession_pct)) %>%
  mutate(
    padj_multiplier = 2 / (1 + exp(-0.1 * (real_possession_pct - 50)))
  )

write.csv(team_possession_real, "data/processed/team_possession_real.csv", row.names = FALSE)

cat(sprintf(
  "\nGuardado data/processed/team_possession_real.csv (%d equipos-temporada).\n",
  nrow(team_possession_real)
))

# Chequeo de cobertura frente a los equipos que el pipeline realmente usa,
# para detectar problemas de nombres (acentos, abreviaturas tipo "Utd" vs
# "United") antes de que fallen silenciosamente en un left_join().
if (file.exists("data/processed/team_possession_proxy.csv")) {
  proxy_squads <- unique(read.csv("data/processed/team_possession_proxy.csv")$Squad)
  real_squads <- unique(team_possession_real$Squad)
  sin_match <- setdiff(proxy_squads, real_squads)
  if (length(sin_match) > 0) {
    cat(sprintf(
      "\n[AVISO] %d equipos del proxy no tienen coincidencia exacta de nombre en los datos reales:\n  %s\n",
      length(sin_match), paste(head(sin_match, 15), collapse = ", ")
    ))
    cat("Revísalos a mano: probablemente son diferencias de nomenclatura FBref (acentos, abreviaturas).\n")
  } else {
    cat("\nTodos los equipos del proxy tienen coincidencia en los datos reales.\n")
  }
}

cat("\nListo. Para usar el dato real en vez del proxy, apunta la lectura de\n")
cat("'team_possession_proxy.csv' en scripts_scouting.R / scripts_padj_metrics.R\n")
cat("a 'team_possession_real.csv' y vuelve a correr run_all.R.\n")
