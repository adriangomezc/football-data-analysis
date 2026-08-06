[![es](https://img.shields.io/badge/lang-es-yellow.svg)](TACTICAL_ANALYSIS.es.md)

# Tactical analysis and profiling of modern centre-back profiles

← Back to the [main README](../README.md)

## Executive summary

This report breaks down the tactical profiles of centre-backs across Europe's top five leagues. A K-means clustering framework (k=4) and Principal Component Analysis isolate distinct player behaviours, while possession-adjusted (PAdj) metrics provide context that raw counting stats omit.

**Sample.** 407 pure centre-backs, each entering with **their most recent qualifying season** — 286 from 2024–25 and 121 from 2023–24. Every table below therefore carries a season column: the ranking compares players at their latest available form, not within a single fixed campaign.

**Sead Kolašinac** (Atalanta) leads the composite scouting framework with an overall score of 5.08, followed by **Riccardo Calafiori** (Bologna, 4.98) and **Timo Hübers** (Köln, 4.84). For pure ball progression, **Iñigo Martínez** (Barcelona) registers the highest progression index in the sample at 4.31.

Applying the sigmoidal curve for possession-adjusted metrics reveals that defensive counts are heavily dictated by team dominance. After normalising for true defensive opportunity, **Timo Hübers** (13.31 combined PAdj) and **Riccardo Calafiori** (13.18) emerge as the most active defenders in the sample.

---

## 1. Tactical profiles and cluster breakdown

K-means clustering (k=4) on z-scored progression and PAdj defensive variables segments the player pool into four distinct tactical archetypes. The algorithm assigns role labels by reading the cluster centroids rather than by hardcoding them.

| Archetype | Players | Mean progression index | Mean PAdj tackles + int. | Mean pass completion |
|:----------|--------:|-----------------------:|-------------------------:|---------------------:|
| Elite Progressive Distributor | 48 | 2.65 | 2.53 | 88.4% |
| Standard Build-up Distributor | 117 | 1.67 | 2.16 | 87.5% |
| High-Intensity Ball-Winner | 97 | 1.30 | 3.66 | 84.1% |
| Limited / Reactive Defender | 145 | 0.95 | 2.28 | 85.8% |

### 1.1. Elite progressive distributors
- **Profile:** Primary build-up directors in high-possession structures or three-at-the-back systems with high carrying freedom. They register the highest progression volume in the sample, and the highest pass completion.
- **Standout examples:** Sead Kolašinac, Nico Schlotterbeck, Iñigo Martínez.

### 1.2. High-intensity ball-winners
- **Profile:** Highly proactive defenders oriented towards jumping out of the line, anticipation, and duels. They present the highest PAdj defensive output in the ecosystem — and, as the trade-off, the lowest pass completion.
- **Standout examples:** Riccardo Calafiori, Timo Hübers, Alidu Seidu.

### 1.3. Standard build-up distributors
- **Profile:** The modal modern centre-back type. Solid safety passing volume and mid-range progression, with the most conservative defensive engagement of the four groups. They serve as the baseline for comparison.
- **Standout examples:** Tyrone Mings, Ezri Konsa.

### 1.4. Limited / reactive defenders
- **Profile:** Minimal ball progression contribution. Often found in structured defensive systems or low blocks with limited build-up responsibility. The largest group in the sample.
- **Standout examples:** Saúl Coco, Matija Nastasić.

---

## 2. Advanced metrics and tactical context

### 2.1. Possession-adjusted (PAdj) defending

Counting raw actions penalises defenders in dominant teams. By applying a sigmoidal multiplier using the league average as a proxy, we normalise defensive intensity per true opportunity. The calculation combines adjusted tackles, interceptions, and recoveries.

| Player | Squad | League | Season | PAdj defensive score (combined) |
|:-------|:------|:-------|:-------|--------------------------------:|
| **Timo Hübers** | Köln | Bundesliga | 2023–24 | **13.31** |
| **Riccardo Calafiori** | Bologna | Serie A | 2023–24 | **13.18** |
| **Alidu Seidu** | Clermont Foot | Ligue 1 | 2023–24 | **12.49** |
| **Giorgio Scalvini** | Atalanta | Serie A | 2023–24 | **11.77** |
| **Sead Kolašinac** | Atalanta | Serie A | 2024–25 | **11.50** |

### 2.2. Progression index

This metric combines progressive passes, progressive carries, and key passes per 90. The weights are not arbitrary; they are dynamically extracted from the PC1 loadings of a Principal Component Analysis (0.346 / 0.352 / 0.302).

| Player | Squad | Season | Progression index | Prog. passes/90 | Prog. carries/90 |
|:-------|:------|:-------|------------------:|----------------:|-----------------:|
| **Iñigo Martínez** | Barcelona | 2024–25 | **4.31** | 9.40 | 2.53 |
| **Nico Schlotterbeck** | Dortmund | 2024–25 | **3.90** | 8.85 | 1.68 |
| **Sead Kolašinac** | Atalanta | 2024–25 | **3.43** | 6.72 | 2.46 |
| **Manuel Akanji** | Manchester City | 2024–25 | **3.29** | 7.06 | 2.06 |
| **Eric García** | Girona | 2023–24 | **3.25** | 7.54 | 1.54 |

---

## 3. The recruitment dashboard: top scouting scores

The master composite score integrates the progression index (40%), PAdj defending performance (30%), pass completion (10%), and an age value curve that rewards peak performance windows (20%).

| Player | Squad | Season | Age | Assigned tactical role | Scouting score |
|:-------|:------|:-------|:----|:-----------------------|---------------:|
| **Sead Kolašinac** | Atalanta | 2024–25 | 31 | Elite Progressive Distributor | **5.08** |
| **Riccardo Calafiori** | Bologna | 2023–24 | 21 | High-Intensity Ball-Winner | **4.98** |
| **Timo Hübers** | Köln | 2023–24 | 27 | High-Intensity Ball-Winner | **4.84** |
| **Nico Schlotterbeck** | Dortmund | 2024–25 | 24 | Elite Progressive Distributor | **4.73** |
| **Alidu Seidu** | Clermont Foot | 2023–24 | 23 | High-Intensity Ball-Winner | **4.62** |

Note how the components trade off. Kolašinac tops the ranking at 31 while carrying the lowest age multiplier of this group (0.85), purely on the strength of a 3.43 progression index — nearly double Calafiori's 1.85. Calafiori closes almost all of that gap from the other direction: the highest combined PAdj defensive score in the sample (13.18 vs 11.50) plus the full U-24 age bonus. The final margin between them is 0.10 points.

---

## 4. Market inefficiencies and U-24 profiles

Filtering exclusively for players aged 24 or under who sit above the 80th percentile in overall performance:

- **Riccardo Calafiori (21, Bologna, 2023–24, 4.98):** The absolute standout regarding age-to-performance ratio. He records the highest PAdj recovery volume in the entire sample (8.79 per 90) within Thiago Motta's aggressive structure, and the highest combined PAdj defensive score (13.18).
- **Nico Schlotterbeck (24, Dortmund, 2024–25, 4.73):** The most dominant U-24 profile in ball progression (3.90). An established elite distributor.
- **Alidu Seidu (23, Clermont Foot, 2023–24, 4.62):** A genuine market inefficiency. His 12.49 combined PAdj score is achieved with a *below-neutral* possession multiplier (0.96) — his output is not inflated by a dominant team, it survives the adjustment.
- **Giorgio Scalvini (19, Atalanta, 2023–24, 4.58):** The highest-scoring teenager in the sample by a clear margin. Statistically performing like an established elite European centre-back.
- **Jarell Quansah (20, Liverpool, 2023–24, 4.00) and El Chadaille Bitshiabu (19, RB Leipzig, 2024–25, 3.81):** Rapidly rising profiles that already clear the technical requirement threshold.

---

## 5. Similarity engine: succession planning

The cosine similarity engine scans the standardised feature space to find the closest tactical profiles. The query was executed to find a replacement for **Sead Kolašinac**, the overall ranking leader.

### Top statistical matches for Sead Kolašinac

| Rank | Player | Squad (sample season) | Cosine similarity |
|:-----|:-------|:----------------------|------------------:|
| 1 | **Mario Gila** | Lazio (2024–25) | **97.1%** |
| 2 | **Javi Rodríguez** | Celta Vigo (2024–25) | **95.9%** |
| 3 | **Facundo Medina** | Lens (2024–25) | **95.3%** |
| 4 | **Mohamed Simakan** | RB Leipzig (2023–24) | **94.2%** |
| 5 | **Lutsharel Geertruida** | RB Leipzig (2024–25) | **94.0%** |

**Mario Gila** (97.1%) emerges as the near-perfect tactical successor: an outside centre-back with high recovery aggression and strong ability to carry the ball and break pressing lines. **Facundo Medina** (95.3%) represents another natural fit as an aggressive left-footed profile. All five matches sit in the *Elite Progressive Distributor* cluster except Javi Rodríguez, who is classified as a *Standard Build-up Distributor* — a reminder that cosine similarity on the feature space and hard cluster assignment answer slightly different questions.

---

## 6. Tactical takeaways

- **The system effect.** The dominant presence of Gasperini's Atalanta (Kolašinac, Scalvini) and of Calafiori in Thiago Motta's 2023–24 Bologna highlights how man-marking and proactive defensive systems drastically elevate their centre-backs' PAdj metrics.
- **Pure centre-backs vs inverted full-backs.** The strict attacking-third touch and progressive-reception filters cleaned the database of "fake centre-backs", allowing true progressive defenders (like Schlotterbeck or Iñigo Martínez) to lead the ranking without competition from overlapping full-backs.
- **The adjustment does real work.** Alidu Seidu and Calafiori illustrate the two sides of it: Seidu's numbers hold up *despite* a possession multiplier below 1, while high-possession sides see their defenders' raw counts corrected upwards. Ranking on unadjusted tackles and interceptions would have produced a materially different shortlist.
- **Similarity as a succession plan.** The engine removes visual bias. Identifying Mario Gila or Javi Rodríguez as twin profiles to Kolašinac provides the scouting department with a purely objective shortlist, ready to be filtered by financial viability.
- **Read this as a shortlisting tool.** The composite weights encode a recruitment philosophy rather than a fitted model, and the sample spans two seasons. See the [limitations section](../README.md#limitations) of the main README before treating any ordering as definitive.
