[![es](https://img.shields.io/badge/lang-es-yellow.svg)](README.es.md)
# Identifying modern centre-backs with strong ball-progression capabilities

This project applies a multivariate statistical scouting framework to identify, profile, and evaluate modern centre-backs and defensive profiles across Europe's top leagues. Moving beyond basic descriptive statistics, this engine integrates possession-adjusted defensive indicators, dimensionality reduction techniques for feature weighting, and cosine similarity algorithms to establish robust tactical arquetypes and uncover high-value recruitment targets.

The pipeline is explicitly optimized to work with aggregate, season-level data (FBref), filtering and contextualizing performance to isolate stable performance patterns over recent seasons.

---

## Methodology

### 1. Data filtering and aggregation
To ensure statistical significance, positional accuracy, and relevance, the player pool was filtered using the following parameters:
* Primary position: Central Defender (DF) and defensive hybrid profiles.
* Minimum threshold of 900 minutes played per season.
* Longitudinal aggregation of the last few seasons to establish a stable performance baseline and mitigate variance from small sample sizes.

### 2. Feature engineering and metrics
Raw data metrics were normalized per 90 minutes and used to build the following composite tactical indicators:
* **Possession-adjusted defending (PAdj):** Team possession was mathematically estimated based on relative league passing volume. Defensive actions (tackles and interceptions) were then adjusted against opponent possession to isolate true defensive intensity per opportunity. This eliminates the inherent counting bias where defenders in low-possession teams artificially accumulate more actions.
* **Progression index (xT proxy):** In the absence of coordinate-based event data, a weighted baseline of progressive passes (60%) and progressive carries (40%) was implemented to measure vertical territory gain and progression threat.
* **Progression score:** A comprehensive on-ball metric combining progressive passes, progressive carries, and key pases.
* **Scouting score:** A master selection metric balancing ball progression, possession-adjusted defensive output (including recoveries), passing security, and an integrated age modifier to prioritize young, high-value developmental profiles.

### 3. Standardization
All engineered variables were standardized using z-score scaling prior to any multivariate analysis. This ensures equal weighting across different statistical scales, such as comparing overall passing accuracy percentages against absolute defensive action counts.

### 4. K-means clustering and PCA projection
Players were segmented into four distinct tactical roles based on their multivariate profile. To eliminate subjectivity in the creation of composite metrics, the weights for the `progression_score` were derived dynamically from the loadings of the first principal component (PC1) of a PCA. This mathematically assigned 25.23% to progressive pases, 37.27% to progressive carries, and 37.50% to key pases.

Principal Component Analysis (PCA) was subsequently used to project these multi-dimensional profiles into a 2D visual space, facilitating the interpretation of latent tactical structures.

### 5. Player similarity engine
A non-parametric recommendation system was built using cosine similarity on the standardized feature space. By measuring the multi-dimensional distance between player profiles, the engine identifies statistical "clones," providing objective, data-driven alternatives for squad succession planning and recruitment.

---

## Key findings

* **Territorial progression threat:** The progression index isolates deep-lying playmakers who act as primary build-up directors. **Oleksandr Zinchenko** leads the continent in vertical progression volume with an index of 8.01, followed closely by highly offensive profiles like Achraf Hakimi (7.03) and Joshua Kimmich (6.60).
* **Defensive context normalization:** Applying the PAdj formula alongside recoveries reveals high-intensity ball-winners in dominant teams whose contributions are typically masked by high possession. **Alidu Seidu** (13.05) and **Mats Wieffer** (12.67) lead this ranking, while **Eduardo Camavinga** scales to an elite 12.34 defending score due to Real Madrid's structural dominance.
* **Tactical archetypes:** The clustering algorithm defined four clear profiles. Notably, **Cluster 2 (Elite Progressive - 163 players)** captures build-up anchors averaging 5.77 progressive passes per 90 and the highest average xT proxy (4.15). Conversely, **Cluster 3 (Traditional Destroyers - 119 players)** isolates reactive defenders who average 4.53 PAdj tackles but post the lowest passing accuracy (78.84%).
* **U-24 recruitment inefficiencies:** Plotting the composite scouting score against age highlights outstanding developmental anomalies. Teenagers like **Soungoutou Magassa** (19 years old, 4.79 score) and **João Neves** (19 years old, 4.56 score) show progression, retention, and defensive intervention baselines that match prime-age veterans.
* **Succession planning accuracy:** The similarity matrix isolates direct replacements without market-value bias. The engine matches **Jon Pacheco** as a 99.98% statistical clone for specific ball-playing centre-back roles, and lists **Juan David Cabal** (94.2%) as the primary alternative for versatile, progressive defensive profiles.

---

## Tactical analysis report

For a comprehensive tactical breakdown of player profiles, specific recruitment shortlists, case studies, and full analytical insights, please read the complete **[Tactical Analysis and Profiling Report](https://github.com/adriangomezc/football-data-analysis/blob/main/docs/TACTICAL_ANALYSIS.md)**.

---

## Results and generated files

The pipeline automatically outputs a total of 14 files, distributed between analytical visualizations and structured data exports:

### Visualizations (`outputs/figures/`)
* `defender_archetypes.jpg`: Scatter plot mapping the market based on progression capability versus defensive volume.
* `cluster_pca_visualization.jpg`: 2D projection of the PCA space displaying player distribution color-coded by tactical archetype.
* `recruitment_value.jpg`: Scatter plot of player age versus composite scouting score to isolate market inefficiencies.
* `padj_defensive_profile.jpg`: Visual mapping of contextualized defensive output (PAdj tackles vs. PAdj interceptions).

### Data exports (`outputs/tables/`)
* `top_recruitment_targets.csv`: General ranking of the top-performing defensive profiles based on the master scouting score.
* `market_inefficiency_targets.csv`: Filtered list isolating under-24 prospects performing above the 80th percentile.
* `player_similarity.csv`: Full cross-product matrix containing the cosine similarity scores between all players in the database.
* `player_similarity_results.csv`: Targeted list containing the closest statistical matches and percentage scores for specific queried profiles.
* `cluster_profiles.csv`: Summary statistics table outlining the mean baselines that define each of the four tactical groups.
* `player_cluster_assignments.csv`: Complete roster of analyzed players with their respective K-means cluster assignment.
* `xt_proxy_ranking.csv`: Specialized ranking sorting the top defenders by vertical progression and line-breaking volume.
* `defensive_ranking.csv`: Sorting of the most active ball-winners based on the indexed sum of PAdj tackles, interceptions, and recoveries.
* `padj_defensive_metrics.csv`: Core processed working data containing the estimated team possession values and adjusted defensive stats.
* `scouting_dashboard.csv`: Master data matrix compiling all engineered indicators, ready for deployment in visualization tools (Tableau, PowerBI).

---

## Technologies

* R
* tidyverse (dplyr, readr, tidyr)
* ggplot2, ggrepel
* factoextra, cluster
* proxy / coop (Cosine similarity matrix calculations)

---

## Repository structure

```text
football-data-analysis/
│
├── data/
│   ├── raw/
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

# Author

Adrián Gómez Conde

MSc Biostatistics candidate
Statistical modelling, multivariate analysis and applied sports analytics
