# =========================================================
# setup_packages.R
# Comprobación de dependencias del pipeline
# =========================================================
# Paquetes que se ATTACHAN (library) porque se usan con llamadas "desnudas"
# en todo el pipeline:
#   tidyverse -> dplyr / tibble (column_to_rownames) / ggplot2
#   ggrepel   -> etiquetas sin solape en las proyecciones PCA
#   proxy     -> matriz de similitud del coseno
required_packages <- c("tidyverse", "ggrepel", "proxy")

# Paquetes que se usan SOLO con :: (namespace explícito), nunca library().
# car:: carga MASS, que enmascara dplyr::select() y rompería el resto del
# pipeline si se attachara. Se comprueba que está instalado pero no se
# carga entero.
#   car     -> vif() para el diagnóstico de multicolinealidad
# cluster:: (silhouette) es un paquete "recommended" que se instala junto
# con R, así que no hace falta declararlo ni comprobarlo aquí.
namespaced_packages <- c("car")

all_packages <- c(required_packages, namespaced_packages)

missing_packages <- all_packages[
  !vapply(all_packages, requireNamespace, logical(1), quietly = TRUE)
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
