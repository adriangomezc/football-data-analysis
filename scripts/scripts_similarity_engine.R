# =========================================================
# scripts_similarity_engine.R
# Player Similarity Engine (Cosine Similarity)
# =========================================================

source("scripts/setup_packages.R")
dir.create("outputs/tables", recursive = TRUE, showWarnings = FALSE)

# =========================
# 1. LOAD DATA
# =========================
# CORRECCIÓN: Apuntamos al archivo maestro unificado
data <- read.csv("outputs/tables/padj_defensive_metrics.csv")

# =========================
# 2. SELECT FEATURES
# =========================
similarity_data <- data %>%
  select(
    Player,
    progressive_passes_per90,
    progressive_carries_per90,
    key_passes_per90,
    padj_interceptions, # ¡CORREGIDO! Algoritmo consciente del contexto
    padj_tackles,       # ¡CORREGIDO! Algoritmo consciente del contexto
    progression_index
  ) %>%
  filter(complete.cases(.)) %>% # Eliminar NAs para que la matriz no se rompa
  column_to_rownames("Player")

# =========================
# 3. COSINE SIMILARITY
# =========================
# Escalamos los datos
features_scaled <- scale(similarity_data)

# Calculamos matriz
sim_matrix <- as.matrix(proxy::simil(features_scaled, method = "cosine"))

# Forzamos los nombres explícitamente para que no se pierdan
rownames(sim_matrix) <- rownames(features_scaled)
colnames(sim_matrix) <- rownames(features_scaled)

# =========================
# 4. SIMILARITY FUNCTION (Flexible & Reutilizable)
# =========================

get_similar_cb <- function(target_name, sim_matrix, top_n = 10) {
  
  # Validación de seguridad: Comprobar si el central existe
  if(!target_name %in% rownames(sim_matrix)) {
    stop(paste("El jugador", target_name, "no se encuentra en la base de datos de centrales filtrados."))
  }
  
  # Extracción de distancias
  similar_players <- data.frame(
    Player = rownames(sim_matrix),
    similarity = as.numeric(sim_matrix[target_name, ]),
    stringsAsFactors = FALSE
  )
  
  # Limpieza y ranking
  result <- similar_players %>%
    filter(Player != target_name) %>%
    arrange(desc(similarity)) %>%
    slice(1:top_n)
  
  return(result)
}

# =========================
# 5. EXECUTE & SAVE OUTPUT
# =========================

# Extraemos el target dinámicamente o introducimos uno manual (Ej: "Alidu Seidu")
target_player <- data %>% arrange(desc(scouting_score)) %>% slice(1) %>% pull(Player)

cat("Buscando perfiles similares a:", target_player, "\n")
top_similar <- get_similar_cb(target_player, sim_matrix, top_n = 10)

# Añadimos contexto (equipo, liga y temporada de la muestra) para que la tabla
# sea legible por sí sola: recuerda que la muestra mezcla dos campañas.
top_similar <- top_similar %>%
  left_join(
    data %>% select(Player, Squad, League, Season, Age, scouting_score),
    by = "Player"
  ) %>%
  mutate(target = target_player, .before = 1)

write.csv(
  top_similar,
  "outputs/tables/player_similarity_results.csv",
  row.names = FALSE
)

cat("Motor de Similitud completado. Listo para ingestar cualquier nombre.\n")