[![es](https://img.shields.io/badge/lang-es-yellow.svg)](README.es.md)
[![R](https://img.shields.io/badge/made%20with-R-276DC3.svg)](https://www.r-project.org/)
[![License: MIT](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

# Identifying modern centre-backs with strong ball-progression capabilities

> Applied multivariate scouting framework in R to profile, rank, and find statistical replacements for centre-backs across Europe's top five leagues.

The pipeline combines possession-adjusted defensive metrics, PCA-driven feature weighting, K-means clustering, and cosine similarity to move beyond raw counting stats and surface genuinely context-aware recruitment targets.

---

## Data and scope

| | |
|---|---|
| **Source** | `data/All_Players_1992-2025.csv` — 92,170 player-season rows, Europe's big-five leagues |
| **Analysis window** | Seasons from 2023–24 onwards |
| **Unit of analysis** | One row per player: **their most recent qualifying season** |
| **Final sample** | **407 centre-backs** — 286 from 2024–25, 121 from 2023–24 |

Because each player enters with their latest qualifying season, the sample **mixes two campaigns**. This keeps every profile at its most current form — the priority for a recruitment tool — but it means the ranking is not a strictly like-for-like single-season comparison. See [Limitations](#limitations).

**Sample funnel**

| Step | Rows remaining |
|------|----------------|
| Player-seasons from 2023–24 onwards | 6,997 |
| Primary position `DF` (hybrid `MF`/`FW` excluded), ≥ 900 minutes | 1,104 |
| Positional filters: crosses/90 < 0.8, progressive receptions/90 < 3.56 (p75), attacking-third touches/90 < 0.20 (p75) | 570 |
| Most recent season per player | **407 unique players** |

The last two positional filters exist to strip out full-backs and wing-backs that the source data still labels `DF`.

---

## Methodology

### 1. Feature engineering
All metrics are normalised per 90 minutes. The composite indicators are:

- **Progression index** — weighted combination of progressive passes, progressive carries, and key passes per 90. Weights are not hand-picked: they are the normalised absolute PC1 loadings of a PCA on those three variables (**0.346**, **0.352**, **0.302** respectively).
- **Possession-adjusted defending (PAdj)** — team possession is estimated from passing volume relative to the league average, then a sigmoidal multiplier `2 / (1 + exp(-0.1 × (possession − 50)))` rescales tackles, interceptions, and recoveries. Defenders in dominant sides get fewer defensive opportunities, so their raw counts are adjusted upwards.
- **Scouting score** — the master ranking metric:

  ```
  scouting_score = progression_index      × 0.40
                 + PAdj_defending_score   × 0.30
                 + (pass_completion / 100) × 0.10
                 + age_score               × 0.20
  ```

  The age curve rewards peak windows (`≤24 → 1.00`, `≤28 → 0.95`, `≤31 → 0.85`, `≤33 → 0.70`, else `0.50`).

### 2. Clustering and tactical roles
Players are segmented into four archetypes with K-means (`k = 4`, `nstart = 50`, `set.seed(123)`) on z-scored progression and PAdj defensive variables. Role labels are **not hardcoded** — the pipeline reads the cluster centroids and assigns names by elimination (highest progression → *Elite Progressive Distributor*, then highest defensive volume → *High-Intensity Ball-Winner*, then lowest progression → *Limited / Reactive Defender*, remainder → *Standard Build-up Distributor*).

### 3. Similarity engine
A cosine-similarity function over the standardised feature space. It takes any target player's name and returns the closest statistical matches, for succession planning.

---

## Key findings

**Top scouting scores** — Sead Kolašinac (Atalanta, **5.08**) tops the master ranking, followed by Riccardo Calafiori (Bologna, **4.98**) and Timo Hübers (Köln, **4.84**).

**Progression leaders** — Iñigo Martínez (Barcelona, **4.31**) dominates the progression index, combining a very high progressive-pass volume with elite carrying. Nico Schlotterbeck (Dortmund, **3.90**) is the runner-up reference point.

**Possession-adjusted defending** — after normalising for team dominance, Timo Hübers (**13.31** combined PAdj) and Riccardo Calafiori (**13.18**) emerge as the most active ball-winners in the sample.

**U-24 market targets** — Riccardo Calafiori (21, 4.98) is the standout. Other elite young profiles flagged by the algorithm: Nico Schlotterbeck (24, 4.73), Alidu Seidu (23, 4.62), Wilfried Singo (23, 4.60), and Giorgio Scalvini (19, 4.58).

**Similarity engine** — queried against the top-ranked profile (Sead Kolašinac), the engine returns Mario Gila (**97.1%** cosine similarity), Javi Rodríguez (95.9%), and Facundo Medina (95.3%).

**Archetype distribution** — Limited / Reactive Defender (145), Standard Build-up Distributor (117), High-Intensity Ball-Winner (97), Elite Progressive Distributor (48).

For full player-level breakdowns, cluster case studies, and recruitment shortlists, see the **[tactical analysis report](docs/TACTICAL_ANALYSIS.md)**.

---

## Figures

**Progression vs possession-adjusted defending**, coloured by algorithmic role and sized by scouting score. The separation between distributors (right) and ball-winners (top) is what the composite score trades off.

![Defender archetypes](outputs/figures/defender_archetypes.png)

**K-means archetypes projected onto the first two principal components.** Only the top 15 by scouting score are labelled.

![Cluster PCA projection](outputs/figures/cluster_pca_visualization.png)

**Age vs scouting score.** The upper-left region — young players with high composite scores — is where the recruitment value sits.

![Recruitment value by age](outputs/figures/recruitment_value.png)

---

## Reproducing the analysis

Requires R (≥ 4.1) and three packages:

```bash
Rscript -e "install.packages(c('tidyverse','ggrepel','proxy'), repos='https://cloud.r-project.org')"
```

Then, from the repository root:

```bash
Rscript scripts/run_all.R
```

The pipeline is deterministic (`set.seed(123)` for K-means) and regenerates every file in `outputs/`. Steps run in order and stop on the first error, since each one consumes the previous one's output.

---

## Generated outputs

### Figures (`outputs/figures/`)
| File | Description |
|------|-------------|
| `defender_archetypes.png` | Progression index vs defending score, coloured by role profile and sized by scouting score |
| `cluster_pca_visualization.png` | 2D PCA projection with K-means archetypes, top 15 labelled |
| `recruitment_value.png` | Age vs scouting score, to locate market inefficiencies |

### Tables (`outputs/tables/`)
| File | Description |
|------|-------------|
| `top_recruitment_targets.csv` | Top 25 players by overall scouting score |
| `market_inefficiency_targets.csv` | U-24 players above the 80th percentile scouting score |
| `xt_proxy_ranking.csv` | Top 20 players by progression index |
| `defensive_ranking.csv` | Top 20 players by possession-adjusted defending score |
| `padj_defensive_metrics.csv` | Full master dataset with all context estimates and PAdj stats |
| `cluster_profiles.csv` | Mean statistics per cluster / assigned role |
| `final_scouting_dashboard.csv` | Full player list with algorithm-assigned tactical roles |
| `player_similarity_results.csv` | Top cosine-similarity matches for the target query |

---

## Limitations

Stated explicitly, because they bound how the ranking should be read:

- **Possession is a proxy, not a measurement.** It is inferred from team passing volume against the league average, so a low-possession side that passes a lot short will be overestimated. True possession data would replace this step directly.
- **The sample mixes two seasons.** Players are compared at their most recent qualifying campaign, which is the right choice for current form but not for a clean cross-section.
- **The composite weights are analyst-set, not fitted.** The 40/30/10/20 split and the age curve encode a recruitment philosophy; they are not estimated against any outcome such as transfer value or minutes earned.
- **`k = 4` is chosen a priori**, not selected by silhouette or gap statistic.
- **Mid-season transfers** are handled at row level by the source data; a player's PAdj context reflects the squad on that row only.
- **The model is blind to** availability and injury history, aerial duels, defensive errors, contract situation, and market value. It is a shortlisting tool, not a signing decision.

---

## Technologies

- R
- tidyverse (dplyr, tibble, ggplot2)
- ggrepel
- proxy (cosine similarity)

---

## Repository structure

```
football-data-analysis/
│
├── data/
│   ├── All_Players_1992-2025.csv        # raw source dataset
│   ├── player_stats_2024_2025.csv       # slim single-season extract
│   └── processed/
│       ├── defenders_processed.csv      # scored master table
│       └── team_possession_proxy.csv    # possession estimates + PAdj multipliers
│
├── scripts/
│   ├── setup_packages.R                 # dependency check
│   ├── scripts_padj_metrics.R           # possession proxy + PAdj multipliers
│   ├── scripts_scouting.R               # filtering, PCA weights, composite scores
│   ├── scripts_clustering.R             # K-means, role assignment, figures
│   ├── scripts_similarity_engine.R      # cosine similarity
│   └── run_all.R                        # master pipeline
│
├── outputs/
│   ├── figures/
│   └── tables/
│
├── docs/
│   ├── TACTICAL_ANALYSIS.md
│   └── TACTICAL_ANALYSIS.es.md
│
├── README.md
├── README.es.md
└── LICENSE
```

---

## License

Released under the [MIT License](LICENSE).

---

## Author

**Adrián Gómez Conde**

MSc Biostatistics candidate

Statistical modelling · multivariate analysis · applied sports analytics
