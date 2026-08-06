[![es](https://img.shields.io/badge/lang-es-yellow.svg)](README.es.md)
[![R](https://img.shields.io/badge/made%20with-R-276DC3.svg)](https://www.r-project.org/)
[![License: MIT](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

# Identifying modern centre-backs with strong ball-progression capabilities

> Applied multivariate scouting framework in R to profile, rank, and find statistical replacements for centre-backs across Europe's top five leagues — with the composite score validated out-of-time against real 2024-25 outcomes.

The pipeline combines possession-adjusted defensive metrics, PCA-driven feature weighting, K-means clustering, and cosine similarity to move beyond raw counting stats and surface genuinely context-aware recruitment targets. Every design choice that is normally left unexamined in a scouting model — the number of clusters, the redundancy between inputs, whether the score predicts anything real — is checked and reported below, including where the checks come back negative.

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

The last two positional filters exist to strip out full-backs and wing-backs that the source data still labels `DF`. A multivariate outlier screen (Mahalanobis D², see [Statistical diagnostics](#statistical-diagnostics)) flags 20 of the 407 as statistically atypical combinations of these filtering variables — they are reported, not removed, since "atypical" is not the same as "wrong".

---

## Methodology

### 1. Feature engineering
All metrics are normalised per 90 minutes. The composite indicators are:

- **Progression index** — weighted combination of progressive passes, progressive carries, and key passes per 90. Weights are not hand-picked: they are the normalised absolute PC1 loadings of a PCA on those three variables (**0.346**, **0.352**, **0.302** respectively). PC1 explains **66.4%** of the joint variance of the three inputs, which is what justifies collapsing them onto a single weighted axis instead of, say, keeping the first two components.
- **Possession-adjusted defending (PAdj)** — team possession is estimated from passing volume relative to the league average, then a sigmoidal multiplier `2 / (1 + exp(-0.1 × (possession − 50)))` rescales tackles, interceptions, and recoveries. Defenders in dominant sides get fewer defensive opportunities, so their raw counts are adjusted upwards.
- **Scouting score** — the master ranking metric:

  ```
  scouting_score = progression_index      × 0.40
                 + PAdj_defending_score   × 0.30
                 + (pass_completion / 100) × 0.10
                 + age_score               × 0.20
  ```

  The age curve rewards peak windows (`≤24 → 1.00`, `≤28 → 0.95`, `≤31 → 0.85`, `≤33 → 0.70`, else `0.50`). A VIF check confirms the four pillars aren't redundant with each other (all VIF ≤ 1.13 — see diagnostics below), so each one is contributing distinct information rather than double-counting the same signal.

### 2. Clustering and tactical roles
Players are segmented into four archetypes with K-means (`k = 4`, `nstart = 50`, `set.seed(123)`) on z-scored progression and PAdj defensive variables. Role labels are **not hardcoded** — the pipeline reads the cluster centroids and assigns names by elimination (highest progression → *Elite Progressive Distributor*, then highest defensive volume → *High-Intensity Ball-Winner*, then lowest progression → *Limited / Reactive Defender*, remainder → *Standard Build-up Distributor*). `k = 4` is a deliberate, disclosed choice rather than a default — see [Statistical diagnostics](#statistical-diagnostics) for the elbow/silhouette evidence behind it.

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

## Statistical diagnostics

Checks that are usually left implicit in a scouting index, run and reported explicitly:

| Diagnostic | Method | Result | Verdict |
|---|---|---|---|
| Multivariate outlier screen | Mahalanobis D² vs. cutoff k+3√(2k) on the 7 filtering/scoring inputs | 20 / 407 players (4.9%) flagged | Reported, not removed — see [`qc_mahalanobis_outliers.csv`](outputs/tables/qc_mahalanobis_outliers.csv) |
| PCA weight justification | Variance explained by PC1 of the 3 progression inputs | PC1 = 66.4%, PC2 = 21.0%, PC3 = 12.6% | PC1 dominance supports using only its loadings as weights |
| Multicollinearity | VIF on each group of composite inputs (`car::vif`) | All VIF ≤ 1.75 (threshold for concern: 10) | No redundancy between inputs at any level of the score |
| Cluster count (`k`) | Elbow (WSS) + silhouette across k = 2–8 | Statistical optimum k = 2 (silhouette 0.335); k = 4 used has silhouette 0.241 | k = 4 is a disclosed interpretability trade-off, not the statistical maximum — see figure below |
| Cluster validity | K-means vs. independent hierarchical clustering (Ward's method) | Adjusted Rand Index = 0.419, cophenetic correlation = 0.586, 75.2% row-agreement | Moderate, non-trivial agreement between two unrelated algorithms — the 4 archetypes are a real, if not sharply separated, structure |

![K selection diagnostics](outputs/figures/cluster_k_selection.png)

**On the `k = 4` trade-off:** the silhouette method's global optimum is k = 2, which collapses the sample into essentially "progressive vs. limited" — a much coarser split than the four-role tactical narrative the rest of this project builds on. Silhouette width at k = 4 (0.241) sits at the boundary of what Kaufman & Rousseeuw's rule of thumb calls "weak structure" (< 0.25). This is disclosed rather than hidden: the four archetypes are chosen for scouting-relevant granularity, and the hierarchical cross-check (ARI 0.419) shows they are a real if moderate signal in the data, not a K-means artefact.

---

## Model validation

A scouting score is only as useful as its ability to say something true about players it hasn't seen. To test this, the whole pipeline was refit using **only 2023-24 data** (PCA weights included, to avoid leaking 2024-25 information), then checked against what actually happened the following season — a genuine temporal train/test split, not random k-fold, since the ordering of time is exactly what must not leak.

**Setup:** 278 centre-backs active in 2023-24. Outcome: did the player play ≥ 900 minutes in 2024-25 (`retained`)? 64.0% did.

| Model | Predictor(s) | Key result | AIC |
|---|---|---|---|
| Intercept only | — | baseline | 365.2 |
| Logistic regression | `scouting_score` | OR = 1.28 (95% CI 0.85–1.97), **p = 0.24 — not significant** | 365.8 |
| Logistic regression | 4 components separately | `age_score` OR = 22.6, **p = 0.001**; `progression_index` OR = 1.60, p = 0.053; `defending_score` and `pass_completion` not significant | 354.2 |

**Headline result: the composite `scouting_score` does not significantly predict whether a player keeps playing next season** (McFadden pseudo-R² = 0.004 — essentially none). Among players who *were* retained, their score doesn't correlate with how many minutes they went on to play either (Spearman ρ = −0.01, p = 0.90).

**Why, and why that's not a failure of the score:** decomposing the composite into its four inputs shows exactly where the signal is. `age_score` alone is a strong, highly significant predictor of retention (older players are less likely to still be playing next season — an unsurprising career-stage effect). But `age_score` only carries **20%** of the composite's weight by design, because the score is built to rank *footballing ability*, not to predict *survival in the sample*. Diluting a strong age signal with 80% weight on ability metrics that don't predict short-term retention is exactly what should happen if the score is doing its intended job. A likelihood-ratio test confirms this: the 4-parameter unconstrained model fits significantly better than the 1-parameter constrained composite (χ² LRT, p < 0.001) — the fixed 40/30/10/20 weighting is a real, measurable constraint, not a free lunch.

As a descriptive cross-check (not causal), retention rate does line up with the algorithm's own archetypes: Elite Progressive Distributor 70.6% (n=34), Standard Build-up Distributor 69.8% (n=86), High-Intensity Ball-Winner 66.1% (n=59), Limited / Reactive Defender 55.6% (n=99).

![Temporal validation](outputs/figures/temporal_validation.png)

**What this validation does and doesn't show:** "played 900+ minutes next season" is a weak, indirect proxy for scouting quality — it's driven at least as much by injuries, squad depth, and a manager's system as by ability, and a great scouting profile does not guarantee a starting shirt at the buying club. A null result here does not mean the score is wrong; it means crude retention is the wrong target to validate it against, and that limitation is now explicit rather than assumed away. Full model output: [`temporal_validation_results.csv`](outputs/tables/temporal_validation_results.csv).

---

## Reproducing the analysis

Requires R (≥ 4.1) and five packages (two of them, `car` and `cluster`, are used only via `::` and never attached, to avoid `car`'s dependency `MASS` silently masking `dplyr::select()`):

```bash
Rscript -e "install.packages(c('tidyverse','ggrepel','proxy','factoextra','car'), repos='https://cloud.r-project.org')"
```

Then, from the repository root:

```bash
Rscript scripts/run_all.R
```

The pipeline is deterministic (`set.seed(123)` for every K-means run) and regenerates every file in `outputs/` in six steps: dependency check → possession proxy → scoring → clustering → similarity engine → **temporal validation**. Steps run in order and stop on the first error, since each one consumes the previous one's output.

**Optional, manual step:** `scripts/scripts_optional_real_possession.R` replaces the estimated possession proxy with real FBref possession percentages via the [`worldfootballR`](https://jaseziv.github.io/worldfootballR/) package. It is not part of `run_all.R` and cannot run in a sandboxed/CI environment — FBref blocks data-centre IPs with Cloudflare (confirmed while building this pipeline) — but it runs from a normal residential connection. See the comments at the top of the script for exactly how to plug its output back into the pipeline.

---

## Generated outputs

### Figures (`outputs/figures/`)
| File | Description |
|------|-------------|
| `defender_archetypes.png` | Progression index vs defending score, coloured by role profile and sized by scouting score |
| `cluster_pca_visualization.png` | 2D PCA projection with K-means archetypes, top 15 labelled |
| `recruitment_value.png` | Age vs scouting score, to locate market inefficiencies |
| `cluster_k_selection.png` | Elbow (WSS) and silhouette diagnostics behind the choice of k = 4 |
| `temporal_validation.png` | Logistic fit of 2024-25 retention against the 2023-24 scouting score |

### Tables (`outputs/tables/`)
| File | Description |
|------|-------------|
| `top_recruitment_targets.csv` | Top 25 players by overall scouting score |
| `market_inefficiency_targets.csv` | U-24 players above the 80th percentile scouting score |
| `progression_ranking.csv` | Top 20 players by progression index |
| `defensive_ranking.csv` | Top 20 players by possession-adjusted defending score |
| `padj_defensive_metrics.csv` | Full master dataset with all context estimates and PAdj stats |
| `cluster_profiles.csv` | Mean statistics per cluster / assigned role |
| `final_scouting_dashboard.csv` | Full player list with algorithm-assigned tactical roles |
| `player_similarity_results.csv` | Top cosine-similarity matches for the target query |
| `qc_mahalanobis_outliers.csv` | Multivariate outlier screen (flagged, not removed) |
| `pca_variance_explained.csv` | Variance explained per component, progression PCA |
| `vif_diagnostics.csv` | Multicollinearity check for every group of composite inputs |
| `cluster_k_selection.csv` | WSS and mean silhouette width for k = 2–8 |
| `kmeans_vs_hierarchical_agreement.csv` | K-means vs. hierarchical clustering contingency table |
| `temporal_validation_results.csv` | Full GLM output (train 2023-24 / test 2024-25) |
| `temporal_validation_predictions.csv` | Per-player prediction data behind the validation |
| `temporal_validation_retention_by_role.csv` | Retention rate by tactical archetype |

---

## Limitations

Stated explicitly, because they bound how the ranking should be read:

- **Possession is a proxy, not a measurement.** It is inferred from team passing volume against the league average, so a low-possession side that passes a lot short will be overestimated. `scripts/scripts_optional_real_possession.R` replaces it with real FBref data, but only when run locally (see [Reproducing the analysis](#reproducing-the-analysis)).
- **The sample mixes two seasons.** Players are compared at their most recent qualifying campaign, which is the right choice for current form but not for a clean cross-section.
- **The composite weights are analyst-set, not statistically fitted.** The 40/30/10/20 split and the age curve encode a recruitment philosophy. They are checked for internal redundancy (VIF, all ≤ 1.13) and tested for predictive validity out-of-time (see [Model validation](#model-validation)) — but "checked" is not "optimised"; no outcome variable was used to fit them.
- **`k = 4` is a disclosed trade-off, not the statistical optimum.** Elbow and silhouette both favour k = 2; k = 4 was kept for tactical interpretability, with the hierarchical cross-check (ARI 0.419) as evidence the four-way split still reflects real, if moderate, structure. Full detail in [Statistical diagnostics](#statistical-diagnostics).
- **Next-season minutes are a weak, indirect validation target.** The temporal validation found no significant link between `scouting_score` and 2024-25 retention — expected, since retention is driven by injuries, squad depth, and club context that no scouting metric captures, and the score is deliberately weighted toward ability (80%) over the one component (age) that does predict retention.
- **Mid-season transfers** are handled at row level by the source data; a player's PAdj context reflects the squad on that row only.
- **The model is blind to** availability and injury history, aerial duels, defensive errors, contract situation, and market value. It is a shortlisting tool, not a signing decision.

---

## Technologies

- R
- tidyverse (dplyr, tibble, ggplot2)
- ggrepel
- proxy (cosine similarity)
- cluster (silhouette width, base R "recommended" package)
- car (VIF)
- stats::glm, stats::hclust, stats::mahalanobis, stats::prcomp (base R)
- worldfootballR (optional, local-only real possession data)

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
│   ├── setup_packages.R                     # dependency check
│   ├── scripts_padj_metrics.R               # possession proxy + PAdj multipliers
│   ├── scripts_scouting.R                   # filtering, PCA weights, QC, VIF, composite scores
│   ├── scripts_clustering.R                 # k selection, K-means, hierarchical cross-check, figures
│   ├── scripts_similarity_engine.R          # cosine similarity
│   ├── scripts_temporal_validation.R        # train/test GLM validation (2023-24 -> 2024-25)
│   ├── scripts_optional_real_possession.R   # [optional/manual] real FBref possession via worldfootballR
│   └── run_all.R                            # master pipeline (6 steps)
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
