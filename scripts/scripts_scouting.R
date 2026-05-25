# =========================================================
# scripts_scouting.R
# Advanced Recruitment and Scouting Analytics
# =========================================================

source("scripts/setup_packages.R")

dir.create("outputs/figures", recursive = TRUE, showWarnings = FALSE)
dir.create("outputs/tables", recursive = TRUE, showWarnings = FALSE)

# =========================================================
# LOAD DATA
# =========================================================

data <- read.csv("data/All_Players_1992-2025.csv")

# =========================================================
# FILTER DEFENDERS
# =========================================================

data <- data %>%
  filter(
    as.numeric(substr(Season, 1, 4)) >= 2023,
    grepl("DF", Pos),
    Min >= 900
  )

# =========================================================================
# FEATURE ENGINEERING & PCA EMPIRICAL WEIGHTING
# =========================================================================

# 1. Calculamos las métricas base per90 y el acierto de pase
data <- data %>%
  mutate(
    progressive_passes_per90 = PrgP * 90 / Min,
    progressive_carries_per90 = PrgC * 90 / Min,
    key_passes_per90 = KP * 90 / Min,
    tackles_per90 = Tkl * 90 / Min,
    interceptions_per90 = Int * 90 / Min,
    recoveries_per90 = Recov * 90 / Min,
    crosses_per90 = Crs * 90 / Min,
    pass_completion = as.numeric(Cmp.)
  )

# 2. Seleccionamos las variables para el PCA de progresión
progression_vars <- data %>% 
  select(progressive_passes_per90, progressive_carries_per90, key_passes_per90)

pca_progression <- prcomp(progression_vars, scale. = TRUE)
raw_loadings <- abs(pca_progression$rotation[, 1])
prog_weights <- raw_loadings / sum(raw_loadings)

# 3. Calculamos los scores compuestos definitivos con base estadística
data <- data %>%
  mutate(
    # Tu antiguo progression_score ahora se calcula con el PCA
    progression_score = (progressive_passes_per90 * prog_weights[1]) + 
      (progressive_carries_per90 * prog_weights[2]) + 
      (key_passes_per90 * prog_weights[3]),
    
    # Unificamos el score defensivo sumando el volumen real
    defending_score = tackles_per90 + interceptions_per90 + recoveries_per90,
    
    # CAMBIO CLAVE: Borramos el "falso xT" y lo convertimos en un índice de progresión puro
    progression_index = (progressive_passes_per90 * 0.6) + (progressive_carries_per90 * 0.4),
    
    age_score = ifelse(Age <= 21, 1.0, ifelse(Age <= 24, 0.75, ifelse(Age <= 28, 0.5, 0.25))),
    
    # El scouting_score final equilibrado
    scouting_score = (progression_score * 0.4) + (defending_score * 0.3) + 
      ((pass_completion / 100) * 0.1) + (age_score * 0.2)
  )
# =========================================================
# AGGREGATE LAST 4 YEARS PER PLAYER
# =========================================================

data <- data %>%
  group_by(Player) %>%
  # Nos quedamos con el equipo y liga más recientes, la edad actual, y promediamos sus métricas
  summarise(
    Squad = last(Squad),
    League = last(League),
    Age = max(Age),
    across(
      c(progressive_passes_per90:scouting_score), 
      \(x) mean(x, na.rm = TRUE)
    )
  ) %>%
  ungroup()

# =========================================================
# ROLE CLASSIFICATION
# =========================================================

data <- data %>%
  mutate(
    role_profile =
      case_when(
        
        progression_score >= quantile(progression_score, 0.75) &
          defending_score >= quantile(defending_score, 0.60)
        ~ "Elite Progressive CB",
        
        progression_score >= quantile(progression_score, 0.75)
        ~ "Ball Progressor",
        
        defending_score >= quantile(defending_score, 0.75)
        ~ "Defensive Stopper",
        
        pass_completion >= quantile(pass_completion, 0.75)
        ~ "Possession Defender",
        
        TRUE ~ "Balanced Defender"
      )
  )

# =========================================================
# TOP RECRUITMENT TARGETS
# =========================================================

top_targets <- data %>%
  arrange(desc(scouting_score)) %>%
  select(
    Player,
    Squad,
    League,
    Age,
    role_profile,
    scouting_score,
    xT_proxy,
    defending_score,
    pass_completion
  ) %>%
  head(25)

write.csv(
  top_targets,
  "outputs/tables/top_recruitment_targets.csv",
  row.names = FALSE
)

# =========================================================
# MARKET INEFFICIENCY TARGETS
# Young + High Output
# =========================================================

market_targets <- data %>%
  filter(
    Age <= 24,
    scouting_score >= quantile(scouting_score, 0.80)
  ) %>%
  arrange(desc(scouting_score)) %>%
  select(
    Player,
    Squad,
    League,
    Age,
    role_profile,
    scouting_score
  )

write.csv(
  market_targets,
  "outputs/tables/market_inefficiency_targets.csv",
  row.names = FALSE
)

# =========================================================
# PLAYER SIMILARITY MODEL
# =========================================================

similarity_data <- data %>%
  select(
    Player,
    progressive_passes_per90,
    progressive_carries_per90,
    defending_score,
    pass_completion,
    xT_proxy
  )

similarity_matrix <- similarity_data %>%
  column_to_rownames("Player") %>%
  scale()

cosine_sim <- coop::cosine(t(similarity_matrix))

cosine_sim_df <- as.data.frame(as.table(cosine_sim))

colnames(cosine_sim_df) <- c(
  "Player1",
  "Player2",
  "Similarity"
)

cosine_sim_df <- cosine_sim_df %>%
  filter(Player1 != Player2) %>%
  arrange(desc(Similarity))

write.csv(
  cosine_sim_df,
  "outputs/tables/player_similarity.csv",
  row.names = FALSE
)

# =========================================================
# SCATTERPLOT:
# PROGRESSION VS DEFENDING
# =========================================================

p1 <- ggplot(
  data,
  aes(
    progression_score,
    defending_score,
    color = role_profile,
    size = scouting_score
  )
) +
  geom_point(alpha = 0.75) +
  theme_minimal() +
  labs(
    title = "Defender Archetypes",
    x = "Progression Score",
    y = "Defending Score"
  )

ggsave(
  "outputs/figures/defender_archetypes.png",
  p1,
  width = 10,
  height = 7
)

# =========================================================
# AGE VS SCOUTING VALUE
# =========================================================

p2 <- ggplot(
  data,
  aes(
    Age,
    scouting_score,
    color = role_profile
  )
) +
  geom_point(size = 3, alpha = 0.75) +
  theme_minimal() +
  labs(
    title = "Recruitment Value by Age",
    x = "Age",
    y = "Scouting Score"
  )

ggsave(
  "outputs/figures/recruitment_value.png",
  p2,
  width = 10,
  height = 7
)

# =========================================================
# xT PROXY RANKING
# =========================================================

xt_ranking <- data %>%
  arrange(desc(xT_proxy)) %>%
  select(
    Player,
    Squad,
    League,
    xT_proxy,
    progressive_passes_per90,
    progressive_carries_per90
  ) %>%
  head(20)

write.csv(
  xt_ranking,
  "outputs/tables/xt_proxy_ranking.csv",
  row.names = FALSE
)

# =========================================================
# DEFENSIVE RANKING
# =========================================================

defensive_ranking <- data %>%
  arrange(desc(defending_score)) %>%
  select(
    Player,
    Squad,
    League,
    defending_score,
    tackles_per90,
    interceptions_per90,
    recoveries_per90
  ) %>%
  head(20)

write.csv(
  defensive_ranking,
  "outputs/tables/defensive_ranking.csv",
  row.names = FALSE
)

# =========================================================
# EXPORT PROCESSED DATA FOR OTHER SCRIPTS
# =========================================================
dir.create("data/processed", recursive = TRUE, showWarnings = FALSE)

write.csv(
  data,
  "data/processed/defenders_processed.csv",
  row.names = FALSE
)

# =========================================================
# SCOUTING DASHBOARD TABLE
# =========================================================

dashboard_table <- data %>%
  select(
    Player,
    Squad,
    League,
    Age,
    role_profile,
    scouting_score,
    progression_score,
    defending_score,
    xT_proxy,
    pass_completion
  ) %>%
  arrange(desc(scouting_score))

write.csv(
  dashboard_table,
  "outputs/tables/scouting_dashboard.csv",
  row.names = FALSE
)


# =========================================================
# FINAL MESSAGE
# =========================================================

cat("\n")
cat("========================================\n")
cat("SCOUTING ANALYSIS COMPLETED\n")
cat("========================================\n")
cat("Outputs generated in outputs/\n")
cat("========================================\n")