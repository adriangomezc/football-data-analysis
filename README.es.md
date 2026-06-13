# Identificación de centrales modernos con buena salida de balón

> Framework estadístico multivariante aplicado en R para perfilar, clasificar y encontrar sustitutos estadísticos de centrales en las cinco grandes ligas europeas (temporada 2023–24).

El pipeline combina métricas defensivas ajustadas por posesión, ponderación de variables mediante PCA, clustering K-means y similitud del coseno para ir más allá de las estadísticas brutas y detectar objetivos de reclutamiento con contexto real.

---

## Metodología

### 1. Filtrado y agregación de datos

La muestra se filtró para garantizar precisión en la posición y relevancia estadística:

* Posición principal: Defensa central (DF). Se excluyen perfiles híbridos MF/FW.
* Umbral mínimo: 900 minutos disputados.
* Filtros posicionales estrictos sobre tasas de recepción progresiva y toques en el último tercio para eliminar laterales disfrazados de centrales.
* Para evitar diluir el estado de forma actual, solo se evalúa la temporada más reciente de cada jugador.

### 2. Ingeniería de variables

Todas las métricas están normalizadas por 90 minutos. Los indicadores compuestos clave incluyen:

* **Índice de progresión:** Combinación ponderada de pases progresivos, conducciones progresivas y pases clave por 90. Los pesos se derivan dinámicamente de los loadings del PC1 de un Análisis de Componentes Principales (0.346, 0.352 y 0.302 respectivamente).
* **Defensa ajustada por posesión (PAdj):** La posesión del equipo se estima utilizando el volumen de pases medio de la liga como proxy del rival. A continuación, aplicamos el multiplicador sigmoideo de StatsBomb a las entradas, intercepciones y recuperaciones para normalizar la intensidad defensiva por oportunidad real de defensa.
* **Scouting score:** La métrica maestra de clasificación. Fórmula: `(índice_progresión × 0.4) + (defending_score_PAdj × 0.3) + (precisión_pase / 100 × 0.1) + (age_score × 0.2)`. La curva de edad premia las ventanas de máximo rendimiento (24-28 años) mientras penaliza suavemente el declive.

### 3. Clustering y roles tácticos

Los jugadores se segmentan en arquetipos tácticos utilizando un algoritmo K-means (k=4). En lugar de fijar las etiquetas manualmente, el pipeline asigna dinámicamente nombres a los roles tácticos (ej. distribuidor progresivo de élite, recuperador de alta intensidad) evaluando los centroides matemáticos de cada cluster resultante.

### 4. Motor de similitud

Una función flexible de similitud del coseno construida sobre el espacio de características estandarizado. Ingiere el nombre de cualquier jugador objetivo e identifica las coincidencias estadísticas más cercanas para ayudar en la planificación de sucesiones.

---

## Hallazgos principales

**Mejores scouting scores:** Sead Kolašinac (Atalanta, 5.08) lidera el ranking general, seguido de cerca por la revelación Riccardo Calafiori (Bologna, 4.98) y Timo Hübers (Colonia, 4.84).

**Líderes en progresión:** Iñigo Martínez (Barcelona, 4.31) domina el índice de progresión, combinando un volumen masivo de pases progresivos con métricas de conducción de élite. Nico Schlotterbeck (Dortmund, 3.90) actúa como punto de referencia secundario.

**Defensa ajustada por posesión:** Tras normalizar el dominio del equipo mediante la curva sigmoidea, Timo Hübers (13.31 PAdj combinado) y Riccardo Calafiori (13.18) emergen como los recuperadores de balón más intensos de la muestra.

**Objetivos de mercado sub-24:** Riccardo Calafiori (21 años, score 4.98) es el jugador más destacado en absoluto. Otros perfiles jóvenes de élite señalados por el algoritmo incluyen a Nico Schlotterbeck (24 años, score 4.73), Alidu Seidu (23 años, score 4.62) y el prometedor adolescente Giorgio Scalvini (19 años, score 4.58).

**Motor de similitud:** Consultado contra nuestro perfil mejor clasificado globalmente (Sead Kolašinac), el motor devuelve a Mario Gila (97.1% de similitud del coseno) como la alternativa táctica más cercana, seguido de Javi Rodríguez (95.9%) y Facundo Medina (95.3%).

---

## Informe de análisis táctico

Para un desglose completo a nivel de jugador, casos de estudio por cluster y shortlists de reclutamiento, consulta el [Informe de análisis táctico](/docs/TACTICAL_ANALYSIS.es.md).

---

## Archivos generados

### Gráficas (`outputs/figures/`)

| Archivo | Descripción |
| --- | --- |
| `defender_archetypes.png` | Índice de progresión vs defending score, coloreado por perfil de rol y tamaño por scouting score |
| `cluster_pca_visualization.png` | Proyección PCA 2D con asignaciones de cluster K-means |
| `recruitment_value.png` | Edad vs scouting score para localizar ineficiencias de mercado |

### Tablas (`outputs/tables/`)

| Archivo | Descripción |
| --- | --- |
| `top_recruitment_targets.csv` | Top 25 jugadores por scouting score general |
| `market_inefficiency_targets.csv` | Jugadores sub-24 por encima del percentil 80 en scouting score |
| `xt_proxy_ranking.csv` | Top 20 jugadores por índice de progresión |
| `defensive_ranking.csv` | Top 20 jugadores por defending score ajustado por posesión |
| `padj_defensive_metrics.csv` | Dataset maestro completo con todas las estimaciones de contexto y estadísticas PAdj |
| `cluster_profiles.csv` | Estadísticas medias por cluster |
| `final_scouting_dashboard.csv` | Lista completa de jugadores con roles tácticos asignados por el algoritmo |
| `player_similarity_results.csv` | Mejores coincidencias por similitud del coseno para la consulta objetivo |

---

## Tecnologías

* R
* tidyverse (dplyr, readr, tidyr)
* ggplot2, ggrepel
* factoextra, cluster
* proxy (similitud del coseno)

---

## Estructura del repositorio

```text
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
