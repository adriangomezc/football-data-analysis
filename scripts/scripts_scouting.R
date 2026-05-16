# =========================================================
# scripts_scouting.R
# Recruitment and Scouting Analytics Pipeline
# =========================================================

source("scripts/setup_packages.R")

dir.create("outputs/figures", recursive = TRUE, showWarnings = FALSE)
dir.create("outputs/tables", recursive = TRUE, showWarnings = FALSE)

# =========================================================
# LOAD DATA
# =========================================================

data <- read.csv("data/processed/defenders_processed.csv")

# =========================================================
# FEATURE ENGINEERING
# =========================================================

data <- data %>%
  mutate(
    
    opponent_possession = 100 - team_possession,
    
    padj_tackles =
      tackles_per90 / (opponent_possession / 50),
    
    padj_interceptions =
      interceptions_per90 / (opponent_possession / 50),
    
    # Age score for recruitment value
    age_score =
      case_when(
        age <= 21 ~ 1.00,
        age <= 24 ~ 0.90,
        age <= 27 ~ 0.75,
        age <= 30 ~ 0.55,
        TRUE ~ 0.30
      ),
    
    # Progressive value
    progression_score =
      progressive_passes_per90 +
      carries_per90 +
      xT_per90,
    
    # Defensive value
    defending_score =
      padj_tackles +
      padj_interceptions +
      aerial_duels_won_pct,
    
    # Composite scouting score
    scouting_score =
      as.numeric(scale(xT_per90)) * 0.30 +
      as.numeric(scale(progressive_passes_per90)) * 0.25 +
      as.numeric(scale(padj_interceptions)) * 0.20 +
      as.numeric(scale(aerial_duels_won_pct)) * 0.15 +
      as.numeric(scale(age_score)) * 0.10
  )

# =========================================================
# TOP RECRUITMENT TARGETS
# =========================================================

top_targets <- data %>%
  arrange(desc(scouting_score)) %>%
  slice(1:20)

write.csv(
  top_targets,
  "outputs/tables/top_scouting_targets.csv",
  row.names = FALSE
)

# =========================================================
# VISUALIZATION
# =========================================================

p1 <- ggplot(
  top_targets,
  aes(
    x = reorder(player, scouting_score),
    y = scouting_score,
    fill = league
  )
) +
  
  geom_col() +
  
  coord_flip() +
  
  theme_minimal() +
  
  labs(
    title = "Top Centre-Back Scouting Targets",
    subtitle = "Composite Recruitment Score",
    x = "",
    y = "Scouting Score"
  )

ggsave(
  "outputs/figures/top_scouting_targets.png",
  p1,
  width = 11,
  height = 8
)

# =========================================================
# AGE VS PERFORMANCE
# =========================================================

p2 <- ggplot(
  data,
  aes(
    x = age,
    y = scouting_score,
    color = league
  )
) +
  
  geom_point(size = 3, alpha = 0.8) +
  
  geom_text_repel(
    aes(label = player),
    size = 3,
    max.overlaps = 15
  ) +
  
  theme_minimal() +
  
  labs(
    title = "Age vs Recruitment Value",
    x = "Age",
    y = "Scouting Score"
  )

ggsave(
  "outputs/figures/age_vs_scouting_value.png",
  p2,
  width = 11,
  height = 8
)

# =========================================================
# PROGRESSION VS DEFENDING
# =========================================================

p3 <- ggplot(
  data,
  aes(
    x = progression_score,
    y = defending_score,
    color = age
  )
) +
  
  geom_point(size = 4, alpha = 0.8) +
  
  geom_text_repel(
    aes(label = player),
    size = 3,
    max.overlaps = 20
  ) +
  
  theme_minimal() +
  
  labs(
    title = "Progression vs Defensive Impact",
    subtitle = "Centre-Back Scouting Map",
    x = "Progression Score",
    y = "Defending Score"
  )

ggsave(
  "outputs/figures/progression_vs_defending.png",
  p3,
  width = 11,
  height = 8
)

# =========================================================
# U23 TALENT IDENTIFICATION
# =========================================================

u23_targets <- data %>%
  filter(age <= 23) %>%
  arrange(desc(scouting_score)) %>%
  slice(1:15)

write.csv(
  u23_targets,
  "outputs/tables/u23_scouting_targets.csv",
  row.names = FALSE
)

# =========================================================
# LEAGUE COMPARISON
# =========================================================

league_profiles <- data %>%
  group_by(league) %>%
  summarise(
    
    avg_xT =
      mean(xT_per90, na.rm = TRUE),
    
    avg_progression =
      mean(progressive_passes_per90, na.rm = TRUE),
    
    avg_defending =
      mean(padj_interceptions, na.rm = TRUE),
    
    avg_duels =
      mean(aerial_duels_won_pct, na.rm = TRUE),
    
    avg_age =
      mean(age, na.rm = TRUE)
  )

write.csv(
  league_profiles,
  "outputs/tables/league_profiles.csv",
  row.names = FALSE
)

# =========================================================
# SCOUTING SHORTLIST VISUAL
# =========================================================

p4 <- ggplot(
  u23_targets,
  aes(
    x = xT_per90,
    y = padj_interceptions,
    size = scouting_score,
    color = league
  )
) +
  
  geom_point(alpha = 0.8) +
  
  geom_text_repel(
    aes(label = player),
    size = 3
  ) +
  
  theme_minimal() +
  
  labs(
    title = "U23 Recruitment Shortlist",
    subtitle = "Ball Progression vs Defensive Output",
    x = "xT per90",
    y = "PAdj Interceptions"
  )

ggsave(
  "outputs/figures/u23_recruitment_shortlist.png",
  p4,
  width = 11,
  height = 8
)

# =========================================================
# EXPORT FULL SCOUTING DATASET
# =========================================================

write.csv(
  data,
  "outputs/tables/full_scouting_dataset.csv",
  row.names = FALSE
)

cat("Scouting analysis completed successfully.\n")
