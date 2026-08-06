# =========================================================
# RUN_ALL.R - MASTER EXECUTION PIPELINE
# =========================================================
# Uso (desde la raíz del repositorio):
#   Rscript scripts/run_all.R
# Los pasos son dependientes entre sí: si uno falla, la ejecución se detiene.

rm(list = ls())

cat("Iniciando el Pipeline de Scouting Analytics...\n")
cat("====================================================\n\n")

run_step <- function(n, total, description, path) {
  cat(sprintf("[%d/%d] %s\n", n, total, description))
  tryCatch(
    source(path),
    error = function(e) {
      stop(sprintf("El pipeline se detuvo en '%s': %s", path, conditionMessage(e)),
           call. = FALSE)
    }
  )
  cat("\n")
}

# 1. SETUP
run_step(1, 5, "Comprobando paquetes requeridos...",
         "scripts/setup_packages.R")

# 2. DATA PREP & PAdj METRICS (la única fuente de verdad de la posesión)
run_step(2, 5, "Calculando estimaciones de posesión y multiplicadores PAdj...",
         "scripts/scripts_padj_metrics.R")

# 3. SCOUTING PRINCIPAL (pesos PCA y scores compuestos)
run_step(3, 5, "Calculando índice de progresión (PCA) y scouting score...",
         "scripts/scripts_scouting.R")

# 4. CLUSTERING Y VISUALIZACIÓN
run_step(4, 5, "Clasificando roles tácticos y generando figuras...",
         "scripts/scripts_clustering.R")

# 5. SIMILARITY ENGINE
run_step(5, 5, "Construyendo el motor de similitud...",
         "scripts/scripts_similarity_engine.R")

cat("====================================================\n")
cat("EJECUCIÓN DEL PIPELINE FINALIZADA CORRECTAMENTE.\n")
cat("Revisa la carpeta 'outputs/' para ver las tablas y figuras.\n")
