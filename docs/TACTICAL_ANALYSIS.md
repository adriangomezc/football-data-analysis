# Tactical analysis and profiling of modern centre-back profiles

## Executive summary

This report breaks down the tactical profiles of centre-backs across Europe's top five leagues using data from the 2023–24 season. A K-means clustering framework (k=4) and Principal Component Analysis isolate distinct player behaviours, while possession-adjusted (PAdj) metrics provide context that raw counting stats omit.

**Sead Kolašinac** (Atalanta) leads the composite scouting framework with an overall score of 5.08, followed by breakout star **Riccardo Calafiori** (Bologna, 4.98) and **Timo Hübers** (Köln, 4.84). For pure ball progression, **Iñigo Martínez** (Barcelona) registers the highest progression index in the sample at 4.31.

Applying the sigmoidal curve for possession-adjusted metrics reveals that defensive counts are heavily dictated by team dominance. After normalising for true defensive opportunity, **Timo Hübers** (13.31 combined PAdj) and **Riccardo Calafiori** (13.18) emerge as the most intense and active defenders across the top five leagues.

---

## 1. Tactical profiles and cluster breakdown

K-means clustering (k=4) on z-scored progression and PAdj defensive variables segments the player pool into four distinct tactical archetypes. The algorithm dynamically assigns role labels by evaluating the mathematical centroids.

### 1.1. Elite progressive distributors
- **Profile:** Primary build-up directors in high-possession structures or three-at-the-back systems with high carrying freedom. They register the highest progression volume in the sample.
- **Standout examples:** Sead Kolašinac, Nico Schlotterbeck, Iñigo Martínez.

### 1.2. High-intensity ball-winners
- **Profile:** Highly proactive defenders oriented towards jumping out of the line, anticipation, and duels. They present the highest PAdj defensive output in the ecosystem.
- **Standout examples:** Riccardo Calafiori, Timo Hübers, Alidu Seidu.

### 1.3. Standard build-up distributors
- **Profile:** The modal modern centre-back type. Solid safety passing volume and balanced defensive involvement. They serve as the baseline for comparison.
- **Standout examples:** Tyrone Mings, Ezri Konsa.

### 1.4. Limited / reactive defenders
- **Profile:** Minimal ball progression contribution. Often found in structured defensive systems or low blocks with limited build-up responsibility.
- **Standout examples:** Saúl Coco, Matija Nastasić.

---

## 2. Advanced metrics and tactical context

### 2.1. Possession-adjusted (PAdj) defending

Counting raw actions penalises defenders in dominant teams. By applying a sigmoidal multiplier using the league average as a proxy, we normalise defensive intensity per true opportunity. The calculation combines adjusted tackles, interceptions, and recoveries.

| Player | Squad | League | PAdj defensive score (Combined) |
|:-------|:------|:-------|:--------------------------------|
| **Timo Hübers** | Köln | Bundesliga | **13.31** |
| **Riccardo Calafiori** | Bologna | Serie A | **13.18** |
| **Alidu Seidu** | Clermont Foot | Ligue 1 | **12.49** |
| **Giorgio Scalvini** | Atalanta | Serie A | **11.77** |
| **Sead Kolašinac** | Atalanta | Serie A | **11.50** |

### 2.2. Progression index

This metric combines progressive passes, progressive carries, and key passes per 90. The weights are not arbitrary; they are dynamically extracted from the PC1 loadings of a Principal Component Analysis.

| Player | Squad | Progression index | Prog. passes/90 | Prog. carries/90 |
|:-------|:------|:------------------|:----------------|:-----------------|
| **Iñigo Martínez** | Barcelona | **4.31** | 9.40 | 2.53 |
| **Nico Schlotterbeck**| Dortmund | **3.90** | 8.85 | 1.68 |
| **Sead Kolašinac** | Atalanta | **3.43** | 6.72 | 2.46 |
| **Manuel Akanji** | Manchester City | **3.29** | 7.06 | 2.06 |
| **Eric García** | Girona | **3.25** | 7.54 | 1.54 |

---

## 3. The recruitment dashboard: top scouting scores

The master composite score integrates the progression index (40%), PAdj defending performance (30%), pass completion (10%), and an age value curve that rewards peak performance windows (20%).

| Player | Squad | Age | Assigned tactical role | Scouting score |
|:-------|:------|:----|:-----------------------|:---------------|
| **Sead Kolašinac** | Atalanta | 31 | Elite Progressive Distributor | **5.08** |
| **Riccardo Calafiori**| Bologna | 21 | High-Intensity Ball-Winner | **4.98** |
| **Timo Hübers** | Köln | 27 | High-Intensity Ball-Winner | **4.84** |
| **Nico Schlotterbeck**| Dortmund | 24 | Elite Progressive Distributor | **4.73** |
| **Alidu Seidu** | Clermont Foot| 23 | High-Intensity Ball-Winner | **4.62** |

---

## 4. Market inefficiencies and U-24 profiles

Filtering exclusively for players aged 24 or under who sit above the 80th percentile in overall performance:

- **Riccardo Calafiori (21, Bologna, 4.98):** The absolute standout regarding age-to-performance ratio. Combines an incredibly high PAdj recovery volume (13.18) within Thiago Motta's aggressive structure.
- **Nico Schlotterbeck (24, Dortmund, 4.73):** The most dominant U-24 profile in ball progression (3.90). An established elite distributor.
- **Alidu Seidu (23, Clermont Foot, 4.62):** Remains a massive market inefficiency in PAdj metrics. Highly impressive output in an underperforming team context.
- **Giorgio Scalvini (19, Atalanta, 4.58):** The highest-scoring teenager on the continent. Statistically performing like an established elite European centre-back.
- **Jarell Quansah (20, Liverpool, 4.00) and El Chadaille Bitshiabu (19, RB Leipzig, 3.81):** Rapidly rising profiles that already clear the technical requirement threshold.

---

## 5. Similarity engine: succession planning

The cosine similarity engine scans the standardised feature space to find identical tactical profiles. The query was executed to find a replacement for **Sead Kolašinac**, the overall ranking leader.

### Top statistical matches for Sead Kolašinac

| Rank | Player | Cosine similarity |
|:-----|:-------|:------------------|
| 1 | **Mario Gila** (Lazio) | **97.1%** |
| 2 | **Javi Rodríguez** (Celta) | **95.9%** |
| 3 | **Facundo Medina** (Lens) | **95.3%** |
| 4 | **Mohamed Simakan** (RB Leipzig) | **94.2%** |
| 5 | **Lutsharel Geertruida** (Feyenoord/RBL) | **94.0%** |

**Mario Gila** (97.1%) emerges as the near-perfect tactical successor: an outside centre-back with high recovery aggression and exceptional ability to carry the ball and break pressing lines. **Facundo Medina** (95.3%) represents another natural fit as an aggressive left-footed profile.

---

## 6. Tactical takeaways

- **The system effect.** The dominant presence of players from Atalanta (Kolašinac, Scalvini) and Motta's Bologna (Calafiori, Lucumí) highlights how man-marking and proactive defensive systems drastically elevate their centre-backs' PAdj metrics.
- **Pure centre-backs vs inverted full-backs.** The strict attacking-third touch filter cleaned the database of "fake centre-backs", allowing true progressive defenders (like Schlotterbeck or Iñigo Martínez) to rightfully lead the ranking without unfair competition from overlapping full-backs.
- **Predictive quality of the model.** Identifying Riccardo Calafiori as one of the most statistically dominant profiles of the season (prior to his mainstream Euro impact and Arsenal transfer) validates the robustness of merging PAdj defensive scoring with PCA-weighted ball progression.
- **Similarity as a succession plan.** The engine removes visual bias. Identifying Mario Gila or Javi Rodríguez as twin profiles to Kolašinac provides the scouting department with a purely objective shortlist, ready to be filtered by financial viability.
