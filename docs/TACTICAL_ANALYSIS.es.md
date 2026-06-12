# Análisis táctico y perfilado de centrales modernos

## Resumen

Este informe desglosa los perfiles tácticos de centrales en las cinco grandes ligas europeas utilizando datos de la temporada 2023–24. Un framework de clustering K-means (k=4) y Análisis de Componentes Principales aísla comportamientos distintos, mientras que las métricas ajustadas por posesión aportan el contexto que las estadísticas brutas no pueden ofrecer.

**Alidu Seidu** (Clermont Foot) lidera el framework de scouting compuesto con una puntuación global de 4.79, seguido de **Leonardo Balerdi** (Marsella, 4.64) y **Tim Siersleben** (Heidenheim, 4.34). En progresión pura con balón, **Joseph Okumu** (Reims) registra el índice de progresión más alto de la muestra con 2.67.

La aplicación de métricas ajustadas por posesión (PAdj), estimadas a través del volumen relativo de pases del equipo, muestra que los recuentos defensivos brutos están distorsionados por el contexto táctico. Tras normalizar por oportunidad defensiva, **Tim Siersleben** (13.15 de entradas + intercepciones PAdj combinadas) y **Alidu Seidu** (11.68) emergen como los defensores más activos del dataset en relación a lo poco que realmente defienden.

---

## 1. Perfiles tácticos y desglose de grupos

El clustering K-means (k=4) sobre variables de progresión e intervencion defensiva PAdj estandarizadas segmenta los 157 jugadores de la muestra en cuatro arquetipos tácticos diferenciados.

### 1.1. Cluster 4: distribuidores progresivos de élite
- **Tamaño de la muestra:** 34 jugadores.
- **Perfil:** Directores de juego desde atrás en estructuras de alta posesión. Mayor volumen de pase y progresión de toda la muestra.
- **Promedios del cluster:**
  - Pases progresivos por 90: **4.21**
  - Índice de progresión: **1.90**
  - Precisión de pase: **86.7%**

### 1.2. Cluster 2: distribuidores estándar
- **Tamaño de la muestra:** 62 jugadores.
- **Perfil:** El tipo modal de central. Buen volumen de pase, participación defensiva moderada. La referencia comparativa de la muestra.
- **Promedios del cluster:**
  - Pases progresivos por 90: **2.86**
  - Índice de progresión: **1.26**
  - Precisión de pase: **86.3%**

### 1.3. Cluster 3: destructores de alta intensidad
- **Tamaño de la muestra:** 13 jugadores.
- **Perfil:** Defensores reactivos y orientados al duelo, con el mayor output defensivo PAdj de toda la muestra. Habitualmente desplegados en bloques defensivos bajos.
- **Promedios del cluster:**
  - Entradas PAdj por 90: **4.38**
  - Intercepciones PAdj por 90: **3.41**
  - Precisión de pase: **84.4%**

### 1.4. Cluster 1: perfiles limitados con balón
- **Tamaño de la muestra:** 48 jugadores.
- **Perfil:** Contribución mínima en progresión, volumen defensivo moderado. Frecuentes en sistemas defensivos estructurados con poca responsabilidad en construcción.
- **Promedios del cluster:**
  - Pases progresivos por 90: **1.82**
  - Índice de progresión: **0.78**
  - Precisión de pase: **85.6%**

---

## 2. Métricas avanzadas y contexto táctico

### 2.1. Defensa ajustada por posesión (PAdj)

Contar acciones defensivas brutas penaliza a los defensores de equipos dominantes que naturalmente afrontan menos transiciones. Dividiendo entre `(posesión_rival / 50)` se normaliza el output de cada jugador a lo que sería si ambos equipos tuvieran posesión igualada.

| Jugador | Equipo | Entradas PAdj | Intercepciones PAdj | Combinado |
|:--------|:-------|:--------------|:--------------------|:----------|
| **Tim Siersleben** | Heidenheim | 7.39 | 5.75 | **13.15** |
| **Alidu Seidu** | Clermont Foot | 6.56 | 5.12 | **11.68** |
| **Teden Mengi** | Luton Town | 5.02 | 5.30 | **10.33** |
| **Gabriel Osho** | Luton Town | 5.10 | 3.86 | **8.96** |
| **Jorge Sáenz** | Leganés | 4.31 | 2.92 | **7.23** |

Siersleben y Seidu juegan en equipos con posesión estimada del ~82% y ~81% respectivamente. Sus cifras brutas de entradas (2.67 y 2.55 por 90) parecen ordinarias pero la corrección PAdj revela que son los defensores más activos por oportunidad del dataset.

### 2.2. Índice de progresión

El índice de progresión combina pases progresivos, conducciones progresivas y pases clave por 90, ponderados por los loadings del PC1 de un PCA. Mide cuánto avanza activamente un central en el terreno, en lugar de limitarse a recircular la posesión.

| Jugador | Equipo | Índice de progresión | Pases prog./90 | Conducciones prog./90 |
|:--------|:-------|:---------------------|:---------------|:----------------------|
| **Joseph Okumu** | Reims | 2.67 | 6.16 | 0.96 |
| **Ladislav Krejčí** | Girona | 2.42 | 5.31 | 1.07 |
| **Virgil Van Dijk** | Liverpool | 2.28 | 5.35 | 0.59 |
| **Karol Mets** | St Pauli | 2.25 | 5.40 | 0.50 |
| **Tim Siersleben** | Heidenheim | 2.25 | 4.75 | 1.19 |

---

## 3. Panel de reclutamiento: mejores scouting scores

La puntuación compuesta de scouting combina índice de progresión (40%), defending score (30%), precisión de pase (10%) y un factor corrector de edad (20%).

| Jugador | Equipo | Edad | Perfil de rol | Scouting Score |
|:--------|:-------|:-----|:--------------|:---------------|
| **Alidu Seidu** | Clermont Foot | 23 | Defensive Stopper | **4.79** |
| **Leonardo Balerdi** | Marsella | 24 | Elite Progressive CB | **4.64** |
| **Tim Siersleben** | Heidenheim | 23 | Elite Progressive CB | **4.34** |
| **Dan-Axel Zagadou** | Stuttgart | 24 | Elite Progressive CB | **3.78** |
| **Kevin Danso** | Lens | 24 | Elite Progressive CB | **3.77** |

---

## 4. Ineficiencias de mercado y perfiles de alto potencial

Filtrando jugadores de 24 años o menos por encima del percentil 80 en scouting score:

- **Alidu Seidu (23, Clermont Foot, 4.79):** Lidera tanto el ranking global como la tabla defensiva PAdj. Una combinación poco frecuente de intensidad de recuperación de élite y output de progresión respetable.
- **Leonardo Balerdi (24, Marsella, 4.64):** Mayor defending score (11.77) entre los perfiles de CB progresivo. Sólida combinación de calidad en el pase y volumen defensivo.
- **Tim Siersleben (23, Heidenheim, 4.34):** Mayor índice de progresión (2.25) y mayor score PAdj combinado (13.15). Jugar en un recién ascendido de la Bundesliga limita su visibilidad, pero las métricas son de nivel élite.
- **Lucas Beraldo (20, PSG, 3.70):** El jugador de alta puntuación más joven de la muestra. Alta precisión de pase (92%) y progresión por encima de la media para su grupo de edad.
- **Willian Pacho (22, PSG, 3.69):** Defensor sólido en un equipo dominante, lo que comprime su output defensivo bruto. La corrección PAdj mejora significativamente su posición relativa.
- **Yarek Gasiorowski (19, Valencia, 3.39):** El más joven del dataset en clasificarse. Perfil de CB progresivo con margen de desarrollo. Uno a seguir.

---

## 5. Motor de similitud: búsqueda de sustitutos estadísticos

El motor de similitud del coseno calcula la distancia geométrica en el espacio de características estandarizado. La consulta se ejecutó contra el jugador mejor clasificado, **Alidu Seidu**.

### Mejores coincidencias estadísticas para Alidu Seidu

| Posición | Jugador | Similitud del coseno |
|:---------|:--------|:---------------------|
| 1 | **Murillo** | 93.0% |
| 2 | **Santiago Mouriño** | 89.1% |
| 3 | **Mickael Nade** | 87.3% |
| 4 | **Arouna Sangante** | 84.6% |
| 5 | **Tim Siersleben** | 84.1% |

Murillo (93.0%) es el perfil estadístico más cercano: un Defensive Stopper con intensidad PAdj y output de progresión comparables. Que Siersleben aparezca en el puesto 5 (84.1%) tiene sentido intuitivo, ya que ambos lideran el ranking PAdj combinado.

---

## 6. Conclusiones

- **Contexto antes que volumen.** Un central con 1.5 entradas por 90 en un equipo con el 70% de posesión hace significativamente más trabajo por oportunidad que uno con 3.0 entradas en un equipo que defiende durante 60 minutos por partido. La corrección PAdj hace esto visible.
- **El efecto Heidenheim.** Tim Siersleben es un caso claro de ineficiencia de mercado impulsada por la visibilidad del club. Lidera el índice de progresión bruto y el ranking PAdj defensivo combinado, jugando en un recién ascendido de la Bundesliga. Los datos apuntan a un perfil de élite que aún no ha recibido el reconocimiento correspondiente.
- **Sub-20 a seguir.** Yarek Gasiorowski (Valencia, 19) y Lucas Beraldo (PSG, 20) puntúan por encima de la media a pesar de las penalizaciones por edad en la fórmula. Eliminando el factor corrector de edad, ambos subirían significativamente en el ranking.
- **La similitud como herramienta de reclutamiento.** El motor elimina la subjetividad al identificar alternativas. En lugar de visualizar partidos e intuir, las puntuaciones de similitud proporcionan una shortlist ordenada de jugadores cuyo perfil de datos se aproxima más a cualquier objetivo. Murillo como la coincidencia más cercana a Seidu es un punto de partida basado en datos, sin sesgos de popularidad.
