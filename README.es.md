# Identificación de Centrales Modernos con Buena Salida de Balón

Este proyecto aplica un marco de *scouting* estadístico multivariante para identificar, perfilar y evaluar centrales modernos y perfiles defensivos. Yendo más allá de las estadísticas descriptivas básicas, este motor aplica reducción de la dimensionalidad, métricas ajustadas por posesión y algoritmos de similitud del coseno para establecer arquetipos tácticos sólidos e identificar ineficiencias de alto valor en el mercado.

El flujo de trabajo procesa datos de eventos para construir indicadores tácticos compuestos, señalando aquellos perfiles que encajan en un juego proactivo y de alta posesión.

---

## Metodología

### 1. Filtrado y Agregación de Datos

Se filtró a los jugadores para garantizar la precisión posicional, la significación estadística y la relevancia:

* Posición principal: Defensa Central (DF) y perfiles defensivos.
* Umbral mínimo de 900 minutos jugados.
* Agregación de temporadas recientes para establecer un perfil de rendimiento longitudinal y estable, mitigando la varianza propia de las muestras pequeñas.

### 2. Ingeniería de Variables y Métricas Contextuales

A partir de los datos brutos de eventos, se construyeron varios indicadores tácticos avanzados por 90 minutos para reflejar las exigencias modernas de la posición:

* **Defensa Ajustada por Posesión (PAdj):** Para cuantificar el rendimiento defensivo real, se estimó matemáticamente la posesión del equipo utilizando el volumen relativo de pases de la liga. Después, las acciones defensivas (entradas e intercepciones) se ajustaron en función de la posesión del rival. Esto aísla la verdadera intensidad defensiva por oportunidad y elimina el sesgo inherente de las estadísticas acumulativas brutas, donde los defensores de equipos con baja posesión acumulan más acciones de forma artificial.
* **Aproximación de Amenaza Esperada (Proxy xT):** Un modelo heurístico que cuantifica el valor territorial y ofensivo generado por las decisiones de pase y conducción del defensor.
* **Progresión de Balón:** Una combinación ponderada de pases progresivos y conducciones progresivas.
* **Seguridad en el Pase:** Efectividad global en la entrega de pases, que sirve como base para la fiabilidad en la salida de balón.
* **Puntuación de Scouting Compuesta:** Una métrica agregada que equilibra la progresión, el rendimiento defensivo, la seguridad en el pase y un modificador por edad para destacar el valor de un posible fichaje.

### 3. Estandarización

Todas las variables creadas se estandarizaron mediante el escalado de puntuación z (*z-score*) antes de realizar cualquier análisis multivariante. Esto garantiza un peso equitativo entre las diferentes escalas estadísticas (por ejemplo, porcentajes de acierto en pases frente a acciones defensivas absolutas).

### 4. Agrupamiento K-Means y Proyección PCA

Los jugadores se segmentaron en distintos roles tácticos según su perfil multivariante. El número óptimo de grupos (k=4) se validó y seleccionó estrictamente mediante la optimización de la suma de cuadrados internos (WSS) y el análisis de silueta (*silhouette*).
Posteriormente, se utilizó el Análisis de Componentes Principales (PCA) para proyectar estos perfiles multidimensionales en un espacio visual bidimensional (2D), facilitando la interpretación de las estructuras tácticas latentes. 
Para eliminar la subjetividad en las puntuaciones compuestas (progression_score), las ponderaciones de los pases progresivos (25.23%), conducciones progresivas (37.27%) y pases clave (37.50%) se extraen dinámicamente de los loadings del primer componente principal (PC1), maximizando la varianza explicada.

### 5. Motor de Similitud de Jugadores

Se construyó un sistema de recomendación no paramétrico utilizando la Similitud del Coseno. Al evaluar las métricas estandarizadas en un espacio multidimensional, el motor identifica "clones" estadísticos de los objetivos de élite, proporcionando alternativas objetivas y basadas en datos para el reclutamiento y la planificación de sucesiones.

---

## Hallazgos Clave

La integración de métricas contextuales generó conclusiones tácticas muy accionables:

1. **Generación de Amenaza Ofensiva (xT):** La aproximación de Amenaza Esperada identifica con éxito a defensores de élite con buena salida de balón que actúan como organizadores retrasados. **Oleksandr Zinchenko** lidera el continente en generación de amenaza desde zonas retrasadas con un excepcional proxy xT de 8.01, seguido de cerca por perfiles marcadamente ofensivos como Achraf Hakimi (7.03) y Joshua Kimmich (6.60).
2. **La Realidad del PAdj:** El ajuste por posesión relativa altera drásticamente el panorama defensivo. El modelo identifica correctamente a destructores puros como **Alidu Seidu** (4.14) y **Mats Wieffer** (4.13), al tiempo que premia a defensores con un alto volumen de acciones en equipos dominantes, como **Eduardo Camavinga** (3.95).
3. **Arquetipos Tácticos:** El algoritmo de agrupamiento identificó cuatro roles distintos. Cabe destacar que el Grupo 2 (Progresivos de Élite - 163 jugadores) engloba a los principales directores de la salida de balón, quienes promedian 5.77 pases progresivos por 90 minutos y un xT medio de 4.15, mientras que el Grupo 3 (Destructores - 119 jugadores) aísla a defensores reactivos y de alto volumen de acciones con un promedio de 4.53 entradas PAdj y una seguridad en el pase del 78.84%.
4. **Ineficiencias del Mercado y Objetivos Sub-24:** Al cruzar la puntuación de scouting compuesta con la edad del jugador, el marco de trabajo aísla el talento joven que rinde por encima de su producción táctica esperada. Adolescentes como **Soungoutou Magassa** (19 años, puntuación de 1.78) y **João Neves** (19 años, puntuación de 1.73) surgen como anomalías estadísticas, mostrando métricas defensivas y de progresión de élite equiparables a las de veteranos en su plenitud futbolística.
5. **Planificación Automatizada de Sucesiones:** El motor de similitud demostró ser capaz de encontrar coincidencias estadísticas exactas para un reclutamiento específico. Por ejemplo, al consultar la matriz en busca de perfiles concretos, se obtuvieron alternativas muy precisas, identificando a jugadores como **Juan David Cabal** con una coincidencia del 94.2% para el rol táctico requerido.

---

## Informe Táctico Detallado

Para obtener un desglose completo de los perfiles de los jugadores, recomendaciones específicas de scouting, estudios de caso e información táctica derivada de los modelos, consulte el **[Informe de Análisis Táctico y Perfilado](https://github.com/adriangomezc/football-data-analysis/blob/main/docs/TACTICAL_ANALYSIS.md)** completo.

---

## Resultados

### Visualizaciones

* `outputs/figures/defender_archetypes.jpg`: Proyección en gráfico de dispersión del mercado según la progresión frente al rendimiento defensivo.
* `outputs/figures/cluster_pca_visualization.jpg`: Proyección de los perfiles de los jugadores en el espacio de componentes principales, codificados por colores según los cuatro arquetipos tácticos.
* `outputs/figures/recruitment_value.jpg`: Edad frente a la puntuación de scouting compuesta para resaltar las ineficiencias del mercado.
* `outputs/figures/padj_defensive_profile.jpg`: Mapeo del rendimiento defensivo contextualizado.

### Exportaciones de Datos

* `outputs/tables/top_recruitment_targets.csv`: Clasificación general basada en la puntuación de scouting compuesta.
* `outputs/tables/market_inefficiency_targets.csv`: Lista filtrada de defensores sub-24 de alto rendimiento.
* `outputs/tables/player_similarity_results.csv`: Lista automatizada de alternativas estadísticas para los perfiles de jugadores consultados.
* `outputs/tables/cluster_profiles.csv`: Estadísticas resumidas que definen cada arquetipo táctico.
* `outputs/tables/xt_proxy_ranking.csv`: Clasificación de los mejores defensores ordenados por generación de amenaza esperada.

---

## Tecnologías

* R
* tidyverse (dplyr, readr, tidyr)
* ggplot2, ggrepel
* factoextra, cluster
* proxy (Similitud del Coseno)

---

## Estructura del Repositorio

```text
football-data-analysis/
│
├── data/
│   ├── raw/
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

# Autor

Adrián Gómez Conde

Candidato a Máster en Bioestadística
Modelización estadística, análisis multivariante y analítica deportiva aplicada
