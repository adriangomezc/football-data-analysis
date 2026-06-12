[![en](https://img.shields.io/badge/lang-en-blue.svg)](README.md)

# Identificación de centrales modernos con buena salida de balón

> Framework estadístico multivariante en R para perfilar, clasificar y encontrar sustitutos estadísticos de centrales en las cinco grandes ligas europeas (temporada 2023–24).

El pipeline mezcla métricas defensivas ajustadas por posesión, ponderación de variables mediante PCA, clustering K-means y similitud del coseno para ir más allá de las estadísticas brutas y detectar objetivos de reclutamiento con contexto real.

---

## Metodología

### 1. Filtrado y agregación de datos

La muestra se filtró para garantizar precisión en la posición y relevancia estadística:

- Posición principal: Defensa central (DF). Se excluyen perfiles híbridos MF/FW.
- Umbral mínimo: 900 minutos disputados.
- Filtros adicionales sobre tasas de recepción progresiva y toques en último tercio para eliminar laterales con libertad ofensiva disfrazados de centrales.

### 2. Ingeniería de variables

Todas las métricas normalizadas por 90 minutos:

- **Índice de progresión:** Combinación ponderada de pases progresivos, conducciones progresivas y pases clave por 90. Los pesos se derivan de los loadings del PC1 de un PCA sobre las tres variables originales.
- **Defending score (bruto):** Suma de entradas, intercepciones y recuperaciones por 90. Se usa en el scouting score y el ranking defensivo.
- **Defensa ajustada por posesión (PAdj):** La posesión de equipo se estima a partir del volumen relativo de pases en la liga. Las entradas e intercepciones se dividen entre `(posesión_rival / 50)` para normalizar la intensidad defensiva por oportunidad real.
- **Scouting score:** `(índice_progresión × 0.4) + (defending_score × 0.3) + (precisión_pase / 100 × 0.1) + (age_score × 0.2)`. El age_score va de 1.0 (≤21 años) a 0.3 (>30 años).

> **Nota:** El scouting score usa el defending score bruto (no PAdj). Las métricas PAdj se usan por separado en el clustering y el ranking defensivo ajustado.

### 3. Estandarización

Todas las variables escaladas con z-scores antes de cualquier análisis multivariante para evitar que diferencias de escala distorsionen los resultados.

### 4. Clustering K-means y proyección PCA

Jugadores segmentados en cuatro arquetipos tácticos (k=4, nstart=50, seed=123). Los centros de cluster se visualizan mediante proyección PCA en 2D.

### 5. Motor de similitud del coseno

Sistema de recomendación no paramétrico construido sobre el espacio de características estandarizado. Identifica los perfiles estadísticamente más cercanos a cualquier jugador objetivo.

---

## Hallazgos principales

**Mejores scouting scores:** Alidu Seidu (Clermont Foot, 4.79) lidera el ranking general, seguido de Leonardo Balerdi (Marsella, 4.64) y Tim Siersleben (Heidenheim, 4.34). Los tres tienen entre 23 y 24 años.

**Líderes en progresión:** Joseph Okumu (Reims, 2.67) y Ladislav Krejčí (Girona, 2.42) encabezan el índice de progresión, combinando alto volumen de pases progresivos con conducción consistente.

**Defensa ajustada por posesión:** Tras normalizar por oportunidad defensiva, Tim Siersleben (padj entradas 7.39 + padj intercepciones 5.75 = 13.15) y Alidu Seidu (11.68) emergen como los recuperadores más intensos de la muestra. Ambos juegan en equipos con posesión estimada en torno al 80%, lo que significa que sus cifras brutas infravalorarían significativamente su carga defensiva real.

**Arquetipos tácticos (k=4, 157 jugadores):**

| Cluster | Jugadores | Perfil | Pases prog. medios/90 | Entradas PAdj medias/90 | Precisión media |
|---------|-----------|--------|-----------------------|-------------------------|-----------------|
| 1 | 48 | Defensores reactivos, poco papel con balón | 1.82 | 1.86 | 85.6% |
| 2 | 62 | Distribuidores estándar en construcción | 2.86 | 1.52 | 86.3% |
| 3 | 13 | Destructores de alta intensidad | 2.68 | 4.38 | 84.4% |
| 4 | 34 | Distribuidores progresivos de élite | 4.21 | 1.66 | 86.7% |

**Objetivos de mercado sub-24:** Seidu, Balerdi y Siersleben cumplen el criterio. Perfiles más jóvenes destacados: Lucas Beraldo (PSG, 20 años, score 3.70), Willian Pacho (PSG, 22 años, 3.69) y Yarek Gasiorowski (Valencia, 19 años, 3.39).

**Motor de similitud:** Consultado contra el perfil mejor clasificado (Alidu Seidu), el motor devuelve a Murillo (93.0% de similitud del coseno) como la coincidencia estadística más cercana, seguido de Santiago Mouriño (89.1%) y Mickael Nade (87.3%).

---

## Informe táctico detallado

Para desglose por jugador, casos de estudio por cluster y shortlists completas, ver el [Informe de análisis táctico](/docs/TACTICAL_ANALYSIS.es.md).

---

## Archivos generados

### Gráficas (`outputs/figures/`)

| Archivo | Descripción |
|---------|-------------|
| `defender_archetypes.png` | Índice de progresión vs defending score, color por perfil de rol y tamaño por scouting score |
| `cluster_pca_visualization.png` | Proyección PCA 2D con asignaciones de cluster K-means |
| `recruitment_value.png` | Edad vs scouting score para localizar ineficiencias de mercado |
| `padj_defensive_profile.png` | Entradas PAdj vs intercepciones PAdj, color por liga |

### Tablas (`outputs/tables/`)

| Archivo | Descripción |
|---------|-------------|
| `scouting_dashboard.csv` | Lista completa de jugadores con todas las métricas calculadas |
| `top_recruitment_targets.csv` | Top 25 jugadores por scouting score |
| `market_inefficiency_targets.csv` | Jugadores sub-24 por encima del percentil 80 de scouting score |
| `xt_proxy_ranking.csv` | Top 20 jugadores por índice de progresión |
| `defensive_ranking.csv` | Top 20 jugadores por defending score bruto |
| `padj_defensive_metrics.csv` | Dataset completo con estimaciones de posesión de equipo y estadísticas PAdj |
| `cluster_profiles.csv` | Estadísticas medias por cluster |
| `player_cluster_assignments.csv` | Asignación de cluster por jugador |
| `player_similarity_results.csv` | Top 10 coincidencias por similitud del coseno para el jugador mejor clasificado |

---

## Tecnologías

- R
- tidyverse (dplyr, readr, tidyr)
- ggplot2, ggrepel
- factoextra, cluster
- proxy (similitud del coseno)

---

## Estructura del repositorio

```
football-data-analysis/
│
├── data/
│   ├── All_Players_1992-2025.csv
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

---

## Autor

**Adrián Gómez Conde**
Bioestadístico
Modelización estadística · análisis multivariante · analítica deportiva aplicada
