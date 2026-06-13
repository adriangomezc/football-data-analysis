required_packages <- c("tidyverse", "data.table", "ggplot2", "ggrepel", "cluster", "factoextra", "proxy")

for(pkg in required_packages){
  if(!requireNamespace(pkg, quietly = TRUE)){
    stop(paste("\n[ERROR FATAL] Falta el paquete:", pkg, 
               "\nPor favor, instálalo manualmente ejecutando: install.packages('", pkg, "')"))
  }
  suppressPackageStartupMessages(library(pkg, character.only = TRUE))
}
cat("Todos los paquetes cargados correctamente.\n")