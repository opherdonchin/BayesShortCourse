# Implementation notes: notebook 12 — Robust likelihoods and PSIS-LOO

Author: implementation agent (Step 2 of `sleep/REVISION_PLAYBOOK.md`).

## Execution status

**The solved notebook is committed-ready with real outputs.** It was executed in place with
the pinned stack (`scratchpad/nbenv`: Python 3.12, `pymc==6.3.2`, `arviz-base==1.3.0`,
`arviz-stats==1.3.2`, `arviz-plots==1.3.1`, `pandas==2.2.3`), using the real `DATA_URL`:

```bash
jupyter nbconvert --to notebook --execute --inplace \
    --ExecutePreprocessor.kernel_name=nbenv --ExecutePreprocessor.timeout=2400 \
    sleep/solved/12_robust_student_t_and_loo.ipynb      # exit: 0, 0 cell errors, ~47 s
```

- The final in-place run and the second scratch draft (`exec_draft2.ipynb`, same code,
  earlier markdown) produced **identical text outputs**, every table and printed number
  compared by script. The first draft differed only in two code details (summary filter,
  `compare` rounding) and matched wherever the code was the same.
- **After the orchestrator's `b1` decision (deviation 1)**, the notebook was rebuilt and
  re-executed in place (exit 0, 0 errors). Compared by script with the pre-rename run, every
  number is identical; only the shared-slope models' label changed (`mu_b1` → `b1`) in the NUTS
  line and the population summaries. The repository file is this post-rename execution.
- The notebook's numbers are also identical to my earlier scratch fits (`fit12.py`, same seed,
  same variable order), so the model factory in the notebook is the model I tested.
- Execution counts run 1–16 with no gaps; no error outputs.

## What was written

- **`sleep/solved/12_robust_student_t_and_loo.ipynb`:** 74 cells (58 markdown, 16 code), every
  cell tagged:
  - 5 `section`;
  - 19 `exercise-question`, each followed by exactly one `solution` (15 markdown, 4 code);
  - 7 `exercise-question` + `given-answer`: 1.3 (the $\nu$ prior), 2.1 (LOO and PSIS), 2.2
    (what PSIS-LOO needs), 3.1 (LOO-PIT), 4.1 (ELPD), 4.3 (Pareto $k$), 4.6 (the comparison
    table);
  - 24 `given`.
- **Built by** `scratchpad/nb12/build_nb12.py` (NB11's builder pattern: stable hashed ids
  `sleep12-<key>`, top-level metadata from the pre-revision file minus `widgets`,
  `json.dump(..., indent=1, ensure_ascii=False, sort_keys=True)` plus trailing newline).
- **`sleep/12_robust_student_t_and_loo.ipynb`:** derived by
  `scratchpad/nb12/derive_and_verify_nb12.py` (NB11's script, file names changed).
- **Verified by script** (`derive_and_verify_nb12.py`, `check_nb12.py`, `nb_diff_files.py`):
  - exactly 20 cells differ (19 `solution` + the badge); every other cell is byte-identical;
    ids, types, tags and order identical;
  - self-work: no outputs, all `execution_count` null, no `metadata.execution`, no
    `metadata.widgets`;
  - both pass `nbformat.validate`, ids unique, trailing newline;
  - Q→A adjacency holds; questions are `###`, sections `##`; every in-notebook
    "Question N.M" reference resolves; math uses only `$`/`$$`;
  - none of: `print(model`, `lam=`, `kind="kde"`, `plot_population`, `population_mu`, `_z"`,
    `participant_intercept`, `participant_slope`, `intercept_sd`, `mu_log`, `mean_rt`,
    `target_accept`, "next notebook", "later notebook", `\(`, `\[`;
  - "Reaction" appears only in the axis label, `observed=sleep["Reaction"]` and the flagged-
    observation table;
  - notebooks cited: 1, 3, 4, 5.

### Section structure

| Section | Content (Q = student answers, G = given, QG = given-answer) |
|---|---|
| Title, Setup, Data, Plotting helper | G. Setup and data cells are NB11's verbatim. The intro frames the two questions and the standalone design (the plan's "does not depend on earlier notebooks"). The helper cell defines `PARTICIPANT_DAY` and a new `plot_loo_participants` (see deviation 4). |
| 1. Four models to compare | 1.1 model math + 2×2 table naming which model is NB4's and NB5's (G) · 1.2 what $\nu$ controls, linked to NB3's $\nu=7$ Student-t prior (Q) · 1.3 the $\operatorname{Gamma}(2,0.1)$ prior: Bambi provenance, what it says, why no new prior predictive check (QG) · 1.4 `build_model` factory + `models` dict (G) · 1.5 shared slope = varying slope with `sd_b1` = 0, so shared `b1` ↔ `mu_b1` (Q) · 1.6 fit loop (G) · 1.7 four-model diagnostic screen + population summaries (G) · 1.8 trace plot of `student_t_slope` (Q code) · 1.9 criteria verdict (Q) |
| 2. Difficult-to-predict observations | 2.1 LOO vs in-sample PPC, what PSIS does, warning foreshadowed (QG) · 2.2 pointwise log likelihood + posterior predictive, `pm.compute_log_likelihood` (QG + G code) · 2.3 Gaussian LOO intervals (G) · 2.4 which days are hardest (Q) · 2.5 Student-t LOO intervals (G) · 2.6 same days, narrower intervals (Q) |
| 3. Robust predictive calibration | 3.1 LOO-PIT, Δ-ECDF, $p$ value, highlighted points, shape reading (QG) · 3.2 `plot_loo_pit` for both slope models (G) · 3.3 Gaussian verdict (Q) · 3.4 Student-t verdict (Q) · 3.5 mechanism: `sd_y` and `nu` (Q) |
| 4. Predictive comparison | 4.1 ELPD and `azs.loo`'s fields (QG) · 4.2 compute `loos` (Q code) · 4.3 how to read Pareto $k$ (QG) · 4.4 `plot_khat` with threshold line + flagged-observation table (G) · 4.5 which models/observations are flagged, and why (Q) · 4.6 the `azs.compare` columns and what they do not establish (QG) · 4.7 `azs.compare` + `plot_compare` (Q code) · 4.8 best model and whether high $k$ threatens it (Q) · 4.9 `azs.compare(..., reference="gaussian_intercept")` (Q code) · 4.10 each change with and without the other (Q) · 4.11 why they interact (Q) |
| 5. What the comparison answers | 5.1 prediction target: same-participant rows, not new participants, not forecasting (Q) · 5.2 the population-average slope (`b1` in shared-slope models, `mu_b1` in varying-slope models) is ~11 ms/day in all four (Q) · 5.3 retrospective summary; last sentence notes, factually, that this ends the sequence (Q) |

**Scaffolding** follows the plan and the brief: the model factory, fit loop, diagnostics
tables, log-likelihood computation and the LOO-interval/LOO-PIT/Pareto-$k$ plotting are
`given`; the new LOO material is introduced by seven `given-answer` explanations (NB1's
power-scaling pattern); students compute `loos` and both comparisons, plot one trace, and
write every interpretation and verdict.

## Actual diagnostic results (notebook run, `RANDOM_SEED = 20260924`)

### Sampling: centered parameterization, default settings, all four models clean

`pm.sample(draws=1000, tune=1500, chains=4, random_seed=RANDOM_SEED)`, no `target_accept`.
The screen covers **every** free parameter, including all 18 `b0` (and `b1`):

| Model | Divergences | Largest R-hat (unrounded) | Smallest bulk ESS | Smallest tail ESS | Time |
|---|---|---|---|---|---|
| `gaussian_intercept` | 0 | 1.0025 | 1951 (`b1`) | 2612 | 4 s |
| `gaussian_slope` | 0 | 1.0040 | 3436 (`sd_b1`) | 2677 | 6 s |
| `student_t_intercept` | 0 | 1.0032 | 1505 (`b1`) | 2256 | 4 s |
| `student_t_slope` | 0 | 1.0053 (shown as 1.01) | 2005 (`sd_y`) | 2098 | 8 s |

Population summaries (mean, 90% HDI):

| | `gaussian_intercept` | `gaussian_slope` | `student_t_intercept` | `student_t_slope` |
|---|---|---|---|---|
| `mu_b0` | 267.9 [250.1, 285.5] | 268.0 [254.1, 282.7] | 268.8 [251.2, 288.0] | 268.0 [253.4, 282.4] |
| `sd_b0` | 42.4 | 32.5 | 44.1 | 35.4 |
| `b1` (shared) / `mu_b1` (varying) | 11.42 [9.55, 13.22] | 11.29 [8.10, 14.55] | 11.55 [9.83, 13.11] | 11.55 [8.24, 14.69] |
| `sd_b1` | — | 7.34 [4.73, 9.98] | — | 7.91 [5.34, 10.36] |
| `sd_y` | 30.48 | 25.71 [22.86, 28.64] | 22.86 | 12.17 [9.25, 15.02] |
| `nu` | — | — | 6.30 [2.00, 10.25] | 2.62 [1.51, 3.73] |

**Centered vs non-centered (scratch, `fit12.py`)**: centered was tried first per playbook
§3.4 and is clean for all four models, with no need for a higher `target_accept`. I also ran
the pre-revision's non-centered form with the same priors and seed: also 0 divergences, but
lower ESS (smallest bulk ESS 808, 2563, 733, 843 vs centered 1951, 3436, 1505, 2005). Eight
observations per participant inform `b0`/`b1` well, the regime in which centering is expected
to do well (pymc-modeling `hierarchical.md`). Centered is kept for all four; no per-model
exception was needed.

Seed robustness of sampling (centered, default settings, seeds 1, 2, 3): 0 divergences in
all 12 fits, largest R-hat ≤ 1.0041, smallest bulk ESS ≥ 1396.

### PSIS-LOO and Pareto $k$

| Model | ELPD (SE) | `p` | Largest $k$ | Obs. with $k > 0.7$ |
|---|---|---|---|---|
| `gaussian_intercept` | −706.69 (14.58) | 19.2 | 0.64 (332 day 4) | 0 |
| `gaussian_slope` | −690.69 (21.72) | 31.3 | 0.97 | 4: 332 day 4 (0.97), 332 day 7 (0.97), 308 day 5 (0.75), 371 day 7 (0.71) |
| `student_t_intercept` | −698.48 (12.22) | 23.6 | 0.54 | 0 |
| `student_t_slope` | −652.67 (14.09) | 43.7 | 0.49 | 0 |

**Against the pre-revision run** (non-centered, `target_accept=0.95`, `sd_y` prior scale 25,
Windows): ELPDs −707.35, −691.70, −698.44, −652.59 (all within 1 of mine); largest $k$ 0.74,
**1.27**, 0.68, 0.57. So the qualitative pattern the plan describes reproduces:
`gaussian_slope` is clearly unreliable, both Student-t models are comfortably below 0.7, and
`gaussian_intercept` is borderline. **But this run's `gaussian_intercept` is 0.64, below the
threshold, not 0.74**, and `gaussian_slope`'s is 0.97, not 1.27. The notebook reports the
actual values and calls `gaussian_intercept` borderline.

Pareto $k$ is itself a Monte Carlo estimate, so I checked its spread (scratch, same code):

| Run | `gaussian_intercept` max $k$ (n > 0.7) | `gaussian_slope` max $k$ (n > 0.7) | `student_t_intercept` | `student_t_slope` |
|---|---|---|---|---|
| **notebook seed**, centered | 0.645 (0) | 0.972 (4) | 0.537 | 0.485 |
| seed 1, centered | 0.689 (0) | 1.245 (3) | 0.606 | 0.509 |
| seed 2, centered | 0.819 (2) | 0.822 (2) | 0.648 | 0.533 |
| seed 3, centered | 0.739 (1) | 1.026 (2) | 0.514 | 0.559 |
| notebook seed, non-centered | 1.050 (2) | 1.318 (2) | 0.518 | 0.655 |

The flagged observations are always drawn from {332 day 4, 332 day 7, 308 day 5} (plus 371 day
7 once). The question text of 4.5 quotes the centered ranges ("about 0.8 to 1.3" and "about
0.65 to 0.8") so that students read a borderline value as borderline. ELPDs moved by at most
about 1.4 across these runs.

**Exact-LOO check (scratch `exact_loo.py`)**: I refitted each model without each flagged
observation (4 × 2000 draws) and computed the exact $\log p(y_i \mid y_{-i})$:

| Model, observation | $k$ | PSIS $\text{elpd}_i$ | exact | PSIS − exact |
|---|---|---|---|---|
| `gaussian_slope`, 332 day 4 | 0.97 | −20.77 | −20.75 | −0.01 |
| `gaussian_slope`, 332 day 7 | 0.97 | −13.54 | −14.21 | +0.66 |
| `gaussian_slope`, 308 day 5 | 0.75 | −14.65 | −14.95 | +0.30 |
| `gaussian_slope`, 371 day 7 | 0.71 | −5.19 | −5.23 | +0.03 |
| `student_t_slope`, same three unusual days | 0.31–0.48 | | | −0.02 to +0.01 |

Summed PSIS errors over the flagged observations were +0.99 (notebook seed), +0.40, +1.39,
+1.81 (seeds 1–3), +0.34 (non-centered): always optimistic, always < 2. That is the basis for
4.3's "tends to be too favorable" and 4.8's question text ("lowered its ELPD by less than 2 in
total"). Against a 38-point gap, it cannot change the ranking.

### Comparison (notebook output, `round_to=2`)

| vs best (`student_t_slope`) | `elpd_diff` | `dse` | `p_worse` | `diag_elpd` |
|---|---|---|---|---|
| `gaussian_slope` | −38.02 | 12.85 | 1.0 (0.998) | 4 k̂ > 0.70 |
| `student_t_intercept` | −45.81 | 8.71 | 1.0 | |
| `gaussian_intercept` | −54.02 | 9.57 | 1.0 | |

Stacking weight 1.0 for `student_t_slope`, 0.0 for the others. With
`reference="gaussian_intercept"`: `student_t_intercept` +8.22 (5.34, `p_better` 0.94),
`gaussian_slope` +16.00 (9.71, 0.95), `student_t_slope` +54.02 (9.57, 1.00). I checked the
paired `dse` by hand from `elpd_i` (ddof 0): identical.

So each change alone is worth < 2 SE; together they are worth ~5.6 SE, more than additive.
This interaction is new content (4.10–4.11); see decision 7.

### LOO predictive checks (scratch cross-checks of what the plots show)

- LOO intervals (equal-tailed, see decision 5): mean 90% width 95 ms (Gaussian) vs 71 ms
  (Student-t); mean 50% width 39 vs 24 ms. Observations outside their 90% interval: 10/144
  (Gaussian) vs 15/144 (Student-t, i.e. ~10%, as calibrated intervals should be). The three far
  misses are the same in both models: 332 day 4 (454 ms; Gaussian 90% interval 278–340,
  LOO mean 307), 332 day 7 (254; 332–416, mean 368), 308 day 5 (290; 373–441, mean 413).
- LOO-PIT (`azs.loo_pit`): 72% of Gaussian-slope PIT values lie in (0.25, 0.75) vs 50% for
  Student-t; Gaussian $p$ = 0.00, Student-t $p$ = 0.44 (as printed on the plots). 3.3's "about
  73%" is read off the Δ-ECDF (−0.12 → +0.11); the exact share is 72%.
- I verified that `plot_loo_participants`' reshaped DataTree gives LOO quantiles identical
  (max abs difference 0.0) to `loo_expectations` on the original `obs_id` data.

## Deviations from the plan and judgment calls (flagged)

1. **Name of the shared slope: `mu_b1`, as the plan specifies, not NB4's `b1`** (resolved:
   renamed to `b1`, see the end of this item). This is in
   tension with playbook §3.1's table (`slope` → `b1` in population models) and its rule that
   the `mu_` prefix is reserved for the center of a participant-level distribution, and with
   NB4's own naming. I followed the plan because in a four-model *comparison* the same
   scientific quantity (the population-average daily effect) should have the same name in every
   model: 5.2 compares `mu_b1` across all four, and one summary call serves all four. The
   notebook makes the choice explicit and meaningful: 1.1 says NB4 called it `b1`, and 1.5 asks
   which varying-slope parameter would have to be zero (`sd_b1`) for the models to coincide.
   **Orchestrator:** if you prefer strict NB4 naming, rename in the `else` branch and in 1.1,
   1.5, 5.2; 5.2's comparison then needs "`b1` or `mu_b1`".

   **Resolved by the orchestrator (after Step 2): renamed to `b1`, matching NB4 and the
   playbook table.** The orchestrator checked `sleep/solved/04_varying_intercept.ipynb`
   directly: NB4's own code is `b1 = pm.Normal("b1", mu=mu_b1, sigma=sd_b1)`, a bare `b1` for
   exactly this case (a population-only slope), so naming the free RV `mu_b1` broke both the
   playbook's §3.1 table and the precedent this notebook sits next to. Implemented:
   - `build_model`: `varying_slope=False` → `b1 = pm.Normal("b1", mu=mu_mu_b1, sigma=sd_mu_b1)`
     and `mu_y = b0[pidx] + b1 * days`; `varying_slope=True` keeps `mu_b1`/`sd_b1`/`b1`
     (`mu_b1` is now created inside that branch). The free-RV order is unchanged.
   - 1.1: math uses $b_1$ for the shared slope; the naming sentence now says the shared slope is
     `b1` as in Notebook 4, and the varying slopes are `b1[participant]` with average `mu_b1` as
     in Notebook 5.
   - 1.5: the question also asks which varying-slope parameter the shared `b1` corresponds to;
     the answer says `mu_b1`, making the two names' relation explicit.
   - 1.7: population summaries select the variables with only `chain`/`draw` dimensions
     (`set(posterior[var].dims) == {"chain", "draw"}`), which picks `b1` in the shared-slope
     models and `mu_b1`/`sd_b1` in the varying-slope ones without a hard-coded list; 1.8's trace
     plot lists its six parameters explicitly again.
   - 5.2: the question names both (`b1` in shared-slope, `mu_b1` in varying-slope models, citing
     1.5), and the answer explains why one quantity has two names: every participant's slope
     vs. the center of the participants' slope distribution.
   - **Re-executed** in place (nbconvert exit 0, 0 errors, execution counts 1–16). Every
     printed number and table is identical to the pre-rename run; the only output changes are
     the label `mu_b1` → `b1` in the two shared-slope models' NUTS line and population
     summaries. Self-work re-derived (20 differing cells = 19 solutions + badge) and
     `check_nb12.py` passes.
2. **`sd_y` prior: `Exponential(scale=50)` (NB4/05's `mu_sd_y = 50`), not the pre-revision's
   `lam=0.04` (scale 25).** The plan says all priors match NB4/05; the pre-revision's text
   claimed "the same mean-structure priors as notebooks 4–5" but its `sigma` prior was not
   NB4/05's. The other pre-revision constants already matched (250/100, 25, 0/20, 10). With
   this change, `gaussian_intercept` and `gaussian_slope` are exactly NB4's and NB5's models,
   which 1.1's table states.
3. **Default `target_accept`** (pre-revision used 0.95), per playbook §3.3, after confirming 0
   divergences in all four models and three extra seeds.
4. **LOO intervals plotted one panel per participant (`plot_loo_participants`), not the
   pre-revision's 144-point strip with "Observation (ordered by participant, then day)".**
   The plan said "given code, matches pre-revision". AGENTS.md ("do not expose ... observation
   indices ... when meaningful predictor values are available"; "same graphical grammar for
   comparable stages") argues for the course's participant-panel grammar, and 2.4/2.6 ask
   students to name participant and day, which the strip made nearly impossible. The helper
   unstacks `obs_id` into participant × day in every group `plot_loo_interval` reads (verified
   identical values). Visual choices: mean as a pink (`C1`, the colour of `plot_participants`'
   mean line) horizontal tick so that the 50% bar stays visible, observed points black; panels
   titled by participant (`NoVarLabeller`), unlike `plot_participants`, because the questions
   name participants. `plot_participants`/`LM_VISUALS` are not defined, because nothing calls
   them (playbook: don't carry helpers forward unused).
5. **LOO intervals are equal-tailed, and the notebook says so (2.3).** `plot_loo_interval` in
   arviz-plots 1.3.1 validates `ci_kind` but ignores it: it always draws weighted quantiles
   (`probs=[(1-p)/2, (1+p)/2]`, source read). The pre-revision passed `ci_kind="hdi"`, which
   silently did nothing. I dropped the argument and explained the ETI.
6. **`pm.compute_log_likelihood` and `sample_posterior_predictive` moved out of the fit loop**
   into 2.2 (given-answer + given code), NB1's power-scaling pattern: the tool's input is
   introduced when the tool is.
7. **Added a reference comparison (4.9) and two questions on it (4.10, 4.11).** The plan's
   verdict "does Student-t help, does the varying slope help, independently" cannot be read off
   the default table, whose differences are all relative to the best model. `reference=` is the
   native way to get the other two one-change comparisons. The result (each change < 2 SE alone,
   ~5.6 SE together) is the notebook's most interesting finding. 4.11's mechanism (systematic
   slope misfit is not tail behaviour, `nu` 6.3 vs 2.6; a Gaussian's inflated `sd_y` dilutes the
   gain from better trajectories) is interpretive. **Reviewer: check it is stated with
   appropriate confidence.**
8. **Added 5.2 (the population-average slope, `b1`/`mu_b1`, across the four models).** From the arviz-diagnostics skill ("compare
   substantive inferences across viable alternatives, not only a winning score") and the plan's
   "what the comparison does and does not establish". No new code: it reads 1.7's summaries.
9. **Pareto-$k$ plotting is `given`, not a student task.** The threshold line and share labels
   need `hline_values=[0.7], visuals={"hlines": {}, "bin_text": {}}`, an API detail not worth
   teaching; without them the two plots have different y-ranges and no threshold. The same cell
   prints a table of every observation with $k > 0.7$ in any model, with participant/day,
   because `plot_khat`'s x-axis is the observation index. `plot_khat`'s own `threshold=` labels
   overlapped (332 days 4 and 7 are adjacent), and `visuals={"title": {"text": ...}}` raises a
   TypeError in 1.3.1 (`labelled_title` receives `text` twice), so titles use
   `pc.get_viz("figure").suptitle(name)`.
10. **`azs.compare(..., round_to=2)`.** The default `round_to="auto"` rounds `elpd_diff` by its
    `dse` and printed −40.0, −50.0, −50.0: unusable for 4.8/4.10. The pre-revision's
    `round_to="none"` printed weights like 4.9e-14.
11. **Diagnostics for four models** (playbook §3.7 adaptation): one screen table over every
    parameter of every model, population summaries per model, and one trace plot (the most
    complex model, with `nu`) as a student task. No first/middle/last participant subset per
    model: with four fits it would add four figures for no new information beyond the
    all-parameter screen. The summaries select parameters with only `chain`/`draw` dimensions
    (after the `b1` rename, see deviation 1); an earlier `var_names=["~b0", "~b1", "~mu_y"]`
    version triggered ArviZ's "Items starting with ~ not found" warning.
12. **No prior predictive check.** The plan has none. 1.3 says so explicitly: the other priors
    were checked in NB4/05, and this notebook is about checking predictions after fitting. The
    Student-t models' prior predictive distribution is not literally NB4/05's (heavier tails),
    so this is an omission, stated, not a claim that it was checked.
13. **No ordinary PPC (`plot_ppc_dist(kind="ecdf")`)**: LOO-PIT (section 3) is the calibration
    check here, and 2.1 explains why it is the fairer version of the same idea.
14. **Summary inside section 5** (5.3), per the plan's outline, rather than a separate
    "## 6. Summary". Its last sentence notes that the notebook ends the sequence, framed
    retrospectively ("it added a check of..."), with no forward framing.
15. **Test-run facts in question text** (4.5: $k$ ranges across seeds; 4.8: exact refits),
    following NB09–11's precedent of quoting labelled test runs. Both are backed by the tables
    above.
16. **Bambi citation (1.3).** Verified in the Bambi 0.21.0 wheel (the version
    `bioassay/bioassay.ipynb` pins): `bambi/defaults/families.py`, family `"t"`,
    `"default_priors": {"sigma": "HalfNormal", "nu": "Gamma"}`, and
    `bambi/defaults/distributions.py`, `"Gamma": {"alpha": 2, "beta": 0.1}`. The notebook says
    "checked in Bambi 0.21.0". (This prior is also commonly attributed to Juárez & Steel 2010; I
    did not verify that and did not cite it.) Constants are named `alpha_nu`/`beta_nu`: the
    playbook's `mu_`/`sd_`/`nu_` scheme has no Gamma case, and `<hyper>_<param>` follows it.
17. **Colour word "pink"** for `C1`. The course README calls this colour "orange", but in
    `arviz-variat` `C1` renders pink/salmon (checked in NB09's committed plot). I described what
    students see.

## For Step 3a: every claim and its basis

"Run" = the notebook's executed output (identical across executions of the same code). "Scratch" =
`scratchpad/nb12/`.

| # | Cell | Claim | Basis | Action if it differs on Colab |
|---|---|---|---|---|
| 1 | 1.3 | Gamma(2, 0.1): mean 20; P(ν<5) ≈ 9%; P(ν>30) ≈ 20%; P(ν<2) ≈ 2% | Analytic (scipy): 0.090, 0.199, 0.018 | Certain |
| 2 | 1.9 | 0 divergences; largest R-hat 1.01; every ESS ≈ 1,500 or more | Run screen (1505 smallest) | Re-read screen; smallest ESS is close to 1,500 |
| 3 | 2.4 | 332 day 4 ≈ 454 vs ≈ 310; 332 day 7 ≈ 254 vs ≈ 370; 308 day 5 ≈ 290 vs ≈ 410; 308 days 0, 3 a little outside | Run figure; scratch LOO quantiles (307, 368, 413) | High; data values are fixed |
| 4 | 2.6 | Same three far misses; narrower intervals, 50% most (309, 335) | Run figures; scratch widths 95→71, 39→24 ms | High |
| 5 | 3.3 | $p$ = 0.00; dip ≈ −0.12 near 0.3, peak ≈ +0.11 near 0.75; ≈ 73% in middle half; highlighted points at both ends and on the dip | Run figure; scratch PIT share 72% | Check figure |
| 6 | 3.4 | $p$ = 0.44; within ≈ 0.05; no highlighted points | Run figure | Check figure |
| 7 | 3.5 | `sd_y` ≈ 26 vs ≈ 12 ms; `nu` ≈ 2.6 [1.5, 3.7] | Run summaries | Certain in this environment |
| 8 | 4.5 | Only `gaussian_slope` > 0.7: 332 d4 and d7 (0.97), 308 d5 (0.75), 371 d7 (0.71), 2.8%; `gaussian_intercept` 0.64 (332 d4), borderline; Student-t < 0.55 | Run printout/table/plots; seed table above | **Most run-dependent claim.** Question text is robust; if Colab's flags differ, rewrite this answer from the table |
| 9 | 4.8 | −38 (dse ≈ 13), ≈ 3 SE, `p_worse` ≈ 1, weight all to `student_t_slope`; refits < 2 | Run table; `exact_loo.py` | High |
| 10 | 4.10 | +8 (5), +38 (13), +16 (10), +46 (9), +54 together; `p_better` ≈ 0.95 | Run tables (4.7 and 4.9) | High |
| 11 | 4.11 | `nu` ≈ 6 [2, 10] vs ≈ 2.6 | Run summaries | Mechanism is interpretive (decision 7) |
| 12 | 5.2 | Population-average slope (`b1` in shared-slope, `mu_b1` in varying-slope models) means 11.3–11.6; HDI 9.6–13.2 (`b1`, `gaussian_intercept`) vs 8.1–14.6 (`mu_b1`, `gaussian_slope`); `sd_b1` ≈ 7–8 | Run summaries | Certain in this environment |
| 13 | 5.3 | Restates 1–12 | As above | |

## Notes for the orchestrator

- **README.** `sleep/solved/README.md`'s "Validation status" still says notebooks 6–12 are
  being revised; with NB12 done, that sentence can be updated in the commit that closes the
  pass. I did not edit it (not a convention change introduced by this notebook).
- **Library quirks found** (arviz-plots 1.3.1), worth knowing for any future LOO material:
  `plot_loo_interval` ignores `ci_kind` (always ETI); `plot_khat`'s title `text` visual raises
  a TypeError; `azs.compare`'s default `round_to="auto"` can round `elpd_diff` to one
  significant figure; `var_names=["~missing"]` warns rather than errors.
- **Runtime:** the whole notebook executes in ~47 s here (4 × 4–8 s sampling). Colab should be
  well under two minutes.
- **Output noise:** the executed notebook shows the arviz-stats Pareto-$k$ `UserWarning` four
  times (three from the Gaussian LOO-interval plot, one from `azs.loo`). Deliberately left
  visible: 2.1 and 2.3 tell students what it is, and hiding it would contradict the lesson.

## Scratch files (`scratchpad/nb12/`)

- **Builders and checks:** `build_nb12.py`, `derive_and_verify_nb12.py`, `check_nb12.py`
  (NB11's check with NB12 patterns).
- **Model and fits:** `model12.py` (factory, centered/non-centered), `fit12.py`,
  `fit_c_default.log`, `fit_c_s{1,2,3}.log`, `fit_nc_default.log`, `fit_*.pkl`.
- **Exact LOO:** `exact_loo.py`, `exact_loo.log`.
- **Plot experiments:** `plots12.py`, `t_loo.py`, `t_khat*.py`, `t_looint.py`, `p_*.png`,
  `t_*.png`.
- **Executed drafts:** `exec_draft.ipynb`, `exec_draft2.ipynb`, `*_dump.txt`, `draft*_imgs/`,
  `final_imgs/`, `nbconvert_*.log`.
- **Pre-revision dump:** `pre_solved_dump.txt`; Bambi source: `bambi/src/`.
