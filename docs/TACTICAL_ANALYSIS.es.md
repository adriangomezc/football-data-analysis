# Análisis táctico y perfilado de defensores modernos

## Resumen ejecutivo

Este informe desglosa los perfiles tácticos de centrales y pivotes defensivos en las principales ligas europeas utilizando datos de rendimiento de las últimas temporadas. Mediante el uso de algoritmos de clústeres k-means (k=4) y el Análisis de Componentes Principales (PCA), el flujo de trabajo aísla los comportamientos de los futbolistas para contextualizar su rendimiento e identificar perfiles transferibles.

**Mats Wieffer** (Brighton) lidera el panel de contratación con una puntuación global de 5.04, seguido de cerca por **Eduardo Camavinga** (4.98). En la faceta de distribución, **Oleksandr Zinchenko** (Arsenal) se mantiene como el perfil de mayor volumen en progresión y ganancia de metros, registrando un índice de peligro (proxy xT) de 8.01.

En el plano defensivo, el uso de métricas ajustadas por posesión (PAdj)—estimadas a partir del volumen de pases del equipo frente a su liga—demuestra que la estadística tradicional penaliza a los jugadores de equipos dominantes. Corregir este sesgo permite medir la intensidad real por oportunidad, destacando la capacidad de corte de **Alidu Seidu** (13.05), premiando la actividad en escenarios de alta posesión como la de **Eduardo Camavinga** (12.34) y sacando a la luz el rendimiento de jóvenes como **Soungoutou Magassa** y **João Neves**.

---

## 1. Perfiles tácticos y desglose de grupos

El algoritmo de agrupamiento no supervisado divide la muestra de jugadores en cuatro arquetipos tácticos según su volumen de pase, precisión, acciones defensivas ajustadas por posesión y metros avanzados mediante conducción:

### 1.1. Grupo 2: distribuidores progresivos de élite
* **Tamaño de la muestra:** 163 jugadores.
* **Perfil:** Iniciadores de juego y organizadores retrasados. Suelen formar parte de equipos con propuestas asociativas elevadas, actuando como el primer escalón de la construcción y destacando en el pase vertical.
* **Promedios del grupo:**
  * Pases progresivos por 90 minutos: 5.77
  * Media del proxy xT: 4.15

### 1.2. Grupo 3: destructores tradicionales
* **Tamaño de la muestra:** 119 jugadores.
* **Perfil:** Defensores de perfil correctivo y reactivo. Habituales en bloques bajos o en esquemas donde se reduce el riesgo con el balón, limitando sus intervenciones ofensivas a entregas de seguridad.
* **Promedios del grupo:**
  * Entradas PAdj por 90 minutos: 4.53
  * Intercepciones PAdj por 90 minutos: 2.69
  * Precisión en el pase: 78.84%

### 1.3. Grupos 1 y 4: perfiles híbridos y de conducción
* **Perfil:** Comportamientos intermedios de transición. El grupo 4 (222 jugadores) destaca especialmente por su tendencia a avanzar metros conduciendo el balón (promedio de 2.48 conducciones progresivas por 90 minutos) en lugar de buscar líneas de pase verticales.

---

## 2. Métricas avanzadas y estructura táctica

### 2.1. Realidades defensivas ajustadas por posesión (PAdj)
Las estadísticas defensivas brutas están sesgadas por el tiempo que un equipo pasa sin el balón. Al normalizar los datos contra la posesión estimada del rival, el modelo evalúa el volumen de recuperaciones, entradas e intercepciones por oportunidad real de intervención:

| Jugador | Equipo | Puntuación defensiva PAdj | Eficacia táctica |
| :--- | :--- | :--- | :--- |
| **Alidu Seidu** | Clermont Foot | 13.05 | Contención de transiciones, alto volumen de duelos y anticipación |
| **Mats Wieffer** | Brighton | 12.67 | Gran radio de acción, interceptor y protección de la zona central |
| **Soungoutou Magassa** | Monaco | 12.63 | Cobertura de alta intensidad, rendimiento de veterano a los 19 años |
| **Eduardo Camavinga** | Real Madrid | 12.34 | Disrupción defensiva alta en entornos de posesión dominante |

### 2.2. Eje de progresión e índice de peligro (proxy xT)
A falta de microdatos de eventos espaciales, el proxy de xT funciona como un indicador del peligro generado mediante la combinación lineal de pases y conducciones que rompen líneas:

| Jugador | Equipo | Puntuación del proxy xT | Método principal de progresión |
| :--- | :--- | :--- | :--- |
| **Oleksandr Zinchenko** | Arsenal | 8.01 | Pase vertical rompelíneas, construcción interior |
| **Achraf Hakimi** | Paris S-G | 7.03 | Conducción progresiva por banda, llegada a último tercio |
| **Joshua Kimmich** | Bayern Munich | 6.60 | Distribución organizada, apoyos en corto y medio alcance |
| **Leon Goretzka** | Bayern Munich | 6.12 | Conducción vertical, ruptura de presiones en bloque medio |
| **Trent Alexander-Arnold** | Liverpool | 5.98 | Desplazamiento en largo y cambios de orientación de alta dificultad |

---

## 3. Panel de reclutamiento: clasificación de máximo rendimiento

La nota final (`scouting_score`) unifica la capacidad de progresión ponderada por el PCA, el acierto en el pase, las acciones de corte ajustadas por PAdj y un factor corrector por edad para identificar los perfiles de mayor valor.

| Jugador | Equipo | Edad | Perfil de rol | Puntuación de scouting compuesta |
| :--- | :--- | :--- | :--- | :--- |
| **Mats Wieffer** | Brighton | 24 | Elite Progressive CB | **5.04** |
| **Eduardo Camavinga** | Real Madrid | 21 | Elite Progressive CB | **4.98** |
| **Niels Nkounkou** | Eint Frankfurt | 22 | Elite Progressive CB | **4.92** |
| **Alphonso Davies** | Bayern Munich | 23 | Elite Progressive CB | **4.83** |
| **Soungoutou Magassa** | Monaco | 19 | Defensive Stopper | **4.79** |

---

## 4. Ineficiencias del mercado y perfiles de alto potencial

Al filtrar los jugadores menores de 24 años que se encuentran en el percentil superior del panel de contratación, el modelo aísla perfiles con un rendimiento superior a su valor de mercado esperado.

* **Validación de la élite:** El algoritmo clasifica en las posiciones más altas a futbolistas contrastados como **Mats Wieffer (5.04)**, **Eduardo Camavinga (4.98)** y **Alphonso Davies (4.83)**, lo que confirma la consistencia de la fórmula empleada.
* **Oportunidades en el mercado de fichajes:**
  * **Soungoutou Magassa (19, Mónaco):** Destaca con una nota de **4.79**. Registra una actividad defensiva PAdj propia de centrales veteranos de equipo replegado, pero sumando una limpieza en la salida de balón muy superior a la media de su clúster.
  * **João Neves (19, PSG):** Con un score de **4.56**, sus registros de circulación bajo presión y retención de balón reflejan una madurez impropia de su edad.
  * **Lilian Brassier (24, Rennes) y Jon Aramburu (22, Real Sociedad):** Alternativas fiables que muestran una regularidad defensiva sólida frente a un coste de adquisición potencialmente menor.

---

## 5. Planificación de sucesiones y emparejamiento por similitud

El motor de similitud del coseno analiza la distancia geométrica de los futbolistas dentro del espacio multidimensional estandarizado para encontrar reemplazos directos en la base de datos.

### 5.1. Coincidencias estadísticas directas (>99% de similitud)
* **Mamadou Sarr** se indexa como un clon estadístico exacto de **Dylan Batubinsika** (99.99% de similitud).
* **Tosin Adarabioyo** muestra la misma firma de rendimiento que **Jon Pacheco** (Real Sociedad - 99.98%), sugiriendo al central de la Real como un relevo viable a menor coste.
* **Sofyan Amrabat** refleja una equivalencia de comportamiento idéntica a la de **Danilo** (99.97%).

### 5.2. Consultas de reemplazo específicas
Al solicitar al sistema perfiles defensivos versátiles, con movilidad y con un peso alto en la circulación desde atrás, el recomendador genera la siguiente lista de alternativas ordenadas por viabilidad técnica:
1. **Juan David Cabal** (94.2% de similitud del coseno) - *Opción principal*
2. **Antonee Robinson** (93.0% de similitud del coseno) - *Alternativa secundaria*
3. **Gideon Mensah** (92.1% de similitud del coseno) - *Tercera alternativa*

---

## 6. Conclusiones tácticas para direcciones deportivas

* **Contexto frente a volumen:** El volumen bruto de entradas o intercepciones suele ser síntoma de un equipo sometido, no de la calidad individual del defensor. El marco PAdj basado en el volumen de pases reales equilibra la balanza, permitiendo valorar el acierto de jugadores como Eduardo Camavinga o Soungoutou Magassa, que intervienen menos veces por partido pero con una efectividad por oportunidad mucho mayor.
* **Detección temprana:** Los procesos de formación actuales aceleran las condiciones técnicas de los jóvenes. Identificar que jugadores de 19 años como Magassa o João Neves rinden al nivel de la media de la liga permite anticipar incorporaciones antes de que entren en el radar de clubes de mayor presupuesto.
* **Automatización de alternativas:** La incorporación de matrices de similitud matemática permite a la secretaría técnica automatizar los planes de contingencia. Contar con nombres directos y monitorizados (como Jon Pacheco) reduce el tiempo de reacción ante salidas inesperadas o rupturas en una negociación de mercado.
