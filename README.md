# Identifying modern ball-playing centre-backs

This project applies statistical profiling, PCA and clustering to identify modern centre-backs who combine defensive solidity with progressive ball progression.

The analysis uses FBref-style player data and focuses on defenders under 28 with sufficient minutes played.

---

## Project objective

Modern football increasingly demands centre-backs who:

- defend proactively  
- progress the ball under pressure  
- contribute to build-up play  

This project identifies those profiles using:

- per-90 statistical metrics  
- a weighted scouting score  
- multivariate clustering  

---

## Pipeline

1. Feature engineering  
2. Per-90 normalization  
3. Scaling  
4. PCA  
5. K-means clustering  
6. Interpretation of clusters  
7. Visualization  

---

## Methodology

### Filtering
- Position = DF  
- Age ≤ 28  
- Min ≥ 900  
- Low crossing volume (anti-fullback filter)

### Custom metrics
- Progression per 90 = progressive passes + progressive carries  
- Defensive actions per 90 = tackles + interceptions + recoveries  
- Modern CB score = weighted combination of progression, defense and key passes  

---

## Outputs

- `outputs/modern_cb_scouting.png` → scouting matrix  
- `outputs/pca_clusters.png` → PCA clustering  
- `outputs/top15_modern_cb.csv` → top ranked players  
- `outputs/clustered_defenders.csv` → full dataset with cluster labels  
- `outputs/cluster_profiles.csv` → cluster interpretation table  

---

## How to run

```bash
Rscript scripts/scouting.R
Rscript scripts/clustering.R
```

---

## Technologies

- R  
- tidyverse  
- ggplot2  
- ggrepel  
- viridis  

---

## Author

Adrián Gómez Conde  
MSc Biostatistics candidate | statistical modelling and data analysis
