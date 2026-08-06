# =========================================================
# setup_packages.R
# Comprobación de dependencias del pipeline
# =========================================================
# Solo se listan los paquetes que el pipeline usa realmente:
#   tidyverse -> dplyr / tibble (column_to_rownames) / ggplot2
#   ggrepel   -> etiquetas sin solape en la proyección PCA
#   proxy     -> matriz de similitud del coseno

required_packages <- c("tidyverse", "ggrepel", "proxy")

missing_packages <- required_packages[
  !vapply(required_packages, requireNamespace, logical(1), quietly = TRUE)
]

if (length(missing_packages) > 0) {
  stop(paste0(
    '\n[ERROR FATAL] Faltan paquetes: ', paste(missing_packages, collapse = ', '),
    '\nInstálalos con: install.packages(c("',
    paste(missing_packages, collapse = '", "'), '"))'
  ), call. = FALSE)
}

for (pkg in required_packages) {
  suppressPackageStartupMessages(library(pkg, character.only = TRUE))
}

cat("Todos los paquetes cargados correctamente.\n")
