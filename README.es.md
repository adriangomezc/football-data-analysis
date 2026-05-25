# Identificación de Centrales Modernos con Buena Salida de Balón (Macro-Scouting Framework)

Este proyecto aplica un marco de *scouting* estadístico multivariante a nivel macro para identificar, perfilar y evaluar centrales modernos y perfiles defensivos en las cinco grandes ligas europeas. Utilizando datos anuales agregados de rendimiento, este motor aplica reducción de la dimensionalidad, métricas ajustadas por posesión real estimada y algoritmos de similitud del coseno para establecer arquetipos tácticos sólidos e identificar ineficiencias de alto valor en el mercado de fichajes.

El flujo de trabajo procesa registros históricos consolidados para construir indicadores tácticos compuestos, señalando aquellos perfiles que encajan en un modelo de juego proactivo y de alta posesión, sin depender de sesgos subjetivos.

---

## Metodología

### 1. Filtrado y Agregación de Datos
Se filtró la base de datos longitudinal para garantizar la precisión posicional, la significación estadística y la relevancia de los perfiles:
* **Posición principal:** Defensa Central (DF) y perfiles defensivos de primera línea.
* **Filtro de actividad:** Umbral mínimo de 900 minutos jugados por temporada.
* **Estabilización del perfil:** Agregación de las últimas temporadas completas para establecer un perfil de rendimiento longitudinal y estable, mitigando la varianza propia de las muestras pequeñas o rachas cortas.

### 2. Ingeniería de Variables y Métricas Contextuales
A partir de los registros estadísticos consolidados de rendimiento (por 90 minutos), se construyeron indicadores avanzados para reflejar las exigencias del fútbol de élite:
* **Defensa Ajustada por Posesión (PAdj):** Para cuantificar el rendimiento defensivo real, se estimó matemáticamente la posesión de cada equipo utilizando el volumen relativo de pases completados frente a la media de su respectiva liga. Las acciones defensivas (entradas e intercepciones) se normalizaron en función de la posesión del rival, aislando la verdadera intensidad defensiva por oportunidad y eliminando el sesgo de los bloques bajos que acumulan volumen por simple hundimiento en el campo.
* **Índice de Progresión Avanzado (Exportado como `xT_proxy`):** Un indicador macro compuesto que pondera el impacto territorial y la ganancia de metros verticales del futbolista mediante la combinación indexada de sus pases y conducciones progresivas.
* **Progresión de Balón de Variación Máxima (`progression_score`):** Una combinación ponderada de pases progresivos, conducciones progresivas y pases clave, cuyos pesos no se asignan de forma arbitraria, sino mediante modelado estadístico.
* **Seguridad en el Pase:** Efectividad porcentual global en la entrega de pases (`pass_completion`), actuando como el umbral de fiabilidad mínimo en la primera fase de construcción.
* **Puntuación de Scouting Compuesta (`scouting_score`):** Una métrica integrada y escalada (z-score) que equilibra la capacidad de progresión, el impacto defensivo ajustado, la seguridad asociativa y un modificador por edad para aislar el valor de mercado potencial.

### 3. Estandarización
Todas las variables creadas se estandarizaron mediante el escalado de puntuación z (*z-score*) antes de realizar cualquier análisis multivariante. Esto garantiza un peso equitativo en los algoritmos analíticos, evitando que las variables con escalas grandes (como los porcentajes de pase) eclipsen a las métricas de volumen absoluto (como las entradas por 90).

### 4. Agrupamiento K-Means y Proyección PCA
Los jugadores se segmentaron en distintos roles tácticos según su perfil multivariante. El número óptimo de grupos (k=4) se seleccionó y validó estrictamente mediante la optimización de la suma de cuadrados internos (WSS) y el análisis de silueta (*silhouette*).
Posteriormente, se utilizó el Análisis de Componentes Principales (PCA) para proyectar estos perfiles multidimensionales en un espacio visual bidimensional (2D), facilitando la interpretación de las estructuras tácticas latentes. 

> **Optimización Matemática de Pesos:** Para eliminar la subjetividad y el sesgo humano en el diseño de los índices, las ponderaciones del `progression_score` se extraen dinámicamente de los *loadings* del primer componente principal (PC1) de los datos: Pases Progresivos (25.23%), Conducciones Progresivas (37.27%) y Pases Clave (37.50%), maximizando la varianza explicada del perfil constructivo.

### 5. Motor de Similitud de Jugadores
Se construyó un sistema de recomendación no paramétrico utilizando la Similitud del Coseno. Al evaluar las métricas estandarizadas en el espacio multidimensional del PCA, el motor identifica "clones" estadísticos de los objetivos de élite, proporcionando alternativas objetivas, viables y de menor coste para la secretaría técnica.

---

## Hallazgos Clave

La integración de métricas contextuales generó conclusiones tácticas muy accionables para la planificación de plantillas:

1. **Capacidad de Progresión Estructurada:** El índice de progresión identifica con éxito a defensores que actúan como organizadores retrasados. **Oleksandr Zinchenko** lidera el continente en volumen de distribución vertical con un valor excepcional de 8.01, seguido de cerca por perfiles de alta proyección ofensiva como Achraf Hakimi (7.03) y Joshua Kimmich (6.60).
2. **La Realidad del PAdj:** El ajuste por posesión relativa y la inclusión del volumen de recuperación alteran drásticamente el mapa de la destrucción. El modelo identifica correctamente la intensidad de destructores consolidados como **Alidu Seidu** (puntuación defensiva PAdj de 13.05) y **Mats Wieffer** (12.67), al tiempo que saca a la luz la agresividad de defensores en equipos de alta dominancia, como **Eduardo Camavinga** (12.34).
3. **Arquetipos Tácticos Coherentes:** El algoritmo de agrupamiento identificó cuatro roles estables. El **Grupo 2 (Progresivos de Élite - 163 jugadores)** engloba a los directores de la salida de balón, promediando 5.77 pases progresivos por 90 y un índice de progresión medio de 4.15. Por contra, el **Grupo 3 (Destructores - 119 jugadores)** aísla a perfiles reactivos de contención con un promedio de 4.53 entradas PAdj y una menor seguridad en el pase (78.84%).
4. **Detección de Ineficiencias Sub-24:** Al cruzar la puntuación de scouting con la edad, el marco de trabajo aísla el talento joven que sobreproduce respecto a su contexto. Adolescentes como **Soungoutou Magassa** (19 años, puntuación general de 4.79) y **João Neves** (19 años, puntuación de 4.56) surgen como auténticas anomalías estadísticas, mostrando un rendimiento de élite equiparable al de veteranos en su plenitud futbolística.
5. **Planificación Automatizada de Sucesiones:** El motor de similitud demostró una precisión milimétrica para encontrar relevos en el mercado, localizando perfiles como el de **Juan David Cabal** con una coincidencia matemática del 94.2% respecto al perfil táctico requerido.

---

## Informe Táctico Detallado

Para obtener un desglose completo de los perfiles de los jugadores, recomendaciones específicas de scouting, estudios de caso e información táctica de los modelos, consulte el **[Informe de Análisis Táctico y Perfilado](https://github.com/adriangomezc/football-data-analysis/blob/main/docs/TACTICAL_ANALYSIS.md)** completo.

---

## Resultados

### Visualizaciones
* `outputs/figures/defender_archetypes.png`: Proyección en gráfico de dispersión del mercado según la progresión frente al rendimiento defensivo.
* `outputs/figures/cluster_pca_visualization.png`: Proyección de los perfiles de los jugadores en el espacio de componentes principales, codificados por colores según los cuatro arquetipos tácticos.
* `outputs/figures/recruitment_value.png`: Edad frente a la puntuación de scouting compuesta para resaltar las ineficiencias del mercado.
* `outputs/figures/padj_defensive_profile.png`: Mapeo del rendimiento defensivo contextualizado por posesión estimada.

### Exportaciones de Datos
* `outputs/tables/top_recruitment_targets.csv`: Clasificación general basada en la puntuación de scouting compuesta.
* `outputs/tables/market_inefficiency_targets.csv`: Lista filtrada de defensores sub-24 de alto rendimiento.
* `outputs/tables/player_similarity_results.csv`: Lista automatizada de alternativas estadísticas para los perfiles de jugadores consultados.
* `outputs/tables/cluster_profiles.csv`: Estadísticas resumidas que definen cada arquetipo táctico.
* `outputs/tables/xt_proxy_ranking.csv`: Clasificación de los mejores defensores ordenados por su índice de progresión vertical.

---

## Tecnologías

* **R Language**
* **tidyverse** (dplyr, readr, tidyr)
* **ggplot2**, **ggrepel**
* **factoextra**, **cluster**
* **coop** (Similitud del Coseno)

---

## Estructura del Repositorio

```text
football-data-analysis/
│
├── data/
│   ├── raw/            # Contiene All_Players_1992-2025.csv
│   └── processed/      # Dataset unificado y estandarizado
│
├── outputs/
│   ├── figures/        # Gráficos del PCA, Perfiles y Scouitng
│   └── tables/         # Reportes y rankings en formato .csv
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
Autor
Adrián Gómez Conde Candidato a Máster en Bioestadística 

Modelización estadística, análisis multivariante y analítica deportiva aplicada.
