# Análisis táctico y perfilado de defensores modernos

## Resumen ejecutivo

Este informe desglosa los perfiles tácticos de los defensores centrales y pivotes modernos en las principales ligas europeas, analizando datos de rendimiento longitudinales que abarcan cuatro temporadas. Al aplicar el agrupamiento k-means ($k=4$) y el análisis de componentes principales (PCA), este marco de trabajo aísla comportamientos específicos de los jugadores para eliminar sesgos y contextualizar su rendimiento.

**Mats Wieffer** (Brighton) emerge como el líder en el panel de contratación con una puntuación global de 5.04, seguido muy de cerca por **Eduardo Camavinga** (4.98). En el apartado constructivo, **Oleksandr Zinchenko** (Arsenal) se mantiene como el referente absoluto en la generación de peligro puro desde atrás, registrando una aproximación de amenaza esperada (proxy xT) de 8.01. 

En el otro extremo del espectro táctico, la aplicación de métricas ajustadas por posesión (PAdj) —estimadas matemáticamente a través del volumen relativo de pases del equipo— revela que el rendimiento defensivo bruto está fuertemente distorsionado por el sistema táctico del equipo. Corregir este sesgo permite descubrir una intensidad defensiva de élite en destructores puros como Alidu Seidu (13.05), premiar a defensores con un alto volumen de acciones en equipos dominantes como Eduardo Camavinga (12.34) e identificar talentos de gran potencial que pasan desapercibidos, como Soungoutou Magassa y João Neves.

---

## 1. Perfiles tácticos y desglose de grupos (clusters)

El algoritmo de agrupamiento no supervisado segmenta al conjunto de jugadores en cuatro arquetipos tácticos distintos según la ganancia de territorio, la seguridad en el pase, el rendimiento defensivo ajustado por posesión y las métricas de conducción de balón:

### 1.1. Grupo 2: distribuidores progresivos de élite
* **Tamaño de la muestra:** 163 jugadores.
* **Perfil:** Defensores organizadores modernos y proactivos. Estos jugadores constituyen el núcleo de los equipos con alta posesión, funcionando como creadores de juego retrasados que destacan en la distribución romriento líneas y en la progresión en el terreno de juego.
* **Promedios base clave:**
  * Pases progresivos por 90 minutos: 5.77
  * Media del proxy xT: 4.15

### 1.2. Grupo 3: destructores tradicionales
* **Tamaño de la muestra:** 119 jugadores.
* **Perfil:** Defensores marcadamente reactivos y orientados a la corrección. Normalmente se despliegan en bloques defensivos bajos o en sistemas que minimizan el riesgo durante las fases de salida de balón. Su participación con el balón es estrictamente de bajo riesgo.
* **Promedios base clave:**
  * Entradas PAdj por 90 minutos: 4.53
  * Intercepciones PAdj por 90 minutos: 2.69
  * Seguridad en el pase (efectividad de pases): 78.84%

### 1.3. Grupos 1 y 4: perfiles híbridos y de conducción
* **Perfil:** Estos grupos capturan comportamientos tácticos intermedios, identificando perfiles de transición. Se caracterizan por una distribución equilibrada de su rendimiento o por una gran dependencia de las conducciones progresivas de balón en lugar de vías de pase puramente progresivas.

---

## 2. Métricas avanzadas y estructura táctica

### 2.1. Realidades defensivas ajustadas por posesión (PAdj)
Contar las estadísticas absolutas penaliza a los defensores de equipos dominantes, quienes por naturaleza se enfrentan a menos transiciones defensivas. Normalizar el rendimiento defensivo frente a la posesión estimada del rival saca a la luz a los recuperadores de balón de mayor intensidad por oportunidad defensiva real (incluyendo el impacto de las recuperaciones):

| Jugador | Equipo | Puntuación defensiva PAdj | Eficacia táctica |
| :--- | :--- | :--- | :--- |
| **Alidu Seidu** | Clermont Foot | 13.05 | Contención de transiciones de élite, volumen de duelos intenso |
| **Mats Wieffer** | Brighton | 12.67 | Gran radio e intercepciones de alto volumen, protección central de élite |
| **Soungoutou Magassa** | Monaco | 12.63 | Cobertura de alta intensidad, igualando el rendimiento de veteranos a los 19 años |
| **Eduardo Camavinga** | Real Madrid | 12.34 | Disrupción defensiva de élite dentro de un marco de posesión de alta dominancia |

### 2.2. Eje de generación de amenaza esperada (xT)
En lugar de medir el volumen bruto de pases, la aproximación de xT aísla a los jugadores cuyas acciones progresivas aumentan activamente la probabilidad de su equipo de crear una ocasión de gol:

| Jugador | Equipo | Puntuación del proxy xT | Método principal de progresión |
| :--- | :--- | :--- | :--- |
| **Oleksandr Zinchenko** | Arsenal | 8.01 | Pases rompelíneas de élite, iniciación por el interior |
| **Achraf Hakimi** | Paris S-G | 7.03 | Conducciones progresivas de alto volumen, entrada al último tercio |
| **Joshua Kimmich** | Bayern Munich | 6.60 | Distribución progresiva, control estructural desde zonas retrasadas |
| **Leon Goretzka** | Bayern Munich | 6.12 | Conducción vertical, disrupción en bloque medio |
| **Trent Alexander-Arnold** | Liverpool | 5.98 | Cambios de orientación diagonales de alta dificultad, progresión vertical |

---

## 3. Panel de reclutamiento: clasificación de máximo rendimiento

La puntuación general `scouting_score` sintetiza la progresión del balón a través de los pesos empíricos del PCA, la seguridad en el pase, las métricas de intervención ajustadas por posesión y un modificador de edad integrado.

| Jugador | Equipo | Edad | Perfil de rol | Puntuación de scouting compuesta |
| :--- | :--- | :--- | :--- | :--- |
| **Mats Wieffer** | Brighton | 24 | Elite Progressive CB | **5.04** |
| **Eduardo Camavinga** | Real Madrid | 21 | Elite Progressive CB | **4.98** |
| **Niels Nkounkou** | Eint Frankfurt | 22 | Elite Progressive CB | **4.92** |
| **Alphonso Davies** | Bayern Munich | 23 | Elite Progressive CB | **4.83** |
| **Soungoutou Magassa** | Monaco | 19 | Defensive Stopper | **4.79** |

---

## 4. Ineficiencias del mercado y perfiles de alto potencial

Al filtrar a los jugadores menores de 24 años que se sitúan en los percentiles más altos de la puntuación de scouting compuesta, el marco de trabajo revela objetivos de adquisición de alto valor antes de que alcancen su valor máximo de mercado.

* **La élite verificada:** El modelo señala con éxito a talentos de renombre mundial como **Mats Wieffer (5.04)**, **Eduardo Camavinga (4.98)** y **Alphonso Davies (4.83)**, lo que valida la precisión de la métrica para identificar líneas base de desarrollo de élite.
* **El espacio de valor de reclutamiento:**
  * **Soungoutou Magassa (19, Mónaco):** Un valor atípico estadístico excepcional. Con una puntuación de **4.79**, iguala a los centrales tradicionales en volumen de intervenciones PAdj, al tiempo que los supera ampliamente en salida limpia y progresión.
  * **João Neves (19, PSG):** Registra una puntuación de **4.56**, mostrando números de progresión y retención de balón que igualan a los de jugadores consolidados en la plenitud de su carrera.
  * **Lilian Brassier (24, Rennes) y Jon Aramburu (22, Real Sociedad):** Opciones defensivas muy eficientes que muestran una marcada infravaloración estadística en relación con su estabilidad.

---

## 5. Planificación de sucesiones no paramétrica y emparejamiento por similitud

El motor de similitud del coseno calcula la distancia en un espacio de características escalado multidimensional para determinar duplicados matemáticos de los perfiles objetivo, eliminando las conjeturas en la planificación de sucesiones.

### 5.1. Ajustes estructurales de alta precisión (>99% de similitud)
* **Perfil A:** Mamadou Sarr se proyecta como un espejo estadístico exacto de **Dylan Batubinsika** con una coincidencia del 99.99%.
* **Perfil B:** Tosin Adarabioyo registra una huella idéntica a la de **Jon Pacheco** (Real Sociedad - 99.98% de coincidencia), presentando a Pacheco como una opción de reemplazo inmediata capaz de ofrecer los mismos números base.
* **Perfil C:** Sofyan Amrabat arroja una equivalencia táctica exacta con **Danilo** (99.97% de coincidencia).

### 5.2. Consultas de reemplazo específicas
Al consultar al sistema por objetivos para la línea defensiva que sean progresivos y versátiles, el motor genera una lista de candidatos óptima ordenada por viabilidad técnica:
1. **Juan David Cabal** (94.2% de similitud del coseno) - *Objetivo principal*
2. **Antonee Robinson** (93.0% de similitud del coseno) - *Alternativa secundaria*
3. **Gideon Mensah** (92.1% de similitud del coseno) - *Tercera alternativa*

---

## 6. Conclusiones tácticas para direcciones deportivas

* **El contexto importa más que la cantidad:** El volumen defensivo bruto es un indicador de la debilidad del equipo, no de la capacidad del jugador. Pasar a un marco PAdj —anclado en estimaciones reales del volumen de pases— aísla la verdadera velocidad de procesamiento y el posicionamiento. Esto queda demostrado por la promoción algorítmica de jugadores como Eduardo Camavinga y Soungoutou Magassa, cuyas acciones defensivas tienen un peso exponencialmente mayor en entornos de alta posesión.
* **Inversión agresiva en la juventud:** Las canteras están acelerando con éxito las capacidades técnicas. Talentos como João Neves y Magassa están generando rendimientos propios de futbolistas consagrados a sus 19 años, lo que los convierte en objetivos prioritarios antes de que sus valoraciones de mercado se disparen.
* **Planificación de contingencias automatizada:** La combinación de la similitud del coseno permite al equipo de reclutamiento establecer opciones de reemplazo inmediatas y sin el influjo del "hype" (por ejemplo, Jon Pacheco) en el momento en que un perfil titular reciba ofertas de mercado sobrevaloradas.
