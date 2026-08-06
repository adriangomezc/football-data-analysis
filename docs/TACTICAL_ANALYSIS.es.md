[![en](https://img.shields.io/badge/lang-en-blue.svg)](TACTICAL_ANALYSIS.md)

# Análisis táctico y perfilado de centrales modernos

← Volver al [README principal](../README.es.md)

## Resumen

Este informe desglosa los perfiles tácticos de centrales en las cinco grandes ligas europeas. Un framework de clustering K-means (k=4) y Análisis de Componentes Principales aísla comportamientos distintos, mientras que las métricas ajustadas por posesión (PAdj) aportan el contexto que las estadísticas brutas omiten.

**Muestra.** 407 centrales puros, cada uno con **su temporada válida más reciente**: 286 de 2024–25 y 121 de 2023–24. Por eso todas las tablas incluyen columna de temporada: el ranking compara a los jugadores en su último estado de forma disponible, no dentro de una única campaña fija.

**Sead Kolašinac** (Atalanta) lidera el framework de scouting compuesto con una puntuación global de 5,08, seguido por **Riccardo Calafiori** (Bologna, 4,98) y **Timo Hübers** (Colonia, 4,84). En progresión pura con balón, **Iñigo Martínez** (Barcelona) registra el índice de progresión más alto de la muestra con 4,31.

La aplicación de la curva sigmoidea para las métricas ajustadas por posesión revela que los recuentos defensivos están fuertemente condicionados por el dominio del equipo. Tras normalizar por oportunidad real, **Timo Hübers** (13,31 PAdj combinado) y **Riccardo Calafiori** (13,18) emergen como los defensores más activos de la muestra.

Dos preguntas que cualquier analista serio debería hacerse antes de fiarse de todo esto —¿es el modelo internamente sólido? y ¿predice algo real?— se responden directamente en las secciones 6 y 7, incluso cuando la respuesta es solo parcial.

---

## 1. Perfiles tácticos y desglose de grupos

El clustering K-means (k=4) sobre las variables tipificadas de progresión y defensa PAdj segmenta a los jugadores en cuatro arquetipos tácticos. El algoritmo asigna los roles leyendo los centroides de cada cluster, en lugar de fijarlos a mano.

| Arquetipo | Jugadores | Índice de progresión medio | Entradas + int. PAdj medias | Precisión de pase media |
|:----------|----------:|---------------------------:|----------------------------:|------------------------:|
| Elite Progressive Distributor | 48 | 2,65 | 2,53 | 88,4% |
| Standard Build-up Distributor | 117 | 1,67 | 2,16 | 87,5% |
| High-Intensity Ball-Winner | 97 | 1,30 | 3,66 | 84,1% |
| Limited / Reactive Defender | 145 | 0,95 | 2,28 | 85,8% |

### 1.1. Distribuidores progresivos de élite
- **Perfil:** Directores de juego desde atrás en estructuras de alta posesión o sistemas de tres centrales con mucha libertad de conducción. Registran el mayor volumen de progresión y también la mejor precisión de pase.
- **Ejemplos destacados:** Sead Kolašinac, Nico Schlotterbeck, Iñigo Martínez.

### 1.2. Recuperadores de alta intensidad
- **Perfil:** Centrales muy proactivos, orientados al salto, la anticipación y el duelo. Presentan el mayor output defensivo PAdj del ecosistema y, como contrapartida, la peor precisión de pase.
- **Ejemplos destacados:** Riccardo Calafiori, Timo Hübers, Alidu Seidu.

### 1.3. Distribuidores estándar en construcción
- **Perfil:** El tipo modal de central moderno. Buen volumen de pase de seguridad y progresión intermedia, con la implicación defensiva más conservadora de los cuatro grupos. Es la referencia comparativa de la muestra.
- **Ejemplos destacados:** Tyrone Mings, Ezri Konsa.

### 1.4. Defensores limitados o reactivos
- **Perfil:** Contribución mínima en la progresión del balón. Frecuentes en sistemas defensivos estructurados o bloques bajos con escasa responsabilidad en la salida. Es el grupo más numeroso de la muestra.
- **Ejemplos destacados:** Saúl Coco, Matija Nastasić.

---

## 2. Métricas avanzadas y contexto táctico

### 2.1. Defensa ajustada por posesión (PAdj)

Contar acciones brutas penaliza a los defensores de equipos dominantes. Al aplicar el multiplicador sigmoideo utilizando la media de la liga como proxy, normalizamos la intensidad defensiva por oportunidad real de intervención. El cálculo combina entradas, intercepciones y recuperaciones ajustadas.

| Jugador | Equipo | Liga | Temporada | Puntuación defensiva PAdj (combinada) |
|:--------|:-------|:-----|:----------|--------------------------------------:|
| **Timo Hübers** | Köln | Bundesliga | 2023–24 | **13,31** |
| **Riccardo Calafiori** | Bologna | Serie A | 2023–24 | **13,18** |
| **Alidu Seidu** | Clermont Foot | Ligue 1 | 2023–24 | **12,49** |
| **Giorgio Scalvini** | Atalanta | Serie A | 2023–24 | **11,77** |
| **Sead Kolašinac** | Atalanta | Serie A | 2024–25 | **11,50** |

### 2.2. Índice de progresión

Esta métrica combina pases progresivos, conducciones progresivas y pases clave por 90. Los pesos no son arbitrarios, sino que se extraen dinámicamente de los loadings del PC1 de un Análisis de Componentes Principales (0,346 / 0,352 / 0,302).

| Jugador | Equipo | Temporada | Índice de progresión | Pases prog./90 | Conducciones prog./90 |
|:--------|:-------|:----------|---------------------:|---------------:|----------------------:|
| **Iñigo Martínez** | Barcelona | 2024–25 | **4,31** | 9,40 | 2,53 |
| **Nico Schlotterbeck** | Dortmund | 2024–25 | **3,90** | 8,85 | 1,68 |
| **Sead Kolašinac** | Atalanta | 2024–25 | **3,43** | 6,72 | 2,46 |
| **Manuel Akanji** | Manchester City | 2024–25 | **3,29** | 7,06 | 2,06 |
| **Eric García** | Girona | 2023–24 | **3,25** | 7,54 | 1,54 |

---

## 3. Panel de reclutamiento: mejores scouting scores

La puntuación compuesta maestra integra el índice de progresión (40%), el rendimiento defensivo PAdj (30%), la precisión de pase (10%) y una curva de valor por edad que prima el pico de rendimiento (20%).

| Jugador | Equipo | Temporada | Edad | Rol táctico asignado | Scouting score |
|:--------|:-------|:----------|:-----|:---------------------|---------------:|
| **Sead Kolašinac** | Atalanta | 2024–25 | 31 | Elite Progressive Distributor | **5,08** |
| **Riccardo Calafiori** | Bologna | 2023–24 | 21 | High-Intensity Ball-Winner | **4,98** |
| **Timo Hübers** | Köln | 2023–24 | 27 | High-Intensity Ball-Winner | **4,84** |
| **Nico Schlotterbeck** | Dortmund | 2024–25 | 24 | Elite Progressive Distributor | **4,73** |
| **Alidu Seidu** | Clermont Foot | 2023–24 | 23 | High-Intensity Ball-Winner | **4,62** |

Conviene ver cómo se compensan los componentes. Kolašinac lidera el ranking con 31 años pese a cargar con el multiplicador de edad más bajo del grupo (0,85), puramente por un índice de progresión de 3,43 —casi el doble que el 1,85 de Calafiori—. Calafiori recorta casi toda esa distancia por el otro lado: la mayor puntuación defensiva PAdj combinada de la muestra (13,18 frente a 11,50) más el bonus íntegro de sub-24. El margen final entre ambos es de 0,10 puntos.

---

## 4. Ineficiencias de mercado y perfiles sub-24

Filtrando exclusivamente a jugadores de 24 años o menos que superan el percentil 80 de rendimiento global:

- **Riccardo Calafiori (21, Bologna, 2023–24, 4,98):** El jugador más destacado en relación edad/rendimiento. Registra el mayor volumen de recuperaciones PAdj de toda la muestra (8,79 por 90) en la agresiva estructura de Thiago Motta, y la mayor puntuación defensiva PAdj combinada (13,18).
- **Nico Schlotterbeck (24, Dortmund, 2024–25, 4,73):** El sub-24 más dominante en progresión de balón (3,90). Un perfil de distribuidor de élite consolidado.
- **Alidu Seidu (23, Clermont Foot, 2023–24, 4,62):** Una ineficiencia de mercado real. Sus 12,49 de PAdj combinado se logran con un multiplicador de posesión *por debajo del neutro* (0,96): su output no está inflado por un equipo dominante, sobrevive al ajuste.
- **Giorgio Scalvini (19, Atalanta, 2023–24, 4,58):** El adolescente con mejor puntuación de la muestra por un margen claro. Ya rinde estadísticamente como un central consolidado en la élite europea.
- **Jarell Quansah (20, Liverpool, 2023–24, 4,00) y El Chadaille Bitshiabu (19, RB Leipzig, 2024–25, 3,81):** Perfiles en claro ascenso que ya superan el corte de exigencia técnica.

---

## 5. Motor de similitud: búsqueda de sucesiones

El algoritmo de similitud del coseno rastrea el espacio de características estandarizado para encontrar los perfiles tácticos más cercanos. La consulta se ejecutó buscando un sustituto para **Sead Kolašinac**, líder del ranking global.

### Mejores coincidencias estadísticas para Sead Kolašinac

| Posición | Jugador | Equipo (temporada en muestra) | Similitud del coseno |
|:---------|:--------|:------------------------------|---------------------:|
| 1 | **Mario Gila** | Lazio (2024–25) | **97,1%** |
| 2 | **Javi Rodríguez** | Celta de Vigo (2024–25) | **95,9%** |
| 3 | **Facundo Medina** | Lens (2024–25) | **95,3%** |
| 4 | **Mohamed Simakan** | RB Leipzig (2023–24) | **94,2%** |
| 5 | **Lutsharel Geertruida** | RB Leipzig (2024–25) | **94,0%** |

**Mario Gila** (97,1%) emerge como el relevo táctico casi perfecto: un central exterior con alta agresividad en la recuperación y mucha facilidad para conducir y romper líneas de presión. **Facundo Medina** (95,3%) representa otra opción natural de perfil zurdo y agresivo. Las cinco coincidencias pertenecen al cluster *Elite Progressive Distributor* salvo Javi Rodríguez, clasificado como *Standard Build-up Distributor*: un recordatorio de que la similitud del coseno sobre el espacio de características y la asignación dura a un cluster responden a preguntas ligeramente distintas.

---

## 6. Comprobaciones de robustez estadística

Antes de fiarse de un ranking conviene preguntarse si la maquinaria que lo produce es sólida: ¿son redundantes las variables de entrada entre sí?, ¿está justificado el número de clusters?, ¿hay jugadores tan atípicos que están distorsionando el cuadro? Las tres preguntas se comprueban directamente en vez de darse por supuestas.

### 6.1. Cribado de outliers multivariantes

Se aplicó un cribado por distancia de Mahalanobis (D²) sobre las siete variables que alimentan el filtrado y el scoring, con el límite estándar k + 3√(2k) para k = 7 (D² > 18,2). 20 de 407 jugadores (4,9%) lo superan.

| Jugador | Equipo | Temporada | D² |
|:--------|:-------|:----------|---:|
| Woyo Coulibaly | Parma | 2024–25 | 46,10 |
| Alidu Seidu | Clermont Foot | 2023–24 | 31,23 |
| César Azpilicueta | Atlético Madrid | 2023–24 | 29,95 |
| Iñigo Martínez | Barcelona | 2024–25 | 26,07 |
| Nicolás Valentini | Hellas Verona | 2024–25 | 24,58 |

Fíjate en quién aparece en esa lista: **Alidu Seidu e Iñigo Martínez son dos de los nombres destacados de las secciones 3 y 4 de este informe.** No es una contradicción, es exactamente lo que debe hacer un buen cribado de outliers. "Estadísticamente atípico" y "error de datos" producen el mismo D², y la única forma de distinguirlos es mirar. Aquí, al mirar, se confirma que ambos son atípicos porque son genuinamente excepcionales, no por un problema de datos. Por eso se marcan, nunca se eliminan en silencio. Listado completo: [`qc_mahalanobis_outliers.csv`](../outputs/tables/qc_mahalanobis_outliers.csv).

### 6.2. ¿Son redundantes entre sí las variables del compuesto?

Se aplicó un chequeo de factor de inflación de la varianza (VIF) sobre tres grupos: las tres variables del índice de progresión, las tres variables PAdj del defending score, y los cuatro pilares del scouting_score en sí mismo. Todos los VIF salieron ≤ 1,75 — muy lejos del umbral de alarma habitual (10). Ninguna de las variables del modelo está duplicando en silencio la señal de otra. Tabla completa: [`vif_diagnostics.csv`](../outputs/tables/vif_diagnostics.csv).

### 6.3. ¿Es k = 4 el número correcto de clusters?

Se ejecutaron el método del codo (WSS) y el de la silueta para k = 2 a 8:

| k | WSS | Silueta media |
|--:|----:|---------------:|
| 2 | 1352,8 | **0,335 (óptimo estadístico)** |
| 3 | 1083,0 | 0,265 |
| **4** | **910,4** | **0,241 (el usado en el pipeline)** |
| 5 | 793,0 | 0,233 |
| 6 | 721,0 | 0,238 |
| 7 | 667,8 | 0,228 |
| 8 | 616,0 | 0,212 |

La respuesta honesta es que k = 2 es el óptimo estadístico, y la silueta de k = 4 (0,241) está justo en el límite de lo que la regla de Kaufman & Rousseeuw llama "estructura débil" (por debajo de 0,25). Se mantuvo k = 4 de forma deliberada porque k = 2 colapsa la muestra en una división gruesa "progresivo vs. limitado" que descarta la granularidad táctica —intensidad recuperadora vs. estilo de distribución— sobre la que se construye el resto de este informe.

Esa decisión necesitaba una segunda comprobación: ¿un algoritmo que nunca ha oído hablar de K-means encuentra aproximadamente los mismos cuatro grupos? Cortar un dendrograma jerárquico (enlace de Ward) en el mismo k = 4 y compararlo con las etiquetas de K-means da un **Índice de Rand Ajustado de 0,419** y un **75,2%** de jugadores que caen en el grupo dominante correspondiente (correlación cofenética del propio dendrograma: 0,586). Es un acuerdo moderado —lejos de perfecto, pero muy por encima del ~0 esperable de dos métodos no relacionados que no coincidieran en nada. Los cuatro arquetipos son un rasgo real, aunque no nítidamente separado, de los datos, y no un artefacto de K-means. Tabla de contingencia completa: [`kmeans_vs_hierarchical_agreement.csv`](../outputs/tables/kmeans_vs_hierarchical_agreement.csv).

---

## 7. Validación predictiva: ¿predice el score algo real?

Todas las comprobaciones anteriores preguntan si el modelo es *internamente* coherente. Esta sección plantea una pregunta más difícil: reajustado usando **solo datos de 2023-24**, ¿dice el score resultante algo cierto sobre lo que ocurrió en **2024-25**, una temporada que nunca vio? Es una partición Train/Test temporal genuina (se ajusta con el pasado, se evalúa con el futuro), no un k-fold aleatorio, porque filtrar información futura al ajuste anularía el sentido de la prueba.

**Planteamiento.** 278 centrales activos en 2023-24, puntuados con pesos PCA reestimados solo en esa temporada. Outcome: ¿jugó ≥ 900 minutos en 2024-25 (`retained`)? El 64,0% sí.

| Modelo | Predictor(es) | Resultado | AIC |
|:-------|:---------------|:----------|----:|
| Solo intercepto | — | referencia | 365,2 |
| Regresión logística | `scouting_score` | OR = 1,28 (IC95% 0,85–1,97), **p = 0,24, no significativo** | 365,8 |
| Regresión logística | 4 componentes por separado | `age_score` OR = 22,6 (**p = 0,001**); `progression_index` OR = 1,60 (p = 0,053); `defending_score`, `pass_completion` n.s. | 354,2 |

**El score compuesto no predice de forma significativa la retención la temporada siguiente** (pseudo-R² de McFadden = 0,004). Entre los jugadores que sí fueron retenidos, el score tampoco predice cuánto jugaron (ρ de Spearman = −0,01, p = 0,90 frente a minutos de 2024-25).

**Por qué esto no es un fallo del score.** Descomponer el compuesto muestra exactamente dónde vive la (limitada) señal: `age_score` por sí solo es un predictor fuerte y muy significativo de la retención —los jugadores más jóvenes tienen sencillamente más probabilidad de seguir jugando la temporada siguiente, un efecto de etapa de carrera nada llamativo—. Pero `age_score` solo pesa un **20%** del compuesto, por diseño, porque el score está construido para clasificar *capacidad futbolística*, no para predecir *supervivencia en la muestra*. Que un score ponderado al 80% hacia la capacidad diluya una señal de edad fuerte pero estrecha hasta la no significación es exactamente lo que debería ocurrir si la ponderación está haciendo su trabajo. Un test de razón de verosimilitud lo precisa: el modelo de 4 parámetros sin restringir ajusta significativamente mejor que el compuesto de un único parámetro (χ², **p < 0,001**) — la ponderación fija 40/30/10/20 es una restricción real y medible para esta tarea de predicción concreta, no una representación gratuita de la misma información.

Como contraste puramente descriptivo (no causal), la tasa de retención sí se alinea con los propios arquetipos del algoritmo:

| Arquetipo | n | Tasa de retención |
|:----------|--:|--------------------:|
| Elite Progressive Distributor | 34 | 70,6% |
| Standard Build-up Distributor | 86 | 69,8% |
| High-Intensity Ball-Winner | 59 | 66,1% |
| Limited / Reactive Defender | 99 | 55,6% |

**Qué muestra esta validación y qué no.** "Jugar 900+ minutos la temporada siguiente" es un proxy débil e indirecto de la calidad de scouting: depende al menos tanto de lesiones, profundidad de plantilla y el sistema de un entrenador como de la capacidad del jugador, y un gran perfil de scouting no garantiza titularidad en el club comprador. El resultado nulo del score compuesto no significa que el ranking esté mal; significa que la retención bruta de la temporada siguiente es el objetivo equivocado para validar un ranking de *calidad*, y esa limitación ahora está medida y declarada en vez de darse por hecha en silencio. Salida completa del modelo: [`temporal_validation_results.csv`](../outputs/tables/temporal_validation_results.csv); figura: [`temporal_validation.png`](../outputs/figures/temporal_validation.png).

---

## 8. Conclusiones

- **El efecto de los sistemas de autor.** La presencia dominante de la Atalanta de Gasperini (Kolašinac, Scalvini) y de Calafiori en el Bologna de Thiago Motta de 2023–24 subraya cómo los sistemas de marcaje al hombre y proactividad defensiva elevan drásticamente las métricas PAdj de sus centrales.
- **Centrales vs laterales invertidos.** El filtro estricto de toques en el último tercio y de recepciones progresivas ha limpiado la base de datos de "falsos centrales", permitiendo que los verdaderos defensores progresivos (como Schlotterbeck o Iñigo Martínez) lideren el ranking sin la competencia de laterales ofensivos.
- **El ajuste hace trabajo real.** Alidu Seidu y Calafiori ilustran sus dos caras: los números de Seidu se sostienen *pese* a un multiplicador de posesión inferior a 1, mientras que los equipos de alta posesión ven corregidos al alza los conteos brutos de sus centrales. Ordenar por entradas e intercepciones sin ajustar habría producido una shortlist materialmente distinta.
- **La similitud como plan de sucesión.** El motor elimina el sesgo visual. Identificar a Mario Gila o Javi Rodríguez como perfiles gemelos a Kolašinac proporciona al departamento de scouting una preselección puramente objetiva, lista para ser filtrada por viabilidad económica.
- **Léase como una herramienta de preselección bien auditada, no como una decisión de fichaje.** Las secciones 6 y 7 muestran un modelo internamente coherente (sin variables redundantes, con una elección de clustering declarada y contrastada) pero cuyo score compuesto no predice los minutos brutos de la temporada siguiente — una limitación de lo que miden "los minutos", no una prueba de que el ranking sea arbitrario. Consulta la [sección de limitaciones](../README.es.md#limitaciones) del README principal antes de tomar cualquier orden como definitivo.
