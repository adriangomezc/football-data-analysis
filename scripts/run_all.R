# =========================================================
# RUN_ALL.R - MASTER EXECUTION PIPELINE
# =========================================================

rm(list = ls())

cat("Iniciando el Pipeline de Scouting Analytics...\n")
cat("====================================================\n\n")

# 1. SETUP
cat("[1/5] Instalando y cargando paquetes requeridos...\n")
source("scripts/setup_packages.R")

# 2. DATA PREP & PAdj METRICS (La ÚNICA fuente de verdad de la posesión)
cat("[2/5] Calculando estimaciones de posesión y métricas PAdj...\n")
tryCatch({
  source("scripts/scripts_padj_metrics.R")
}, error = function(e) cat("  -> ERROR en scripts_padj_metrics.R:", conditionMessage(e), "\n"))

# 3. SCOUTING PRINCIPAL (Cálculo de PCA y Scores)
cat("[3/5] Calculando Índice de Progresión (PCA) y Scouting Score...\n")
tryCatch({
  source("scripts/scripts_scouting.R")
}, error = function(e) cat("  -> ERROR en scripts_scouting.R:", conditionMessage(e), "\n"))

# 4. CLUSTERING Y VISUALIZACIÓN
cat("[4/5] Clasificando roles tácticos y generando dashboards...\n")
tryCatch({
  source("scripts/scripts_clustering.R")
}, error = function(e) cat("  -> ERROR en scripts_clustering.R:", conditionMessage(e), "\n"))

# 5. SIMILARITY ENGINE
cat("[5/5] Construyendo Motor de Similitud...\n")
tryCatch({
  source("scripts/scripts_similarity_engine.R")
}, error = function(e) cat("  -> ERROR en scripts_similarity_engine.R:", conditionMessage(e), "\n"))

cat("\n====================================================\n")
cat("EJECUCIÓN DEL PIPELINE FINALIZADA.\n")
cat("Revisa la carpeta 'outputs/' para ver las tablas y gráficos.\n")