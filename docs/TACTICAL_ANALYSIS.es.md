# Análisis táctico y perfilado de centrales modernos

## Resumen

Este informe desglosa los perfiles tácticos de centrales en las cinco grandes ligas europeas utilizando datos de la temporada 2023–24. Un framework de clustering K-means (k=4) y Análisis de Componentes Principales aísla comportamientos distintos, mientras que las métricas ajustadas por posesión (PAdj) aportan el contexto que las estadísticas brutas omiten.

**Sead Kolašinac** (Atalanta) lidera el framework de scouting compuesto con una puntuación global de 5.08, seguido por la revelación **Riccardo Calafiori** (Bologna, 4.98) y **Timo Hübers** (Colonia, 4.84). En progresión pura con balón, **Iñigo Martínez** (Barcelona) registra el índice de progresión más alto de la muestra con 4.31.

La aplicación de la curva sigmoidea para las métricas ajustadas por posesión revela que los recuentos defensivos están fuertemente condicionados por el dominio del equipo. Tras normalizar por oportunidad real, **Timo Hübers** (13.31 PAdj combinado) y **Riccardo Calafiori** (13.18) emergen como los defensores más intensos y activos de las cinco grandes ligas.

---

## 1. Perfiles tácticos y desglose de grupos

El clustering K-means (k=4) sobre las variables estandarizadas de progresión y defensa PAdj segmenta a los jugadores en cuatro arquetipos tácticos. El algoritmo asigna dinámicamente los roles evaluando los centroides matemáticos.

### 1.1. Cluster: distribuidores progresivos de élite
- **Perfil:** Directores de juego desde atrás en estructuras de alta posesión o sistemas de tres centrales con mucha libertad de conducción. Registran el mayor volumen de progresión.
- **Ejemplos destacados:** Sead Kolašinac, Nico Schlotterbeck, Iñigo Martínez.

### 1.2. Cluster: recuperadores de alta intensidad
- **Perfil:** Centrales muy proactivos, orientados al salto, la anticipación y el duelo. Presentan el mayor output defensivo PAdj del ecosistema.
- **Ejemplos destacados:** Riccardo Calafiori, Timo Hübers, Alidu Seidu.

### 1.3. Cluster: distribuidores estándar en construcción
- **Perfil:** El tipo modal de central moderno. Buen volumen de pase de seguridad y participación defensiva equilibrada. Es la referencia comparativa de la muestra.
- **Ejemplos destacados:** Tyrone Mings, Ezri Konsa.

### 1.4. Cluster: defensores limitados o reactivos
- **Perfil:** Contribución mínima en la progresión del balón. Frecuentes en sistemas defensivos estructurados o bloques bajos con escasa responsabilidad en la salida.
- **Ejemplos destacados:** Saúl Coco, Matija Nastasić.

---

## 2. Métricas avanzadas y contexto táctico

### 2.1. Defensa ajustada por posesión (PAdj)

Contar acciones brutas penaliza a los defensores de equipos dominantes. Al aplicar el multiplicador sigmoideo utilizando la liga como proxy, normalizamos la intensidad defensiva por oportunidad real de intervención. El cálculo combina entradas, intercepciones y recuperaciones ajustadas.

| Jugador | Equipo | Liga | Puntuación defensiva PAdj (Combinada) |
|:--------|:-------|:-----|:--------------------------------------|
| **Timo Hübers** | Köln | Bundesliga | **13.31** |
| **Riccardo Calafiori** | Bologna | Serie A | **13.18** |
| **Alidu Seidu** | Clermont Foot | Ligue 1 | **12.49** |
| **Giorgio Scalvini** | Atalanta | Serie A | **11.77** |
| **Sead Kolašinac** | Atalanta | Serie A | **11.50** |

### 2.2. Índice de progresión

Esta métrica combina pases progresivos, conducciones progresivas y pases clave. Los pesos no son arbitrarios, sino que se extraen dinámicamente de los loadings del PC1 de un Análisis de Componentes Principales.

| Jugador | Equipo | Índice de progresión | Pases prog./90 | Conducciones prog./90 |
|:--------|:-------|:---------------------|:---------------|:----------------------|
| **Iñigo Martínez** | Barcelona | **4.31** | 9.40 | 2.53 |
| **Nico Schlotterbeck** | Dortmund | **3.90** | 8.85 | 1.68 |
| **Sead Kolašinac** | Atalanta | **3.43** | 6.72 | 2.46 |
| **Manuel Akanji** | Manchester City | **3.29** | 7.06 | 2.06 |
| **Eric García** | Girona | **3.25** | 7.54 | 1.54 |

---

## 3. Panel de reclutamiento: mejores scouting scores

La puntuación compuesta maestra integra el índice de progresión (40%), el rendimiento defensivo PAdj (30%), la precisión de pase (10%) y una curva de valor por edad que prima el pico de rendimiento (20%).

| Jugador | Equipo | Edad | Rol táctico asignado | Scouting score |
|:--------|:-------|:-----|:---------------------|:---------------|
| **Sead Kolašinac** | Atalanta | 31 | Elite Progressive Distributor | **5.08** |
| **Riccardo Calafiori** | Bologna | 21 | High-Intensity Ball-Winner | **4.98** |
| **Timo Hübers** | Köln | 27 | High-Intensity Ball-Winner | **4.84** |
| **Nico Schlotterbeck**| Dortmund | 24 | Elite Progressive Distributor | **4.73** |
| **Alidu Seidu** | Clermont Foot | 23 | High-Intensity Ball-Winner | **4.62** |

---

## 4. Ineficiencias de mercado y perfiles sub-24

Filtrando exclusivamente a jugadores de 24 años o menos que superan el percentil 80 de rendimiento global:

- **Riccardo Calafiori (21, Bologna, 4.98):** El jugador más destacado en relación edad/rendimiento. Combina un volumen altísimo de recuperación PAdj (13.18) en la agresiva estructura de Thiago Motta.
- **Nico Schlotterbeck (24, Dortmund, 4.73):** El sub-24 más dominante en progresión de balón (3.90). Un perfil de distribuidor de élite consolidado.
- **Alidu Seidu (23, Clermont Foot, 4.62):** Se mantiene como un chollo de mercado en métricas PAdj. Destaca enormemente en un contexto de equipo desfavorecido.
- **Giorgio Scalvini (19, Atalanta, 4.58):** El adolescente con mejor puntuación del continente. Ya rinde estadísticamente como un central consolidado en la élite europea.
- **Jarell Quansah (20, Liverpool, 4.00) y El Chadaille Bitshiabu (19, RB Leipzig, 3.81):** Perfiles en claro ascenso que ya superan el corte de exigencia técnica.

---

## 5. Motor de similitud: búsqueda de sucesiones

El algoritmo de similitud del coseno rastrea el espacio de características estandarizado para encontrar perfiles tácticos idénticos. La consulta se ejecutó buscando un sustituto para **Sead Kolašinac**, líder del ranking global.

### Mejores coincidencias estadísticas para Sead Kolašinac

| Posición | Jugador | Similitud del coseno |
|:---------|:--------|:---------------------|
| 1 | **Mario Gila** (Lazio) | **97.1%** |
| 2 | **Javi Rodríguez** (Celta) | **95.9%** |
| 3 | **Facundo Medina** (Lens) | **95.3%** |
| 4 | **Mohamed Simakan** (RB Leipzig) | **94.2%** |
| 5 | **Lutsharel Geertruida** (Feyenoord/RBL) | **94.0%** |

**Mario Gila** (97.1%) emerge como el relevo táctico casi perfecto: un central exterior con alta agresividad en la recuperación y muchísima facilidad para conducir y romper líneas de presión. **Facundo Medina** (95.3%) representa otra opción natural de perfil zurdo y agresivo.

---

## 6. Conclusiones

- **El efecto de los sistemas de autor.** La presencia dominante de jugadores del Atalanta (Kolašinac, Scalvini) y del Bologna de Motta (Calafiori, Lucumí) subraya cómo los sistemas de marcaje al hombre y proactividad defensiva elevan drásticamente las métricas PAdj de sus centrales.
- **Centrales vs Laterales invertidos.** El filtro estricto de toques en el último tercio ha limpiado la base de datos de "falsos centrales", permitiendo que los verdaderos defensores progresivos (como Schlotterbeck o Iñigo Martínez) lideren el ranking de manera justa, sin la competencia desleal de laterales ofensivos.
- **Calidad predictiva del modelo.** Identificar a Riccardo Calafiori como uno de los perfiles más dominantes a nivel estadístico de la temporada (antes de su gran impacto mediático en la Eurocopa y salto al Arsenal) valida la solidez de la conjunción entre la nota defensiva PAdj y la ponderación PCA de la salida de balón.
- **La similitud como plan de sucesión.** El motor elimina el sesgo visual. Identificar a Mario Gila o Javi Rodríguez como perfiles gemelos a Kolašinac proporciona al departamento de scouting una preselección puramente objetiva, lista para ser filtrada por viabilidad económica.
