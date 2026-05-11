# Identifying modern ball-playing centre-backs

This project applies a multivariate statistical scouting framework to identify modern centre-backs capable of combining defensive solidity with progressive ball progression.

The analysis focuses on identifying players who simultaneously contribute to defensive actions, progression through passing/carrying and creative involvement in possession.

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

Several composite variables were constructed to better capture modern centre-back profiles.

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

Measured through pass completion percentage.

---

## 3. Standardisation

All variables were standardised before multivariate analysis using z-score scaling.

---

## 4. Principal component analysis (PCA)

PCA was applied to:

- Reduce dimensionality
- Identify latent player archetypes
- Explore correlations between tactical variables

---

## 5. K-means clustering

K-means clustering was used to identify groups of centre-backs with similar statistical profiles.

The optimal number of clusters was selected using silhouette analysis.

---

# Outputs

## Scouting matrix

`outputs/modern_cb_scouting.png`

Visual representation of defensive intensity vs ball progression.

---

## PCA clusters

`outputs/pca_clusters.png`

Projection of player profiles onto principal component space.

---

## PCA biplot

`outputs/pca_biplot.png`

Interpretation of variable loadings and player archetypes.

---

## Cluster profiles

`outputs/cluster_profiles.csv`

Summary statistics for each tactical cluster.

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
- ggrepel
- viridis

---

# Author

Adrián Gómez Conde

MSc Biostatistics candidate  
Statistical modelling, multivariate analysis and applied sports analytics
