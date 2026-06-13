[![es](https://img.shields.io/badge/lang-es-yellow.svg)](README.es.md)

# Identifying modern centre-backs with strong ball-progression capabilities

> Applied multivariate scouting framework in R to profile, rank, and find statistical replacements for centre-backs across Europe's top five leagues (2023–24 season).

The pipeline combines possession-adjusted defensive metrics, PCA-driven feature weighting, K-means clustering, and cosine similarity to move beyond raw counting stats and surface genuinely context-aware recruitment targets.

---

## Methodology

### 1. Data filtering and aggregation
The player pool was filtered to ensure positional accuracy and statistical significance:
- Primary position: Central Defender (DF). Hybrid MF/FW profiles excluded.
- Minimum threshold: 900 minutes played.
- Strict positional filters applied on progressive-receiving and attacking-third touch rates to remove wing-backs disguised as centre-backs.
- To avoid diluting current form, only the most recent season for each player is evaluated.

### 2. Feature engineering
All metrics normalised per 90 minutes. Key composite indicators include:
- **Progression index:** Weighted combination of progressive passes, progressive carries, and key passes per 90. Weights are derived dynamically from the PC1 loadings of a Principal Component Analysis (0.346, 0.352, and 0.302 respectively).
- **Possession-adjusted defending (PAdj):** Team possession is estimated using league-average passing volumes as a proxy for the opponent. We then apply the StatsBomb sigmoidal multiplier to tackles, interceptions, and recoveries to normalise defensive intensity per true defensive opportunity.
- **Scouting score:** The master ranking metric. Formula: `(progression_index × 0.4) + (PAdj_defending_score × 0.3) + (pass_completion / 100 × 0.1) + (age_score × 0.2)`. The age curve rewards peak performance windows (24-28 years) while gently penalising decline.

### 3. Clustering and tactical roles
Players are segmented into tactical archetypes using a K-means algorithm (k=4). Instead of hardcoding labels, the pipeline dynamically assigns tactical role names (e.g., Elite Progressive Distributor, High-Intensity Ball-Winner) by evaluating the mathematical centroids of each resulting cluster.

### 4. Similarity engine
A flexible cosine similarity function built on the standardised feature space. It ingests any target player's name and identifies the closest statistical matches to aid in succession planning.

---

## Key findings

**Top scouting scores:** Sead Kolašinac (Atalanta, 5.08) tops the master ranking, followed closely by breakout star Riccardo Calafiori (Bologna, 4.98) and Timo Hübers (Köln, 4.84). 

**Progression leaders:** Iñigo Martínez (Barcelona, 4.31) dominates the progression index, combining massive progressive pass volume with elite carrying metrics. Nico Schlotterbeck (Dortmund, 3.90) acts as the runner-up reference point.

**Possession-adjusted defending:** After normalising for team dominance using the sigmoidal curve, Timo Hübers (13.31 combined PAdj) and Riccardo Calafiori (13.18) emerge as the most intense ball-winners in the sample.

**U-24 market targets:** Riccardo Calafiori (21, score 4.98) is the absolute standout. Other elite young profiles highlighted by the algorithm include Nico Schlotterbeck (24, score 4.73), Alidu Seidu (23, score 4.62), and highly-rated teenager Giorgio Scalvini (19, score 4.58).

**Similarity engine:** Queried against our overall top-ranked profile (Sead Kolašinac), the engine returns Mario Gila (97.1% cosine similarity) as the closest tactical alternative, followed by Javi Rodríguez (95.9%) and Facundo Medina (95.3%).

---

## Tactical analysis report

For full player-level breakdowns, cluster case studies, and recruitment shortlists, see the [Tactical analysis report](docs/TACTICAL_ANALYSIS.md).

---

## Generated outputs

### Figures (`outputs/figures/`)
| File | Description |
|------|-------------|
| `defender_archetypes.png` | Progression index vs defending score, coloured by role profile and sized by scouting score |
| `cluster_pca_visualization.png` | 2D PCA projection with K-means cluster assignments |
| `recruitment_value.png` | Age vs scouting score to locate market inefficiencies |

### Tables (`outputs/tables/`)
| File | Description |
|------|-------------|
| `top_recruitment_targets.csv` | Top 25 players by overall scouting score |
| `market_inefficiency_targets.csv` | U-24 players above the 80th percentile scouting score |
| `xt_proxy_ranking.csv` | Top 20 players by progression index |
| `defensive_ranking.csv` | Top 20 players by possession-adjusted defending score |
| `padj_defensive_metrics.csv` | Full master dataset with all context estimates and PAdj stats |
| `cluster_profiles.csv` | Mean statistics per cluster |
| `final_scouting_dashboard.csv` | Full player list with algorithm-assigned tactical roles |
| `player_similarity_results.csv` | Top cosine similarity matches for the target query |

---

## Technologies
- R
- tidyverse (dplyr, readr, tidyr)
- ggplot2, ggrepel
- factoextra, cluster
- proxy (cosine similarity)

---

## Repository structure


```

football-data-analysis/
│
├── data/
│   ├── All_Players_1992-2025.csv
│   └── processed/
│
├── outputs/
│   ├── figures/
│   └── tables/
│
├── scripts/
│   ├── setup_packages.R
│   ├── scripts_scouting.R
│   ├── scripts_padj_metrics.R
│   ├── scripts_clustering.R
│   ├── scripts_similarity_engine.R
│   └── run_all.R
│
├── docs/
│   └── TACTICAL_ANALYSIS.md
│
├── README.md
└── .gitignore

```

---

## Author

**Adrián Gómez Conde**

MSc Biostatistics candidate

Statistical modelling · multivariate analysis · applied sports analytics

Ya tienes la versión en inglés lista. Si quieres, envíale el enlace de GitHub actualizado a ese *recruiter* del Levante UD. Con el nivel de detalle que tiene ahora el código y la documentación, no hay director de datos que le pueda poner una pega.
