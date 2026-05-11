# Identifying Modern Ball-Playing Centre-Backs

This project applies statistical profiling, PCA and clustering to identify modern centre-backs who combine defensive solidity with progressive ball progression.

The analysis uses FBref-style player data and focuses on defenders under 28 with sufficient minutes played.

---

# Project objective

Modern football increasingly demands centre-backs who:

- defend proactively  
- progress the ball under pressure  
- contribute to build-up play  

This project identifies those profiles using a combination of:

- per-90 statistical metrics  
- a weighted scouting score  
- multivariate clustering  

---

# Methodology

## Filtering
- Position = DF  
- Age ≤ 28  
- Min ≥ 900  
- Low crossing volume (anti-fullback filter)

## Custom metrics
- Progression per 90 = progressive passes + progressive carries  
- Defensive actions per 90 = tackles + interceptions + recoveries  
- Modern CB score = weighted combination of progression, defense and key passes  

---

# Advanced analysis

## PCA + k-means clustering
To demonstrate multivariate profiling:

- PCA reduces the metric space  
- K-means groups defenders into distinct archetypes  
- Clusters reveal different tactical profiles  

---

# Outputs

- `outputs/modern_cb_scouting.png` → scouting matrix  
- `outputs/pca_clusters.png` → PCA clustering  
- `outputs/top15_modern_cb.csv` → top ranked players  
- `outputs/clustered_defenders.csv` → full dataset with cluster labels  

---

# Technologies

- R  
- tidyverse  
- ggplot2  
- ggrepel  
- viridis  
- factoextra  

---

# Author

Adrián Gómez Conde  
MSc Biostatistics candidate | Statistical modelling and data analysis
