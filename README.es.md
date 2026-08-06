[![en](https://img.shields.io/badge/lang-en-blue.svg)](README.md)
[![R](https://img.shields.io/badge/hecho%20con-R-276DC3.svg)](https://www.r-project.org/)
[![Licencia: MIT](https://img.shields.io/badge/licencia-MIT-green.svg)](LICENSE)

# Identificación de centrales modernos con buena salida de balón

> Framework estadístico multivariante aplicado en R para perfilar, clasificar y encontrar sustitutos estadísticos de centrales en las cinco grandes ligas europeas — con ponderación de fiabilidad empírico-bayesiana, un análisis declarado de sensibilidad de pesos, y el score compuesto validado fuera de muestra contra resultados reales de 2024-25.

El pipeline combina métricas defensivas ajustadas por posesión, ponderación de variables mediante PCA, shrinkage empírico-bayesiano de tasas de muestra pequeña, clustering K-means y similitud del coseno para ir más allá de las estadísticas brutas y detectar objetivos de reclutamiento con contexto real. Cada decisión de diseño que normalmente se queda sin examinar en un modelo de scouting —el número de clusters, la redundancia entre variables, cuánto se puede confiar en una muestra pequeña de minutos, cuánto importan los pesos elegidos a mano, si el score predice algo real— se comprueba y se reporta a continuación, incluso cuando el resultado es negativo.

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

Los dos últimos filtros posicionales existen para eliminar laterales y carrileros que el dataset de origen sigue etiquetando como `DF`. Un cribado de outliers multivariante (D² de Mahalanobis, ver [Diagnósticos estadísticos](#diagnósticos-estadísticos)) marca a 20 de los 407 como combinaciones estadísticamente atípicas de estas variables de filtrado — se reportan, no se eliminan, porque "atípico" no es lo mismo que "erróneo".

**Los datos son de 2023-25.** Una actualización a 2025-26 es posible pero no automática desde un entorno alojado — ver [Mantener los datos al día](#mantener-los-datos-al-día).

---

## Metodología

### 1. Tasas ponderadas por fiabilidad (shrinkage empírico-bayesiano)
Un jugador con 900 minutos (10 partidos) y otro con 3.420 (38 partidos) pueden mostrar la misma tasa de entradas por 90, pero la primera estimación es mucho más ruidosa. Tratarlas como igual de fiables es un error estadístico real, y concretamente infla justo los perfiles de pocos minutos y sub-24 que este proyecto pretende identificar como "ineficiencias de mercado".

Cada tasa basada en conteo (pases progresivos, conducciones progresivas, pases clave, entradas, intercepciones, recuperaciones) se corrige con el estimador empírico-bayesiano conjugado Poisson-Gamma, el ejemplo de libro de texto — el mismo mecanismo detrás del shrinkage de promedios de bateo de Efron & Morris (1975), aplicado aquí a acciones defensivas en vez de hits. `MASS::glm.nb()` ajusta `count ~ offset(log(minutos/90))` por métrica, dando la tasa media poblacional (μ) y la dispersión (θ); la media posterior para el jugador *i* es `(θ + conteo_i) / (θ/μ + minutos_i/90)` — encogida hacia la media poblacional en proporción inversa a sus minutos jugados. La corrección es real y va donde debe: el encogimiento medio absoluto en el cuartil inferior de minutos jugados es **2-3 veces mayor** que en el cuartil superior, en las seis métricas.

### 2. Ingeniería de variables
Todas las métricas están normalizadas por 90 minutos, usando las tasas ya encogidas. Los indicadores compuestos son:

- **Índice de progresión** — combinación ponderada de pases progresivos, conducciones progresivas y pases clave por 90. Los pesos no se eligen a mano: son los loadings absolutos normalizados del PC1 de un PCA sobre esas tres variables (**0,36 / 0,36 / 0,28**). El PC1 explica el **66,8%** de la varianza conjunta de las tres variables, que es justo lo que justifica reducirlas a un único eje ponderado.
- **Defensa ajustada por posesión (PAdj)** — la posesión del equipo se estima a partir del volumen de pases frente a la media de la liga, y después un multiplicador sigmoideo `2 / (1 + exp(-0,1 × (posesión − 50)))` reescala entradas, intercepciones y recuperaciones. Los defensas de equipos dominantes tienen menos oportunidades defensivas, así que sus conteos brutos se ajustan al alza.
- **Scouting score** — la métrica maestra de clasificación:

  ```
  scouting_score = índice_progresión        × 0,40
                 + defending_score_PAdj      × 0,30
                 + (precisión_pase / 100)    × 0,10
                 + age_score                 × 0,20
  ```

  La curva de edad premia las ventanas de máximo rendimiento (`≤24 → 1,00`; `≤28 → 0,95`; `≤31 → 0,85`; `≤33 → 0,70`; resto `0,50`). Un chequeo de VIF confirma que los cuatro pilares no son redundantes entre sí (todos con VIF ≤ 1,13 — ver diagnósticos abajo). Un chequeo GAM de la propia curva de edad está en [Diagnósticos estadísticos](#diagnósticos-estadísticos).

### 3. ¿Cuánto importa la elección concreta 40/30/10/20?
Los pesos codifican una filosofía de reclutamiento, no un ajuste estadístico, así que su influencia se mide directamente. Se generan 2.000 conjuntos de pesos alternativos mediante muestreo de una distribución Dirichlet centrada en 40/30/10/20 (una forma con base estadística de simular "desacuerdo razonable" sobre la ponderación), y se recalcula el ranking cada vez. Ver [Diagnósticos estadísticos](#diagnósticos-estadísticos) para el resultado.

### 4. Clustering y roles tácticos
Los jugadores se segmentan en cuatro arquetipos con K-means (`k = 4`, `nstart = 50`, `set.seed(123)`) sobre variables de progresión y defensa PAdj tipificadas. Las etiquetas de rol **no están fijadas a mano**: el pipeline lee los centroides y asigna los nombres por eliminación (mayor progresión → *Elite Progressive Distributor*; después mayor volumen defensivo → *High-Intensity Ball-Winner*; después menor progresión → *Limited / Reactive Defender*; el restante → *Standard Build-up Distributor*). `k = 4` es una elección deliberada y declarada — ver [Diagnósticos estadísticos](#diagnósticos-estadísticos) para la evidencia de codo/silueta.

### 5. Motor de similitud
Una función de similitud del coseno sobre el espacio de características estandarizado. Ingiere el nombre de cualquier jugador objetivo y devuelve las coincidencias estadísticas más cercanas, para planificación de sucesiones.

---

## Hallazgos principales

**Mejores scouting scores** — Sead Kolašinac (Atalanta, **4,75**) lidera el ranking general, seguido de Riccardo Calafiori (Bologna, **4,65**) y Timo Hübers (Colonia, **4,56**).

**Líderes en progresión** — Iñigo Martínez (Barcelona, **4,07**) lidera el índice de progresión, combinando un volumen alto de pases progresivos con conducción de élite. Nico Schlotterbeck (Dortmund, **3,62**) actúa como referencia secundaria.

**Defensa ajustada por posesión** — tras normalizar el dominio del equipo, Timo Hübers (**12,36** PAdj combinado) y Riccardo Calafiori (**12,16**) emergen como los recuperadores más activos de la muestra.

**Objetivos de mercado sub-24** — Riccardo Calafiori (21, 4,65) es el más destacado. Otros perfiles jóvenes de élite señalados por el algoritmo: Nico Schlotterbeck (24, 4,44), Wilfried Singo (23, 4,35) y Giorgio Scalvini (19, 4,33). Alidu Seidu (23) sigue en la lista con 3,99, pero siete puestos por debajo de antes de aplicar la ponderación por fiabilidad — se explica por qué más abajo.

**Motor de similitud** — consultado contra el perfil mejor clasificado (Sead Kolašinac), el motor devuelve a Mario Gila (**96,7%** de similitud del coseno), Javi Rodríguez (95,0%) y César Azpilicueta (94,3%).

**Distribución de arquetipos** — Limited / Reactive Defender (157), Standard Build-up Distributor (147), High-Intensity Ball-Winner (67), Elite Progressive Distributor (36). El shrinkage acercó un número considerable de perfiles "extremos" de muestra pequeña hacia los dos arquetipos intermedios — ver más abajo.

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

## Diagnósticos estadísticos

Comprobaciones que normalmente se quedan implícitas en un índice de scouting, ejecutadas y reportadas de forma explícita:

| Diagnóstico | Método | Resultado | Veredicto |
|---|---|---|---|
| Fiabilidad de muestra pequeña | Shrinkage empírico-bayesiano Poisson-Gamma (`MASS::glm.nb`) sobre 6 métricas de tasa | Cuartil inferior de minutos encogido 2-3× más que el cuartil superior | Las tasas de "explosión" con pocos minutos ahora se descuentan por su tamaño de muestra, no se tratan como igual de fiables |
| Sensibilidad de pesos | 2.000 reponderaciones Dirichlet de 40/30/10/20 | Mediana de Spearman ρ = **0,989** vs. ranking original; solapamiento del Top-10 **87,9%** de media | El ranking es en general robusto a un desacuerdo razonable sobre los pesos — con excepciones nombradas, ver abajo |
| Cribado de outliers multivariantes | D² de Mahalanobis vs. límite k+3√(2k) sobre las 7 variables de filtrado/scoring | 20 / 407 jugadores (4,9%) marcados | Se reportan, no se eliminan — ver [`qc_mahalanobis_outliers.csv`](outputs/tables/qc_mahalanobis_outliers.csv) |
| Justificación de los pesos PCA | Varianza explicada por el PC1 de las 3 variables de progresión | PC1 = 66,8%, PC2 = 21,1%, PC3 = 12,2% | El dominio del PC1 respalda usar solo sus loadings como pesos |
| Multicolinealidad | VIF sobre cada grupo de variables del compuesto (`car::vif`) | Todos los VIF ≤ 1,77 (umbral de alarma: 10) | Sin redundancia entre variables en ningún nivel del score |
| Curva de edad | GAM (`mgcv::gam`) de output crudo vs. edad, progresión y defensa ajustadas por separado | Defensa: p = 0,0056 pero R² = 0,025 (pequeño); Progresión: p = 0,66 (sin relación) | Evidencia débil en ambos sentidos — el escalón fijado a mano no se contradice, pero tampoco se respalda con fuerza; no se sustituye en esta ronda, ver figura abajo |
| Número de clusters (`k`) | Codo (WSS) + silueta para k = 2–8 | Óptimo estadístico k = 2 (silueta 0,344); el k = 4 usado tiene silueta 0,259 | k = 4 es un trade-off de interpretabilidad declarado, no el máximo estadístico |
| Validez del clustering | K-means vs. clustering jerárquico independiente (enlace de Ward) | Índice de Rand Ajustado = 0,295, correlación cofenética = 0,496, 62,4% de acuerdo por fila | Acuerdo más débil que antes del shrinkage (era 0,419) — encoger varianza real entre jugadores junto con el ruido también suavizó las fronteras de los clusters; sigue muy por encima del azar |

![Diagnóstico de selección de k](outputs/figures/cluster_k_selection.png)

**Sensibilidad de pesos, nombre a nombre:** la mayor parte del Top-10 actual apenas se mueve bajo 2.000 reponderaciones plausibles — Kolašinac se mantiene en el top-10 en el 100% de las réplicas, Schlotterbeck y Singo en el 99,7%, Calafiori en el 98,5%. Pero el final del Top-10 es genuinamente frágil: **Alidu Seidu (52,0%) y Mohammed Salisu (49,4%) son prácticamente una moneda al aire** — que entren o no depende casi tanto de la ponderación concreta como de sus números de base. Es una afirmación bastante más honesta que simplemente "aquí está el top 10".

![Sensibilidad de pesos](outputs/figures/weight_sensitivity.png)

**Qué cambió el shrinkage, en concreto:** Alidu Seidu jugó solo 1.131 minutos antes de su traspaso de enero de 2024. Sus entradas/90 crudas (2,55) e intercepciones/90 (1,99) parecían de élite; las estimaciones ponderadas por fiabilidad (2,08 y 1,59) siguen siendo buenas pero ya no excepcionales — parte de sus números PAdj destacados eran una racha de muestra pequeña, no una tasa estable. Bajó del **#5 (4,62)** en la versión anterior sin encoger de este modelo al **#10 (3,99)**. Es exactamente el tipo de corrección que el método está diseñado para hacer, y justo el perfil —pocos minutos, mucho hype— donde más importa.

![Curva de edad empírica](outputs/figures/age_curve_gam.png)

---

## Validación del modelo

Un scouting score solo es útil si es capaz de decir algo cierto sobre jugadores que no ha visto. Para comprobarlo, se reajustó todo el pipeline —incluido el paso de shrinkage— usando **solo datos de 2023-24**, y se contrastó contra lo que realmente ocurrió la temporada siguiente — una partición Train/Test temporal genuina, no k-fold aleatorio, porque aquí el orden temporal es precisamente lo que no puede filtrarse.

**Planteamiento:** 278 centrales activos en 2023-24. Outcome: ¿jugó el jugador ≥ 900 minutos en 2024-25 (`retained`)? El 64,0% sí lo hizo.

| Modelo | Predictor(es) | Resultado clave | AIC |
|---|---|---|---|
| Solo intercepto | — | referencia | 365,2 |
| Regresión logística | `scouting_score` | OR = 1,38 (IC95% 0,83–2,32), **p = 0,22 — no significativo** | 365,7 |
| Regresión logística | 4 componentes por separado | `age_score` OR = 22,5, **p = 0,0015**; `progression_index` OR = 1,72, p = 0,049; `defending_score` y `pass_completion` no significativos | 354,1 |

**Resultado principal, sin cambios tras el shrinkage: el `scouting_score` compuesto no predice de forma significativa si un jugador sigue jugando la temporada siguiente.** `age_score` por sí solo es un predictor fuerte y significativo de la retención (los jugadores más jóvenes tienen sencillamente más probabilidad de seguir jugando), pero solo pesa un **20%** del compuesto por diseño, porque el score clasifica *capacidad futbolística*, no *supervivencia en la muestra*. Un test de razón de verosimilitud confirma que la ponderación fija es una restricción real y medible para esta tarea de predicción concreta (χ², p < 0,001).

Como contraste descriptivo (no causal), la tasa de retención sí se alinea con los propios arquetipos del algoritmo: Elite Progressive Distributor 81,5% (n=27), High-Intensity Ball-Winner 64,1% (n=39), Standard Build-up Distributor 63,1% (n=111), Limited / Reactive Defender 60,4% (n=101).

![Validación temporal](outputs/figures/temporal_validation.png)

**Qué muestra esta validación y qué no:** "jugar 900+ minutos la temporada siguiente" es un proxy débil e indirecto de la calidad de scouting —depende al menos tanto de lesiones, profundidad de plantilla y el sistema de un entrenador como de la capacidad del jugador, y un gran perfil de scouting no garantiza titularidad en el club comprador. Un resultado nulo aquí no significa que el score esté mal; significa que la retención bruta es el objetivo equivocado para validarlo. Salida completa del modelo: [`temporal_validation_results.csv`](outputs/tables/temporal_validation_results.csv).

---

## ¿Esto encuentra de verdad algo que el mercado no supiera ya?

Respuesta corta: **no, en realidad no — y es un hallazgo importante y declarado, no una nota al pie.** Comprobando los nombres destacados de este informe contra lo que realmente pasó en el mercado de fichajes:

| Jugador | Lo que dice este informe | Lo que pasó en realidad |
|---|---|---|
| Alidu Seidu | "Ineficiencia de mercado" en el Clermont, 2023-24 | Vendido al Rennes por **11M€** el **29 de enero de 2024** — a mitad de la misma temporada que puntúa este modelo, tras solo 14 partidos de Ligue 1 |
| Riccardo Calafiori | Destacado sub-24, 2023-24 | Vendido Bologna → Arsenal por **~45-49M€** en verano de 2024, tras una Eurocopa 2024 destacada |
| Wilfried Singo | Destacado sub-24 | Ya vendido Torino → Mónaco por **10M€** en verano de 2023, antes incluso de que empiece la ventana de este análisis |
| Giorgio Scalvini | El adolescente con mejor puntuación | El Atalanta lo declaró "intransferible" con una valoración de **60M€** y cuatro clubes de la Premier League interesados |
| Mario Gila | Mejor coincidencia de similitud del coseno | Producto de la cantera del Real Madrid; el Lazio ya pagó **6M€** por él en 2022, dos años antes de este análisis |

Todos los nombres destacados de este informe ya habían sido detectados, valorados y en la mayoría de los casos ya vendidos por departamentos de scouting profesionales con información mucho más rica (vídeo, datos médicos, valoración de carácter personal) —normalmente antes de que terminara la temporada que este modelo puntúa. Este modelo tiene buena precisión identificando calidad; no tiene **ninguna ventaja de anticipación sobre el mercado real**, y ningún modelo público basado en estadísticas de conteo razonablemente podría tenerla.

Por eso existe `scripts/scripts_optional_market_value_residuals.R`: sustituye la definición actual y arbitraria de "ineficiencia de mercado" ("sub-24 + percentil 80") por una real — regresando el logaritmo del valor de mercado sobre `scouting_score`, edad y liga, y señalando a los jugadores cuyo precio *real* en Transfermarkt está estadísticamente por debajo de lo que predice su rendimiento. Esa sí es una afirmación de ineficiencia genuina; un corte de percentil nunca lo fue. Ver [Mantener los datos al día](#mantener-los-datos-al-día) — como los scripts de posesión y de temporada fresca, necesita ejecutarse en local.

---

## Mantener los datos al día

Los datos son de 2023-25. Tres scripts opcionales y solo-locales los amplían — ninguno puede ejecutarse desde un entorno alojado/sandbox, por las razones que indica cada uno:

| Script | Qué añade | Por qué es manual |
|---|---|---|
| `scripts_ingest_fresh_season.R` | Armoniza un CSV de la temporada 2025-26 (p. ej. el mirror de FBref de [Kaggle](https://www.kaggle.com/datasets/hubertsidorowicz/football-players-stats-2025-2026), mantenido por la comunidad y actualizado semanalmente) al esquema del pipeline | Kaggle exige una cuenta autenticada / token de API |
| `scripts_optional_real_possession.R` | Sustituye el proxy de posesión estimada por el % de posesión real de FBref vía [`worldfootballR`](https://jaseziv.github.io/worldfootballR/) | FBref bloquea IPs de centros de datos con Cloudflare (confirmado al construir este pipeline) |
| `scripts_optional_market_value_residuals.R` | Valores de mercado reales de Transfermarkt, y una definición de "infravalorado" basada en el residuo de una regresión (ver arriba) | `transfermarkt.com` ni siquiera resuelve por DNS desde este entorno de construcción — una restricción más fuerte que la de FBref |

Los tres están programados de forma defensiva (detección automática de columnas, mensajes de fallo explícitos, sin números incorrectos en silencio) y se verificaron todo lo posible sin acceso en vivo — ver la cabecera de comentarios de cada script para lo que se pudo y no se pudo probar.

---

## Reproducir el análisis

Requiere R (≥ 4.1) y seis paquetes (`car` y `MASS` se usan solo con `::` y nunca se cargan enteros, ya que `MASS` enmascara `dplyr::select()`; `cluster` y `mgcv` se instalan junto con R):

```bash
Rscript -e "install.packages(c('tidyverse','ggrepel','proxy','factoextra','car','MASS'), repos='https://cloud.r-project.org')"
```

Después, desde la raíz del repositorio:

```bash
Rscript scripts/run_all.R
```

El pipeline es determinista (`set.seed(123)` en cada K-means y muestreo Dirichlet) y regenera todos los archivos de `outputs/` en seis pasos: comprobación de dependencias → proxy de posesión → scoring (shrinkage, PCA, VIF, sensibilidad de pesos, GAM) → clustering → motor de similitud → validación temporal. Los pasos se ejecutan en orden y se detienen ante el primer error, ya que cada uno consume la salida del anterior.

---

## Archivos generados

### Gráficas (`outputs/figures/`)
| Archivo | Descripción |
| --- | --- |
| `defender_archetypes.png` | Índice de progresión vs defending score, coloreado por perfil de rol y tamaño por scouting score |
| `cluster_pca_visualization.png` | Proyección PCA 2D con arquetipos K-means, top 15 etiquetado |
| `recruitment_value.png` | Edad vs scouting score, para localizar ineficiencias de mercado |
| `cluster_k_selection.png` | Diagnóstico de codo (WSS) y silueta detrás de la elección k = 4 |
| `weight_sensitivity.png` | Distribución de correlaciones de ranking sobre 2.000 conjuntos de pesos perturbados Dirichlet |
| `age_curve_gam.png` | Curva de edad empírica GAM (progresión y defensa por separado) vs. la función escalón |
| `temporal_validation.png` | Ajuste logístico de la retención 2024-25 frente al scouting score de 2023-24 |
| `market_value_residuals.png` | *(solo local)* Valor de mercado predicho vs. real |

### Tablas (`outputs/tables/`)
| Archivo | Descripción |
| --- | --- |
| `top_recruitment_targets.csv` | Top 25 jugadores por scouting score general |
| `market_inefficiency_targets.csv` | Sub-24 por encima del percentil 80 (basado en percentil; ver la alternativa por residuos arriba) |
| `progression_ranking.csv` | Top 20 jugadores por índice de progresión |
| `defensive_ranking.csv` | Top 20 jugadores por defending score ajustado por posesión |
| `padj_defensive_metrics.csv` | Dataset maestro completo — tasas encogidas y crudas, estadísticas PAdj, todas las estimaciones de contexto |
| `cluster_profiles.csv` | Estadísticas medias por cluster / rol asignado |
| `final_scouting_dashboard.csv` | Lista completa de jugadores con roles tácticos asignados por el algoritmo |
| `player_similarity_results.csv` | Mejores coincidencias por similitud del coseno para la consulta objetivo |
| `shrinkage_diagnostics.csv` | Magnitud media del encogimiento por cuartil de minutos jugados, por métrica |
| `weight_sensitivity_top10.csv` | Tasa de retención en el Top-10 por jugador, a través de las reponderaciones |
| `weight_sensitivity_replications.csv` | Salida cruda de las 2.000 réplicas Dirichlet |
| `qc_mahalanobis_outliers.csv` | Cribado de outliers multivariantes (marcados, no eliminados) |
| `pca_variance_explained.csv` | Varianza explicada por componente, PCA de progresión |
| `vif_diagnostics.csv` | Chequeo de multicolinealidad para cada grupo de variables del compuesto |
| `age_curve_gam.csv` | Valores GAM ajustados, output de progresión y defensa vs. edad |
| `cluster_k_selection.csv` | WSS y ancho medio de silueta para k = 2–8 |
| `kmeans_vs_hierarchical_agreement.csv` | Tabla de contingencia K-means vs. clustering jerárquico |
| `temporal_validation_results.csv` | Salida completa del GLM (train 2023-24 / test 2024-25) |
| `temporal_validation_predictions.csv` | Datos de predicción por jugador detrás de la validación |
| `temporal_validation_retention_by_role.csv` | Tasa de retención por arquetipo táctico |
| `market_inefficiency_residuals.csv` | *(solo local)* Ranking de "infravalorados" por residuo de regresión |
| `market_value_unmatched_players.csv` | *(solo local)* Jugadores de FBref sin valor de Transfermarkt emparejado |

---

## Limitaciones

Se declaran explícitamente porque acotan cómo debe leerse el ranking:

- **La posesión es un proxy, no una medición.** Se infiere del volumen de pases del equipo frente a la media de la liga. `scripts_optional_real_possession.R` lo sustituye por datos reales de FBref, pero solo al ejecutarse en local.
- **La muestra combina dos temporadas, y es de 2023-25.** Ver [Mantener los datos al día](#mantener-los-datos-al-día) para el camino (solo local) hacia 2025-26.
- **Los pesos del compuesto los fija el analista, no se ajustan estadísticamente.** Se comprueba que no son redundantes entre sí (VIF ≤ 1,13), se testa su validez predictiva fuera de muestra, y se someten a estrés contra 2.000 reponderaciones razonables — pero "comprobado" no es "optimizado": no se ha usado ninguna variable outcome para ajustarlos, y el final del Top-10 (Seidu, Salisu) es genuinamente sensible a la elección concreta.
- **`k = 4` es un trade-off declarado, no el óptimo estadístico**, y la separación de clusters se debilitó tras el shrinkage (el ARI bajó de 0,419 a 0,295) — encoger ruido también arrastró varianza real entre jugadores. Los clusters siguen muy por encima del acuerdo por azar con un método independiente, pero deben leerse como tendencias amplias, no categorías nítidas.
- **La curva de edad es una función escalón fijada a mano** que un chequeo GAM ni confirma con fuerza ni contradice (el output de progresión no muestra ninguna relación con la edad en estos datos; el de defensa muestra una pequeña, estadísticamente real). No se sustituye en esta ronda por falta de una alternativa fiable.
- **Los minutos de la temporada siguiente son un objetivo de validación débil e indirecto**, sin cambios tras la actualización del shrinkage — la retención depende de lesiones, profundidad de plantilla y contexto de club que ninguna métrica de scouting captura.
- **Este modelo prácticamente no tiene ventaja de anticipación sobre el scouting profesional.** Ver [¿Esto encuentra de verdad algo que el mercado no supiera ya?](#esto-encuentra-de-verdad-algo-que-el-mercado-no-supiera-ya) — todos los nombres destacados de este informe ya eran conocidos por departamentos de reclutamiento reales, normalmente antes de que terminara la temporada puntuada.
- **Los traspasos a mitad de temporada** se gestionan a nivel de fila según el dataset de origen; el contexto PAdj de un jugador refleja únicamente el equipo de esa fila.
- **El modelo no ve** disponibilidad ni historial de lesiones, duelos aéreos, errores defensivos, situación contractual ni (sin el script opcional de residuos) valor de mercado. Es una herramienta de preselección, no una decisión de fichaje.

---

## Tecnologías

- R
- tidyverse (dplyr, tibble, ggplot2)
- ggrepel
- proxy (similitud del coseno)
- MASS (`glm.nb` — shrinkage empírico-bayesiano)
- cluster (ancho de silueta, paquete "recommended" de R base)
- mgcv (diagnóstico GAM de la curva de edad, paquete "recommended" de R base)
- car (VIF)
- stats::glm, stats::hclust, stats::mahalanobis, stats::prcomp, stats::rgamma (R base)
- worldfootballR (opcional, datos reales de posesión y valor de mercado solo en local)

---

## Estructura del repositorio

```text
football-data-analysis/
│
├── data/
│   ├── All_Players_1992-2025.csv        # dataset original
│   ├── player_stats_2024_2025.csv       # extracto reducido de una temporada
│   ├── raw/                             # deja aquí un CSV de temporada fresca (ver scripts_ingest_fresh_season.R)
│   └── processed/
│       ├── defenders_processed.csv      # tabla maestra con scores
│       └── team_possession_proxy.csv    # estimaciones de posesión + multiplicadores PAdj
│
├── scripts/
│   ├── setup_packages.R                          # comprobación de dependencias
│   ├── scripts_padj_metrics.R                    # proxy de posesión + multiplicadores PAdj
│   ├── scripts_scouting.R                        # shrinkage, PCA, QC, VIF, sensibilidad de pesos, GAM, scores compuestos
│   ├── scripts_clustering.R                      # selección de k, K-means, contraste jerárquico, figuras
│   ├── scripts_similarity_engine.R               # similitud del coseno
│   ├── scripts_temporal_validation.R             # validación GLM train/test (2023-24 -> 2024-25)
│   ├── scripts_ingest_fresh_season.R             # [opcional/manual] armonizar un CSV 2025-26 (p. ej. Kaggle)
│   ├── scripts_optional_real_possession.R        # [opcional/manual] posesión real de FBref vía worldfootballR
│   ├── scripts_optional_market_value_residuals.R # [opcional/manual] valores de mercado reales + modelo de ineficiencia por residuos
│   └── run_all.R                                 # pipeline maestro (6 pasos)
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
