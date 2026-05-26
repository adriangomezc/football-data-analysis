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
    !grepl("LB", Pos), !grepl("RB", Pos), !grepl("WB", Pos),
    Min >= 900
  )

# =========================================================================
# FEATURE ENGINEERING & PCA EMPIRICAL WEIGHTING
# =========================================================================
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

progression_vars <- data %>% select(progressive_passes_per90, progressive_carries_per90, key_passes_per90)
pca_prog <- prcomp(progression_vars, scale. = TRUE)
# 4. Extraemos y normalizamos los loadings correctamente
raw_loadings <- abs(pca_prog$rotation[, 1])
prog_weights <- raw_loadings / sum(raw_loadings)

# 5. Calculamos los scores compuestos con los pesos corregidos
data <- data %>%
  mutate(
    progression_index = (progressive_passes_per90 * prog_weights[1]) + 
      (progressive_carries_per90 * prog_weights[2]) + 
      (key_passes_per90 * prog_weights[3]),
    
    defending_score = tackles_per90 + interceptions_per90 + recoveries_per90,
    
    age_score = case_when(
      Age <= 21 ~ 1.00,
      Age <= 24 ~ 0.90,
      Age <= 27 ~ 0.75,
      Age <= 30 ~ 0.55,
      TRUE ~ 0.30
    ),
    
    scouting_score = (progression_index * 0.4) + (defending_score * 0.3) + 
      ((pass_completion / 100) * 0.1) + (age_score * 0.2)
  ) %>%

filter(crosses_per90 < 0.5)
# =========================================================
# AGGREGATE LAST 4 YEARS PER PLAYER (Corregido de forma segura)
# =========================================================

data <- data %>%
  group_by(Player) %>%
  summarise(
    Squad = last(Squad),
    League = last(League),
    Age = max(Age),
    # Especificamos las variables numéricas finales de forma explícita para evitar errores de rango
    across(
      c(progressive_passes_per90, progressive_carries_per90, key_passes_per90,
        tackles_per90, interceptions_per90, recoveries_per90, crosses_per90,
        pass_completion, defending_score, progression_index, age_score, scouting_score), 
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
        # Cambiamos progression_score por el nuevo progression_index
        progression_index >= quantile(progression_index, 0.75) &
          defending_score >= quantile(defending_score, 0.60)
        ~ "Elite Progressive CB",
        
        progression_index >= quantile(progression_index, 0.75)
        ~ "Ball Progressor",
        
        defending_score >= quantile(defending_score, 0.75)
        ~ "Defensive Stopper",
        
        pass_completion >= quantile(pass_completion, 0.75)
        ~ "Possession Defender",
        
        TRUE ~ "Balanced Defender"
      )
  )

# =========================================================
# TOP RECRUITMENT TARGETS (Corregido con progression_index)
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
    progression_index, # ¡Cambiado xT_proxy por la variable real!
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
# SCATTERPLOT: PROGRESSION VS DEFENDING
# =========================================================

p1 <- ggplot(
  data,
  aes(
    progression_index, # ¡Actualizado!
    defending_score,
    color = role_profile,
    size = scouting_score
  )
) +
  geom_point(alpha = 0.75) +
  theme_minimal() +
  labs(
    title = "Defender Archetypes (Pure CB)",
    x = "Progression Index (PCA Weighted)",
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
  aes(Age, scouting_score, color = role_profile)
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
# PROGRESSION RANKING (Sustituye al antiguo ranking xT)
# =========================================================

prog_ranking <- data %>%
  arrange(desc(progression_index)) %>%
  select(
    Player,
    Squad,
    League,
    progression_index, # ¡Actualizado!
    progressive_passes_per90,
    progressive_carries_per90
  ) %>%
  head(20)

write.csv(
  prog_ranking,
  "outputs/tables/xt_proxy_ranking.csv", # Mantenemos el nombre de salida para no romper dependencias externas
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
    progression_index, # ¡Actualizado!
    defending_score,
    pass_completion
  ) %>%
  arrange(desc(scouting_score))

write.csv(
  dashboard_table,
  "outputs/tables/scouting_dashboard.csv",
  row.names = FALSE
)

cat("\n========================================\n")
cat("SCOUTING ANALYSIS COMPLETED\n")
cat("========================================\n")