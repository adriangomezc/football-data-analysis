# Identificación de centrales modernos con buena salida de balón

Este proyecto analiza datos de rendimiento para identificar y evaluar centrales en las grandes ligas europeas con un perfil proactivo en la circulación de juego. En lugar de usar estadísticas descriptivas tradicionales, el flujo de trabajo combina el ajuste por posesión de las métricas defensivas, la reducción de dimensionalidad mediante PCA para ponderar variables de progresión, y algoritmos de similitud para detectar perfiles infravalorados en el mercado.

El análisis está diseñado para trabajar sobre datos anuales agregados (FBref), buscando patrones estables a lo largo de las últimas temporadas.

---

## Metodología

### 1. Filtrado y agregación de datos
Para limpiar la muestra y conservar perfiles con relevancia estadística, se aplicaron los siguientes filtros:
* Posición principal: Defensa central (DF) y perfiles híbridos defensivos excluyendo laterales puros.
* Mínimo de 900 minutos disputados por temporada.
* Agregación longitudinal de los registros de las últimas temporadas para estabilizar los promedios y reducir el ruido de muestras pequeñas.

### 2. Ingeniería de variables y métricas
Las métricas se normalizaron por 90 minutos y se construyeron los siguientes indicadores compuestos:
* **Defensa ajustada por posesión (PAdj):** Se estimó la posesión media de cada equipo a través de su volumen de pases respecto a la media de su liga. Las métricas de corte (entradas e intercepciones) se ajustaron según la posesión del rival para evaluar la intensidad real por oportunidad de defensa, evitando el sesgo estadístico de los jugadores en equipos replegados.
* **Índice de Progresión (Progression Index):** Un índice multidimensional que mide el impacto con el balón y la ganancia de territorio.
* **Puntuación de Scouting (Scouting Score):** Nota global que equilibra el Índice de Progresión (40%), la puntuación defensiva (30%), el acierto en el pase (10%) y un factor corrector por edad (20%) para priorizar el talento joven.

### 3. Ponderación Empírica (PCA) y Estandarización
Para evitar asignar los pesos del Índice de Progresión de forma arbitraria, se utilizaron los *loadings* del primer componente principal (PC1) de un Análisis de Componentes Principales. Esto asignó de forma matemática el peso relativo exacto a los pases progresivos, las conducciones progresivas y los pases clave. Todas las variables empleadas en los modelos multivariantes fueron previamente estandarizadas (*z-scores*).

### 4. Clústeres con K-means y Proyección Espacial
Se segmentó a los jugadores en cuatro roles tácticos estadísticos utilizando el algoritmo K-means. Posteriormente, las dimensiones originales se proyectaron en un espacio bidimensional (PCA) para facilitar la lectura visual de la distribución de los arquetipos defensivos.

### 5. Matriz de Similitud
Se desarrolló un motor de recomendación basado en la similitud del coseno sobre las variables normalizadas. El sistema mide la distancia geométrica entre los perfiles en un espacio multidimensional para identificar "clones estadísticos", sirviendo como herramienta automatizada de *scouting* para buscar sustitutos directos.

---

## Hallazgos clave

* **Generación de peligro:** Tras aplicar el ajuste por PCA, el Índice de Progresión ubica a **Leon Goretzka** como el jugador de perfil híbrido con mayor impacto progresivo de Europa (3.37). Le sigue **Iñigo Martínez** como el central puro más destacado en salida de balón (3.06), junto con **Warren Zaïre-Emery** (2.61) y **Curtis Jones** (2.57).
* **Impacto del ajuste defensivo (PAdj):** Al aplicar la corrección de posesión, emergen perfiles de mucha actividad en equipos dominantes que antes quedaban ocultos. **Alidu Seidu** (13.05) y **Mats Wieffer** (12.67) lideran este registro, mientras que **Eduardo Camavinga** escala hasta 12.34 debido a la altísima dominancia del Real Madrid.
* **Definición de los grupos:** El clúster 3 (56 jugadores) destaca como el perfil de iniciadores de élite, promediando 5.63 pases progresivos por partido, el acierto en pase más alto (89.65%) y la media de progresión más elevada (2.10). Por otro lado, el clúster 1 (68 jugadores) define al destructor clásico: lideran ampliamente con 3.70 entradas PAdj y 2.64 intercepciones, pero registran el acierto de pase más bajo de la muestra (83.22%).
* **Detección de talento sub-24:** Cruzando la nota de scouting con la curva de edad, aparecen anomalías estadísticas muy marcadas en el fútbol europeo. Es el caso de **Soungoutou Magassa** (19 años, 4.79 de *score*) y **João Neves** (19 años, 4.56 de *score*).
* **Eficacia del recomendador:** El motor de similitud devuelve sustitutos directos sin el sesgo del valor de mercado, identificando coincidencias estructurales superiores al 94% para cubrir roles específicos.

---

## Resultados y archivos generados

El pipeline automatizado en `run_all.R` genera los siguientes *outputs*:

### Gráficos y visualizaciones (`outputs/figures/`)
* `defender_archetypes.jpg`: Dispersión del mercado comparando el Índice de Progresión frente a la puntuación defensiva.
* `cluster_pca_visualization.jpg`: Gráfico del PCA en 2D que muestra la dispersión de los jugadores coloreados por su arquetipo (clúster).
* `recruitment_value.jpg`: Gráfico de dispersión de edad frente al *Scouting Score* para localizar las ineficiencias del mercado.
* `padj_defensive_profile.jpg`: Mapeo visual del volumen de entradas frente a intercepciones con la corrección de posesión (PAdj) aplicada.

### Tablas y exportaciones de datos (`outputs/tables/`)
* `top_recruitment_targets.csv`: Clasificación general de los mejores perfiles según el score global de scouting.
* `market_inefficiency_targets.csv`: Registro filtrado de los jugadores sub-24 con rendimiento por encima del percentil 80.
* `player_similarity.csv`: Matriz cruzada de similitud del coseno.
* `player_similarity_results.csv`: Historial ordenado con las mejores alternativas y porcentaje de coincidencia para el jugador objetivo.
* `cluster_profiles.csv`: Tabla con las medias estadísticas que definen el comportamiento de cada grupo.
* `player_cluster_assignments.csv`: Listado de futbolistas con su arquetipo táctico asignado.
* `xt_proxy_ranking.csv`: Ranking de los jugadores con mayor Índice de Progresión.
* `defensive_ranking.csv`: Clasificación de los perfiles más eficientes en tareas destructivas.
* `padj_defensive_metrics.csv`: Base de datos de trabajo con el cálculo final del proxy de posesión y métricas PAdj.
* `scouting_dashboard.csv`: Matriz unificada lista para herramientas de BI (Tableau, PowerBI).
---

## Autor

**Adrián Gómez Conde** 

*Candidato a Máster en Bioestadística* 

*Modelización estadística, análisis multivariante y analítica deportiva aplicada*
