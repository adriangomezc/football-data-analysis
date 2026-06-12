# Tactical analysis and profiling of modern centre-back profiles

## Executive summary

This report breaks down the tactical profiles of centre-backs across Europe's top five leagues using data from the 2023–24 season. A K-means clustering framework (k=4) and Principal Component Analysis isolate distinct player behaviours, while possession-adjusted metrics provide context that raw counting stats cannot.

**Alidu Seidu** (Clermont Foot) leads the composite scouting framework with an overall score of 4.79, followed by **Leonardo Balerdi** (Marseille, 4.64) and **Tim Siersleben** (Heidenheim, 4.34). For pure ball progression, **Joseph Okumu** (Reims) registers the highest progression index in the sample at 2.67.

Applying possession-adjusted (PAdj) metrics — estimated via relative team pass volume — reveals that raw defensive counts are heavily distorted by tactical context. After normalising per defensive opportunity, **Tim Siersleben** (13.15 combined PAdj tackles + interceptions) and **Alidu Seidu** (11.68) emerge as the most active defenders in the dataset relative to how little they actually defend.

---

## 1. Tactical profiles and cluster breakdown

K-means clustering (k=4) on z-scored progression and PAdj defensive variables segments the 157-player pool into four distinct tactical archetypes.

### 1.1. Cluster 4: elite progressive distributors
- **Sample size:** 34 players.
- **Profile:** Primary build-up directors in high-possession structures. Highest passing volume and progression output in the sample.
- **Cluster averages:**
  - Progressive passes per 90: **4.21**
  - Progression index: **1.90**
  - Pass completion: **86.7%**

### 1.2. Cluster 2: standard distributors
- **Sample size:** 62 players.
- **Profile:** The modal centre-back type. Solid passing output, moderate defensive involvement. The baseline for comparison.
- **Cluster averages:**
  - Progressive passes per 90: **2.86**
  - Progression index: **1.26**
  - Pass completion: **86.3%**

### 1.3. Cluster 3: high-intensity ball-winners
- **Sample size:** 13 players.
- **Profile:** Reactive, duel-oriented defenders with the highest PAdj defensive output in the sample. Generally deployed in lower defensive blocks.
- **Cluster averages:**
  - PAdj tackles per 90: **4.38**
  - PAdj interceptions per 90: **3.41**
  - Pass completion: **84.4%**

### 1.4. Cluster 1: limited on-ball profiles
- **Sample size:** 48 players.
- **Profile:** Minimal progression contribution, moderate defensive volume. Often found in structured defensive systems with limited build-up responsibility.
- **Cluster averages:**
  - Progressive passes per 90: **1.82**
  - Progression index: **0.78**
  - Pass completion: **85.6%**

---

## 2. Advanced metrics and tactical context

### 2.1. Possession-adjusted (PAdj) defending

Counting raw defensive actions penalises defenders in dominant teams who naturally face fewer transitions. Dividing by `(opponent_possession / 50)` normalises each player's output to what it would be if both teams had equal possession.

| Player | Squad | PAdj Tackles | PAdj Interceptions | Combined |
|:-------|:------|:-------------|:-------------------|:---------|
| **Tim Siersleben** | Heidenheim | 7.39 | 5.75 | **13.15** |
| **Alidu Seidu** | Clermont Foot | 6.56 | 5.12 | **11.68** |
| **Teden Mengi** | Luton Town | 5.02 | 5.30 | **10.33** |
| **Gabriel Osho** | Luton Town | 5.10 | 3.86 | **8.96** |
| **Jorge Sáenz** | Leganés | 4.31 | 2.92 | **7.23** |

Siersleben and Seidu play for teams with estimated possession of ~82% and ~81% respectively. Their raw tackle numbers (2.67 and 2.55 per 90) look ordinary; the PAdj correction reveals they are the most active defenders per opportunity in the dataset.

### 2.2. Progression index

The progression index combines progressive passes, progressive carries, and key passes per 90, weighted by PC1 loadings from a PCA. It measures how much a defender actively advances territory rather than simply recycling possession.

| Player | Squad | Progression Index | Progressive Passes/90 | Progressive Carries/90 |
|:-------|:------|:------------------|:----------------------|:----------------------|
| **Joseph Okumu** | Reims | 2.67 | 6.16 | 0.96 |
| **Ladislav Krejčí** | Girona | 2.42 | 5.31 | 1.07 |
| **Virgil Van Dijk** | Liverpool | 2.28 | 5.35 | 0.59 |
| **Karol Mets** | St Pauli | 2.25 | 5.40 | 0.50 |
| **Tim Siersleben** | Heidenheim | 2.25 | 4.75 | 1.19 |

---

## 3. The recruitment dashboard: top scouting scores

The composite scouting score combines progression index (40%), defending score (30%), pass completion (10%), and an age modifier (20%).

| Player | Squad | Age | Role Profile | Scouting Score |
|:-------|:------|:----|:-------------|:---------------|
| **Alidu Seidu** | Clermont Foot | 23 | Defensive Stopper | **4.79** |
| **Leonardo Balerdi** | Marseille | 24 | Elite Progressive CB | **4.64** |
| **Tim Siersleben** | Heidenheim | 23 | Elite Progressive CB | **4.34** |
| **Dan-Axel Zagadou** | Stuttgart | 24 | Elite Progressive CB | **3.78** |
| **Kevin Danso** | Lens | 24 | Elite Progressive CB | **3.77** |

---

## 4. Market inefficiencies and high-potential profiles

Filtering for players aged 24 or under above the 80th percentile scouting score:

- **Alidu Seidu (23, Clermont Foot, 4.79):** Leads both the overall ranking and the PAdj defensive table. A rare combination of elite recovery intensity and respectable progression output.
- **Leonardo Balerdi (24, Marseille, 4.64):** Highest defending score (11.77) among the progressive CB profiles. Strong combination of passing quality and defensive volume.
- **Tim Siersleben (23, Heidenheim, 4.34):** Top progression index (2.25) and top raw PAdj combined score (13.15). Playing for a promoted Bundesliga side limits visibility, but the metrics are elite-level.
- **Lucas Beraldo (20, PSG, 3.70):** Youngest high-scorer in the sample. High pass completion (92%) and above-average progression for his age group.
- **Willian Pacho (22, PSG, 3.69):** Strong defender playing in a dominant team, which compresses his raw defensive output. PAdj correction improves his standing significantly.
- **Yarek Gasiorowski (19, Valencia, 3.39):** Youngest qualifier in the dataset. Progressive CB profile with room for development. One to monitor.

---

## 5. Similarity engine: statistical replacement matching

The cosine similarity engine calculates geometric distance in the standardised feature space. The query was run against the top-ranked player, **Alidu Seidu**.

### Top statistical matches for Alidu Seidu

| Rank | Player | Cosine Similarity |
|:-----|:-------|:-----------------|
| 1 | **Murillo** | 93.0% |
| 2 | **Santiago Mouriño** | 89.1% |
| 3 | **Mickael Nade** | 87.3% |
| 4 | **Arouna Sangante** | 84.6% |
| 5 | **Tim Siersleben** | 84.1% |

Murillo (93.0%) is the closest statistical profile — a Defensive Stopper with comparable PAdj intensity and progression output. Siersleben appearing at rank 5 (84.1%) makes intuitive sense given that both lead the PAdj combined ranking.

---

## 6. Tactical takeaways

- **Context before counting.** A defender with 1.5 tackles per 90 in a team with 70% possession is doing significantly more work per opportunity than one with 3.0 tackles in a team that defends for 60 minutes a game. The PAdj correction surfaces this.
- **The Heidenheim effect.** Tim Siersleben is a clear case of market inefficiency driven by club visibility. He leads the raw progression index and the PAdj combined defensive metric, while playing in a promoted Bundesliga side. The data suggests an elite profile that has not yet received corresponding recognition.
- **U-20 watch.** Yarek Gasiorowski (Valencia, 19) and Lucas Beraldo (PSG, 20) both score above average despite age penalties in the formula. Removing the age modifier would push them significantly higher.
- **Similarity as a recruitment tool.** The engine removes the subjectivity from identifying alternatives. Rather than watching footage and guessing, the similarity scores provide a ranked shortlist of players whose data profiles most closely match any target. Murillo as the closest match to Seidu is a data-backed, hype-free starting point for further scouting.
