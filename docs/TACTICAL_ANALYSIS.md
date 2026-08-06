[![es](https://img.shields.io/badge/lang-es-yellow.svg)](TACTICAL_ANALYSIS.es.md)

# Tactical analysis and profiling of modern centre-back profiles

← Back to the [main README](../README.md)

## Executive summary

This report breaks down the tactical profiles of centre-backs across Europe's top five leagues. A K-means clustering framework (k=4) and Principal Component Analysis isolate distinct player behaviours, while possession-adjusted (PAdj) metrics and empirical-Bayes reliability weighting provide context that raw counting stats omit.

**Sample.** 407 pure centre-backs, each entering with **their most recent qualifying season** — 286 from 2024–25 and 121 from 2023–24. Every table below therefore carries a season column: the ranking compares players at their latest available form, not within a single fixed campaign.

**Sead Kolašinac** (Atalanta) leads the composite scouting framework with an overall score of 4.75, followed by **Riccardo Calafiori** (Bologna, 4.65) and **Timo Hübers** (Köln, 4.56). For pure ball progression, **Iñigo Martínez** (Barcelona) registers the highest progression index in the sample at 4.07.

Applying the sigmoidal curve for possession-adjusted metrics reveals that defensive counts are heavily dictated by team dominance. After normalising for true defensive opportunity, **Timo Hübers** (12.36 combined PAdj) and **Riccardo Calafiori** (12.16) emerge as the most active defenders in the sample.

Three questions a good analyst should ask before trusting any of this — *is the model internally sound?*, *does it predict anything real?*, and *does it tell me anything the market doesn't already know?* — are answered directly in sections 7, 8, and 9, including where the answers are only partial or negative.

---

## 1. Tactical profiles and cluster breakdown

K-means clustering (k=4) on z-scored progression and PAdj defensive variables segments the player pool into four distinct tactical archetypes. The algorithm assigns role labels by reading the cluster centroids rather than by hardcoding them.

| Archetype | Players | Mean progression index | Mean PAdj tackles + int. | Mean pass completion |
|:----------|--------:|-----------------------:|-------------------------:|---------------------:|
| Elite Progressive Distributor | 36 | 2.61 | 2.22 | 89.5% |
| High-Intensity Ball-Winner | 67 | 1.79 | 3.34 | 85.1% |
| Standard Build-up Distributor | 147 | 1.50 | 2.15 | 87.2% |
| Limited / Reactive Defender | 157 | 1.01 | 2.78 | 84.9% |

Compared with the pre-shrinkage version of this pipeline, the Elite and High-Intensity archetypes lost players (48→36 and 97→67) while the two middle archetypes gained them (117→147 and 145→157). That's an expected, not a worrying, side effect: reliability weighting pulls small-sample "hot streak" profiles back toward the population centre, and small samples are disproportionately common in the more extreme clusters. See [section 7](#7-statistical-robustness-checks).

### 1.1. Elite progressive distributors
- **Profile:** Primary build-up directors in high-possession structures or three-at-the-back systems with high carrying freedom. They register the highest progression volume in the sample, and the highest pass completion.
- **Standout examples:** Sead Kolašinac, Nico Schlotterbeck, Iñigo Martínez.

### 1.2. High-intensity ball-winners
- **Profile:** Highly proactive defenders oriented towards jumping out of the line, anticipation, and duels. They present the highest PAdj defensive output in the ecosystem — and, as the trade-off, the lowest pass completion.
- **Standout examples:** Riccardo Calafiori, Timo Hübers, Giorgio Scalvini.

### 1.3. Standard build-up distributors
- **Profile:** The modal modern centre-back type. Solid safety passing volume and mid-range progression, with the most conservative defensive engagement of the four groups. They serve as the baseline for comparison. Now the second-largest group after shrinkage, absorbing several profiles that previously looked more extreme on small samples.
- **Standout examples:** Tyrone Mings, Ezri Konsa, Saúl Coco.

### 1.4. Limited / reactive defenders
- **Profile:** Minimal ball progression contribution. Often found in structured defensive systems or low blocks with limited build-up responsibility. The largest group in the sample.
- **Standout examples:** Matija Nastasić.

---

## 2. Advanced metrics and tactical context

### 2.1. Possession-adjusted (PAdj) defending

Counting raw actions penalises defenders in dominant teams. By applying a sigmoidal multiplier using the league average as a proxy, we normalise defensive intensity per true opportunity. The calculation combines adjusted tackles, interceptions, and recoveries — all three now reliability-weighted (see [section 6.1](#61-reliability-weighted-rates-empirical-bayes-shrinkage)) before the PAdj multiplier is applied.

| Player | Squad | League | Season | PAdj defensive score (combined) |
|:-------|:------|:-------|:-------|--------------------------------:|
| **Timo Hübers** | Köln | Bundesliga | 2023–24 | **12.36** |
| **Riccardo Calafiori** | Bologna | Serie A | 2023–24 | **12.16** |
| **Giorgio Scalvini** | Atalanta | Serie A | 2023–24 | **11.02** |
| **Sead Kolašinac** | Atalanta | Serie A | 2024–25 | **10.75** |
| **Wilfried Singo** | Monaco | Ligue 1 | 2024–25 | **10.51** |

### 2.2. Progression index

This metric combines progressive passes, progressive carries, and key passes per 90 — all reliability-weighted. The weights are not arbitrary; they are dynamically extracted from the PC1 loadings of a Principal Component Analysis (0.36 / 0.36 / 0.28, explaining 66.8% of the joint variance of the three inputs).

| Player | Squad | Season | Progression index |
|:-------|:------|:-------|------------------:|
| **Iñigo Martínez** | Barcelona | 2024–25 | **4.07** |
| **Nico Schlotterbeck** | Dortmund | 2024–25 | **3.62** |
| **Sead Kolašinac** | Atalanta | 2024–25 | **3.16** |
| **Eric García** | Girona | 2023–24 | **3.13** |
| **Manuel Akanji** | Manchester City | 2024–25 | **3.10** |

---

## 3. The recruitment dashboard: top scouting scores

The master composite score integrates the progression index (40%), PAdj defending performance (30%), pass completion (10%), and an age value curve that rewards peak performance windows (20%).

| Player | Squad | Season | Age | Assigned tactical role | Scouting score |
|:-------|:------|:-------|:----|:-----------------------|---------------:|
| **Sead Kolašinac** | Atalanta | 2024–25 | 31 | Elite Progressive Distributor | **4.75** |
| **Riccardo Calafiori** | Bologna | 2023–24 | 21 | High-Intensity Ball-Winner | **4.65** |
| **Timo Hübers** | Köln | 2023–24 | 27 | High-Intensity Ball-Winner | **4.56** |
| **Nico Schlotterbeck** | Dortmund | 2024–25 | 24 | Elite Progressive Distributor | **4.44** |
| **Wilfried Singo** | Monaco | 2024–25 | 23 | High-Intensity Ball-Winner | **4.35** |

Kolašinac still tops the ranking at 31, carrying the lowest age multiplier of this group (0.85), on the strength of a 3.16 progression index — still comfortably the highest among the top five. Calafiori closes most of that gap from the other direction: the highest combined PAdj defensive score in the sample (12.16) plus the full U-24 age bonus. The margin between them narrowed slightly to 0.10 points after reliability weighting.

**This ranking is not equally trustworthy end to end.** A 2,000-replication weight-sensitivity check (see [section 6.2](#62-how-much-does-the-40301020-weighting-choice-matter)) shows Kolašinac, Schlotterbeck, Singo, and Calafiori are stable — they stay in the Top-10 under essentially every reasonable reweighting of 40/30/10/20. Further down the Top-10, that stops being true.

---

## 4. Market inefficiencies and U-24 profiles

Filtering exclusively for players aged 24 or under who sit above the 80th percentile in overall performance:

- **Riccardo Calafiori (21, Bologna, 2023–24, 4.65):** The standout regarding age-to-performance ratio — the highest combined PAdj defensive score in the sample (12.16) within Thiago Motta's aggressive structure, plus the full U-24 bonus.
- **Nico Schlotterbeck (24, Dortmund, 2024–25, 4.44):** The most dominant U-24 profile in ball progression (3.62). An established elite distributor.
- **Wilfried Singo (23, Monaco, 2024–25, 4.35)** and **Giorgio Scalvini (19, Atalanta, 2023–24, 4.33):** High-intensity U-24 profiles with heavy, reliability-weighted defensive volume (10.51 and 11.02 combined PAdj respectively) built on full-minutes seasons, not short samples.
- **Alidu Seidu (23, Clermont Foot, 2023–24, 3.99):** Still on the list, but a **different, more honest story than before.** Before reliability weighting, Seidu's 1,131-minute season (he was sold to Rennes in January 2024, mid-campaign) produced a raw tackles/90 of 2.55 and interceptions/90 of 1.99 — elite-looking numbers built on a genuinely short sample. Empirical-Bayes shrinkage (see [section 6.1](#61-reliability-weighted-rates-empirical-bayes-shrinkage)) discounts them to 2.08 and 1.59: still good, no longer exceptional. His combined PAdj score dropped from 12.49 to 10.45, and his rank from #5 (4.62) to #10 (3.99). This is the shrinkage method working exactly as intended on exactly the kind of profile it exists to catch — and, as [section 9](#9-does-this-find-anything-the-market-didnt-already-know) shows, Rennes had already paid €11M for him in real life before this model, unshrunk or not, could have "found" him.

---

## 5. Similarity engine: succession planning

The cosine similarity engine scans the standardised feature space to find the closest tactical profiles. The query was executed to find a replacement for **Sead Kolašinac**, the overall ranking leader.

### Top statistical matches for Sead Kolašinac

| Rank | Player | Squad (sample season) | Cosine similarity |
|:-----|:-------|:----------------------|------------------:|
| 1 | **Mario Gila** | Lazio (2024–25) | **96.7%** |
| 2 | **Javi Rodríguez** | Celta Vigo (2024–25) | **95.0%** |
| 3 | **César Azpilicueta** | Atlético Madrid (2023–24) | **94.3%** |
| 4 | **Lutsharel Geertruida** | RB Leipzig (2024–25) | **94.3%** |
| 5 | **Facundo Medina** | Lens (2024–25) | **93.9%** |

**Mario Gila** (96.7%) remains the standout tactical successor: a Real Madrid academy product (Lazio paid €6M for him in 2022) with high recovery aggression and strong carrying ability. The reliability-weighted feature space brought **César Azpilicueta** — a 33-year-old, high-mileage profile — into the top matches, a reminder that cosine similarity finds statistical twins, not twins in age or career stage.

---

## 6. Model reliability improvements

Two upgrades were made to how the underlying numbers themselves are estimated, independent of the composite formula. Both are aimed squarely at biostatistics-grade rigour rather than just adding more diagnostics on top of an unchanged model.

### 6.1. Reliability-weighted rates (empirical-Bayes shrinkage)

A player with 900 minutes (10 matches) and one with 3,420 (38 matches) can post the same per-90 rate, but the first estimate carries far more sampling noise. Treating them as equally trustworthy is a real statistical error — and it specifically inflates exactly the short-sample, U-24 profiles a "market inefficiency" list is supposed to highlight.

Every count-based rate (progressive passes, progressive carries, key passes, tackles, interceptions, recoveries) is corrected with the Poisson-Gamma conjugate empirical-Bayes estimator — the textbook mechanism behind Efron & Morris's (1975) baseball batting-average shrinkage, applied here to defensive actions. `MASS::glm.nb()` fits `count ~ offset(log(minutes/90))` per metric to obtain the population mean rate (μ) and dispersion (θ); by conjugacy, the posterior mean for player *i* is:

```
rate_shrunk_i = (θ + count_i) / (θ/μ + minutes_i/90)
```

which shrinks toward the population mean in inverse proportion to minutes played. The correction lands where it should: mean absolute shrinkage in the bottom quartile of minutes played is **2–3× larger** than in the top quartile, across all six metrics (full table: [`shrinkage_diagnostics.csv`](../outputs/tables/shrinkage_diagnostics.csv)). Alidu Seidu (section 4) is the clearest concrete illustration of the effect.

### 6.2. How much does the 40/30/10/20 weighting choice matter?

The weights are a stated recruitment philosophy, not a statistical fit, so their influence on the ranking is measured directly rather than left as an unexamined assumption. 2,000 alternative weight vectors are drawn from a Dirichlet distribution centred on 40/30/10/20 — the multivariate generalisation of the Beta distribution, the natural way to simulate "reasonable disagreement" about a set of proportions that must sum to one — and the ranking is recomputed for each draw.

**Global result:** median Spearman correlation with the original ranking = **0.989** (IQR 0.972–0.997); the original Top-10 overlaps the reweighted Top-10 by **87.9%** on average. The ranking, broadly, does not hinge on the specific 40/30/10/20 split.

**But not uniformly.** Per-player Top-10 retention rate across the 2,000 replications:

| Player | Scouting score | % of replications retained in Top-10 |
|:-------|----------------:|---------------------------------------:|
| Sead Kolašinac | 4.75 | 100.0% |
| Nico Schlotterbeck | 4.44 | 99.7% |
| Wilfried Singo | 4.35 | 99.7% |
| Riccardo Calafiori | 4.65 | 98.5% |
| Lucas Martínez Quarta | 4.13 | 98.5% |
| Giorgio Scalvini | 4.33 | 96.8% |
| Timo Hübers | 4.56 | 94.6% |
| Facundo Medina | 4.11 | 90.2% |
| Alidu Seidu | 3.99 | 52.0% |
| Mohammed Salisu | 4.01 | 49.4% |

The top of the ranking is genuinely stable. The bottom two names in the current Top-10 are essentially a coin flip: whether Seidu or Salisu make the cut depends almost as much on the specific weighting as on their underlying numbers. Reporting "here is the Top-10" without this table would overstate the precision of the ranking exactly where it is weakest. Full data: [`weight_sensitivity_top10.csv`](../outputs/tables/weight_sensitivity_top10.csv), [`weight_sensitivity_replications.csv`](../outputs/tables/weight_sensitivity_replications.csv).

---

## 7. Statistical robustness checks

Before trusting a ranking, it is worth asking whether the machinery producing it is sound: are the inputs redundant with each other, is the number of clusters defensible, and are there players whose profile is so unusual that they're distorting the picture?

### 7.1. Multivariate outlier screening

A Mahalanobis distance (D²) screen was run on the seven variables that feed the filtering and scoring stages (post-shrinkage), using the standard cutoff k + 3√(2k) for k = 7 variables (D² > 18.2). 20 of 407 players (4.9%) exceed it — the same rate as before shrinkage, since shrinkage discounts extreme rates rather than removing the underlying variability structure.

Notice that Alidu Seidu and Iñigo Martínez — both discussed as standout names above — are on that flagged list. That is not a contradiction; it is exactly what a well-behaved outlier screen should do. "Statistically unusual" and "data error" produce the same D², and the only way to tell them apart is to look. Here, the look confirms both are unusual because they are genuinely exceptional profiles, not because of a data problem. Players are flagged, never silently dropped. Full list: [`qc_mahalanobis_outliers.csv`](../outputs/tables/qc_mahalanobis_outliers.csv).

### 7.2. Are the composite's inputs redundant with each other?

A variance inflation factor (VIF) check was run on three groups: the three inputs of the progression index, the three PAdj inputs of the defending score, and the four top-level pillars of the scouting score itself. Every VIF came back ≤ 1.77 — nowhere near the conventional concern threshold of 10. None of the variables feeding the model are quietly duplicating another's signal. Full table: [`vif_diagnostics.csv`](../outputs/tables/vif_diagnostics.csv).

### 7.3. Is the hand-coded age curve defensible?

`age_score` is a step function (24/28/31/33 breakpoints), fixed by the analyst rather than fit. As a diagnostic — not a refit, to avoid cascading a second change through the composite score in the same pass — a GAM (`mgcv::gam`) was fit to progression-type and defensive-type raw output separately against age, over the full 570 player-season pool (not deduplicated by player, for more data).

The picture is genuinely mixed. Progression-type output shows **no relationship with age at all** (p = 0.66, adjusted R² ≈ 0): distributors don't reliably get worse, or better, as they age in this data. Defensive-type output shows a small but statistically real age effect (p = 0.0056, adjusted R² = 0.025), rising gently to a soft peak around 22–24 and declining slowly through the late 20s — broadly consistent with treating the early-to-mid 20s as peak years, though far more gradual than the current step function's discrete jumps. The apparent late-career uptick past 35 in the fitted curve is a confidence-interval artefact from very sparse data at that tail and should not be read as "defenders peak at 40."

**Conclusion: the GAM check neither strongly confirms nor contradicts the hand-coded curve.** It is not replaced this round for lack of a confident alternative — replacing a disclosed, simple assumption with an unreliable tail-extrapolated one would be a downgrade, not an improvement. Data: [`age_curve_gam.csv`](../outputs/tables/age_curve_gam.csv); figure: [`age_curve_gam.png`](../outputs/figures/age_curve_gam.png).

### 7.4. Is k = 4 the right number of clusters?

The elbow (WSS) and silhouette methods were run across k = 2 to 8 (post-shrinkage):

| k | WSS | Mean silhouette |
|--:|----:|-----------------:|
| 2 | 1351.7 | **0.344** (statistical optimum) |
| 3 | 1077.3 | 0.245 |
| **4** | **892.8** | **0.259 (used in the pipeline)** |
| 5 | 773.5 | 0.237 |
| 6 | 712.9 | 0.235 |
| 7 | 659.4 | 0.227 |
| 8 | 612.6 | 0.211 |

k = 2 remains the statistical optimum; k = 4 is kept for the same reason as before — it preserves the tactical granularity (ball-winning intensity vs. distribution style) the rest of this report is built on, and its silhouette (0.259) actually improved slightly after shrinkage removed some sampling noise from the feature space.

The independent cross-check tells a more nuanced story than the silhouette alone. Cutting a Ward's-method hierarchical dendrogram at k = 4 and comparing to the K-means labels now gives an **Adjusted Rand Index of 0.295** (down from 0.419 pre-shrinkage) and **62.4%** row-agreement (cophenetic correlation: 0.496, down from 0.586). Shrinkage improved the *within-K-means* silhouette but *weakened* agreement with an entirely independent clustering method — a legitimate, disclosed trade-off: reliability weighting pulls small-sample noise back toward the mean, but some of what gets pulled back is real between-player variance too, and that softens the boundaries a second, unrelated algorithm can find. The four archetypes remain well above the ~0 agreement expected by chance, but should now be read as broad tendencies rather than sharply separated categories. Full contingency table: [`kmeans_vs_hierarchical_agreement.csv`](../outputs/tables/kmeans_vs_hierarchical_agreement.csv).

---

## 8. Predictive validation: does the score predict anything real?

Every check so far asks whether the model is *internally* coherent. This section asks a harder question: refit — including the shrinkage step — using **only 2023-24 data**, does the resulting score say anything true about what happened in **2024-25**, a season it never saw? This is a genuine temporal train/test split (fit on the past, evaluate on the future), not a random k-fold, because leaking future information into the fit would defeat the point.

**Setup.** 278 centre-backs active in 2023-24, scored using shrinkage parameters and PCA weights both re-estimated on that season alone. Outcome: did they play ≥ 900 minutes in 2024-25 (`retained`)? 64.0% did.

| Model | Predictor(s) | Result | AIC |
|:------|:--------------|:-------|----:|
| Intercept only | — | baseline | 365.2 |
| Logistic regression | `scouting_score` | OR = 1.38 (95% CI 0.83–2.32), **p = 0.22, not significant** | 365.7 |
| Logistic regression | 4 components separately | `age_score` OR = 22.5 (**p = 0.0015**); `progression_index` OR = 1.72 (p = 0.049); `defending_score`, `pass_completion` n.s. | 354.1 |

**The composite score still does not significantly predict next-season retention, unchanged by reliability weighting.** Decomposing the composite shows exactly where the (limited) signal lives: `age_score` alone is a strong, significant predictor of retention — younger players are simply more likely to still be playing next season. But `age_score` carries only **20%** of the composite's weight, by design, because the score ranks *footballing ability*, not *survival in the sample*. A likelihood-ratio test confirms the fixed weighting is a real, measurable constraint on this specific prediction task (χ², p < 0.001).

As a purely descriptive (non-causal) cross-check, retention rate does line up with the algorithm's own archetypes:

| Archetype | n | Retention rate |
|:----------|--:|----------------:|
| Elite Progressive Distributor | 27 | 81.5% |
| High-Intensity Ball-Winner | 39 | 64.1% |
| Standard Build-up Distributor | 111 | 63.1% |
| Limited / Reactive Defender | 101 | 60.4% |

**What this validation does and doesn't show.** "Played 900+ minutes next season" is a weak, indirect proxy for scouting quality — shaped at least as much by injuries, squad depth, and a manager's system as by ability. The null result does not mean the ranking is wrong; it means crude next-season retention is the wrong target to validate a *quality* ranking against. Full model output: [`temporal_validation_results.csv`](../outputs/tables/temporal_validation_results.csv); figure: [`temporal_validation.png`](../outputs/figures/temporal_validation.png).

---

## 9. Does this find anything the market didn't already know?

Section 8 asks whether the score predicts the future. This section asks an even more grounding question: checking the headline names in this very report against what actually happened in the real transfer market since.

| Player | This report | What actually happened |
|:-------|:-------------|:------------------------|
| **Alidu Seidu** | "Market inefficiency" at Clermont, 2023-24 | Sold to Rennes for **€11M** on **29 January 2024** — mid-way through the very season this model scores him on, after just 14 Ligue 1 appearances |
| **Riccardo Calafiori** | U-24 standout, 2023-24 | Sold Bologna → Arsenal for **~€45-49M** in summer 2024, on the back of a standout Euro 2024 |
| **Wilfried Singo** | U-24 standout | Already sold Torino → Monaco for **€10M** in summer 2023, before the analysis window even starts |
| **Giorgio Scalvini** | Highest-scoring teenager | Atalanta declared him "unsellable" at a **€60M** valuation, with Newcastle, Chelsea, Manchester United, and Tottenham reportedly interested |
| **Mario Gila** | Top cosine-similarity match for Kolašinac | Real Madrid academy product; Lazio already paid **€6M** for him in 2022, two years before this analysis |

Every headline name in this report was already scouted, priced, and — in most cases — already sold by professional recruitment departments working with far richer information (video scouting, medical data, personal character assessment, years of in-person tracking) than a public-stats model can ever access. In Seidu's case specifically, the transfer closed *during* the very season this model uses to score him.

**This model has good precision at identifying quality centre-backs. It has essentially no lead-time advantage over the real market, and no model built on public counting stats reasonably could.** That is a materially different, more honest claim than "this algorithm finds undiscovered value" — and it is the reason `scripts/scripts_optional_market_value_residuals.R` exists: replacing the current, arbitrary "U-24 + top 20th-percentile" definition of "market inefficiency" (section 4) with a real one, regressing log(market value) on `scouting_score`, age, and league, and flagging players whose *actual* price sits statistically below what performance predicts. That is a genuine inefficiency claim; a percentile cutoff on one variable never was. It requires a local run — see the [main README](../README.md#keeping-the-data-current).

---

## 10. Tactical takeaways

- **The system effect.** The dominant presence of Gasperini's Atalanta (Kolašinac, Scalvini) and of Calafiori in Thiago Motta's 2023–24 Bologna highlights how man-marking and proactive defensive systems drastically elevate their centre-backs' PAdj metrics.
- **Pure centre-backs vs inverted full-backs.** The strict attacking-third touch and progressive-reception filters cleaned the database of "fake centre-backs", allowing true progressive defenders (like Schlotterbeck or Iñigo Martínez) to lead the ranking without competition from overlapping full-backs.
- **Reliability weighting changes the shortlist, not just the decimals.** Alidu Seidu's fall from #5 to #10 (section 4) shows the empirical-Bayes correction doing real work on exactly the short-sample profiles a scouting report is most likely to overrate.
- **Most of the ranking is robust to the exact weighting choice; the marginal names are not.** Section 6.2's weight-sensitivity table should travel with any shortlist pulled from this project — a name retained in 50% of reasonable reweightings is a different kind of recommendation than one retained in 100%.
- **Similarity as a succession plan.** The engine removes visual bias. Identifying Mario Gila as a twin profile to Kolašinac provides the scouting department with a purely objective shortlist, ready to be filtered by financial viability.
- **This model finds quality, not secrets.** Section 9 shows every headline name here was already known to real recruitment departments, usually before the scored season had even ended. That reframes the whole exercise honestly: a well-audited, statistically rigorous shortlisting tool, not a market-beating discovery engine.
- **Read this as a well-audited shortlisting tool, not a signing decision.** Sections 6 through 9 show a model that is internally coherent (no redundant inputs, reliability-weighted rates, a disclosed and cross-validated clustering choice) but whose composite score does not predict crude next-season playing time and has no discovery edge over the market. See the [limitations section](../README.md#limitations) of the main README before treating any ordering as definitive.
