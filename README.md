# Identifying modern ball-playing centre-backs

This project applies a multivariate statistical scouting framework to identify modern centre-backs capable of combining defensive solidity with progressive ball progression.

The analysis focuses on profiling defenders through dimensionality reduction, clustering and composite tactical metrics.

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

Weighted combination of:

- Progressive passes
- Progressive carries

### Defensive intensity

Weighted combination of:

- Tackles
- Interceptions
- Recoveries

### Creative involvement

Measured using key passes per 90.

### Passing security

Measured using pass completion percentage.

### Progressive defender index

Composite variable integrating progression and passing reliability.

### Defensive aggression

Combined tackle and interception volume.

### Ball retention

Proxy metric for possession recovery and passing retention.

---

## 3. Standardisation

All variables were standardised using z-score scaling prior to multivariate analysis.

---

## 4. Principal component analysis (PCA)

PCA was applied to:

- Reduce dimensionality
- Explore latent tactical structures
- Identify relationships between defensive and progression variables
- Visualise player archetypes in reduced-dimensional space

---

## 5. K-means clustering

K-means clustering was used to identify centre-back archetypes with similar tactical profiles.

The optimal number of clusters was selected using silhouette analysis.

---

# Outputs

## Scouting matrix

`outputs/modern_cb_scouting.png`

Multivariate scouting visualization using progression and defensive intensity.

---

## PCA clusters

`outputs/pca_clusters.png`

Projection of player profiles into principal component space.

---

## PCA biplot

`outputs/pca_biplot.png`

Visual interpretation of PCA loadings and tactical relationships.

---

## Correlation heatmap

`outputs/correlation_heatmap.png`

Correlation structure between engineered tactical variables.

---

## Radar chart

`outputs/cluster_radar.png`

Standardized tactical profiles for each cluster.

---

## Cluster profiles

`outputs/cluster_profiles.csv`

Summary statistics for each tactical archetype.

---

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
- fmsb
- ggrepel
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

---

# Author

Adrián Gómez Conde

MSc Biostatistics candidate  
Statistical modelling, multivariate analysis and applied sports analytics
