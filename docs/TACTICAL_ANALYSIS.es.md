[![en](https://img.shields.io/badge/lang-en-blue.svg)](TACTICAL_ANALYSIS.md)

# Análisis táctico y perfilado de centrales modernos

← Volver al [README principal](../README.es.md)

## Resumen

Este informe desglosa los perfiles tácticos de centrales en las cinco grandes ligas europeas. Un framework de clustering K-means (k=4) y Análisis de Componentes Principales aísla comportamientos distintos, mientras que las métricas ajustadas por posesión (PAdj) y la ponderación por fiabilidad empírico-bayesiana aportan el contexto que las estadísticas brutas omiten.

**Muestra.** 407 centrales puros, cada uno con **su temporada válida más reciente**: 286 de 2024–25 y 121 de 2023–24. Por eso todas las tablas incluyen columna de temporada: el ranking compara a los jugadores en su último estado de forma disponible, no dentro de una única campaña fija.

**Sead Kolašinac** (Atalanta) lidera el framework de scouting compuesto con una puntuación global de 4,75, seguido por **Riccardo Calafiori** (Bologna, 4,65) y **Timo Hübers** (Colonia, 4,56). En progresión pura con balón, **Iñigo Martínez** (Barcelona) registra el índice de progresión más alto de la muestra con 4,07.

La aplicación de la curva sigmoidea para las métricas ajustadas por posesión revela que los recuentos defensivos están fuertemente condicionados por el dominio del equipo. Tras normalizar por oportunidad real, **Timo Hübers** (12,36 PAdj combinado) y **Riccardo Calafiori** (12,16) emergen como los defensores más activos de la muestra.

Tres preguntas que cualquier analista serio debería hacerse antes de fiarse de todo esto —¿es el modelo internamente sólido?, ¿predice algo real?, y ¿me dice algo que el mercado no supiera ya?— se responden directamente en las secciones 7, 8 y 9, incluso cuando la respuesta es solo parcial o negativa.

---

## 1. Perfiles tácticos y desglose de grupos

El clustering K-means (k=4) sobre las variables tipificadas de progresión y defensa PAdj segmenta a los jugadores en cuatro arquetipos tácticos. El algoritmo asigna los roles leyendo los centroides de cada cluster, en lugar de fijarlos a mano.

| Arquetipo | Jugadores | Índice de progresión medio | Entradas + int. PAdj medias | Precisión de pase media |
|:----------|----------:|---------------------------:|----------------------------:|------------------------:|
| Elite Progressive Distributor | 36 | 2,61 | 2,22 | 89,5% |
| High-Intensity Ball-Winner | 67 | 1,79 | 3,34 | 85,1% |
| Standard Build-up Distributor | 147 | 1,50 | 2,15 | 87,2% |
| Limited / Reactive Defender | 157 | 1,01 | 2,78 | 84,9% |

Frente a la versión de este pipeline previa al shrinkage, los arquetipos Elite y High-Intensity perdieron jugadores (48→36 y 97→67) mientras que los dos arquetipos intermedios ganaron (117→147 y 145→157). Es un efecto secundario esperado, no preocupante: la ponderación por fiabilidad acerca los perfiles de "racha con muestra pequeña" hacia el centro de la población, y las muestras pequeñas son desproporcionadamente comunes en los clusters más extremos. Ver [sección 7](#7-comprobaciones-de-robustez-estadística).

### 1.1. Distribuidores progresivos de élite
- **Perfil:** Directores de juego desde atrás en estructuras de alta posesión o sistemas de tres centrales con mucha libertad de conducción. Registran el mayor volumen de progresión y también la mejor precisión de pase.
- **Ejemplos destacados:** Sead Kolašinac, Nico Schlotterbeck, Iñigo Martínez.

### 1.2. Recuperadores de alta intensidad
- **Perfil:** Centrales muy proactivos, orientados al salto, la anticipación y el duelo. Presentan el mayor output defensivo PAdj del ecosistema y, como contrapartida, la peor precisión de pase.
- **Ejemplos destacados:** Riccardo Calafiori, Timo Hübers, Giorgio Scalvini.

### 1.3. Distribuidores estándar en construcción
- **Perfil:** El tipo modal de central moderno. Buen volumen de pase de seguridad y progresión intermedia, con la implicación defensiva más conservadora de los cuatro grupos. Es la referencia comparativa de la muestra. Ahora es el segundo grupo más numeroso tras el shrinkage, al absorber varios perfiles que antes parecían más extremos sobre muestras pequeñas.
- **Ejemplos destacados:** Tyrone Mings, Ezri Konsa, Saúl Coco.

### 1.4. Defensores limitados o reactivos
- **Perfil:** Contribución mínima en la progresión del balón. Frecuentes en sistemas defensivos estructurados o bloques bajos con escasa responsabilidad en la salida. Es el grupo más numeroso de la muestra.
- **Ejemplos destacados:** Matija Nastasić.

---

## 2. Métricas avanzadas y contexto táctico

### 2.1. Defensa ajustada por posesión (PAdj)

Contar acciones brutas penaliza a los defensores de equipos dominantes. Al aplicar el multiplicador sigmoideo utilizando la media de la liga como proxy, normalizamos la intensidad defensiva por oportunidad real de intervención. El cálculo combina entradas, intercepciones y recuperaciones ajustadas — las tres ya ponderadas por fiabilidad (ver [sección 6.1](#61-tasas-ponderadas-por-fiabilidad-shrinkage-empírico-bayesiano)) antes de aplicar el multiplicador PAdj.

| Jugador | Equipo | Liga | Temporada | Puntuación defensiva PAdj (combinada) |
|:--------|:-------|:-----|:----------|--------------------------------------:|
| **Timo Hübers** | Köln | Bundesliga | 2023–24 | **12,36** |
| **Riccardo Calafiori** | Bologna | Serie A | 2023–24 | **12,16** |
| **Giorgio Scalvini** | Atalanta | Serie A | 2023–24 | **11,02** |
| **Sead Kolašinac** | Atalanta | Serie A | 2024–25 | **10,75** |
| **Wilfried Singo** | Monaco | Ligue 1 | 2024–25 | **10,51** |

### 2.2. Índice de progresión

Esta métrica combina pases progresivos, conducciones progresivas y pases clave por 90 — todos ponderados por fiabilidad. Los pesos no son arbitrarios: se extraen dinámicamente de los loadings del PC1 de un Análisis de Componentes Principales (0,36 / 0,36 / 0,28, que explica el 66,8% de la varianza conjunta de las tres variables).

| Jugador | Equipo | Temporada | Índice de progresión |
|:--------|:-------|:----------|----------------------:|
| **Iñigo Martínez** | Barcelona | 2024–25 | **4,07** |
| **Nico Schlotterbeck** | Dortmund | 2024–25 | **3,62** |
| **Sead Kolašinac** | Atalanta | 2024–25 | **3,16** |
| **Eric García** | Girona | 2023–24 | **3,13** |
| **Manuel Akanji** | Manchester City | 2024–25 | **3,10** |

---

## 3. Panel de reclutamiento: mejores scouting scores

La puntuación compuesta maestra integra el índice de progresión (40%), el rendimiento defensivo PAdj (30%), la precisión de pase (10%) y una curva de valor por edad que prima el pico de rendimiento (20%).

| Jugador | Equipo | Temporada | Edad | Rol táctico asignado | Scouting score |
|:--------|:-------|:----------|:-----|:---------------------|---------------:|
| **Sead Kolašinac** | Atalanta | 2024–25 | 31 | Elite Progressive Distributor | **4,75** |
| **Riccardo Calafiori** | Bologna | 2023–24 | 21 | High-Intensity Ball-Winner | **4,65** |
| **Timo Hübers** | Köln | 2023–24 | 27 | High-Intensity Ball-Winner | **4,56** |
| **Nico Schlotterbeck** | Dortmund | 2024–25 | 24 | Elite Progressive Distributor | **4,44** |
| **Wilfried Singo** | Monaco | 2024–25 | 23 | High-Intensity Ball-Winner | **4,35** |

Kolašinac sigue liderando el ranking con 31 años, cargando con el multiplicador de edad más bajo del grupo (0,85), gracias a un índice de progresión de 3,16 — todavía claramente el más alto entre los cinco primeros. Calafiori recorta casi toda esa distancia por el otro lado: la mayor puntuación defensiva PAdj combinada de la muestra (12,16) más el bonus íntegro de sub-24. El margen entre ambos se estrechó ligeramente a 0,10 puntos tras la ponderación por fiabilidad.

**Este ranking no es igual de fiable de principio a fin.** Un chequeo de sensibilidad de pesos con 2.000 réplicas (ver [sección 6.2](#62-cuánto-importa-la-elección-concreta-de-pesos-40301020)) muestra que Kolašinac, Schlotterbeck, Singo y Calafiori son estables — se mantienen en el Top-10 bajo prácticamente cualquier reponderación razonable de 40/30/10/20. Más abajo en el Top-10, eso deja de ser cierto.

---

## 4. Ineficiencias de mercado y perfiles sub-24

Filtrando exclusivamente a jugadores de 24 años o menos que superan el percentil 80 de rendimiento global:

- **Riccardo Calafiori (21, Bologna, 2023–24, 4,65):** El más destacado en relación edad/rendimiento — la mayor puntuación defensiva PAdj combinada de la muestra (12,16) en la agresiva estructura de Thiago Motta, más el bonus íntegro sub-24.
- **Nico Schlotterbeck (24, Dortmund, 2024–25, 4,44):** El sub-24 más dominante en progresión de balón (3,62). Un perfil de distribuidor de élite consolidado.
- **Wilfried Singo (23, Monaco, 2024–25, 4,35)** y **Giorgio Scalvini (19, Atalanta, 2023–24, 4,33):** Perfiles sub-24 de alta intensidad con un volumen defensivo ponderado por fiabilidad considerable (10,51 y 11,02 PAdj combinado respectivamente) construido sobre temporadas de minutos completos, no muestras cortas.
- **Alidu Seidu (23, Clermont Foot, 2023–24, 3,99):** Sigue en la lista, pero con una historia **distinta y más honesta que antes.** Antes de la ponderación por fiabilidad, la temporada de 1.131 minutos de Seidu (fue vendido al Rennes en enero de 2024, a mitad de campaña) producía unas entradas/90 crudas de 2,55 e intercepciones/90 de 1,99 — números de apariencia élite construidos sobre una muestra genuinamente corta. El shrinkage empírico-bayesiano (ver [sección 6.1](#61-tasas-ponderadas-por-fiabilidad-shrinkage-empírico-bayesiano)) los descuenta a 2,08 y 1,59: siguen siendo buenos, ya no excepcionales. Su puntuación PAdj combinada bajó de 12,49 a 10,45, y su posición del #5 (4,62) al #10 (3,99). Es el método de shrinkage funcionando exactamente como debe sobre justo el tipo de perfil que existe para detectar — y, como muestra la [sección 9](#9-esto-encuentra-de-verdad-algo-que-el-mercado-no-supiera-ya), el Rennes ya había pagado 11M€ por él en la vida real antes de que este modelo, encogido o no, pudiera "encontrarlo".

---

## 5. Motor de similitud: búsqueda de sucesiones

El algoritmo de similitud del coseno rastrea el espacio de características estandarizado para encontrar los perfiles tácticos más cercanos. La consulta se ejecutó buscando un sustituto para **Sead Kolašinac**, líder del ranking global.

### Mejores coincidencias estadísticas para Sead Kolašinac

| Posición | Jugador | Equipo (temporada en muestra) | Similitud del coseno |
|:---------|:--------|:------------------------------|---------------------:|
| 1 | **Mario Gila** | Lazio (2024–25) | **96,7%** |
| 2 | **Javi Rodríguez** | Celta de Vigo (2024–25) | **95,0%** |
| 3 | **César Azpilicueta** | Atlético Madrid (2023–24) | **94,3%** |
| 4 | **Lutsharel Geertruida** | RB Leipzig (2024–25) | **94,3%** |
| 5 | **Facundo Medina** | Lens (2024–25) | **93,9%** |

**Mario Gila** (96,7%) sigue siendo el sucesor táctico destacado: producto de la cantera del Real Madrid (el Lazio pagó 6M€ por él en 2022), con alta agresividad en la recuperación y buena capacidad de conducción. El espacio de características ponderado por fiabilidad trajo a **César Azpilicueta** —un perfil de 33 años y alto kilometraje— a las mejores coincidencias, un recordatorio de que la similitud del coseno encuentra gemelos estadísticos, no gemelos en edad o etapa de carrera.

---

## 6. Mejoras de fiabilidad del modelo

Se hicieron dos mejoras a cómo se estiman los propios números subyacentes, independientes de la fórmula del compuesto. Ambas apuntan directamente a un rigor de nivel bioestadístico, no solo a añadir más diagnósticos sobre un modelo sin cambios.

### 6.1. Tasas ponderadas por fiabilidad (shrinkage empírico-bayesiano)

Un jugador con 900 minutos (10 partidos) y otro con 3.420 (38 partidos) pueden presentar la misma tasa por 90, pero la primera estimación arrastra mucho más ruido de muestreo. Tratarlas como igual de fiables es un error estadístico real — y concretamente infla justo los perfiles de muestra corta y sub-24 que una lista de "ineficiencias de mercado" pretende destacar.

Cada tasa basada en conteo (pases progresivos, conducciones progresivas, pases clave, entradas, intercepciones, recuperaciones) se corrige con el estimador empírico-bayesiano conjugado Poisson-Gamma —el mecanismo de libro de texto detrás del shrinkage de promedios de bateo de Efron & Morris (1975), aplicado aquí a acciones defensivas—. `MASS::glm.nb()` ajusta `count ~ offset(log(minutos/90))` por métrica para obtener la tasa media poblacional (μ) y la dispersión (θ); por conjugación, la media posterior para el jugador *i* es:

```
tasa_encogida_i = (θ + conteo_i) / (θ/μ + minutos_i/90)
```

que encoge hacia la media poblacional en proporción inversa a los minutos jugados. La corrección va donde debe: el encogimiento medio absoluto en el cuartil inferior de minutos jugados es **2-3 veces mayor** que en el cuartil superior, en las seis métricas (tabla completa: [`shrinkage_diagnostics.csv`](../outputs/tables/shrinkage_diagnostics.csv)). Alidu Seidu (sección 4) es la ilustración concreta más clara del efecto.

### 6.2. ¿Cuánto importa la elección concreta de pesos (40/30/10/20)?

Los pesos son una filosofía de reclutamiento declarada, no un ajuste estadístico, así que su influencia sobre el ranking se mide directamente en vez de dejarse como una suposición sin examinar. Se generan 2.000 vectores de pesos alternativos mediante muestreo de una distribución Dirichlet centrada en 40/30/10/20 —la generalización multivariante de la distribución Beta, la forma natural de simular "desacuerdo razonable" sobre un conjunto de proporciones que deben sumar uno— y se recalcula el ranking en cada réplica.

**Resultado global:** correlación de Spearman mediana con el ranking original = **0,989** (RIC 0,972–0,997); el Top-10 original solapa con el Top-10 reponderado en un **87,9%** de media. El ranking, en general, no depende del reparto concreto 40/30/10/20.

**Pero no de forma uniforme.** Tasa de retención en el Top-10 por jugador a través de las 2.000 réplicas:

| Jugador | Scouting score | % de réplicas retenido en el Top-10 |
|:--------|----------------:|---------------------------------------:|
| Sead Kolašinac | 4,75 | 100,0% |
| Nico Schlotterbeck | 4,44 | 99,7% |
| Wilfried Singo | 4,35 | 99,7% |
| Riccardo Calafiori | 4,65 | 98,5% |
| Lucas Martínez Quarta | 4,13 | 98,5% |
| Giorgio Scalvini | 4,33 | 96,8% |
| Timo Hübers | 4,56 | 94,6% |
| Facundo Medina | 4,11 | 90,2% |
| Alidu Seidu | 3,99 | 52,0% |
| Mohammed Salisu | 4,01 | 49,4% |

La cabeza del ranking es genuinamente estable. Los dos últimos nombres del Top-10 actual son prácticamente una moneda al aire: que Seidu o Salisu entren depende casi tanto de la ponderación concreta como de sus números de base. Reportar "aquí está el Top-10" sin esta tabla exageraría la precisión del ranking justo donde es más débil. Datos completos: [`weight_sensitivity_top10.csv`](../outputs/tables/weight_sensitivity_top10.csv), [`weight_sensitivity_replications.csv`](../outputs/tables/weight_sensitivity_replications.csv).

---

## 7. Comprobaciones de robustez estadística

Antes de fiarse de un ranking conviene preguntarse si la maquinaria que lo produce es sólida: ¿son redundantes las variables de entrada entre sí?, ¿está justificado el número de clusters?, ¿hay jugadores tan atípicos que están distorsionando el cuadro?

### 7.1. Cribado de outliers multivariantes

Se aplicó un cribado por distancia de Mahalanobis (D²) sobre las siete variables que alimentan el filtrado y el scoring (ya con shrinkage aplicado), con el límite estándar k + 3√(2k) para k = 7 (D² > 18,2). 20 de 407 jugadores (4,9%) lo superan — la misma tasa que antes del shrinkage, ya que el shrinkage descuenta tasas extremas en vez de eliminar la estructura de variabilidad subyacente.

Fíjate en que Alidu Seidu e Iñigo Martínez —ambos nombres destacados más arriba— están en esa lista marcada. No es una contradicción; es exactamente lo que debe hacer un buen cribado de outliers. "Estadísticamente atípico" y "error de datos" producen el mismo D², y la única forma de distinguirlos es mirar. Aquí, al mirar, se confirma que ambos son atípicos porque son perfiles genuinamente excepcionales, no por un problema de datos. Los jugadores se marcan, nunca se eliminan en silencio. Listado completo: [`qc_mahalanobis_outliers.csv`](../outputs/tables/qc_mahalanobis_outliers.csv).

### 7.2. ¿Son redundantes entre sí las variables del compuesto?

Se aplicó un chequeo de factor de inflación de la varianza (VIF) sobre tres grupos: las tres variables del índice de progresión, las tres variables PAdj del defending score, y los cuatro pilares del scouting_score en sí mismo. Todos los VIF salieron ≤ 1,77 — muy lejos del umbral de alarma habitual (10). Ninguna de las variables del modelo está duplicando en silencio la señal de otra. Tabla completa: [`vif_diagnostics.csv`](../outputs/tables/vif_diagnostics.csv).

### 7.3. ¿Es defendible la curva de edad fijada a mano?

`age_score` es una función escalón (puntos de corte 24/28/31/33), fijada por el analista en vez de ajustada. Como diagnóstico —no como reajuste, para no encadenar un segundo cambio sobre el score compuesto en la misma pasada— se ajustó un GAM (`mgcv::gam`) al output de tipo progresivo y de tipo defensivo por separado frente a la edad, sobre el pool completo de 570 jugador-temporada (sin deduplicar por jugador, para tener más datos).

El panorama es genuinamente mixto. El output de tipo progresivo no muestra **ninguna relación con la edad** (p = 0,66, R² ajustado ≈ 0): los distribuidores no empeoran, ni mejoran, de forma fiable al envejecer en estos datos. El output de tipo defensivo muestra un efecto de edad pequeño pero estadísticamente real (p = 0,0056, R² ajustado = 0,025), con un ascenso suave hasta un pico moderado en torno a los 22-24 años y un declive lento hasta finales de la veintena — coherente en líneas generales con tratar la primera mitad de la veintena como años de pico, aunque mucho más gradual que los saltos discretos de la función escalón actual. El aparente repunte en la última etapa de la carrera (más allá de los 35) en la curva ajustada es un artefacto del intervalo de confianza por datos muy escasos en esa cola, y no debe leerse como que "los centrales alcanzan su pico a los 40".

**Conclusión: el chequeo GAM ni confirma con fuerza ni contradice la curva fijada a mano.** No se sustituye en esta ronda por falta de una alternativa fiable — sustituir una suposición simple y declarada por otra no fiable y extrapolada en la cola sería un retroceso, no una mejora. Datos: [`age_curve_gam.csv`](../outputs/tables/age_curve_gam.csv); figura: [`age_curve_gam.png`](../outputs/figures/age_curve_gam.png).

### 7.4. ¿Es k = 4 el número correcto de clusters?

Se ejecutaron el método del codo (WSS) y el de la silueta para k = 2 a 8 (ya con shrinkage aplicado):

| k | WSS | Silueta media |
|--:|----:|---------------:|
| 2 | 1351,7 | **0,344 (óptimo estadístico)** |
| 3 | 1077,3 | 0,245 |
| **4** | **892,8** | **0,259 (el usado en el pipeline)** |
| 5 | 773,5 | 0,237 |
| 6 | 712,9 | 0,235 |
| 7 | 659,4 | 0,227 |
| 8 | 612,6 | 0,211 |

k = 2 sigue siendo el óptimo estadístico; se mantiene k = 4 por la misma razón que antes — preserva la granularidad táctica (intensidad recuperadora vs. estilo de distribución) sobre la que se construye el resto de este informe, y su silueta (0,259) de hecho mejoró ligeramente tras eliminar el shrinkage parte del ruido de muestreo del espacio de características.

El contraste independiente cuenta una historia más matizada que la silueta por sí sola. Cortar un dendrograma jerárquico (enlace de Ward) en k = 4 y compararlo con las etiquetas de K-means da ahora un **Índice de Rand Ajustado de 0,295** (frente a 0,419 antes del shrinkage) y un **62,4%** de acuerdo por fila (correlación cofenética: 0,496, frente a 0,586). El shrinkage mejoró la silueta *dentro de K-means* pero *debilitó* el acuerdo con un método de clustering totalmente independiente — un trade-off legítimo y declarado: la ponderación por fiabilidad acerca el ruido de muestra pequeña hacia la media, pero parte de lo que se acerca es también varianza real entre jugadores, y eso suaviza las fronteras que puede encontrar un segundo algoritmo no relacionado. Los cuatro arquetipos siguen muy por encima del ~0 de acuerdo esperable por azar, pero ahora deben leerse como tendencias amplias en lugar de categorías nítidamente separadas. Tabla de contingencia completa: [`kmeans_vs_hierarchical_agreement.csv`](../outputs/tables/kmeans_vs_hierarchical_agreement.csv).

---

## 8. Validación predictiva: ¿predice el score algo real?

Todas las comprobaciones anteriores preguntan si el modelo es *internamente* coherente. Esta sección plantea una pregunta más difícil: reajustado —incluido el paso de shrinkage— usando **solo datos de 2023-24**, ¿dice el score resultante algo cierto sobre lo que ocurrió en **2024-25**, una temporada que nunca vio? Es una partición Train/Test temporal genuina (se ajusta con el pasado, se evalúa con el futuro), no un k-fold aleatorio, porque filtrar información futura al ajuste anularía el sentido de la prueba.

**Planteamiento.** 278 centrales activos en 2023-24, puntuados con los parámetros de shrinkage y los pesos PCA reestimados solo en esa temporada. Outcome: ¿jugó ≥ 900 minutos en 2024-25 (`retained`)? El 64,0% sí.

| Modelo | Predictor(es) | Resultado | AIC |
|:-------|:---------------|:----------|----:|
| Solo intercepto | — | referencia | 365,2 |
| Regresión logística | `scouting_score` | OR = 1,38 (IC95% 0,83–2,32), **p = 0,22, no significativo** | 365,7 |
| Regresión logística | 4 componentes por separado | `age_score` OR = 22,5 (**p = 0,0015**); `progression_index` OR = 1,72 (p = 0,049); `defending_score`, `pass_completion` n.s. | 354,1 |

**El score compuesto sigue sin predecir de forma significativa la retención la temporada siguiente, sin cambios tras la ponderación por fiabilidad.** Descomponer el compuesto muestra exactamente dónde vive la (limitada) señal: `age_score` por sí solo es un predictor fuerte y significativo de la retención —los jugadores más jóvenes tienen sencillamente más probabilidad de seguir jugando la temporada siguiente—. Pero `age_score` solo pesa un **20%** del compuesto, por diseño, porque el score clasifica *capacidad futbolística*, no *supervivencia en la muestra*. Un test de razón de verosimilitud confirma que la ponderación fija es una restricción real y medible para esta tarea de predicción concreta (χ², p < 0,001).

Como contraste puramente descriptivo (no causal), la tasa de retención sí se alinea con los propios arquetipos del algoritmo:

| Arquetipo | n | Tasa de retención |
|:----------|--:|--------------------:|
| Elite Progressive Distributor | 27 | 81,5% |
| High-Intensity Ball-Winner | 39 | 64,1% |
| Standard Build-up Distributor | 111 | 63,1% |
| Limited / Reactive Defender | 101 | 60,4% |

**Qué muestra esta validación y qué no.** "Jugar 900+ minutos la temporada siguiente" es un proxy débil e indirecto de la calidad de scouting —depende al menos tanto de lesiones, profundidad de plantilla y el sistema de un entrenador como de la capacidad del jugador—. El resultado nulo no significa que el ranking esté mal; significa que la retención bruta de la temporada siguiente es el objetivo equivocado para validar un ranking de *calidad*. Salida completa del modelo: [`temporal_validation_results.csv`](../outputs/tables/temporal_validation_results.csv); figura: [`temporal_validation.png`](../outputs/figures/temporal_validation.png).

---

## 9. ¿Esto encuentra de verdad algo que el mercado no supiera ya?

La sección 8 pregunta si el score predice el futuro. Esta sección plantea una pregunta todavía más de base: comprobar los nombres destacados de este mismo informe contra lo que realmente ha pasado en el mercado de fichajes real desde entonces.

| Jugador | Lo que dice este informe | Lo que pasó en realidad |
|:--------|:---------------------------|:---------------------------|
| **Alidu Seidu** | "Ineficiencia de mercado" en el Clermont, 2023-24 | Vendido al Rennes por **11M€** el **29 de enero de 2024** — a mitad de la misma temporada que puntúa este modelo, tras solo 14 partidos de Ligue 1 |
| **Riccardo Calafiori** | Destacado sub-24, 2023-24 | Vendido Bologna → Arsenal por **~45-49M€** en verano de 2024, tras una Eurocopa 2024 destacada |
| **Wilfried Singo** | Destacado sub-24 | Ya vendido Torino → Mónaco por **10M€** en verano de 2023, antes incluso de que empiece la ventana de este análisis |
| **Giorgio Scalvini** | El adolescente con mejor puntuación | El Atalanta lo declaró "intransferible" con una valoración de **60M€**, con Newcastle, Chelsea, Manchester United y Tottenham reportadamente interesados |
| **Mario Gila** | Mejor coincidencia de similitud del coseno para Kolašinac | Producto de la cantera del Real Madrid; el Lazio ya pagó **6M€** por él en 2022, dos años antes de este análisis |

Todos los nombres destacados de este informe ya habían sido detectados, valorados y —en la mayoría de los casos— ya vendidos por departamentos de scouting profesionales que trabajan con información mucho más rica (vídeo, datos médicos, valoración de carácter personal, años de seguimiento en persona) de la que un modelo de estadísticas públicas puede acceder jamás. En el caso concreto de Seidu, el traspaso se cerró *durante* la misma temporada que este modelo usa para puntuarlo.

**Este modelo tiene buena precisión identificando centrales de calidad. No tiene prácticamente ninguna ventaja de anticipación sobre el mercado real, y ningún modelo construido sobre estadísticas públicas de conteo razonablemente podría tenerla.** Es una afirmación bastante más honesta que "este algoritmo encuentra valor sin descubrir" — y es la razón de ser de `scripts/scripts_optional_market_value_residuals.R`: sustituye la definición actual y arbitraria de "ineficiencia de mercado" (sección 4) ("sub-24 + percentil 80") por una real, regresando el logaritmo del valor de mercado sobre `scouting_score`, edad y liga, y señalando a los jugadores cuyo precio *real* está estadísticamente por debajo de lo que predice el rendimiento. Esa sí es una afirmación de ineficiencia genuina; un corte de percentil sobre una variable nunca lo fue. Requiere ejecución en local — ver el [README principal](../README.es.md#mantener-los-datos-al-día).

---

## 10. Conclusiones

- **El efecto de los sistemas de autor.** La presencia dominante de la Atalanta de Gasperini (Kolašinac, Scalvini) y de Calafiori en el Bologna de Thiago Motta de 2023–24 subraya cómo los sistemas de marcaje al hombre y proactividad defensiva elevan drásticamente las métricas PAdj de sus centrales.
- **Centrales vs laterales invertidos.** El filtro estricto de toques en el último tercio y de recepciones progresivas ha limpiado la base de datos de "falsos centrales", permitiendo que los verdaderos defensores progresivos (como Schlotterbeck o Iñigo Martínez) lideren el ranking sin la competencia de laterales ofensivos.
- **La ponderación por fiabilidad cambia la shortlist, no solo los decimales.** La caída de Alidu Seidu del #5 al #10 (sección 4) muestra a la corrección empírico-bayesiana haciendo trabajo real justo sobre los perfiles de muestra corta que un informe de scouting tiene más riesgo de sobrevalorar.
- **La mayor parte del ranking es robusta a la elección concreta de pesos; los nombres al margen, no.** La tabla de sensibilidad de pesos de la sección 6.2 debería acompañar a cualquier shortlist extraída de este proyecto — un nombre retenido en el 50% de reponderaciones razonables es una recomendación de un tipo distinto a uno retenido en el 100%.
- **La similitud como plan de sucesión.** El motor elimina el sesgo visual. Identificar a Mario Gila como perfil gemelo a Kolašinac proporciona al departamento de scouting una preselección puramente objetiva, lista para ser filtrada por viabilidad económica.
- **Este modelo encuentra calidad, no secretos.** La sección 9 muestra que todos los nombres destacados de este informe ya eran conocidos por departamentos de reclutamiento reales, normalmente antes de que terminara la temporada puntuada. Eso replantea todo el ejercicio con honestidad: una herramienta de preselección bien auditada y estadísticamente rigurosa, no un motor de descubrimiento que le gana al mercado.
- **Léase como una herramienta de preselección bien auditada, no como una decisión de fichaje.** Las secciones 6 a 9 muestran un modelo internamente coherente (sin variables redundantes, tasas ponderadas por fiabilidad, una elección de clustering declarada y contrastada) pero cuyo score compuesto no predice los minutos brutos de la temporada siguiente y no tiene ventaja de descubrimiento sobre el mercado. Consulta la [sección de limitaciones](../README.es.md#limitaciones) del README principal antes de tomar cualquier orden como definitivo.
