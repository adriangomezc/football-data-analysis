[![es](https://img.shields.io/badge/lang-es-yellow.svg)](README_es.md)

# Identifying modern centre-backs with strong ball-progression capabilities

> Applied multivariate scouting framework in R to profile, rank, and find statistical replacements for centre-backs and defensive profiles across Europe's top five leagues (2023–24 season).

The pipeline combines possession-adjusted defensive metrics, PCA-driven feature weighting, K-means clustering, and cosine similarity to move beyond raw counting stats and surface genuinely context-aware recruitment targets.

---

## Methodology

### 1. Data filtering and aggregation

The player pool was filtered to ensure positional accuracy and statistical significance:

- Primary position: Central Defender (DF). Hybrid MF/FW profiles excluded.
- Minimum threshold: 900 minutes played.
- Additional positional filters applied on progressive-receiving and attacking-third touch rates to remove wing-backs and overlapping fullbacks disguised as centre-backs.

### 2. Feature engineering

All metrics normalised per 90 minutes. Key composite indicators:

- **Progression index:** Weighted combination of progressive passes, progressive carries, and key passes per 90. Weights derived empirically from PC1 loadings of a PCA on the three raw variables.
- **Defending score (raw):** Sum of tackles, interceptions, and recoveries per 90. Used in the scouting score and defensive ranking.
- **Possession-adjusted defending (PAdj):** Team possession estimated from relative league passing volume. Tackles and interceptions then divided by `(opponent_possession / 50)` to normalise defensive intensity per true defensive opportunity.
- **Scouting score:** Master ranking metric. Formula: `(progression_index × 0.4) + (defending_score × 0.3) + (pass_completion / 100 × 0.1) + (age_score × 0.2)`. Age score runs from 1.0 (≤21) to 0.3 (>30).

> **Note:** The scouting score uses the raw defending score (not PAdj). PAdj metrics are used separately in the clustering and the PAdj defensive ranking. This is an acknowledged limitation — a future iteration should integrate PAdj into the master score.

### 3. Standardisation

All variables z-score scaled before any multivariate analysis to prevent scale differences from distorting results.

### 4. K-means clustering and PCA projection

Players segmented into four tactical archetypes (k=4, nstart=50, seed=123). Cluster centres visualised via 2D PCA projection.

### 5. Cosine similarity engine

Non-parametric recommendation system built on the standardised feature space. Identifies the closest statistical profiles to any target player for succession planning and recruitment shortlisting.

---

## Key findings

**Top scouting scores:** Alidu Seidu (Clermont Foot, 4.79) leads overall, followed by Leonardo Balerdi (Marseille, 4.64) and Tim Siersleben (Heidenheim, 4.34). The top three are all aged 23–24.

**Progression leaders:** Joseph Okumu (Reims, 2.67) and Ladislav Krejčí (Girona, 2.42) top the progression index, combining high progressive pass volume with consistent carrying. Virgil Van Dijk (2.28) appears here as a benchmark reference.

**Possession-adjusted defending:** After normalising for defensive opportunity, Tim Siersleben (padj tackles 7.39 + padj interceptions 5.75 = 13.15) and Alidu Seidu (11.68) emerge as the most intense ball-winners in the sample. Both play for teams with estimated possession around 80%, meaning their raw numbers significantly understate their actual defensive workload.

**Tactical archetypes (k=4, 157 players):**

| Cluster | Players | Profile | Avg prog. passes/90 | Avg PAdj tackles/90 | Avg pass% |
|---------|---------|---------|---------------------|---------------------|-----------|
| 1 | 48 | Reactive defenders, limited on-ball role | 1.82 | 1.86 | 85.6 |
| 2 | 62 | Standard build-up distributors | 2.86 | 1.52 | 86.3 |
| 3 | 13 | High-intensity ball-winners | 2.68 | 4.38 | 84.4 |
| 4 | 34 | Elite progressive distributors | 4.21 | 1.66 | 86.7 |

**U-24 market targets:** Seidu, Balerdi, and Siersleben all qualify. Younger standouts include Lucas Beraldo (PSG, age 20, score 3.70), Willian Pacho (PSG, age 22, score 3.69), and Yarek Gasiorowski (Valencia, age 19, score 3.39).

**Similarity engine:** Queried against the top-ranked profile (Alidu Seidu), the engine returns Murillo (93.0% cosine similarity) as the closest statistical match, followed by Santiago Mouriño (89.1%) and Mickael Nade (87.3%).

---

## Tactical analysis report

For full player-level breakdowns, cluster case studies, and recruitment shortlists, see the [Tactical Analysis Report](TACTICAL_ANALYSIS.md).

---

## Generated outputs

### Figures (`outputs/figures/`)

| File | Description |
|------|-------------|
| `defender_archetypes.png` | Progression index vs defending score, coloured by role profile and sized by scouting score |
| `cluster_pca_visualization.png` | 2D PCA projection with K-means cluster assignments |
| `recruitment_value.png` | Age vs scouting score to locate market inefficiencies |
| `padj_defensive_profile.png` | PAdj tackles vs PAdj interceptions, coloured by league |

### Tables (`outputs/tables/`)

| File | Description |
|------|-------------|
| `scouting_dashboard.csv` | Full player list with all engineered metrics and scores |
| `top_recruitment_targets.csv` | Top 25 players by scouting score |
| `market_inefficiency_targets.csv` | U-24 players above 80th percentile scouting score |
| `xt_proxy_ranking.csv` | Top 20 players by progression index |
| `defensive_ranking.csv` | Top 20 players by raw defending score |
| `padj_defensive_metrics.csv` | Full dataset with team possession estimates and PAdj stats |
| `cluster_profiles.csv` | Mean statistics per cluster |
| `player_cluster_assignments.csv` | Per-player cluster assignment |
| `player_similarity_results.csv` | Top 10 cosine similarity matches for the top-ranked player |

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
