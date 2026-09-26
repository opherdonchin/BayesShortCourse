# Implementation notes: notebook 06 — Lognormal regression

Author: implementation agent (Step 2 of `sleep/REVISION_PLAYBOOK.md`). Nothing was
executed with PyMC/Jupyter in this step. Outputs are empty, and every numeric claim below is
a prediction for Step 3a to confirm or correct.

## What was written

- `sleep/solved/06_lognormal_regression.ipynb`: 80 cells (61 markdown, 19 code), every cell
  tagged. There are 7 `section`, 27 `exercise-question`, 3 `exercise-question`+`given-answer`,
  15 `given` (8 markdown, 7 code), and 28 `solution` cells (16 markdown, 12 code). Outputs are empty and
  `execution_count` is null.
- `sleep/06_lognormal_regression.ipynb`: derived mechanically from the solved notebook
  (script: `derive_and_verify_nb06.py` in the session scratchpad). The derivation keeps the
  same cell ids, types, order and tags. The 28 `solution` cells are replaced with
  `- answer here` / `# answer here`, and the badge path is changed to `sleep/06_...`.
  Outputs are cleared, and there is no `metadata.execution` or `metadata.widgets`.
- Verified by script, not by eye: every non-`solution` cell's source is byte-identical
  between the two files, except cell 0, which differs only by the badge URL. That makes 29
  differing cells (28 solution + 1 badge).
- Notebook metadata was taken from the pre-revision solved file (`colab`, `kernelspec`
  "Python 3", `language_info` 3.12.12). Cell ids are stable hashes of per-cell keys.

Section structure:

| Section | Questions |
|---|---|
| Setup / Data / Plotting helpers (all `given`) | — |
| 1. Priors on the wrong scale | 1.1 model display (given) · 1.2 what `mu_y` means / $e^{250}$ · 1.3 mis-scaled model (given) · 1.4 sample its prior predictive · 1.5 numeric summary (given) · 1.6 criteria verdict |
| 2. Priors on the log scale | 2.1 `b0` elicitation · 2.2 `b1` elicitation · 2.3 `sd_y` elicitation · 2.4 store constants · 2.5 build model · 2.6 prior predictive draws · 2.7 plot · 2.8 criteria verdict · 2.9 why the mean sits above the 50% band |
| 3. Fit and diagnose the model | 3.1 sample · 3.2 divergences + summary + trace · 3.3 criteria verdict |
| 4. Population effect under a lognormal likelihood | 4.1 `mean_rt` vs `mu_y` · 4.2 `plot_population(idata, "mean_rt")` · 4.3 mean-vs-predictive bands · 4.4 multiplicative reading of `b1` |
| 5. Predictive consequences of the likelihood | 5.1 PPC participants · 5.2 `mean_rt` → `y` · 5.3 participant-level verdict · 5.4 ECDF criteria (given-answer) · 5.5 ECDF plot · 5.6 verdict + comparison with NB5 |
| 6. Sensitivity on the log scale | 6.1 why (given-answer) · 6.2 bookkeeping (given) · 6.3 `psense_summary` · 6.4 verdict |
| 7. Summary | 7.1 retrospective summary of this notebook's findings |

The model follows the plan and playbook §3.1–3.2. It uses `b0`, `b1`, `sd_y`, `mu_y`,
`mean_rt = exp(mu_y + sd_y**2 / 2)`, and `y = pm.LogNormal(...)`. The prior constants are named
(`mu_b0`, `sd_b0`, `mu_b1`, `sd_b1`, `mu_sd_y`), and `pm.Exponential(scale=...)` is used
throughout. The mis-scaled model uses Notebook 1's values (250/100, 0/20, scale 50). The
corrected model keeps the pre-revision values (5/0.55, 0/0.2, scale 1/3). Sampling uses
`draws=1000, tune=1500, chains=4`, with no `target_accept`.

## Instructor corrections applied (received mid-task via the orchestrator)

1. **No forward pointer at the end.** The plan's closing Q&A pointed ahead to Notebook 7.
   I replaced it with `## 7. Summary` / `### 7.1 What has this notebook shown?`, a
   retrospective summary of this notebook's own findings: priors, interpretation,
   predictive checks, and sampling/sensitivity. The notebook contains no reference to
   Notebook 7 anywhere. The limitation found by the participant-level check is still
   stated, but as a finding of this notebook (5.3 and 7.1), not as a preview.
2. **NB1–3 phrasing is the better style model than NB4–5.** Question and answer wording
   follows NB1–3 (e.g. NB1's elicitation phrasing, NB1 5.10's mean-vs-predictive question,
   NB3's diagnostics/power-scaling wording). Structural conventions from NB4–5 are kept: tags,
   naming, `coords=None` helper, and ECDF PPC.

## Deviations from the plan, and why

- **Numeric summary instead of a plot for the mis-scaled prior predictive (1.5, `given`).**
  This resolves the plan's open question. The draws span roughly $10^{-300}$ to `inf` ms, so a
  millisecond-axis plot would be unreadable: the shared y-axis would reach ~$10^{200}$ and the
  mean would be `inf`. The supplied cell prints the median prior predictive reaction time and
  the share of draws between 50 ms and 1 s. It uses plain xarray reductions, because a native
  ArviZ summary is also broken by the `inf` draws. I checked this code with numpy/xarray only
  (no PyMC) on equivalent simulated draws. It runs without warnings and prints about `3e+104 ms`
  and `0.2%`. I added it as its own numbered `given` step, which shifts the plan's 1.x numbering
  by one. A `### 1.1` model-display cell was also added, because students need the lognormal
  model on screen before 1.2 can ask what `mu_y` means.
- **Constants stored as a separate step (2.4).** This follows NB1's "Store the prior" pattern,
  compressed into one code task after the three elicitation answers. The mis-scaled cell
  defines the same names with millisecond values, and 2.4 deliberately overwrites them. The
  prompt says so ("same names … only their values, and the scale they act on, change").
- **Slope elicitation framing.** The plan's example ("up to ~20%/day → log(1.2) ≈ 0.18 →
  Normal(0, 0.20)") does not match NB1's "95% between A and B → Normal(mid, (B−A)/4)"
  convention: under that convention, ±0.18 would give sd ≈ 0.09. I kept the plan's and old
  notebook's value, 0.2, and framed it consistently as a 95% range of ×0.67 to ×1.5 per day
  (±0.4 on the log scale). **Flag for review:** this is a broad prior, and see the
  prior-predictive note below.
- **Prior predictive split into 2.6 generate / 2.7 plot / 2.8 verdict / 2.9 skew** (the
  plan's 2.5/2.6), following NB1–3's one-task-per-cell pattern.
- **Diagnostics split into 3.2 (code) and 3.3 (verdict)**, as in NB3.
- **Plan 4.3 (credible baseline mean reaction time) dropped.** It was replaced by 4.3
  (mean-vs-predictive bands, per the report's checklist item 30) and 4.4 (multiplicative
  interpretation of `b1`). No scalar in the model answers "baseline mean RT". Answering it
  would require selecting an `obs_id` index, which is an implementation detail, or adding a
  Deterministic that the plan does not list. The multiplicative reading of `b1` is the core of
  "how the likelihood changes interpretation" (README teaching goal), and it is answered from
  the existing 3.2 summary.
- **Added 5.2 (`mean_rt` → `y`) and 5.4 (ECDF criteria, given-answer)**, following the
  checklist's criteria-first and mean-vs-predictive rules.
- **`azp.plot_psense_dist` omitted.** This follows NB1: the summary table answers 6.4.
- **No `pm.model_to_graphviz`.** The plan made it optional, and the model has three parameters.
- **Heading `### Plotting helpers` (plural).** The single `given` cell defines both
  `plot_participants` (with `coords=None`) and `plot_population` (used in 4.2), so the singular
  heading would be inaccurate.
- `coords` is defined in the supplied mis-scaled model cell and reused in the student's 2.5
  model. The 2.5 prompt says so.

## Judgment calls the plan left open

- The plausibility range in the 1.5 summary is 50 ms to 1 s. It is deliberately generous,
  roughly twice the largest observed reaction time, so that a failure cannot be blamed on a
  tight range.
- `round_to=2` is kept in `azs.summary`, per playbook §3.7. `b1` will display as roughly
  `0.04 [0.03, 0.05]`, which is coarse but enough for the "3–5% per day" answer. If the
  orchestrator prefers `round_to=3` for log-scale parameters, 4.4's wording would need its
  numbers updated.
- No `target_accept`. This is a well-conditioned three-parameter regression on log RT. The old
  notebook's `target_accept=0.92` was prophylactic, and 0 divergences are expected at the
  default settings.

## To check during execution (Step 3a)

I simulated the prior predictive numbers in pure Python beforehand. The posterior numbers are
taken from the pre-revision notebook's run of the same model, whose only difference was
`target_accept=0.92`.

| Cell | Claim | Basis / confidence |
|---|---|---|
| 1.2 | $e^{250} \approx 10^{108}$ ms; age of universe ≈ $4\times10^{20}$ ms | analytic; certain |
| 1.6 | median > $10^{100}$ ms; about **0.2%** of draws in 50 ms–1 s | simulation: 3e104 ms, 0.2%; high |
| 2.8 | day-0 90% bands roughly **20–350 ms**; day-7 bands from near zero to about 1 s | simulation; medium-high |
| 2.9 | mean line above the 50% band; the 50% band sinks toward zero across days; mean line jumpy late in the week | simulation (day-0 mean ~200 vs 50% top ~175; day 7 mean 400–600, jagged across panels); medium-high |
| 3.3 | 0 divergences, R-hat 1.00, bulk/tail ESS > 1,000 | old run: 0 div, ESS 1,700–2,500; high |
| 4.1 | `sd_y` ≈ 0.17; mean ≈ 1.5% above median | old run: 0.17; high |
| 4.3 | most observations lie outside the `mean_rt` bands | band ≈ ±5% of ~270–360 ms; high |
| 4.4 | `b1` 90% HDI ≈ **0.03–0.05** (3–5%/day) | old run; high |
| 5.3 | all predictions positive; bands somewhat wider on later days; whole participants above/below bands | ~150 → ~200 ms band width; high |
| 5.6 | pooled ECDF broadly consistent, no persistent tail displacement | **least certain**: old notebook only had a KDE check; please inspect the plot and rewrite 5.6 (and the 7.1 "Predictive checks" bullet) if there is a visible systematic mismatch |
| 6.4 | all prior sensitivities far below 0.05, no flags | old run: 0.005–0.008, all ✓; high |
| 7.1 | repeats the above | update with any corrected numbers |

**Prior-predictive display risk (2.7).** The prior-predictive mean has infinite expectation
under `Exponential(scale=1/3)` for `sd_y`, because $E[e^{sd_y^2/2}]$ diverges. The orange mean
line will therefore be noticeably jumpy at later days, and the shared y-axis will reach
about 1,000–1,200 ms. The answer to 2.9 explains this. If the executed plot looks misleading
rather than instructive, prefer adjusting the 2.9 text over changing the prior; the plan fixes
the prior values. Separately, about a quarter of simulated day-7 prior-predictive reaction
times are below 50 ms. Answer 2.8 states this honestly ("positive support rules out negative
reaction times, not implausible ones"). If the reviewer or instructor would rather tighten
`sd_b1`, that would change 2.2's elicitation range, and it is a plan-level decision.

## Not done in this step (out of scope for this task)

- No execution. Outputs are to be produced in Step 3a.
- `sleep/solved/README.md` was not touched. Its "Plotting grammar" and "expected reaction
  time" lines already match this notebook (`plot_population` defined because it is used;
  `mean_rt = exp(mu_y + sd_y**2 / 2)`).
