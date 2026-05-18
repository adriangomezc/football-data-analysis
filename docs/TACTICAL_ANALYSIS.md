# Análisis Táctico y Perfilado de Defensores Modernos

## Resumen Ejecutivo

Este informe desglosa los perfiles tácticos de los defensores centrales y pivotes modernos en las principales ligas europeas, analizando datos de rendimiento longitudinales que abarcan cuatro temporadas. Al aplicar el agrupamiento K-means (k=4) y el Análisis de Componentes Principales (PCA), este marco de trabajo aísla comportamientos específicos de los jugadores para eliminar sesgos y contextualizar su rendimiento.

Oleksandr Zinchenko (Arsenal) emerge como el referente absoluto en la fase de salida de balón, generando una aproximación de Amenaza Esperada (proxy xT) de 8.01 (la más alta de los datos analizados) y liderando la métrica de scouting compuesta final con una puntuación global de 2.09. En el otro extremo del espectro táctico, la aplicación de métricas ajustadas por posesión (PAdj) —estimadas matemáticamente a través del volumen relativo de pases del equipo— revela que el rendimiento defensivo bruto está fuertemente distorsionado por el sistema táctico del equipo. Corregir este sesgo permite descubrir una intensidad defensiva de élite en destructores puros como Alidu Seidu (4.14), premiar a defensores con un alto volumen de acciones en equipos dominantes como Eduardo Camavinga (3.95) e identificar talentos de gran potencial que pasan desapercibidos, como Soungoutou Magassa y João Neves.

---

## 1. Perfiles Tácticos y Desglose de Grupos (Clusters)

El algoritmo de agrupamiento no supervisado segmenta al conjunto de jugadores en cuatro arquetipos tácticos distintos según la ganancia de territorio, la seguridad en el pase, el rendimiento defensivo ajustado por posesión y las métricas de conducción de balón:

### 1.1. Grupo 2: Distribuidores Progresivos de Élite

* **Tamaño de la muestra:** 188 jugadores.
* **Perfil:** Defensores organizadores modernos y proactivos. Estos jugadores constituyen el núcleo de los equipos con alta posesión, funcionando como creadores de juego retrasados que destacan en la distribución rompiendo líneas y en la progresión en el terreno de juego.
* **Promedios Base Clave:**
* Pases progresivos por 90 minutos: 5.60
* Media del proxy xT: 4.06



### 1.2. Grupo 3: Destructores Tradicionales

* **Tamaño de la muestra:** 173 jugadores.
* **Perfil:** Defensores marcadamente reactivos y orientados a la corrección. Normalmente se despliegan en bloques defensivos bajos o en sistemas que minimizan el riesgo durante las fases de salida de balón. Su participación con el balón es estrictamente de bajo riesgo.
* **Promedios Base Clave:**
* Entradas PAdj por 90 minutos: 2.38
* Intercepciones PAdj por 90 minutos: 1.43
* Seguridad en el pase (Efectividad de pases): 78.00%



### 1.3. Grupos 1 y 4: Perfiles Híbridos y de Conducción

* **Perfil:** Estos grupos capturan comportamientos tácticos intermedios, identificando perfiles de transición. Se caracterizan por una distribución equilibrada de su rendimiento o por una gran dependencia de las conducciones progresivas de balón en lugar de vías de pase puramente progresivas.

---

## 2. Métricas Avanzadas y Estructura Táctica

### 2.1. Realidades Defensivas Ajustadas por Posesión (PAdj)

Contar las estadísticas absolutas penaliza a los defensores de equipos dominantes, quienes por naturaleza se enfrentan a menos transiciones defensivas. Normalizar el rendimiento defensivo frente a la posesión estimada del rival (derivada del volumen relativo de pases de la liga) saca a la luz a los recuperadores de balón de mayor intensidad por oportunidad defensiva real:

| Jugador | Equipo | Puntuación Defensiva PAdj | Eficacia Táctica |
| --- | --- | --- | --- |
| **Alidu Seidu** | Clermont Foot | 4.14 | Contención de transiciones de élite, volumen de duelos intenso |
| **Mats Wieffer** | Brighton | 4.13 | Gran radio e intercepciones de alto volumen, protección central de élite |
| **Soungoutou Magassa** | Monaco | 4.04 | Cobertura de alta intensidad, igualando el rendimiento de veteranos a los 19 años |
| **Eduardo Camavinga** | Real Madrid | 3.95 | Disrupción defensiva de élite dentro de un marco de posesión de alta dominancia |

### 2.2. Eje de Generación de Amenaza Esperada (xT)

En lugar de medir el volumen bruto de pases, la aproximación de xT aísla a los jugadores cuyas acciones progresivas aumentan activamente la probabilidad de su equipo de crear una ocasión de gol:

| Jugador | Equipo | Puntuación del Proxy xT | Método Principal de Progresión |
| --- | --- | --- | --- |
| **Oleksandr Zinchenko** | Arsenal | 8.01 | Pases rompelíneas de élite, iniciación por el interior |
| **Achraf Hakimi** | Paris S-G | 7.03 | Conducciones progresivas de alto volumen, entrada al último tercio |
| **Joshua Kimmich** | Bayern Munich | 6.60 | Distribución progresiva, control estructural desde zonas retrasadas |
| **Leon Goretzka** | Bayern Munich | 6.12 | Conducción vertical, disrupción en bloque medio |
| **Trent Alexander-Arnold** | Liverpool | 5.98 | Cambios de orientación diagonales de alta dificultad, progresión vertical |

---

## 3. Panel de Reclutamiento: Clasificación de Máximo Rendimiento

La puntuación general `scouting_score` sintetiza la progresión del balón a través de xT, la seguridad en el pase, las métricas de intervención ajustadas por posesión y un modificador de edad integrado para identificar los activos defensivos más completos del mercado.

| Jugador | Equipo | Edad | Perfil de Rol | Puntuación de Scouting Compuesta |
| --- | --- | --- | --- | --- |
| **Oleksandr Zinchenko** | Arsenal | 26 | Distribuidor progresivo de élite | **2.09** |
| **Eduardo Camavinga** | Real Madrid | 21 | Híbrido de central / pivote progresivo de élite | **1.82** |
| **Achraf Hakimi** | Paris S-G | 25 | Distribuidor progresivo de élite | **1.82** |
| **Soungoutou Magassa** | Monaco | 19 | Híbrido progresivo de élite | **1.78** |
| **João Neves** | Paris S-G | 19 | Híbrido progresivo de élite | **1.73** |

---

## 4. Ineficiencias del Mercado y Perfiles de Alto Potencial

Al filtrar a los jugadores menores de 24 años que se sitúan en los percentiles más altos de la puntuación de scouting compuesta, el marco de trabajo revela objetivos de adquisición de alto valor antes de que alcancen su valor máximo de mercado.

* **La Élite Verificada:** El modelo señala con éxito a talentos de renombre como **Eduardo Camavinga (1.82)** y **Alphonso Davies (1.70)**, lo que valida la precisión de la métrica para identificar líneas base de desarrollo de élite.
* **El Espacio de Valor de Reclutamiento:**
* **João Neves (19, PSG) y Warren Zaïre-Emery (18, PSG):** Registran números de progresión y retención de balón que igualan a los de jugadores en la plenitud de su carrera.
* **Soungoutou Magassa (19, Mónaco):** Un valor atípico estadístico excepcional. A sus 19 años, iguala a los centrales tradicionales en volumen de intervenciones PAdj, al tiempo que los supera ampliamente en rendimiento progresivo.
* **Lilian Brassier (24, Rennes) y Jon Aramburu (22, Real Sociedad):** Opciones defensivas muy eficientes que muestran una marcada infravaloración estadística en relación con su estabilidad defensiva.



---

## 5. Planificación de Sucesiones No Paramétrica y Emparejamiento por Similitud

El motor de Similitud del Coseno calcula la distancia en un espacio de características escalado multidimensional para determinar duplicados matemáticos de los perfiles objetivo, eliminando las conjeturas en la planificación de sucesiones.

### 5.1. Ajustes Estructurales de Alta Precisión (>99% de Similitud)

* **Perfil A:** Neco Williams se proyecta como un espejo estadístico exacto de **Max Finkgräfe** (Köln) con una coincidencia del 99.98%.
* **Perfil B:** Tosin Adarabioyo registra una huella idéntica a la de **Jon Pacheco** (Real Sociedad), presentando a Pacheco como una opción de reemplazo inmediata capaz de ofrecer los mismos números base.
* **Perfil C:** Sofyan Amrabat arroja una equivalencia táctica exacta con **Danilo** (99.98% de coincidencia).

### 5.2. Consultas de Reemplazo Específicas

Al consultar al sistema por objetivos para la línea defensiva que sean progresivos, versátiles, muestren gran movilidad y tengan perfiles de posesión en zonas retrasadas, el motor genera una lista de candidatos óptima para el traspaso, ordenada por viabilidad técnica:

1. **Juan David Cabal** (94.2% de Similitud del Coseno) - *Objetivo Principal*
2. **Antonee Robinson** (93.0% de Similitud del Coseno) - *Alternativa Secundaria*
3. **Gideon Mensah** (92.1% de Similitud del Coseno) - *Tercera Alternativa*

---

## 6. Conclusiones Tácticas para Direcciones Deportivas

* **El Contexto Importa Más que la Cantidad:** El volumen defensivo bruto es un indicador de la debilidad del equipo, no de la capacidad del jugador. Pasar a un marco PAdj —anclado en estimaciones reales del volumen de pases— aísla la verdadera velocidad de procesamiento y el posicionamiento. Esto queda demostrado por la promoción algorítmica de jugadores como Eduardo Camavinga y Soungoutou Magassa, cuyas acciones defensivas tienen un peso exponencialmente mayor en entornos de alta posesión.
* **Inversión Agresiva en la Juventud:** Las canteras están acelerando con éxito las capacidades técnicas. Talentos como João Neves y Magassa están generando rendimientos propios de futbolistas consagrados a sus 19 años, lo que los convierte en objetivos prioritarios para la planificación de la plantilla a largo plazo antes de que sus valoraciones de mercado se adapten a su realidad estadística.
* **Planificación de Contingencias Automatizada:** La incorporación de la similitud del coseno permite al equipo de reclutamiento establecer opciones de reemplazo inmediatas y sin el influjo del "hype" (por ejemplo, Jon Pacheco o Max Finkgräfe) en el momento en que un perfil titular entre en disputas contractuales o reciba ofertas de mercado sobrevaloradas.
