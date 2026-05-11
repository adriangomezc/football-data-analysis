# Identifying modern ball-playing centre-backs

This project applies a multivariate statistical scouting framework to identify modern centre-backs capable of combining defensive solidity with progressive ball distribution.

The analysis focuses on profiling defenders through dimensionality reduction, clustering, and composite tactical metrics, moving beyond basic descriptive statistics to establish robust tactical archetypes.

---

# Methodology

## 1. Data filtering

Players were filtered from the 2024/2025 dataset using the following criteria to ensure positional accuracy and sufficient sample size:
- Position = DF
- Age ≤ 28
- Minutes played ≥ 900
- Low crossing volume filter (Crs ≤ 15) to exclude wide full-backs

---

## 2. Feature engineering

Several advanced tactical indicators per 90 minutes were constructed from raw event data:

- **Ball progression:** Weighted combination of progressive passes and progressive carries.
- **Defensive intensity:** Weighted combination of tackles, interceptions, and ball recoveries.
- **Creative involvement:** Measured using key passes per 90.
- **Passing security:** Measured using overall pass completion percentage.

**Note on Composite Scoring:** The overall progressive defender index and final composite scores were designed as a heuristic tactical indicator rather than a strict predictive performance metric. They serve to flag profiles that fit a specific, possession-oriented game model.

---

## 3. Standardisation

All engineered variables were standardised using z-score scaling prior to any multivariate analysis to ensure equal weighting across different statistical scales.

---

## 4. Principal component analysis (PCA)

PCA was applied to explore latent tactical structures and visualise player archetypes in a reduced-dimensional space.

**Interpretation of Components:**
- **PC1** was primarily associated with progression-related variables (progressive passing, carries, and key passes), effectively explaining the variance in a centre-back's responsibility during build-up phases.
- **PC2** captured defensive activity and recovery volume, separating active ball-winners from more passive or positional defenders.

---

## 5. K-means clustering

K-means clustering was used to identify centre-back archetypes with similar tactical profiles. 

The optimal number of clusters ($k=2$) was not chosen arbitrarily; it was strictly validated and selected based on **silhouette analysis optimisation**.

---

# Key findings

The analysis identified two major tactical archetypes among modern centre-backs:

1. **Progressive distributors:** These defenders combined high ball progression, creative involvement, and strong passing security. They represent the modern archetype capable of breaking lines and taking the initiative during build-up phases.
2. **Conservative defenders:** This group showed consistently lower progression and creativity metrics. They are characterised by safer possession profiles and are primarily focused on traditional defensive duties and low-risk distribution.

The PCA projection strongly suggested that progression-related metrics, rather than purely defensive actions, explain most of the variability between centre-back profiles in the modern game.

---

# Outputs

## Scouting matrix
`outputs/modern_cb_scouting.jpg`
Multivariate scouting visualization using progression and defensive intensity to highlight standout profiles.

## Cluster validation
`outputs/silhouette_plot.png`
Statistical justification for the selected $k=2$ in K-means clustering using the silhouette method.

## PCA clusters
`outputs/pca_clusters.jpg`
Projection of player profiles into the principal component space, color-coded by tactical archetype.

## PCA biplot
`outputs/pca_biplot.jpg`
Visual interpretation of PCA loadings and the relationships between tactical variables.

## Tactical profiles heatmap
`outputs/cluster_heatmap.png`
Standardised means of tactical metrics by cluster, cleanly visualising the distinct multivariate profiles of each archetype.

## Correlation heatmap
`outputs/correlation_heatmap.png`
Correlation structure between all engineered tactical variables.

## Data exports
- `outputs/cluster_profiles.csv`: Summary statistics for each tactical archetype.
- `outputs/clustered_defenders.csv`: Full dataset with appended PCA coordinates and cluster assignments.
- `outputs/top15_modern_cb.csv`: Highest scoring centre-backs according to the heuristic composite scouting metric.

---

# Technologies

- R
- tidyverse
- ggplot2
- factoextra
- cluster
- corrplot
- viridis

---

# Repository structure

```text
football-data-analysis/
│
├── data/
├── outputs/
├── scripts/
│   ├── scouting.R
│   └── clustering.R
│
├── README.md
└── .gitignore
```
# Author

Adrián Gómez Conde

MSc Biostatistics candidate  
Statistical modelling, multivariate analysis and applied sports analytics
