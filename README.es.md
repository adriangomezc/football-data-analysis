# Identificación de centrales modernos con buena salida de balón

Este proyecto analiza datos de rendimiento para identificar y evaluar centrales en las grandes ligas europeas con un perfil proactivo en la circulación de juego. En lugar de usar estadísticas descriptivas tradicionales, el flujo de trabajo combina el ajuste por posesión de las métricas de corte, la reducción de dimensionalidad para ponderar variables y algoritmos de similitud para detectar perfiles interesantes o infravalorados en el mercado.

El análisis está diseñado para trabajar sobre datos anuales agregados (FBref), buscando patrones estables a lo largo de las últimas temporadas.

---

## Metodología

### 1. Filtrado y agregación de datos
Para limpiar la muestra y quedarnos con perfiles con relevancia estadística, se aplicaron los siguientes filtros:
* Posición principal: Defensa central (DF) y perfiles híbridos defensivos.
* Mínimo de 900 minutos disputados por temporada.
* Agregación longitudinal de los registros de las últimas temporadas para estabilizar los promedios y reducir el ruido de muestras pequeñas.

### 2. Ingeniería de variables y métricas
Las métricas se normalizaron por 90 minutos y se construyeron los siguientes indicadores compuestos:
* **Defensa ajustada por posesión (PAdj):** Se estimó la posesión media de cada equipo a través de su volumen de pases respecto a la media de su liga. Las métricas de corte (entradas e intercepciones) se ajustaron según la posesión del rival para evaluar la intensidad real por oportunidad, evitando el sesgo de los jugadores de equipos replegados.
* **Índice de Progresión (Progression Index):** Un índice multidimensional que mide el impacto con el balón y la ganancia de territorio, optimizado mediante los pesos empíricos extraídos del PCA.
* **Puntuación de scouting:** Nota global que equilibra la progresión, la defensa ajustada (incluyendo la actividad en recuperaciones), el acierto en el pase y un factor corrector por edad para priorizar el talento joven.

### 3. Estandarización y Ponderación Empírica (PCA)
Para evitar que las diferentes escalas de las variables distorsionen los algoritmos, todas las variables se normalizaron mediante puntuaciones z (*z-scores*) antes de introducirlas en los modelos. Para el Índice de Progresión, en lugar de asignar los pesos de forma arbitraria ("a ojo"), se utilizaron los *loadings* del primer componente principal (PC1) de un PCA para determinar de forma matemática el impacto de los pases progresivos, conducciones progresivas y pases clave.

### 4. Clústeres con k-means y proyección con PCA
Se segmentó a los jugadores en cuatro roles estadísticos mediante el algoritmo K-means. Posteriormente, las dimensiones se proyectaron en un espacio bidimensional mediante un Análisis de Componentes Principales (PCA) para facilitar la lectura visual de los grupos.

### 5. Matriz de similitud
Se desarrolló un recomendador basado en la similitud del coseno sobre las variables normalizadas. El sistema mide la distancia geométrica entre los perfiles en un espacio multidimensional para identificar "clones estadísticos", sirviendo como herramienta automática para buscar sustitutos en el mercado.

---

## Hallazgos clave

* **Generación de peligro:** El Índice de Progresión destaca a futbolistas con un rol claro de organizadores retrasados. **Oleksandr Zinchenko** lidera el volumen europeo con un índice de 8.01, seguido de cerca por laterales y pivotes de corte asociativo como **Achraf Hakimi** (7.03) y **Joshua Kimmich** (6.60).
* **Impacto del ajuste defensivo:** Al aplicar la corrección PAdj e incluir las recuperaciones, emergen perfiles de mucha actividad defensiva en equipos dominantes que antes quedaban ocultos por la falta de volumen. **Alidu Seidu** (13.05) y **Mats Wieffer** (12.67) lideran este registro, mientras que **Eduardo Camavinga** escala hasta una puntuación de 12.34 debido a la alta dominancia del Real Madrid.
* **Definición de los grupos:** El clúster 2 (163 jugadores) destaca como el perfil de iniciadores de élite, promediando 5.77 pases progresivos por partido y la media de Índice de Progresión más alta (4.15). El clúster 3 (119 jugadores) define al destructor clásico: promedian 4.53 entradas PAdj pero registran el acierto de pase más bajo de la muestra (78.84%).
* **Detección de talento sub-24:** Cruzando la nota de scouting con la edad, aparecen anomalías estadísticas muy marcadas en el fútbol europeo. Es el caso de **Soungoutou Magassa** (19 años, 4.79 de score) y **João Neves** (19 años, 4.56 de score), cuyos números en progresión y coberturas igualan o superan a los de futbolistas en plena madurez profesional.
* **Eficacia del recomendador:** El buscador de similitud devuelve sustitutos directos sin el sesgo del valor de mercado. Por ejemplo, define a **Jon Pacheco** como un clon con más del 99.9% de coincidencia para ciertos perfiles de centrales zurdos de perfil asociativo, u ofrece a **Juan David Cabal** (94.2%) como la alternativa principal para cubrir roles exteriores de progresión mixta.

---

## Informe táctico detallado

Para ver el desglose completo de los perfiles de los jugadores, casos de estudio y las recomendaciones específicas derivadas de los modelos, consulta el **[Informe de análisis táctico y perfilado](https://github.com/adriangomezc/football-data-analysis/blob/main/docs/TACTICAL_ANALYSIS.md)**.

---

## Resultados y archivos generados

El pipeline genera un total de 14 archivos de salida distribuidos entre gráficos de análisis y tablas de datos estructuradas:

### Gráficos y visualizaciones (`outputs/figures/`)
* `defender_archetypes.png`: Dispersión del mercado comparando la capacidad de progresión frente al volumen defensivo.
* `cluster_pca_visualization.png`: Gráfico del PCA en 2D que muestra la dispersión de los jugadores coloreados por su clúster.
* `recruitment_value.png`: Gráfico de dispersión de edad frente a la nota de scouting para localizar las ineficiencias del mercado.
* `padj_defensive_profile.png`: Mapeo visual del volumen de entradas frente a intercepciones con la corrección de posesión aplicada.

### Tablas y exportaciones de datos (`outputs/tables/`)
* `top_recruitment_targets.csv`: Clasificación general de los mejores perfiles según el score global de scouting.
* `market_inefficiency_targets.csv`: Registro filtrado de los jugadores sub-24 con rendimiento por encima del percentil 80.
* `player_similarity.csv`: Matriz cruzada de similitud del coseno entre todos los jugadores de la base de datos.
* `player_similarity_results.csv`: Historial ordenado con las mejores alternativas y porcentaje de coincidencia para perfiles específicos.
* `cluster_profiles.csv`: Tabla con las medias estadísticas y métricas base que definen el comportamiento de cada uno de los 4 grupos.
* `player_cluster_assignments.csv`: Listado completo de futbolistas con el ID del clúster asignado por el algoritmo.
* `xt_proxy_ranking.csv`: Ranking de los jugadores con mayor capacidad de ganancia de metros y volumen progresivo por partido.
* `defensive_ranking.csv`: Clasificación de los perfiles más eficientes en la destrucción basándose en la suma indexada de tackles, intercepciones y recuperaciones.
* `padj_defensive_metrics.csv`: Base de datos de trabajo con el cálculo final del proxy de posesión de equipo y las métricas defensivas corregidas.
* `scouting_dashboard.csv`: Matriz unificada con todas las métricas calculadas y scores finales lista para su uso en herramientas de visualización (Tableau, PowerBI).

---

## Tecnologías utilizadas

* R
* tidyverse (dplyr, readr, tidyr)
* ggplot2 y ggrepel
* factoextra y cluster (Algoritmos multivariantes)
* proxy / coop (Cálculo de similitud del coseno)

---

## Estructura del repositorio

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

## Autor

**Adrián Gómez Conde** 

*Candidato a Máster en Bioestadística* 

*Modelización estadística, análisis multivariante y analítica deportiva aplicada*
