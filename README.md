# Identifying modern ball‑playing centre‑backs

This project applies a full multivariate scouting pipeline to identify modern centre‑backs who combine defensive output with progressive ball progression.

---

## Pipeline

1. Feature engineering  
2. Per‑90 normalization  
3. Scaling  
4. PCA  
5. K‑means clustering  
6. Interpretation of clusters  
7. Visualization  

---

## Filters

- Position = DF  
- Age ≤ 28  
- Min ≥ 900  
- Low crossing volume (anti‑fullback filter)

---

## Outputs

- `outputs/modern_cb_scouting.png` → scouting matrix  
- `outputs/pca_clusters.png` → PCA clusters  
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
- cluster  

---

## Author

Adrián Gómez Conde  
MSc Biostatistics candidate | statistical modelling and data analysis
