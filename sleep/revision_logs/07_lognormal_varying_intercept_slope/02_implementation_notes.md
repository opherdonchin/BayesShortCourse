# Implementation notes: notebook 07 — Hierarchical lognormal regression

Author: implementation agent (Step 2 of `sleep/REVISION_PLAYBOOK.md`). Nothing was
executed with PyMC or Jupyter. Outputs are empty. Every numeric or visual claim in the
answers is a **prediction** for Step 3a to confirm or correct.

The predictions come from an independent, numpy-only approximation of the same model.
Scripts are in the session scratchpad:
- `nb07_prior_sim.py` and `nb07_prior_axis*.py`: prior predictive simulation.
- `nb07_gibbs.py`: a Gibbs/slice sampler for the centered posterior, run on the real
  `sleepstudy` data.
- `nb07_psense.py`: `arviz_stats.psense_summary` on those draws, with log priors
  computed by hand.
- `nb07_ppc.py`: posterior predictive coverage and ECDF quantiles.

The Gibbs posterior reproduces the pre-revision notebook's committed summary (same
posterior, different parameterization) to two decimals. So these predictions are well
founded, but they are not validated output.

## What was written

- `sleep/solved/07_lognormal_varying_intercept_slope.ipynb`: 91 cells (70 markdown,
  21 code), every cell tagged:
  - 7 `section`;
  - 27 `exercise-question`;
  - 3 `exercise-question`+`given-answer`;
  - 27 `given` (13 markdown, 14 code);
  - 27 `solution` (20 markdown, 7 code).

  Outputs are empty and `execution_count` is null. The builder is
  `build_nb07.py` in the scratchpad. Cell ids are stable hashes of per-cell keys, and the
  notebook metadata is copied from the pre-revision file.
- `sleep/07_lognormal_varying_intercept_slope.ipynb` was derived mechanically by
  `derive_and_verify_nb07.py`, the NB06 script with only the file names changed:
  - the 27 `solution` cells become `- answer here` / `# answer here`;
  - the badge now points to `sleep/07_...`;
  - outputs are cleared;
  - there is no `metadata.execution` and no `metadata.widgets`.
- **Verified by script:** 28 differing cells (27 solution + 1 badge). Every other cell
  is byte-identical, with the same ids, types and tags. A separate check,
  `check_nb07.py`, found:
  - every code cell parses;
  - every markdown cell uses only `$`/`$$` math;
  - every source uses the correct line-ending format;
  - no `print(model)`, `target_accept`, `lam=`, `_z`, `population_mu`, or reference
    to Notebook 8 / "next notebook" anywhere.

Scaffolding is NB5-style, as planned. The model, the prior sampling and its plots, the
sampling, the diagnostics code and the power-scaling bookkeeping are all `given`.
Students write:
- the posterior plots (4.1, 4.3, 4.5, 5.1);
- the posterior predictive and ECDF code (5.3, 5.7);
- the `psense_summary` call (6.3);
- every interpretation answer.

| Section | Questions |
|---|---|
| Setup / Data (with the NB5 participant index and asserts) / Plotting helper (`plot_participants` only) | all `given` |
| 1. Read the hierarchical lognormal model | 1.1 math (given) · 1.2 code + graphviz (given) · 1.3 what varies by participant · 1.4 `mu_b1` and its multiplicative reading · 1.5 population distributions, read proportionally · 1.6 what `sd_y` means now and why it should shrink · 1.7 `mean_rt` vs `mu_y` |
| 2. Check the prior implications | 2.1 criteria (given) · 2.2 prior draws + `plot_dist` of the 5 top-level parameters (given) · 2.3 are the hierarchy priors reasonable (compounding of slope differences) · 2.4 prior predictive plot (given) · 2.5 criteria verdict · 2.6 why all panels look alike (exchangeability) |
| 3. Fit and diagnose the hierarchy | 3.1 sample (given) · 3.2 divergences + summary + trace (given) · 3.3 verdict · 3.4 all-participant screen + 308/337/372 subset (given) · 3.5 verdict |
| 4. Examine the fitted hierarchy | 4.1 plot `mu_b1` · 4.2 credible range in %/day · 4.3 plot `sd_b1` · 4.4 credible range · 4.5 forest `b1` · 4.6 heterogeneity verdict · 4.7 `sd_y` vs Notebook 6 |
| 5. Predictive consequences | 5.1 plot `mean_rt` per participant · 5.2 what the bands mean · 5.3 PPC · 5.4 `mean_rt` → `y` · 5.5 participant-level verdict incl. positivity and vs NB6 · 5.6 ECDF criteria (given-answer) · 5.7 ECDF · 5.8 verdict + explicit NB6 comparison |
| 6. Sensitivity of the hierarchical scales | 6.1 why, and which priors to power-scale (given-answer + given text) · 6.2 bookkeeping (given) · 6.3 `psense_summary(..., prior_var_names=...)` · 6.4 verdict |
| 7. Summary | 7.1 retrospective summary only |

The model follows the plan:
- centered `mu_b0`/`sd_b0`/`b0[participant]` and `mu_b1`/`sd_b1`/`b1[participant]`;
- `sd_y`, `mu_y = b0[pidx] + b1[pidx] * days`, and `mean_rt = exp(mu_y + sd_y**2 / 2)`;
- `y = pm.LogNormal(...)`;
- named prior constants and `pm.Exponential(scale=...)`;
- no `population_mu`/`population_mean_rt`;
- `pm.sample(draws=1000, tune=1500, chains=4, random_seed=RANDOM_SEED)`, with no
  `target_accept`.

## Decision on the open question: the `sd_y` prior

**Decision: `mu_sd_y = 1 / 3`**, which is Notebook 6's prior, reused. It is not the
pre-revision NB7 value of 1/6. The notebook states this in the model comment and in
1.2, and it discusses the choice explicitly in Q&A 1.6 and 4.7.

Reasons:
1. **Instructor precedent for the exact same situation.** When the Gaussian sequence
   added a hierarchy (NB4/5), the old notebooks had a narrower residual prior (mean
   25 ms) than the population notebook NB1 (50 ms). The instructor's revision
   harmonized back to NB1's value and taught it as reuse. The shared report records
   this in §3.3. Old NB7 (1/6) versus NB6 (1/3) is the same pattern.
2. **Playbook §3.2.** NB6 is the notebook that elicited this prior, with a stated
   meaning (×1.4 per SD). The old 1/6 has no recorded rationale. `mu_b0` and `mu_b1`
   already reuse NB6's `b0`/`b1` priors, so reusing NB6's `sd_y` keeps all three
   carried-over priors consistent.
3. **The narrower meaning is taught, not ignored.** Q&A 1.6 asks what `sd_y` now
   describes. It is within-participant day-to-day variation, so it should be smaller
   than in NB6, and NB6's prior is generous for that role. Q&A 4.7 then confirms this
   against the fit: predicted about 0.08 versus NB6's 0.17. This is likely the
   rationale behind the old narrower value, now made explicit instead of silent.
4. **The choice is not consequential for inference or for the prior predictive plot.**
   144 observations pin `sd_y` down, and the predicted top-level power-scaling
   sensitivity is about 0.001. The prior predictive spread is dominated by the
   `b0`/`b1` uncertainty. In the simulation, 1/6 and 1/3 give nearly identical bands.

## Deviations from the plan, and why

### 1. `sd_sd_b1` changed from 0.1 to 0.05 (the most important deviation — please review)

The plan reuses the old `Exponential(lam=10)`, which is scale 0.1. This deviation is
driven by evidence:

- **The pre-revision notebook's own committed PyMC output proves the problem.** I
  extracted the old prior predictive image (old cell 18, same hierarchy priors). One
  panel's prior predictive **mean line spikes to about 34,000 ms at day 7**. Because
  the helper uses `sharey=True`, every panel's bands and data are flattened onto the
  x-axis, so the plot is unreadable and the criteria cannot be judged from it.
- **It is not bad luck; it is typical.** In 40 numpy prior predictive simulations of
  500 draws each:

  | `sd_sd_b1` | Median of the largest panel-mean | Chance it exceeds 3,000 ms |
  |---|---|---|
  | 0.1 | about 10,000 ms | 85% |
  | 0.05 | about 950 ms | 10% |

  NB6's non-hierarchical model gives about 670 ms, with a 5% chance of exceeding
  3,000 ms. The driver is the Exponential tail of `sd_b1`: rare large between-participant
  slope differences compound over seven days. `sd_y` is not the driver; changing it to
  1/6 made no difference.
- **Scientific justification (stated in the notebook, 2.3).**
  - A difference in daily effect compounds over the week. At the prior mean 0.05, one
    SD corresponds to a ×1.4 difference over seven days, and about ×2 near the upper
    end of the prior. At 0.1 these become ×2 and about ×5, which makes "enormous
    seven-day differences" routine. That violates the plan's own hierarchy criterion.
  - 0.05 is also close to NB5's Gaussian slope-variation prior translated to the log
    scale: 10 ms/day at about 250–300 ms is about 0.035–0.04. It stays slightly
    broader, in keeping with NB6's broad log-scale priors.
- **The posterior is unaffected.** In the numpy posterior, `sd_b1` is 0.022
  [0.014, 0.030] under both values. Its top-level sensitivity moves only from 0.010 to
  0.021.
- `sd_sd_b0 = 1/6` is kept as planned. The intercept tail does not compound, so it
  causes no display problem.

If the instructor prefers 0.1, the answers that need rewriting are 2.3, 2.5 and 7.1,
and the prior predictive plot would need a display fix, such as a capped y-axis.
Reverting alone is not enough.

### 2. Power-scaling uses only the top-level priors (`prior_var_names`)

The plan asked to re-check the old "potential prior-data conflict" flags on the
participant-scale hyperparameters. I investigated the mechanism with the numpy draws
and `arviz_stats` 1.3.2 `psense_summary`:

| Log prior power-scaled | `sd_b0` prior / likelihood | `sd_b1` prior / likelihood | Other flags |
|---|---|---|---|
| Non-centered, all priors (the old notebook's setup) | 0.403 / 0.061, conflict | 0.360 / 0.133, conflict | none |
| Old notebook, actual PyMC output | 0.403 / 0.066, conflict | 0.379 / 0.121, conflict | none |
| **Centered, all priors (the default call)** | 0.315, conflict | 0.393, conflict | **all 5 flagged** (`mu_b0`, `mu_b1` "strong prior / weak likelihood"; `sd_y` "conflict") |
| **Centered, top-level priors only** | **0.035 ✓** | **0.021 ✓** | none (all ≤ 0.012) |

The first row reproduces the old flag almost exactly. The flag therefore comes from
power-scaling the conditional population densities (`b0 | mu_b0, sd_b0` in the centered
form, or the `_z` terms in the non-centered form). Those densities are how the data
inform the hyperparameters. The flag says nothing about the top-level priors we chose.
It also changes with the parameterization of the same posterior, which a real
prior-data conflict would not.

**In the notebook:**
- 6.1 (given text) explains why only the chosen top-level priors are power-scaled. It
  also says openly that power-scaling the population densities would flag the
  hyperparameters for reasons unrelated to the chosen priors.
- 6.3 uses `azs.psense_summary(idata, var_names=top_level, prior_var_names=top_level)`.
- The bookkeeping cell is unchanged from NB1/NB6.

I did not include a second, all-priors table. It would add a confusing flood of flags
and a second concept to a secondary section; AGENTS treats added sophistication as a
cost. If the orchestrator or instructor wants the contrast shown in the notebook, it is
one extra `given` cell plus one Q&A. **Step 3a should run the default call once in a
scratch session (not committed) to confirm the 6.1 claim.**

### 3. Structure additions beyond the plan's outline

Each addition is small and serves a stated rule:
- **1.1/1.2 split** (math, then code + graphviz). This is NB5's layout, and it shifts
  the plan's 1.x numbering by one.
- **1.6 (`sd_y` meaning) and 4.7 (fitted `sd_y` vs NB6).** This is the in-notebook
  treatment of the open question, which the plan asked for.
- **2.1 criteria cell (given)** before the checks, per playbook §1.2.
- **2.6 "Why do all the panels look alike?"** In a hierarchical prior predictive plot,
  each panel shows the same marginal distribution because participants are
  exchangeable. Without this, students would try to judge between-participant
  variation from panels that cannot show it. This is also why 2.3 judges it from the
  `sd_b0`/`sd_b1` priors.
- **5.1/5.2 posterior `mean_rt` trajectories and 5.4 `mean_rt` → `y`.** `mean_rt` must
  be used after being defined (AGENTS: every Deterministic is used). The
  mean-versus-predictive distinction must be shown separately (AGENTS; NB5 §5–6; NB6
  4.2–5.2). This puts the plan's PPC items at 5.3/5.5/5.7/5.8 instead of 5.1–5.4.
- **5.6 ECDF criteria as a given-answer**, following NB6's 5.4 pattern.

### 4. Plotting helper and other minor points

- `plot_population` is dropped, as the plan says.
- No `print(model)`; `pm.model_to_graphviz` is used, per playbook §3.7.
- The prior draws sample only the variables that are used:
  `["mu_b0", "sd_b0", "mu_b1", "sd_b1", "sd_y", "y"]`. This avoids the report's
  "unused sampled variables" issue.

## Things for the orchestrator or a course-wide pass (not changed here)

- **`pm.stats.compute_log_prior` exists in PyMC 6.3.2.** It is exported in
  `pymc/stats/__init__.py` and wraps `compute_log_density(kind="prior")`. The README
  says there is "no separate public `kind="prior"` wrapper yet", which is now stale. I
  kept the course's existing bookkeeping cell (shared infrastructure, playbook §1.3).
  Switching is a course-wide decision covering NB1–3, NB6 and NB7.
- **`round_to=2` with log-scale parameters.** The summary will show roughly `mu_b1`
  0.04 [0.03, 0.05], `sd_b1` 0.02 [0.01, 0.03] and `sd_y` 0.08 [0.07, 0.09], which is
  one significant figure. The NB6 review already deferred this to a playbook-level
  decision, and I kept playbook §3.7.
- The README's "Prior sensitivity (… notebooks 1, 2, 3, 6, 7)" line is still correct.
  NB7's use of `prior_var_names` could be mentioned there in the course-wide README
  update.
- **If the instructor ever adopts NB6 review option B** (tightening/re-centering NB6's
  `b0`/`b1` priors), NB7's `mu_mu_b0`/`sd_mu_b0`/`sd_mu_b1` should follow, and 2.5/7.1
  would need rewriting.

## To check during execution (Step 3a)

"Predicted" values come from the numpy approximation. Items are ordered by how much
they matter.

| # | Cell | Claim written | Predicted basis / confidence |
|---|---|---|---|
| 1 | 3.3, 3.5, 7.1 | Centered, default settings: **0 divergences**, R-hat 1.00, bulk/tail ESS "in the thousands" (population and all-participant screen) | The geometry is NB5's on the log scale: I ≈ 6 for `b0` and 3.4 for `b1` (NB5: 3.8/3.4); P(`sd_b1` < 0.01) ≈ 0.001. **High.** If divergences appear, switch to non-centered (`b0_z = pm.Normal("b0_z", 0, 1, dims="participant")`; `b0 = pm.Deterministic("b0", mu_b0 + sd_b0 * b0_z, dims="participant")`, same for `b1`), explain why in 3.3, and keep §6 as written (it already uses only the top-level priors). If ESS is merely in the high hundreds, reword "in the thousands". |
| 2 | 6.4 | All five top-level prior sensitivities are below 0.05, none flagged; the largest is `sd_b0` at "about 0.03" | 3 independent runs: `sd_b0` 0.030–0.035, `sd_b1` about 0.02, the rest ≤ 0.012. **High.** Also run the default all-priors call in a scratch cell to confirm 6.1's claim (see deviation 2 above). |
| 3 | 2.5, 7.1 | At baseline the 90% band is about 20–350 ms; the 50% bands lie below about 200 ms on every day, below every observation; by day 7 the 50% band nearly reaches 0 and the 90% band exceeds 1 s | Simulation: day 0 50% [63, 171], 90% [21, 343]; day 7 50% [2, 151], 90% [1, ~1,270], at most about 1,500; 100% of observations lie above their panel's 50% band. **High**, but **look at the plot yourself**. The NB6 review found the implementer's reading too generous, and I wrote "only partly" deliberately. **Readability risk:** there is still about a 10% chance that one panel's mean line spikes above 3,000 ms and stretches the shared y-axis. If so, do not change the prior: note the spike in 2.5, or cap the axis in the given cell with a stated reason. |
| 4 | 2.3 | `sd_b0` mostly below about 0.4; `sd_b1` mostly below about 0.11 | Analytic 90% HDIs [0, 0.384] and [0, 0.115]; the KDE of 500 draws will be approximate. High. |
| 5 | 4.2, 7.1 | `mu_b1` 90% HDI "approximately 0.03–0.05", which is 3–5%/day | Predicted [0.026, 0.046]. **Rounding risk**: `round_to=2` may print 0.02 or 0.04 at an edge. Adjust the numbers if so; the interpretation stands. |
| 6 | 4.4 | `sd_b1` HDI about 0.01–0.03 | Predicted [0.014, 0.030]. Medium-high; same rounding caveat. |
| 7 | 4.6, 7.1 | Participant 335 is near zero; 308, 337, 350 and 370 are about 6%/day | Predicted `b1` means: 335 −0.005; 308 0.057; 337 0.058; 370 0.058; 350 0.063. High. Check the forest plot. |
| 8 | 4.7, 7.1 | `sd_y` about 0.08 [0.07, 0.09], half of NB6's 0.17; `mean_rt` about 0.3% above the median | Predicted 0.079 [0.070, 0.088]. The old run also gave 0.08. High. |
| 9 | 5.2 | Observations scatter more widely than the `mean_rt` bands | Median 90% band width 34 ms against a 90% predictive width of 86 ms; about 23% of observations lie outside the `mean_rt` 90% band. High. |
| 10 | 5.5, 7.1 | No participant sits systematically off the bands; misses are isolated and concentrated in 308 and 332; 309's observations sit well inside the bands | Predicted misses (outside the 90% band): 308 (days 3 and 5), 332 (days 4 and 7), 370 (day 3), 371 (day 4), about 4% of observations. The old notebook's committed PPC image shows the same pattern, with 309 hugging its mean line. High. Check the plot. |
| 11 | 5.8, 7.1 | Pooled ECDF broadly consistent, no persistent tail displacement; NB6 passed too | Observed 5/25/50/75/95% quantiles fall at percentiles 0.69/0.28/0.33/0.85/0.41 of the replicated quantiles; the observed max and min are inside the replicated ranges. High. |
| 12 | 1.x, 2.6 | Structural and definitional answers | Certain. |

## Not done in this step

- No execution; Step 3a produces the outputs.
- No README change. No other file was touched besides the two notebooks and this note.

## Orchestrator decision on the flagged `sd_sd_b1` deviation (Step 3a)

Accepted the implementer's change to 0.05, after verifying with real execution (not
the implementer's numpy approximation) that 0.1 produces a genuinely unreadable plot
(axis reaching 1e7 ms) while 0.05 produces a legible, honestly-still-imperfect one.
See `03_execution_log.md` for the full reasoning and the before/after images. Also
fixed a rounding mismatch the implementer had flagged as a risk (`mu_b1`'s HDI rounds
to 0.02-0.05, not 0.03-0.05) and adjusted the "why do panels look alike" Q&A (2.6) to
match the real plot, which shows 2 of 18 panels with a visible spike rather than none.
