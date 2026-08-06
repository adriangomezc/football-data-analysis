[![en](https://img.shields.io/badge/lang-en-blue.svg)](README.md)
[![R](https://img.shields.io/badge/hecho%20con-R-276DC3.svg)](https://www.r-project.org/)
[![Licencia: MIT](https://img.shields.io/badge/licencia-MIT-green.svg)](LICENSE)

# Identificación de centrales modernos con buena salida de balón

> Framework estadístico multivariante aplicado en R para perfilar, clasificar y encontrar sustitutos estadísticos de centrales en las cinco grandes ligas europeas.

El pipeline combina métricas defensivas ajustadas por posesión, ponderación de variables mediante PCA, clustering K-means y similitud del coseno para ir más allá de las estadísticas brutas y detectar objetivos de reclutamiento con contexto real.

---

## Datos y alcance

| | |
|---|---|
| **Fuente** | `data/All_Players_1992-2025.csv` — 92.170 filas jugador-temporada de las cinco grandes ligas |
| **Ventana de análisis** | Temporadas desde 2023–24 en adelante |
| **Unidad de análisis** | Una fila por jugador: **su temporada válida más reciente** |
| **Muestra final** | **407 centrales** — 286 de 2024–25 y 121 de 2023–24 |

Como cada jugador entra con su última temporada válida, la muestra **combina dos campañas**. Esto mantiene cada perfil en su estado de forma más actual —lo que interesa en una herramienta de reclutamiento— pero implica que el ranking no es una comparación estrictamente homogénea de una única temporada. Ver [Limitaciones](#limitaciones).

**Embudo de filtrado**

| Paso | Filas restantes |
|------|-----------------|
| Jugador-temporada desde 2023–24 | 6.997 |
| Posición principal `DF` (se excluyen híbridos `MF`/`FW`), ≥ 900 minutos | 1.104 |
| Filtros posicionales: centros/90 < 0,8; recepciones progresivas/90 < 3,56 (p75); toques en último tercio/90 < 0,20 (p75) | 570 |
| Temporada más reciente por jugador | **407 jugadores únicos** |

Los dos últimos filtros posicionales existen para eliminar laterales y carrileros que el dataset de origen sigue etiquetando como `DF`.

---

## Metodología

### 1. Ingeniería de variables
Todas las métricas están normalizadas por 90 minutos. Los indicadores compuestos son:

- **Índice de progresión** — combinación ponderada de pases progresivos, conducciones progresivas y pases clave por 90. Los pesos no se eligen a mano: son los loadings absolutos normalizados del PC1 de un PCA sobre esas tres variables (**0,346**, **0,352** y **0,302** respectivamente).
- **Defensa ajustada por posesión (PAdj)** — la posesión del equipo se estima a partir del volumen de pases frente a la media de la liga, y después un multiplicador sigmoideo `2 / (1 + exp(-0,1 × (posesión − 50)))` reescala entradas, intercepciones y recuperaciones. Los defensas de equipos dominantes tienen menos oportunidades defensivas, así que sus conteos brutos se ajustan al alza.
- **Scouting score** — la métrica maestra de clasificación:

  ```
  scouting_score = índice_progresión        × 0,40
                 + defending_score_PAdj      × 0,30
                 + (precisión_pase / 100)    × 0,10
                 + age_score                 × 0,20
  ```

  La curva de edad premia las ventanas de máximo rendimiento (`≤24 → 1,00`; `≤28 → 0,95`; `≤31 → 0,85`; `≤33 → 0,70`; resto `0,50`).

### 2. Clustering y roles tácticos
Los jugadores se segmentan en cuatro arquetipos con K-means (`k = 4`, `nstart = 50`, `set.seed(123)`) sobre variables de progresión y defensa PAdj tipificadas. Las etiquetas de rol **no están fijadas a mano**: el pipeline lee los centroides y asigna los nombres por eliminación (mayor progresión → *Elite Progressive Distributor*; después mayor volumen defensivo → *High-Intensity Ball-Winner*; después menor progresión → *Limited / Reactive Defender*; el restante → *Standard Build-up Distributor*).

### 3. Motor de similitud
Una función de similitud del coseno sobre el espacio de características estandarizado. Ingiere el nombre de cualquier jugador objetivo y devuelve las coincidencias estadísticas más cercanas, para planificación de sucesiones.

---

## Hallazgos principales

**Mejores scouting scores** — Sead Kolašinac (Atalanta, **5,08**) lidera el ranking general, seguido de Riccardo Calafiori (Bologna, **4,98**) y Timo Hübers (Colonia, **4,84**).

**Líderes en progresión** — Iñigo Martínez (Barcelona, **4,31**) domina el índice de progresión, combinando un volumen muy alto de pases progresivos con conducción de élite. Nico Schlotterbeck (Dortmund, **3,90**) actúa como referencia secundaria.

**Defensa ajustada por posesión** — tras normalizar el dominio del equipo, Timo Hübers (**13,31** PAdj combinado) y Riccardo Calafiori (**13,18**) emergen como los recuperadores más activos de la muestra.

**Objetivos de mercado sub-24** — Riccardo Calafiori (21, 4,98) es el más destacado. Otros perfiles jóvenes de élite señalados por el algoritmo: Nico Schlotterbeck (24, 4,73), Alidu Seidu (23, 4,62), Wilfried Singo (23, 4,60) y Giorgio Scalvini (19, 4,58).

**Motor de similitud** — consultado contra el perfil mejor clasificado (Sead Kolašinac), el motor devuelve a Mario Gila (**97,1%** de similitud del coseno), Javi Rodríguez (95,9%) y Facundo Medina (95,3%).

**Distribución de arquetipos** — Limited / Reactive Defender (145), Standard Build-up Distributor (117), High-Intensity Ball-Winner (97), Elite Progressive Distributor (48).

Para un desglose completo a nivel de jugador, casos de estudio por cluster y shortlists de reclutamiento, consulta el **[informe de análisis táctico](docs/TACTICAL_ANALYSIS.es.md)**.

---

## Figuras

**Progresión vs defensa ajustada por posesión**, coloreado por rol algorítmico y con tamaño según scouting score. La separación entre distribuidores (derecha) y recuperadores (arriba) es precisamente el trade-off que arbitra el score compuesto.

![Arquetipos de central](outputs/figures/defender_archetypes.png)

**Arquetipos K-means proyectados sobre las dos primeras componentes principales.** Solo se etiquetan los 15 primeros por scouting score.

![Proyección PCA de clusters](outputs/figures/cluster_pca_visualization.png)

**Edad vs scouting score.** La zona superior izquierda —jugadores jóvenes con scores compuestos altos— es donde está el valor de reclutamiento.

![Valor de reclutamiento por edad](outputs/figures/recruitment_value.png)

---

## Reproducir el análisis

Requiere R (≥ 4.1) y tres paquetes:

```bash
Rscript -e "install.packages(c('tidyverse','ggrepel','proxy'), repos='https://cloud.r-project.org')"
```

Después, desde la raíz del repositorio:

```bash
Rscript scripts/run_all.R
```

El pipeline es determinista (`set.seed(123)` para K-means) y regenera todos los archivos de `outputs/`. Los pasos se ejecutan en orden y se detienen ante el primer error, ya que cada uno consume la salida del anterior.

---

## Archivos generados

### Gráficas (`outputs/figures/`)
| Archivo | Descripción |
| --- | --- |
| `defender_archetypes.png` | Índice de progresión vs defending score, coloreado por perfil de rol y tamaño por scouting score |
| `cluster_pca_visualization.png` | Proyección PCA 2D con arquetipos K-means, top 15 etiquetado |
| `recruitment_value.png` | Edad vs scouting score, para localizar ineficiencias de mercado |

### Tablas (`outputs/tables/`)
| Archivo | Descripción |
| --- | --- |
| `top_recruitment_targets.csv` | Top 25 jugadores por scouting score general |
| `market_inefficiency_targets.csv` | Jugadores sub-24 por encima del percentil 80 en scouting score |
| `xt_proxy_ranking.csv` | Top 20 jugadores por índice de progresión |
| `defensive_ranking.csv` | Top 20 jugadores por defending score ajustado por posesión |
| `padj_defensive_metrics.csv` | Dataset maestro completo con todas las estimaciones de contexto y estadísticas PAdj |
| `cluster_profiles.csv` | Estadísticas medias por cluster / rol asignado |
| `final_scouting_dashboard.csv` | Lista completa de jugadores con roles tácticos asignados por el algoritmo |
| `player_similarity_results.csv` | Mejores coincidencias por similitud del coseno para la consulta objetivo |

---

## Limitaciones

Se declaran explícitamente porque acotan cómo debe leerse el ranking:

- **La posesión es un proxy, no una medición.** Se infiere del volumen de pases del equipo frente a la media de la liga, así que un equipo de poca posesión que juegue mucho pase corto quedará sobreestimado. Con datos reales de posesión, este paso se sustituye directamente.
- **La muestra combina dos temporadas.** Los jugadores se comparan en su campaña válida más reciente, lo cual es correcto para estado de forma pero no para un corte transversal limpio.
- **Los pesos del compuesto los fija el analista, no se estiman.** El reparto 40/30/10/20 y la curva de edad codifican una filosofía de reclutamiento; no están ajustados contra ningún resultado observable como valor de mercado o minutos ganados.
- **`k = 4` se elige a priori**, no por silueta ni por estadístico gap.
- **Los traspasos a mitad de temporada** se gestionan a nivel de fila según el dataset de origen; el contexto PAdj de un jugador refleja únicamente el equipo de esa fila.
- **El modelo no ve** disponibilidad ni historial de lesiones, duelos aéreos, errores defensivos, situación contractual ni valor de mercado. Es una herramienta de preselección, no una decisión de fichaje.

---

## Tecnologías

- R
- tidyverse (dplyr, tibble, ggplot2)
- ggrepel
- proxy (similitud del coseno)

---

## Estructura del repositorio

```text
football-data-analysis/
│
├── data/
│   ├── All_Players_1992-2025.csv        # dataset original
│   ├── player_stats_2024_2025.csv       # extracto reducido de una temporada
│   └── processed/
│       ├── defenders_processed.csv      # tabla maestra con scores
│       └── team_possession_proxy.csv    # estimaciones de posesión + multiplicadores PAdj
│
├── scripts/
│   ├── setup_packages.R                 # comprobación de dependencias
│   ├── scripts_padj_metrics.R           # proxy de posesión + multiplicadores PAdj
│   ├── scripts_scouting.R               # filtrado, pesos PCA y scores compuestos
│   ├── scripts_clustering.R             # K-means, asignación de roles y figuras
│   ├── scripts_similarity_engine.R      # similitud del coseno
│   └── run_all.R                        # pipeline maestro
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

## Licencia

Publicado bajo [Licencia MIT](LICENSE).

---

## Autor

**Adrián Gómez Conde**

Bioestadístico

Modelización estadística · análisis multivariante · analítica deportiva aplicada
