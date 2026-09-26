# Implementation notes: notebook 08 — Distributional lognormal model

Author: implementation agent (Step 2 of `sleep/REVISION_PLAYBOOK.md`).

**The notebook itself was not executed.** Its outputs are empty and its execution counts are
null. Unlike NB07's implementation step, the numbers and plot readings in the answers do
not come from a numpy approximation. I built and ran the exact model in the pinned venv
(`scratchpad/nbenv`: `pymc==6.3.2`, `arviz-*` 1.3.x) using scratch scripts:

- `scratchpad/nb08/model08.py` and `fit08.py` mirror the notebook's code.
- `lit08.py` goes further: it extracts the solved notebook's **literal code cells**, swaps
  `DATA_URL` for the local copy of the same CSV, and runs them headless. It exits 0 and
  reproduces every number below.

These are still predictions for Step 3a to confirm against the executed notebook, not
validated output. One reason is that NUTS was not bit-reproducible across processes here
(see decision 5).

## What was written

- `sleep/solved/08_lognormal_distributional.ipynb`: 105 cells (82 markdown, 23 code),
  every cell tagged:
  - 6 `section`;
  - 36 `exercise-question`, each followed immediately by exactly one `solution`;
  - 1 `exercise-question`+`given-answer` (5.6, the ECDF criteria, following the NB06/07
    pattern);
  - 26 `given` (13 markdown, 13 code);
  - 36 `solution` (26 markdown, 10 code).

  The builder is `scratchpad/nb08/build_nb08.py`. Cell ids are stable hashes of per-cell
  keys, and the top-level metadata comes from the pre-revision file, minus `widgets`.
- `sleep/08_lognormal_distributional.ipynb` was derived mechanically by
  `derive_and_verify_nb08.py`, NB07's script with only the file names changed:
  - the 36 `solution` cells become `- answer here` / `# answer here`;
  - the badge points to `sleep/08_...`;
  - outputs are cleared and execution counts are null;
  - there is no `metadata.execution` and no `metadata.widgets`.
- **Verified by script:**
  - 37 differing cells (36 solution + 1 badge), with every other cell byte-identical;
  - identical ids, types and tags in the two files;
  - both files pass `nbformat.validate`;
  - cell ids are unique;
  - Q→A adjacency holds;
  - only `$`/`$$` math;
  - no `print(model)`, `lam=`, `_z`, `population_mu`, `plot_population`,
    `residual_scale`, `sigma_intercept`, `compute_log_density`, "next notebook", or
    reference to Notebooks 9–12 / ex-Gaussian anywhere. The only `target_accept` is the
    deliberate one (decision 5).
- JSON is written with `indent=1, ensure_ascii=False, sort_keys=True` plus a trailing
  newline. `sort_keys` matches nbformat's own writer and NB07's builder, which avoids key-order
  churn when Step 3a re-saves the file.

### Section structure

| Section | Questions (Q = student answers, G = given) |
|---|---|
| Title/intro, Setup, Data, Plotting helper | G. The intro states NB07's residual-scale mismatch as the motivation. |
| 1. Build the residual-scale hierarchy | 1.1 model math (G) · 1.2 supplied mean structure as a *partial* model (G code) · 1.3 what $sd_{y,s}$ is vs NB07 · 1.4 why a log link for a scale · 1.5 $e^{\mu_{\log sd_y}}$ = median participant's scale · 1.6 why pool the scales · 1.7 what a center at 0 would imply · 1.8 elicit `mu_log_sd_y` · 1.9 is reusing NB07's estimate legitimate? · 1.10 elicit `sd_log_sd_y` · 1.11 store constants (code) · 1.12 add hyperparameters (code) · 1.13 add `log_sd_y`, `sd_y` (code) · 1.14 indexing `sd_y[pidx]` · 1.15 add `mean_rt` + `y` (code) · 1.16 graphviz (G) · 1.17 read the graph |
| 2. Check the prior implications | 2.1 criteria + new residual-scale criterion (G) · 2.2 prior draws (G) · 2.3 `plot_dist` of the two hyperpriors (code) · 2.4 are they reasonable · 2.5 prior predictive plot (G) · 2.6 NB1 criteria verdict · 2.7 cause of the single-day spikes · 2.8 can the panels show between-participant variability? (exchangeability) |
| 3. Fit and diagnose the model | 3.1 sample, `target_accept=0.9` (G) · 3.2 **why the higher `target_accept`** · 3.3 population diagnostics (G) · 3.4 verdict · 3.5 all-participant screen incl. `log_sd_y` + subset 308/337/372 (G) · 3.6 verdict |
| 4. Examine the participant residual scales | 4.1 `plot_dist` of hyperparameters (code) · 4.2 typical residual scale vs NB07's shared `sd_y` · 4.3 between-participant factor · 4.4 prior → posterior movement · 4.5 forest of `sd_y` (code) · 4.6 heterogeneity verdict, in ms |
| 5. Predictive consequences | 5.1 `mean_rt` per participant (code) · 5.2 compare with NB07's expected trajectories · 5.3 PPC (code) · 5.4 `mean_rt` → `y` · 5.5 participant-level verdict vs NB07 · 5.6 ECDF criteria (given-answer) · 5.7 ECDF (code) · 5.8 verdict and why the pooled check can't separate NB07/NB08 |
| 6. Summary | 6.1 retrospective only: model, priors, sampling, fitted scales, predictive checks. There is no reference to any later notebook. |

**Scaffolding follows the plan.** The mean structure is supplied (`given`) as a partially
built `model` whose constants are copied verbatim from NB07. Students add only the new
nodes, in `with model:` blocks, which is NB4's incremental device used for the new piece
only. The fit, the diagnostics code and the prior-predictive plot are `given`. Every
elicitation, the model-building code for the new piece, the posterior plots, the PPC code
and every interpretation are `solution`.

## Decisions on the plan's open questions

### 1. `mu_mu_b0` harmonized to 5, and the other mean-structure constants too

The notebook uses NB07's constants verbatim: `mu_mu_b0=5, sd_mu_b0=0.55, sd_sd_b0=1/6,
mu_mu_b1=0, sd_mu_b1=0.2, sd_sd_b1=0.05`.

The pre-revision draft differed from NB07 in three places, not only the one the plan
flagged:
- `intercept ~ Normal(5.5, 0.55)`;
- `participant_intercept_sd ~ Exponential(lam=3)`, which is scale 1/3 against NB07's 1/6;
- `participant_slope_sd ~ Exponential(lam=5)`, which is scale 0.2 against NB07's 0.05.

Its only justification was the sentence "a separate refit choice made when the sigma
component was added". All three are harmonized to NB07, following the plan's rule "reuse
verbatim", and that sentence is dropped.

The notebook does not mention the correction. Students never saw 5.5, so the given cell
says only "from Notebook 7" (playbook §3.2). The record is here.

### 2. `mu_log_sd_y` centered at log(0.08) ≈ −2.5 (SD 0.5), not 0 — with one correction to the plan's reasoning

**The pre-revision's own committed output shows why the center at 0 had to change.** Its
posterior was:
- `sigma_intercept` −0.94 [−1.50, −0.36];
- `participant_sigma_sd` **1.86** [1.21, 2.47].

That is a textbook prior–data conflict. The data put the typical log residual scale near
−2.9, almost ten prior SDs from the center of `Normal(0, 0.3)`. The model compromised by
moving the center only partway, to −0.94, and inflating the between-participant SD
threefold, so that every participant's deviation could reach the data. The draft also
needed `target_accept=0.95` and `tune=2000`.

The harmonized prior gives −2.85 [−3.10, −2.62] and 0.59 [0.40, 0.80] (scratch).

**Correction to the plan's rationale.** The plan calls centering on NB07's *fitted* `sd_y`
"the same move Notebook 6/7 made reusing Notebook 1's/6's priors". It is not the same
move:
- NB06/07 reused earlier *priors*. This reuses a *posterior* fitted to **the same data**.
- The PyMC-Labs `prior-elicitation` skill says to "separate … independent prior
  information from outcome-based scaling".

I kept the plan's center, because it is the right order of magnitude and the plan asked
for it. I did not present it silently:
- **Q1.9** asks whether reusing NB07's estimate is legitimate. The answer is "only with
  care; it uses the data twice". It is defensible because the prior takes only the order
  of magnitude: the prior's 95% range, 0.03–0.22, spans ×7, against ×1.3 for NB07's 90%
  HDI.
- **Q4.4** checks the reuse. The posterior HDI is about a third of the prior's width, and
  its center moved *below* the prior center.
- A scratch power-scaling run (top-level priors only, NB07's convention) gives
  `mu_log_sd_y` a prior sensitivity of 0.039, which is not flagged. So the reused center
  is not driving the result.
- **Q1.7** ("what would a prior centered at zero imply?") turns the harmonization itself
  into teaching content. A residual scale of 1 means ×2.7 per SD, and zero on the log
  scale is not neutral.

*If the instructor prefers* an outcome-independent elicitation, for example "a typical
person's day-to-day variation is between about 3% and 25%" from domain reasoning, the
numbers barely change (Normal(−2.5, 0.5) or Normal(−2.3, 0.6)). Only the wording of 1.8
and 1.9 would change, and 1.9 could be dropped.

### 3. `sd_log_sd_y ~ Exponential(scale=1/3)`, reused from the pre-revision `lam=3` as planned

This prior is reused unchanged. However, the scratch `psense_summary` **flags it**: prior
0.073, likelihood 0.195, "potential prior–data conflict". The posterior mean, 0.59, is at
about the 83rd percentile of the prior.

I did not change it. Changing it after seeing the fit would be the kind of data-driven
tuning AGENTS.md and the skill warn against. The notebook discloses the tension instead,
in Q4.4 and the summary: the posterior lies in the upper part of the prior, the data show
more heterogeneity than the prior expected, and because an Exponential prior favors small
values, the heterogeneity conclusion is conservative.

The prior predictive check also shows that the tail of this prior produces the rare
single-day spikes (Q2.7). If the instructor wants a less "generous" upper tail, a scale of
1/4 would do it, but that is a choice for them, not for me.

### 4. Section 6 (sensitivity): **omitted**

Reasons:
1. The README's power-scaling list is "notebooks 1, 2, 3, 6, 7". The pre-revision NB08 had
   no sensitivity section either. Adding one is a repository-wide README change, which is
   outside this task's file scope and the plan's default.
2. AGENTS.md: "Do not add … sensitivity analyses … merely because they are available". The
   new construct already makes section 1 the longest section in the notebook, with 17
   questions.
3. NB07 has just power-scaled the identical mean-structure priors, and none were flagged.
4. The one prior question that is specific to this notebook, whether the NB07-informed
   center drives the answer, is answered natively and more simply by the prior-vs-posterior
   comparison in Q4.4.

**What omitting it leaves out, stated so it is not hidden.** Power-scaling would flag
`sd_log_sd_y` (see decision 3). The notebook reaches the same substantive point without
psense:
- the posterior sits in the upper part of the prior;
- the prior pulls it down, if anything;
- heterogeneity is robust.

If the instructor wants §6 anyway, the addition would be:
- the four NB07-style cells, with `prior_var_names` = the six top-level priors;
- a 0.05-threshold verdict that has to interpret this flag;
- a README list update.

Summary would then become §7.

### 5. Parameterization: centered works, but needs `target_accept=0.9` (the plan anticipated this)

**Centered, default settings.** With the notebook's `RANDOM_SEED`, the default settings
gave **1 divergence** (chain 1) in 8 of 9 separate processes. The very first process gave
0, with slightly different draws: sampling was not bit-reproducible across processes,
probably because of a cold compile cache on the first run.

**Seed study** (8 seeds each, full model, `seeds08.py`):

| Configuration | Seeds with ≥1 divergence | Min participant-level bulk / tail ESS |
|---|---|---|
| Centered, default (0.8) | **2/8** (1 divergence each) | ~1,770–1,990 / ~1,310–1,700 |
| **Centered, `target_accept=0.9`** | **0/8** | ~2,200–2,780 / ~1,780–2,240 |
| Non-centered `log_sd_y`, default | 0/8 | ~1,020–1,650 / ~1,490–1,910 |

**Diagnosis** (`divloc.py`, `divdiag.py`). The divergences are not in the neck of an
`sd_log_sd_y` funnel: at the divergent draws, `sd_log_sd_y` is at the 31st and 58th
percentiles of its posterior. They occur where some participant's `log_sd_y` is in its
lower tail, for example 371 at its 4th percentile.

This is a **within-participant funnel**. For participants 309 and 352, the posterior SD
of `b0` and `b1` grows about 2.6× from the lowest to the highest quintile of that
participant's `log_sd_y`. A participant's residual scale sets how sharply their eight
observations pin down their intercept and slope. This geometry is intrinsic to
distributional models. Non-centering the *scale* hierarchy does not target it, although
it happened to avoid divergences here, at lower ESS. A smaller step does target it.

**Decision.** Keep the centered form, which matches the `b0`/`b1` form students just
wrote, with `target_accept=0.9` in the given sampling cell. It is explained in **Q3.2**,
whose answer is the within-participant funnel. This is playbook §3.3's exact condition:
the default settings were confirmed to produce divergences, and the need is explained in a
Q&A rather than set prophylactically.

It is also genuine teaching content for this notebook: letting a scale parameter vary
changes the posterior geometry of the parameters it scales. The summary has a
**Sampling** bullet on it.

## Other decisions and deviations from the plan

- **Naming** (this notebook sets the precedent for distributional models, per playbook
  §3.1):
  - `mu_log_sd_y` and `sd_log_sd_y` are the hyperparameters;
  - `log_sd_y` is the **centered** participant log residual scale, `dims="participant"`;
  - `sd_y = pm.Deterministic("sd_y", pm.math.exp(log_sd_y), dims="participant")`;
  - `sd_y[pidx]` is used in the likelihood and in `mean_rt`;
  - the constants are `mu_mu_log_sd_y`, `sd_mu_log_sd_y` and `sd_sd_log_sd_y`.

  The plan floated `v`/`log_sd_y_dev` (a deviation) and an observation-level
  `sd_y[obs_id]` Deterministic. I used the participant-level quantity instead:
  - a centered deviation-free `log_sd_y` mirrors `b0`/`b1` exactly (`b0` is the
    participant's intercept itself, not a deviation);
  - the participant-level `sd_y` is the scientifically meaningful quantity, and it is the
    one forest-plotted in 4.5;
  - an observation-level copy would be 144 values with 8 repeats each, which AGENTS'
    "every deterministic must be used" argues against.

  The pre-revision's `residual_scale`/`population_residual_scale` are gone. `sd_y`
  replaces the first, and the "typical participant" twin is dropped per playbook §3.6.

  **Orchestrator:** if this naming is accepted, record it in playbook §3.1 for NB09–11.
- **`mean_rt`** is kept, following the README and playbook §3.1 convention. It is used in
  5.1/5.2, where it makes the notebook's key contrast: the distributional component barely
  moves the *expected* trajectories, but changes how precisely each is known and, in 5.4,
  how widely individual reaction times scatter.
- **Added questions beyond the plan's outline.** Each serves a stated rule:
  - **1.7:** turns the harmonization into content.
  - **1.9:** the same-data honesty point from decision 2.
  - **1.14:** the one genuinely new indexing step, `sd_y[pidx]`.
  - **2.7:** attributes each spike to its actual cause, which is NB07 review finding 1's
    lesson. See Step 3a item 3.
  - **2.8:** the new residual-variability criterion cannot be judged from exchangeable
    panels, so it is judged from the hyperpriors in 2.4.
  - **3.2:** `target_accept`.
  - **4.4:** prior versus posterior, in place of §6.
  - **5.1/5.2:** the `mean_rt` contrast with NB07.
- **Plotting-helper markdown.** I added one sentence saying that panels appear in
  participant order, left to right and top to bottom. This applies NB07 review finding 3,
  option (a), at the source, because 2.7, 5.2 and 5.5 cite panels by row and position.
  **The helper code is unchanged.** I did not propagate the sentence to NB05–07; that is
  the orchestrator's call.
- **Imports:** `compute_log_density` is dropped because there is no power-scaling.
  Everything else is NB07's.
- **Prior-predictive draws** sample only the variables that are plotted:
  `["mu_log_sd_y", "sd_log_sd_y", "y"]`.

## For Step 3a — every plot- and number-based claim, with its basis

"Scratch" means the literal-code run or the mirror scripts in `scratchpad/nb08/`. Prior
draws are plain RNG draws, and they were identical across processes and across different
`var_names` lists, so I expect Step 3a's prior plots to match exactly. Posterior draws may
not match bit-for-bit (decision 5), so read the posterior items as ± their last digit.

| # | Cell(s) | Claim | Scratch basis | Confidence / what to do if it fails |
|---|---|---|---|---|
| 1 | 2.4, 4.4 | `mu_log_sd_y` prior 90% HDI "about −3.2 to −1.7" (→ 0.04–0.19); `sd_log_sd_y` "mostly below about 0.8" | [−3.24, −1.67]; [0, 0.807] | High |
| 2 | 2.6 | Baseline 90% bands "roughly 30–350 ms"; 50% bands "end near 200 ms or below on every day"; every observation above its own panel's 50% band; day-7 50% band "almost zero"; 90% band "about 1.2–1.5 s" | Day-0 90%: lower 26–49, upper 322–362. Max 50% upper edge anywhere: 208 ms. 100% of observations above their own 50% band. Day-7 50% lower 1–3 ms; 90% upper 1,244–1,534 ms | High, **but look at the plot**. The NB06/07 reviews found generous readings. |
| 3 | **2.7 (question text too)** | Spikes on a single day in **351 (row 3, panel 1) on day 2** and **371 (row 3, panel 5) on day 7**. Both are single extreme residuals ("more than ten minutes"), requiring `sd_log_sd_y` > 1.3. A smaller step in **335 (row 2, panel 3) on day 6** has the same cause. | 351 d2: panel mean 2,858 ms; one draw is 1,330,306 ms, with `sd_y[351]` = 5.14 and `sd_log_sd_y` = 1.37. 371 d7: mean 2,036 ms (its day 6 is 411); one draw is 747,420 ms, with `sd_y` = 5.76, `sd_log_sd_y` = 1.93 and **`b1` = −0.056, so it is not a slope effect despite being on day 7**. 335 d6: draw 66,668 ms, `sd_y` = 1.91, `sd_log_sd_y` = 1.44. The literal run's unlabeled plot matched. | High if the prior draws reproduce. **If the executed plot differs, rewrite 2.7's question and answer and re-attribute each spike individually** (`prior_spikes.py` does this). Do not assume a late-week spike is a slope. |
| 4 | 3.2 (premise) | "With the default `target_accept` of 0.8, the sampler occasionally reports a divergence for this model" | Seed study: 2/8 seeds; `RANDOM_SEED` gave 1 divergence in 8 of 9 processes | **Please re-confirm once in scratch** (default settings, `RANDOM_SEED`), per playbook §3.3. |
| 5 | 3.4, 3.6 | With 0.9: no divergences; population R-hat 1.00; ESS "in the thousands"; participant screen R-hat 1.00 and minimum ESS "well above 1,000"; traces for 308, 337 and 372 mix well | 0 divergences; R-hat ≤ 1.004 overall; population ESS ≥ 3,651 bulk and 3,077 tail; participant minimum 2,707 bulk and 1,813 tail | High (0/8 seeds diverged at 0.9). If a divergence appears, first try 0.95; the non-centered `log_sd_y` alternative is tested (0/8) but has lower ESS. |
| 6 | 4.2, 6.1 | `mu_log_sd_y` HDI "−3.1 to −2.6" → "0.045–0.075", "4.5–7.5%"; smaller than NB07's 0.08 [0.07, 0.09]; "most participants are steadier than the shared value" | [−3.097, −2.616]; 13 of 18 participant means < 0.079 | High |
| 7 | 4.3 | `sd_log_sd_y` HDI "0.4–0.8" → ×1.5 to ×2.2 | [0.395, 0.795]; `round_to=2` prints 0.40–0.80 | High |
| 8 | 4.4 | The posterior HDI is "roughly a third" of the prior's width; posterior center "about −2.9"; `sd_log_sd_y` values below 0.4 ruled out | Widths 0.48 vs 1.57; mean −2.853; prior P(< 0.4) = 0.70 | High |
| 9 | 4.6, 6.1 | 309 and 352 "about 0.03 (90% HDIs roughly 0.01–0.04)"; 308 and 332 "about 0.14 and 0.16 (roughly 0.09–0.23)"; no overlap; "five- to six-fold"; ±8 ms vs ±45 ms at 300 ms | 309 0.027 [0.012, 0.041]; 352 0.027 [0.013, 0.042]; 308 0.142 [0.090, 0.191]; 332 0.164 [0.105, 0.225] | High. Check the forest plot. |
| 10 | 5.2 | Mean lines are "almost unchanged" from NB07; 309's `mean_rt` band "little more than a line"; 308's and 332's bands are wider than in NB07; 332's line is "slightly steeper" | Mean line vs NB07: median \|Δ\| 1.0 ms, max 13.8 ms (332). 90% `mean_rt` band widths: 309 12–14 ms (NB07 31–36); 308 63–107 (NB07 42–68); 332 69–96 (NB07 45–53). `b1[332]` 0.016 (NB07) → 0.026 (population 0.036); 334/335/349/352 moved *away* from the population | Medium on the visual. **If 332's steeper line (≤ 14 ms) is not visible at the plot's scale, soften or drop that sentence.** The width contrast is robust. |
| 11 | 5.4 | 309's predictive band "about 25 ms"; 308's and 332's "about 150–220 ms"; NB07 "about 60–130 ms" | NB08: 309 22–25; 308 148–223; 332 168–208. NB07 (refit, which matches NB07's committed widths): 63–131 | High |
| 12 | 5.5 | The residual-variation mismatch is gone. 309's observations spread across narrow bands. 308's and 332's mostly fall inside wider bands. Only isolated misses remain, "most clearly 332 on day 4" | Outside the 90% band: 332 d4 and 370 d3 (2/144). Near the edge: 308 d5, 351 d5, 371 d4. These were outside in an earlier run with different draws, so the text avoids an exact count. 309 inside its 50% band: 6/8 (NB07 8/8). Overall share inside the 50% band: 63% (NB07 75%). | High for the qualitative claims. |
| 13 | 5.8 | The ECDF is broadly consistent and matches NB07's verdict; it cannot separate the models | The observed ECDF is inside the pointwise 95% band at all 120 grid points (180–520 ms) for both NB07 and NB08 | High |
| 14 | 1.16/1.17 | The graph shows the new nodes; `sd_y` sits in the participant plate and feeds `y` and `mean_rt` | Rendered and checked | Certain |
| 15 | 1.x, 2.8, 3.2 answer | Definitional and structural answers. The funnel explanation in 3.2 is backed by the quintile analysis in decision 5. | — | High |

## Not done in this step

- No execution of the notebook. Step 3a produces the outputs.
- No README or playbook change, and no other notebook touched. Suggested course-wide
  follow-ups for the orchestrator:
  - record the distributional naming (decision "Naming" above) in playbook §3.1;
  - optionally note in the README's modeling notes that NB08 uses `target_accept=0.9` for
    a stated reason;
  - decide on the panel-order sentence for NB05–07's helper text.
- All scratch scripts and figures are in `scratchpad/nb08/`: `build_nb08.py`,
  `derive_and_verify_nb08.py`, `check_nb08.py`, `model08.py`, `fit08.py`, `lit08.py`,
  `prior_spikes.py`, `cover08.py`, `ecdf08.py`, `psense08.py`, `seeds08.py`, `divloc.py`,
  `divdiag.py` and `*.png`.
