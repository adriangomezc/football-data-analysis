# =========================================================
# scripts_similarity_engine.R
# Player Similarity Engine (Cosine Similarity)
# =========================================================

source("scripts/setup_packages.R")
dir.create("outputs/tables", recursive = TRUE, showWarnings = FALSE)

# =========================
# 1. LOAD DATA
# =========================
data <- read.csv("data/processed/defenders_processed.csv")

# =========================
# 2. SELECT FEATURES
# =========================
similarity_data <- data %>%
  select(
    Player,
    progressive_passes_per90,
    progressive_carries_per90,
    key_passes_per90,
    interceptions_per90,
    tackles_per90,
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
# 4. FIND SIMILAR PLAYERS
# =========================
target_player <- data %>% 
  arrange(desc(scouting_score)) %>% 
  slice(1) %>% 
  pull(Player)

cat("El jugador objetivo para la similitud es:", target_player, "\n")

# Construimos la tabla forzando que todo sea texto y números legibles
similar_players <- data.frame(
  Player = rownames(sim_matrix),
  similarity = as.numeric(sim_matrix[target_player, ]),
  stringsAsFactors = FALSE
)

# Filtramos y nos quedamos con el Top 10
top_similar <- similar_players %>%
  filter(Player != target_player) %>%
  arrange(desc(similarity)) %>%
  slice(1:10)

# =========================
# 5. SAVE OUTPUT
# =========================
write.csv(
  top_similar,
  "outputs/tables/player_similarity_results.csv",
  row.names = FALSE
)

cat("Similarity Engine completed successfully.\n")