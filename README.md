# Identifying modern ball-playing centre-backs

This project applies a multivariate statistical scouting framework to identify modern centre-backs capable of combining defensive solidity with progressive ball progression.

The analysis focuses on profiling defenders through dimensionality reduction, clustering, and composite tactical metrics.

---

# Methodology

## 1. Data filtering

Players were filtered using the following criteria:

- Position = DF
- Age ≤ 28
- Minutes played ≥ 900
- Low crossing volume filter to remove full-backs

---

## 2. Feature engineering

Several advanced tactical indicators were constructed from raw event data.

### Ball progression
Weighted combination of progressive passes and progressive carries.

### Defensive intensity
Weighted combination of tackles, interceptions, and recoveries.

### Creative involvement
Measured using key passes per 90.

### Passing security
Measured using pass completion percentage.

### Composite Scoring Note
The overall progressive defender index and final scores were designed as a heuristic tactical indicator rather than a strict predictive performance metric, aiming to flag profiles that fit a specific game model.

---

## 3. Standardisation

All variables were standardised using z-score scaling prior to multivariate analysis.

---

## 4. Principal component analysis (PCA)

PCA was applied to explore latent tactical structures and visualise player archetypes. 

**Interpretation:**
- **PC1** was primarily associated with progression-related variables (progressive passing, carries, and key passes), explaining the variation in build-up responsibility.
- **PC2** captured defensive activity and recovery volume, separating pure ball-winners from passive defenders.

---

## 5. K-means clustering

K-means clustering was used to identify centre-back archetypes with similar tactical profiles. 

Cluster selection was based on strict statistical validation, with the optimal number of clusters ($k=2$) determined via **silhouette optimisation**.

---

# Key findings

The analysis identified two major tactical archetypes among modern centre-backs:

1. **Progressive distributors:** Combined high ball progression, creative involvement, and strong passing security, representing defenders capable of taking the initiative during build-up phases.
2. **Conservative defenders:** Showed lower progression metrics across the board and were characterised by safer, less creative possession profiles, focusing primarily on traditional defensive duties.

The PCA projection confirmed that progression-related metrics explained most of the tactical variability between centre-back profiles in the modern game.

---

# Outputs

## Scouting matrix
`outputs/modern_cb_scouting.png`
Multivariate scouting visualization using progression and defensive intensity.

## Cluster validation
`outputs/silhouette_plot.png`
Statistical justification for the selected $k$ in K-means clustering.

## PCA clusters
`outputs/pca_clusters.png`
Projection of player profiles into principal component space.

## PCA biplot
`outputs/pca_biplot.png`
Visual interpretation of PCA loadings and tactical relationships.

## Tactical profiles heatmap
`outputs/cluster_heatmap.png`
Standardised means of tactical metrics by cluster archetype, visualising the distinct profiles.

## Correlation heatmap
`outputs/correlation_heatmap.png`
Correlation structure between engineered tactical variables.

## Cluster profiles summary
`outputs/cluster_profiles.csv`
Summary statistics for each tactical archetype.

## Top ranked players
`outputs/top15_modern_cb.csv`
Highest scoring centre-backs according to the composite scouting metric.

---

# Technologies

- R
- tidyverse
- ggplot2
- factoextra
- cluster
- corrplot
- ggrepel

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
