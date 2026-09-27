# Fresh-eyes review: notebook 12 — Robust likelihoods and PSIS-LOO

Reviewer: independent agent (Step 3b of `sleep/REVISION_PLAYBOOK.md`). I did not write this
notebook. A previous attempt at this review failed on an infrastructure error and left no
output, so this review starts from scratch.

**Inputs read in full:**
- `AGENTS.md` and the playbook, especially §3.1 (naming), §3.5 (NB12 introduces the LOO tools
  with `given-answer` questions) and §3.10 (summarize, don't preview).
- `01_plan.md`, `02_implementation_notes.md` (all 17 deviations) and `03_execution_log.md`.
- Both NB12 notebooks, cell by cell, with every executed output. I also viewed all eight
  figures: the trace plot, both LOO-interval panel grids, both LOO-PIT plots, both Pareto-$k$
  plots and the comparison plot.
- NB04 and NB05 solved (model code, priors, sampling settings and committed posterior
  summaries), NB03 solved (the ν = 7 prior 1.2 cites), and NB11's `04_review.md` as the template.
- The pre-revision NB12 (`git show e72c461^:sleep/solved/12_...`), to check deviation 2.
- The `arviz-diagnostics` skill's `references/model_evaluation.md` (LOO, Pareto $k$ and
  comparison guidance).

**Independent checks** (`scratchpad/review12/`, pinned venv `scratchpad/nbenv`):
- **The notebook's own code.** Every script `exec`s the notebook's own data and model cells.
  The only change is a local copy of the CSV, which I confirmed is byte-identical to `DATA_URL`.
- **Same-seed re-execution.** I ran `jupyter nbconvert --execute` on a scratch copy of the
  committed solved notebook (exit 0, 0 errors). **It is not bit-identical to the committed
  output**, unlike the orchestrator's Step 3a run: every sampled number differs at the Monte
  Carlo level.
  - Sampling is deterministic *within* this session. The same model and seed gave identical
    draws four times, with `cores` 1 and 2.
  - So the difference is host- or compilation-specific: the committed outputs are one
    realization, and a Colab run will be another. That makes this re-run a free "another
    machine" test of which prose claims are robust (finding 1).
- **Nine further realizations.** I ran the notebook's model code with seeds 20260924 (on this
  host) and 11–18: 36 fits in all, 0 divergences. For each I recorded every Pareto $k$ above
  0.7, the default and `reference=` comparisons, ν, `sd_y` and the LOO-PIT middle-half share.
- **Exact LOO.** I refitted `gaussian_slope` and `student_t_slope` without each of the three
  unusual days and computed the exact $\log p(y_i \mid y_{-i})$.
- **Library sources and docstrings (arviz-stats 1.3.2, arviz-plots 1.3.1).** I read
  `azs.loo`'s `Returns` section and the `ELPDData` attributes, `azs.compare`'s column
  descriptions, `plot_loo_interval` (the `ci_kind` handling), `plot_loo_pit`/`plot_ecdf_pit`
  (the $p$/α label and the highlight rule), `plot_compare` (the error bars) and `plot_khat` (the
  x-label default).
- **Mechanism checks for 4.11.** Residual structure per model, a decomposition of each ELPD
  difference into the three unusual days versus the other 141, and participant-clustered
  standard errors of the paired differences.
- **Priors.** The Gamma(2, 0.1) probabilities with scipy, and a spot-check of the saved Bambi
  0.21.0 source (`families.py` `"t"` → `"nu": "Gamma"`; `distributions.py` →
  `{"alpha": 2, "beta": 0.1}`). `bioassay/bioassay.ipynb` pins `bambi==0.21.0`.

**Verdict: ready to commit after small, markdown-only fixes. Nothing is blocking.**
- **The `b1`/`mu_b1` rename is complete and consistent in both files.** Details below.
- **The statistics are right.** The priors are exactly NB4/05's, and the `sd_y` correction from
  scale 25 to 50 is right. The Student-t parameterization and the Bambi citation are correct.
  NB12's two Gaussian models reproduce NB4's and NB5's committed posteriors.
- **Every column 4.1 and 4.6 describe matches arviz-stats 1.3.2**, and so does every visual
  feature 2.3, 3.1 and 4.4 describe.
- **The comparison's conclusions are very stable.** Across the committed run and my 9
  realizations, `student_t_slope` always wins, with all the stacking weight. `gaussian_slope` is
  always 37–39 behind (`dse` 12.5–13), and each single change is always < 2 `dse`, with
  `p_better` 0.94–0.96. ν is always ≈ 6.3 and ≈ 2.6. The implementer's other 3 seeds report
  ELPDs within 1.4 of these, so they are consistent.
- **4.11's interaction mechanism holds up**, and my residual and ELPD-decomposition checks
  support it quantitatively (finding 5 only tightens its wording).
- **The one claim that does not survive other runs is about the Student-t models' Pareto
  $k$** (finding 1). 4.5's answer says "Both Student-t models stay below about 0.55", and 5.3
  says "Under a Student-t likelihood, no observation was influential enough to be flagged".
  - In my same-seed re-execution, `student_t_intercept` flagged participant 332's day 4 (k =
    0.71), and it did so in 2 of my 9 runs (0.71, 0.90).
  - `student_t_slope`'s largest $k$ was 0.54–0.68 in my runs. The committed 0.49 is the lowest
    of all 13.
  - 4.5's question text hedges only the Gaussian models, so a Colab student can see the
    notebook's own lesson contradicted by their output.
- **I recommend findings 1–5.** Finding 1 is the one I would not skip. Findings 6–8 are minor,
  and T1–T6 are trivial.
- **No re-execution is needed** for findings 1–6 and 8, which are markdown-only. Finding 7
  touches a code cell and is optional. **If anything is re-executed, recheck every quoted
  number** (the claims table in `02_implementation_notes.md`), because a re-run on the current
  host produces a new realization, not the committed one.
- **Mirror edits to the self-work file.** Findings 1 (question part), 2, 6, 7 and T1 touch
  `exercise-question`, `given-answer` or `given` cells. Mirror them by re-running
  `derive_and_verify_nb12.py`.

**Cell references** use `[index]` in the 74-cell notebook, the question number and the cell
id. Ids are identical in both files.

---

## The `b1`/`mu_b1` rename (the orchestrator's specific request)

**Verified complete and consistent.** I grepped every cell of both files for `b1`, `mu_b1`,
`sd_b1`, `b_1` and `\mu_{b1}`:

- **[14] `build_model`.**
  - `varying_slope=False`: `b1 = pm.Normal("b1", mu=mu_mu_b1, sigma=sd_mu_b1)` and
    `mu_y = b0[pidx] + b1 * days`.
  - `varying_slope=True`: `mu_b1`, `sd_b1` and `b1` with `dims="participant"`, and
    `b1[pidx] * days`.
  - The committed NUTS lines confirm it: `[mu_b0, sd_b0, b0, b1, sd_y]` for the shared-slope
    fits and `[..., mu_b1, sd_b1, b1, ...]` for the varying-slope fits.
- **[9] 1.1.** The math writes $b_1$ for the shared slope and $b_{1,s} \sim
  \operatorname{Normal}(\mu_{b1}, sd_{b1})$ for the varying slopes. The prose: "As in Notebook 4,
  the shared slope is `b1` … As in Notebook 5, the varying slopes are `b1` with one value per
  participant, and their population average is `mu_b1`." This is correct.
- **[15]/[16] 1.5.** The question asks which varying-slope parameter the shared `b1`
  corresponds to, and the answer says `mu_b1`. This is correct and nicely motivated: the models
  coincide at `sd_b1` = 0, and the shared `b1` also has exactly `mu_b1`'s prior, N(0, 20), so the
  nesting is exact.
- **[20] 1.7.** The summaries select the variables whose only dimensions are `chain` and
  `draw`. The committed tables show `b1` for `gaussian_intercept` and `student_t_intercept`, and
  `mu_b1`/`sd_b1` for the other two.
- **[22] 1.8.** The trace plot is for `student_t_slope`, so `mu_b1` is correct there.
- **[70]/[71] 5.2.** The question names both, and the answer explains the two names ("every
  participant's slope" vs "the center of the distribution of participants' slopes").
- **Nowhere else.** No other cell mentions either name. Neither a stray `mu_b1` for a
  shared-slope model nor a stray `b1` meaning the population mean remains.
- **Constant naming (non-issue).** NB4 stored its shared slope's prior constants as
  `mu_b1 = 0` and `sd_b1 = 20` (Python constants). NB12 reuses NB5's `mu_mu_b1`/`sd_mu_b1` for
  the shared `b1`, and the code comment says so ("with the prior of mu_b1"). This follows
  playbook §3.2 and is unavoidable in a single factory where `mu_b1` is also an RV name.
- **Precedent confirmed.** NB4's cell 70 is `b1 = pm.Normal("b1", mu=mu_b1, sigma=sd_b1)`, a
  bare `b1` for the population-only slope, exactly as the orchestrator found.

---

## Statistical correctness (brief item 1)

- **Priors: identical to NB4/05.**
  - NB5's cell has `mu_mu_b0 = 250`, `sd_mu_b0 = 100`, `sd_sd_b0 = 25`, `mu_mu_b1 = 0`,
    `sd_mu_b1 = 20`, `sd_sd_b1 = 10` and `mu_sd_y = 50`. NB4 has the same values for its
    intercepts, its shared `b1` (0, 20) and `sd_y` (50). Every `Exponential` uses `scale=`.
  - Both use the centered `b0` (and, in NB5, `b1`).
  - NB12's constants match exactly.
- **The `sd_y` correction (deviation 2) is right.** The pre-revision code had
  `sigma = pm.Exponential("sigma", lam=0.04)` (scale 25) and claimed NB4/05's priors. NB4 cell 76
  and NB5 both have `mu_sd_y = 50`. The pre-revision's other `lam`s (0.04 and 0.10) did match
  `sd_sd_b0 = 25` and `sd_sd_b1 = 10`.
- **The two Gaussian models are NB4's and NB5's models.**
  - The sampling settings match: `draws=1000, tune=1500, chains=4`, no `target_accept`.
  - The committed posteriors agree to Monte Carlo precision:

    | | NB4 | NB12 `gaussian_intercept` |
    |---|---|---|
    | `b1` | 11.42 [9.53, 13.12] | 11.42 [9.55, 13.22] |
    | `sd_y` | 30.49 | 30.48 |

    | | NB5 | NB12 `gaussian_slope` |
    |---|---|---|
    | `mu_b1` | 11.30 [8.07, 14.62] | 11.29 [8.10, 14.55] |
    | `sd_y` | 25.76 | 25.71 |

  - 1.1's table labels ("Notebook 4's model", "Notebook 5's model") are therefore literally
    true.
- **The Student-t parameterization is correct.** `pm.StudentT("y", nu=nu, mu=mu_y,
  sigma=sd_y)` uses PyMC's `(nu, mu, sigma)` form, where `sigma` is the scale.
- **The Bambi claim is correct.**
  - Bambi 0.21.0's `"t"` family has `"default_priors": {"sigma": "HalfNormal", "nu": "Gamma"}`,
    and its Gamma default is `{"alpha": 2, "beta": 0.1}`.
  - PyMC's `beta` is a rate, so 1.3's "shape 2 and rate 0.1" is right.
  - Only ν's prior is Bambi's (Bambi's σ default is HalfNormal), and 1.3 claims no more.
- **1.3's numbers are correct:** mean 20; P(ν < 5) = 9.0%, P(ν > 30) = 19.9%, P(ν < 2) = 1.75%.
- **1.3's omission of a prior predictive check is stated honestly** (deviation 12), and 1.3
  gives the reason. Acceptable.

## LOO / PSIS-LOO content (brief item 2)

- **2.1 is correct and well pitched.**
  - An in-sample PPC flatters the model because each observation pulls the fit toward itself.
  - PSIS reweights the full-posterior draws, giving less weight to draws under which $y_i$ is
    probable. This is right, since the raw ratios are $1/p(y_i \mid \theta_s)$.
  - Pareto smoothing stabilizes the largest weights, and ArviZ warns when the approximation
    fails.
- **2.2 is slightly imprecise** about what is needed for what (finding 6).
- **4.1 matches `ELPDData`.**
  - `azs.loo` returns `ELPDData` with `.elpd`, `.se`, `.p`, `.pareto_k` and `.good_k`, as 4.1
    names them.
  - `good_k` = min(1 − 1/log₁₀ 4000, 0.7) = 0.7, as 4.3 says.
  - "An ELPD means little on its own: it is compared between models fitted to the same
    observations" is right.
  - One word is loose (T1).
- **4.6 matches the `azs.compare` docstring, column by column:**
  - `elpd_diff` is the model minus the reference (the best by default);
  - `dse` is the paired standard error;
  - `p_worse` comes from a normal approximation, and becomes `p_better` with `reference=`;
  - `diag_diff` flags `N < 100` or `|elpd_diff| < 4`, which 4.6's "difference is too small, or
    the data too few" paraphrases correctly;
  - `diag_elpd` is "K k̂ > threshold", with bias "favoring models with a large number of high
    Pareto k values";
  - `weight` is the stacking weight.
- **4.6's `plot_compare` sentence is right.** The source uses `se_key = "dse"` on the relative
  scale, and the committed bar for `gaussian_slope` spans about −51 to −25, which is ±12.85.
- **4.6's caution on stacking weights and ranks is correct.**
- **4.6's `dse` is reported as "the" uncertainty, with no caveat** that these data are
  clustered by participant (finding 2).
- **5.1 is correct and neither over- nor underclaimed.** Leave-one-row-out keeps the
  participant's other seven rows, so this is not new-participant generalization. Leaving out
  day 4 while keeping days 5–7 is interpolation, not forecasting. Two small precision points are
  in T2.
- **5.2 and 5.3's "a rank or a stacking weight is not proof"** are appropriate.
- **4.3's claim that high-$k$ estimates "tend to be too favorable"** matches the compare
  docstring and the arviz-diagnostics skill. My exact refits confirm it:

  | `gaussian_slope` | $k$ (my run) | PSIS $\text{elpd}_i$ | exact | PSIS − exact |
  |---|---|---|---|---|
  | 332 day 4 | 0.97 | −20.42 | −21.06 | +0.65 |
  | 332 day 7 | 0.83 | −13.31 | −14.03 | +0.72 |
  | 308 day 5 | 0.78 | −14.68 | −15.07 | +0.39 |
  | Sum | | | | **+1.75** |

  - That is < 2 in total, which confirms 4.8's question text.
  - `student_t_slope` on the same three days: PSIS − exact is −0.03 to 0.00, even at k = 0.59.
- **A native alternative the notebook does not mention (optional, not recommended to add).**
  arviz-stats 1.3.2 supports `azs.loo(..., moment_match=True, model=model)` for PyMC models, as
  a way to handle high $k$ without refitting. The notebook only *describes* exact refits in
  prose and hand-codes nothing, so AGENTS.md's "prefer native" rule is not engaged. The skill
  also notes that moment matching "need not fix high k". Adding it would be new sophistication
  in an already full notebook.

## Pareto-$k$ honesty (brief item 3)

- **For the Gaussian models, the prose is honest and appropriately hedged.**
  - 4.3 ends with "a value near 0.7 can fall on the other side of the threshold in another run".
  - 4.5's question quotes test-run ranges, and 4.5's answer calls `gaussian_intercept`'s 0.64
    "borderline".
  - My runs confirm the pattern: `gaussian_slope`'s largest $k$ was 0.88–1.25, with 3–5
    observations flagged and **always** including 332 days 4 and 7 and 308 day 5.
  - `gaussian_intercept`'s largest $k$ was 0.66–0.84, above 0.7 in 6 of my 9 runs (8 of 13
    with the implementer's). "About 0.65 to 0.8" is slightly narrow (finding 1).
- **For the Student-t models, the prose overstates the committed run's cleanliness**
  (finding 1).
- **4.8's conclusion is robust.** The flags cannot change the ranking: the gap was 37.2–39.2 in
  every run, and the PSIS error is < 2 and optimistic.

## The 4.9–4.11 interaction claim (brief item 4)

**The arithmetic in 4.10 is right, and it is stable across the committed run and my 9
realizations:**
- Gaussian → Student-t: +8.0 to 9.1 (`dse` ≈ 5.3) with a shared slope, against +37 to 39
  (≈ 12.8) with varying slopes.
- Shared → varying slopes: +15.8 to 16.7 (≈ 9.5) under the Gaussian, against +45.2 to 46.3
  (≈ 8.6) under the Student-t.
- The interaction contrast is ≈ 29.8. In my run it was 28.6 with a paired SE of 8.7 (z ≈ 3.3),
  or 11.8 (z ≈ 2.4) clustered by participant. "Far more than 8 + 16" is supported.

**The mechanism in 4.11 is sound, and I checked it three ways (my realization):**
- **Residual structure.** A per-participant linear day trend explains **38%** of the
  within-participant residual variance in both shared-slope models, against **3–4%** in the
  varying-slope models. Residual excess kurtosis is about 3.4–4.0 with a shared slope and
  10–13 with varying slopes.
  - So a shared slope leaves broad, systematic misfit, and varying slopes leave small scatter
    plus a few outliers.
  - That is exactly 4.11's first paragraph. It is also why ν is ≈ 6.3 vs ≈ 2.6 in every run.
- **ELPD decomposition into the three unusual days vs the other 141 observations:**

  | Difference | Total | 3 unusual days | Other 141 |
  |---|---|---|---|
  | Student-t − Gaussian, shared slope | +9.0 | +6.7 | +2.3 |
  | Student-t − Gaussian, varying slopes | +37.6 | +18.0 | +19.6 |
  | varying − shared, Gaussian | +17.3 | **−12.0** | +29.4 |
  | varying − shared, Student-t | +45.9 | −0.8 | +46.7 |

  - With a shared slope, heavy tails help almost only on the unusual days.
  - Under a Gaussian, varying slopes shrink `sd_y` (30.5 → 25.7), which makes the three
    unusual days 12 units *more* surprising. The Student-t absorbs them (−0.8), and its scale can
    fall much further (22.9 → 12.2).
  - This is 4.11's second paragraph, made concrete.
- **`sd_y` across models** (visible in 1.7): the Gaussian's falls 16% with varying slopes, and
  the Student-t's scale falls 47%.

**Epistemic confidence is slightly too categorical.**
- "Heavy tails cannot describe such a systematic mismatch" is too strong. `student_t_intercept`
  does gain 9, mostly on the unusual days.
- The second paragraph asserts, without evidence, a point that the notebook's own `sd_y`
  numbers would demonstrate. Finding 5 fixes both in two sentences.

## Conventions (brief item 5)

- **HDI and point estimate.**
  - Summaries use `ci_prob=0.90, ci_kind="hdi"`. The LOO intervals use `point_estimate="mean"`
    and 50%/90% equal-tailed intervals.
  - The ETI is a real library limitation, not a choice. `plot_loo_interval` in arviz-plots
    1.3.1 validates `ci_kind` and then always computes
    `probs=[(1-p)/2, (1+p)/2]` quantiles (source lines 149 and 192–209).
  - 2.3 says so explicitly. This satisfies AGENTS.md's "unless … a substantive reason".
  - "median" appears only in 3.1's LOO-PIT definition, where it is correct.
- **Tags.**
  - 5 `section`, 24 `given`, 19 `exercise-question` each followed immediately by exactly one
    `solution` (15 markdown, 4 code), and 7 `exercise-question` + `given-answer`. No cell is
    untagged.
  - The `given-answer` set (1.3, 2.1, 2.2, 3.1, 4.1, 4.3, 4.6) is exactly the new explanatory
    material, as playbook §3.5 prescribes for NB12.
  - Students compute `loos` and both comparisons, and write every verdict. The split serves the
    teaching goal.
- **Criteria before checks.** 1.9 restates NB1's criteria. 3.1 says what calibration looks
  like before 3.2's plot, 4.3 explains $k$ before 4.4, and 4.6 explains the table before 4.7.
- **Closing (5.3).**
  - Its bullets cover sections 1–5, not just section 4.
  - Its last two sentences are factual and retrospective: "This notebook ends the
    sleep-deprivation sequence. To the posterior predictive checks used throughout, it added…".
  - "next notebook", "later notebook" and "upcoming" do not appear, and nothing frames the end
    as a lead-in.
- **Headings.** `##` sections are short noun phrases with no question marks. `###` sub-headings
  are questions or imperative tasks (with a period), matching NB5's style exactly. `## Setup`,
  `## Data` and `### Plotting helper` are correct.
- **Other naming.**
  - `mu_b0`/`sd_b0`/`b0[participant]` are used throughout, and `sd_y` is population-only.
  - `nu` has no log link, which is correct: `pm.Gamma` is already positive, and this is not the
    NB09 pattern.
  - `mu_y` is the expected value, with no `mean_rt` (playbook §3.1's NB12 note).
  - `alpha_nu`/`beta_nu` for the Gamma constants follow the `<hyper>_<param>` scheme sensibly.
- **Forbidden strings.** None of `print(model`, `lam=`, `kind="kde"`, `plot_population`,
  `population_mu`, `_z"`, `\(` or `\[` appears.
- **Graphical grammar.**
  - The two LOO-interval grids are identical in layout, with shared axes. Days stay a
    continuous numeric x-axis, and the mean tick uses `plot_participants`' C1 mean color.
  - The two LOO-PIT plots share y-limits.
  - The two Pareto-$k$ plots do not share y-limits and use the generic "Data Point" label
    (finding 7).

## Self-work / solved consistency (brief item 7)

Verified by my own script:
- 74 cells in each file, with identical ids, types, tags and order.
- **Exactly 20 cells differ:**
  - the 19 `solution` cells, each exactly `- answer here` (markdown) or `# answer here` (code);
  - cell 0, identical after the URL swap `sleep/solved/12_` → `sleep/12_`.
- The self-work file has no outputs, null execution counts, and no `metadata.execution` or
  `metadata.widgets`.
- Both files pass `nbformat.validate` and end with a newline.
- The solved file's execution counts run 1–16 without gaps.

**Self-work dependency (non-issue).** The given 4.4 cell uses `loos` from the 4.2 solution. That
is intended: 4.2 fixes the name (`loos`), the keys (model names) and `pointwise=True`, which 4.4
needs. No other `given` cell depends on a solution cell.

---

## Findings (most severe first)

### 1. Moderate (a qualitative claim that other runs contradict): the Student-t models' Pareto $k$ is not reliably "below about 0.55", and a Student-t model sometimes flags an observation

**Cells:**
- [54] 4.5 question (`5d25839f`), `exercise-question`: mirror the edit;
- [55] 4.5 solution (`6e36aa97`);
- [73] 5.3 solution (`ae99ee22`).

**What the notebook says.**
- 4.5's answer: "Both Student-t models stay below about 0.55 for every observation."
- 5.3: "Under a Student-t likelihood, no observation was influential enough to be flagged."
- 4.5's question text quotes test-run ranges for the two Gaussian models only.

**What other realizations show.** The table combines the implementer's 4 centered runs, which
include the committed one, with my 9:

| Model | Largest $k$ range | Runs with $k$ > 0.7 |
|---|---|---|
| `gaussian_slope` | 0.82–1.25 | 13 / 13 |
| `gaussian_intercept` | 0.645–0.84 | 8 / 13 |
| `student_t_intercept` | 0.42–0.90 | **2 / 13** (332 day 4: 0.71 and 0.90) |
| `student_t_slope` | 0.485–0.68 | 0 / 13 |

- One of the two flagged `student_t_intercept` runs is my **same-seed** re-execution of the
  committed notebook, on this session's host.
- `student_t_slope`'s committed 0.49 is the lowest of all 13 runs. Its usual range is 0.54–0.68.

**Why it matters.**
- The playbook asks that numbers match the committed output, and they do. But 4.5's question
  hedge exists precisely so that a Colab student whose run differs reads their own output
  correctly, and it omits the Student-t models.
- A student whose `student_t_intercept` flags 332's day 4 (about 1 in 6 or 7 runs) sees 4.5's
  answer and 5.3's summary contradicted, on the notebook's central Pareto-$k$ lesson.
- The flagged case has a clean explanation the notebook already contains: with a shared slope,
  ν is ≈ 6, so the tails are only moderately heavy (4.11).

**Fix:**
- (a) Replace the last sentence of the 4.5 question with:
  > In test runs of this notebook with other random seeds, the largest $k$ of `gaussian_slope`
  > ranged from about 0.8 to 1.3, that of `gaussian_intercept` from about 0.65 to 0.85, and
  > those of the Student-t models from about 0.4 to 0.7, except that in two of thirteen runs
  > participant 332's day 4 exceeded 0.7 under `student_t_intercept`.
- (b) In the 4.5 answer, replace "Both Student-t models stay below about 0.55 for every
  observation." with:
  > Both Student-t models stay below about 0.55 for every observation in this run. In test runs,
  > `student_t_intercept`, whose tails are only moderately heavy (`nu` about 6), occasionally
  > flagged participant 332's day 4, but never as many observations, or as far above 0.7, as the
  > Gaussian models.
- (c) In 5.3's **Pareto $k$** bullet, replace "Under a Student-t likelihood, no observation was
  influential enough to be flagged." with:
  > Under a Student-t likelihood, the same days were far less influential: none was flagged in
  > this run.

### 2. Minor–moderate (a missing standard caveat): `dse` treats the 144 observations as independent, but they are 18 participants' repeated measures

**Cells:**
- [56] 4.6 (`b4f735f2`), `exercise-question` + `given-answer`: mirror the edit;
- optionally [60] 4.8 solution (`f8f150f2`).

**The problem.**
- The arviz-diagnostics skill (`model_evaluation.md`) says normal intervals for ELPD
  differences have limitations, and that "clustered or serial outcomes need particular care".
  This dataset is both.
- The notebook judges every difference "against its `dse`" (4.6), calls 38/12.85 "about three
  standard errors" and `p_worse` "essentially 1" (4.8), and reads 4.10's single changes as
  "less than two standard errors".

**What a participant-clustered SE gives** (my realization; SE of the sum of per-participant
differences, 18 clusters):

| Comparison | Difference | `dse` (iid) | z | Clustered SE | z |
|---|---|---|---|---|---|
| `student_t_slope` − `gaussian_slope` | 37.6 | 12.5 | 3.0 | 16.5 | 2.3 |
| `student_t_slope` − `student_t_intercept` | 45.9 | 8.6 | 5.3 | 15.7 | 2.9 |
| `student_t_intercept` − `gaussian_intercept` | 9.0 | 5.4 | 1.7 | 8.3 | 1.1 |
| `gaussian_slope` − `gaussian_intercept` | 17.3 | 9.4 | 1.9 | 11.5 | 1.5 |
| interaction contrast | 28.6 | 8.7 | 3.3 | 11.8 | 2.4 |

- **Every conclusion survives.** The winner is still clear, and the single changes become even
  more modest, which *reinforces* 4.10's point.
- But `dse` is systematically optimistic here.
- Participant 332 alone contributes 13.6 of the 37.6 by which `student_t_slope` beats
  `gaussian_slope`.
- 18 clusters is itself a small number, so I would not ask students to compute a clustered SE.
  A one-sentence caveat is the right size.

**Fix:** append to the `dse` bullet of 4.6:
> It treats the 144 observations as independent; observations of the same participant are not,
> so the real uncertainty of a difference is somewhat larger than `dse`.

Optionally, in 4.8, change "the difference is about three standard errors, and `p_worse` is
essentially 1" to:
> the difference is about three standard errors (somewhat fewer if we allowed for observations
> of the same participant being related, Question 4.6), and `p_worse` is essentially 1

### 3. Minor (accuracy): 1.2 ties "`sd_y` is a scale, not a standard deviation" to ν ≤ 2 only

**Cell:** [11] 1.2 solution (`ef029275`).

**The problem.**
- 1.2 says: "For $\nu \le 2$, the distribution does not even have a finite standard deviation,
  so in the Student-t models $sd_y$ is a scale rather than a standard deviation."
- The "so" suggests that for ν > 2, `sd_y` *is* the SD. It never is. The SD is
  $sd_y\sqrt{\nu/(\nu-2)}$ for ν > 2.

**Why it matters.**
- At ν ≈ 2.6, the implied SD is about twice `sd_y`, and 19.5% of `student_t_slope`'s posterior
  has ν < 2.
- 3.5 then compares the Gaussian's `sd_y` (26 ms) with the Student-t's (12 ms). A student who
  read 1.2 as "a scale only when ν ≤ 2" may conclude the Student-t says the scatter is half as
  large.
- 3.5's own framing ("a smaller scale with much heavier tails") is right. 1.2 just needs to set
  it up correctly.

**Fix:** replace the last sentence of 1.2's first paragraph with:
> In the Student-t models, $sd_y$ is therefore a scale, not a standard deviation: for $\nu > 2$
> the standard deviation is $sd_y\sqrt{\nu/(\nu-2)}$, larger than $sd_y$, and for $\nu \le 2$ it
> is infinite.

### 4. Minor (what a student will see and wonder about): 2.6 does not mention that *more* observations fall just outside the Student-t's narrower intervals

**Cell:** [36] 2.6 solution (`f3f0b7d6`).

**The problem.**
- In the committed Student-t grid, more points fall just outside their 90% bars than in the
  Gaussian grid. Examples are 308 day 0, 337 day 0, 351 day 5, 371 day 4 and 331 day 7.
  - The implementer counted 15/144 vs 10/144; I counted 15 vs 9 in my realization.
- 2.6 asks "Are the same observations far outside their intervals?", and its answer covers only
  the far misses and the narrower intervals.
- A student comparing the grids may read the extra near-misses as the Student-t predicting
  *worse*. That is backwards: about 10% outside is what calibrated 90% intervals should give,
  and the Gaussian's too-wide intervals miss too rarely, which 3.3 then shows.

**Fix:** append to 2.6's second paragraph:
> Because its intervals are narrower, a few more observations fall just outside them than in the
> Gaussian model. Calibrated 90% intervals should miss about 1 observation in 10, about 14 of 144;
> Section 3 checks this directly.

### 5. Minor (interpretive confidence): 4.11 is right, but "cannot" is too strong and its second paragraph asserts what the notebook's own `sd_y` values would show

**Cell:** [66] 4.11 solution (`158cd305`).

**The mechanism is sound** (see "The 4.9–4.11 interaction claim" above for my three checks).
Two wording issues:
- "Heavy tails cannot describe such a systematic mismatch." `student_t_intercept` does improve
  on the Gaussian by 8–9, mostly on the three unusual days. Heavy tails describe the mismatch
  *poorly*, not not at all.
- The "Conversely" paragraph gives no evidence. 1.7's summaries, which students already have,
  show it directly: varying slopes lower the Gaussian `sd_y` only from about 30 to 26 ms, but the
  Student-t scale from about 23 to 12 ms.

**Fix:**
- In the first paragraph, change "Heavy tails cannot describe such a systematic mismatch" to:
  > Heavy tails describe such a systematic mismatch poorly
- Replace the second paragraph with:
  > Conversely, under a Gaussian likelihood the unusual days keep `sd_y` large: varying slopes
  > lower it only from about 30 to 26 ms, while under the Student-t they lower the scale from
  > about 23 to 12 ms (Question 1.7). So the more accurate trajectories of the varying-slope
  > model sharpen the Gaussian's predictions much less than the Student-t's.

### 6. Minor (precision of a new concept): 2.2 says PSIS-LOO needs posterior predictive draws, but the ELPD needs only the log likelihood

**Cell:** [27] 2.2 (`5d29e93e`), `exercise-question` + `given-answer`: mirror the edit.

**The problem.**
- `azs.loo` uses only the `log_likelihood` group; `plot_loo_interval` and `azs.loo_pit` also
  read `posterior_predictive`.
- 2.2 lists both as what "PSIS-LOO needs". A student who later computes a LOO comparison
  elsewhere may think the posterior predictive draws are required.

**Fix:** replace the first sentence with:
> It needs the **pointwise log likelihood**, $\log p(y_i \mid \theta)$ for every observation $i$
> and every posterior draw $\theta$, which gives the weights; that is all the ELPD of Section 4
> needs. The leave-one-out predictive intervals and LOO-PIT of Sections 2 and 3 also need
> posterior predictive draws of $y$, which the same weights turn into leave-one-out predictions.

### 7. Minor, optional (AGENTS.md plotting rules): the Pareto-$k$ plots keep `plot_khat`'s generic "Data Point" x-label and have different y-ranges

**Cells:**
- [53] 4.4 code (`bb100fb0`), `given`: mirror the edit;
- optionally [52] 4.4 text (`f5ba8dfb`).

**The problem.**
- AGENTS.md says "do not expose … observation indices … or generic 'data point' labels", and
  asks for the same axes on directly comparable plots.
- The table under the plots already translates indices to participant and day, which mitigates
  the first point.
- `gaussian_slope`'s panel spans about 0 to 1.0, and `student_t_slope`'s about −0.1 to 0.7. The
  threshold line therefore sits at mid-height in one plot and at the top edge in the other.

**Fix (tested with the notebook's objects in the pinned venv; it runs).** `plot_khat`'s x-label
text is a `setdefault`, so it can be overridden:

```python
top = max(1.05, max(loos[name].pareto_k.max().item() for name in ["gaussian_slope", "student_t_slope"]) + 0.05)
for name in ["gaussian_slope", "student_t_slope"]:
    pc = azp.plot_khat(
        loos[name],
        hline_values=[0.7],
        visuals={"hlines": {}, "bin_text": {}, "xlabel": {"text": "Observation, by participant then day"}},
    )
    fig = pc.get_viz("figure")
    fig.suptitle(name)
    fig.axes[0].set_ylim(-0.15, top)
    plt.show()
```

**This changes a code cell**, so the notebook must be re-executed, and re-execution on the
current host gives a new realization (see "Independent checks"). **Every quoted number would
then need rechecking.** If that cost is not wanted now, skip this finding. The table already
covers the substance.

### 8. Minor (summary wording): 5.3's last bullet lists a finding under "What it does not establish" and drops 5.2's nuance

**Cell:** [73] 5.3 solution (`ae99ee22`).

**The problem.**
- "What it does not establish. … and the population-average effect of sleep deprivation, about
  11 ms/day, is the same in all four models."
- The effect being the same is a result, not something the comparison fails to establish.
- 5.2's second half is also missing: the shared-slope models are overconfident about that
  average (90% HDIs about 9.6–13.2 against 8.1–14.6).

**Fix:** replace the last sentence of that bullet with:
> A rank or a stacking weight is not proof that a model is true. The choice of model also does
> not change the scientific conclusion: the population-average effect of sleep deprivation is
> about 11 ms/day in all four models, although the shared-slope models are overconfident about
> it.

### Trivial (optional)

- **T1. [48] 4.1, `given-answer`: mirror the edit.** "Summed over all observations, it gives
  the model's expected log pointwise predictive density (ELPD)."
  - The sum of $\log p(y_i \mid y_{-i})$ *estimates* the ELPD for new data.
  - Suggested: "Summed over all observations, it estimates the model's …".
- **T2. [69] 5.1 solution.** Two small precision points:
  - "so their own intercept and slope are still estimated": the shared-slope models have no
    participant slope. Suggested: "so their own intercept (and, in the varying-slope models,
    their own slope) is still estimated".
  - "leaving out a whole participant changes the posterior too much for PSIS": "usually
    changes" is safer.
- **T3. [44] 3.4 solution.** "Yes" for a test that fails to reject.
  - Also, `plot_ecdf_pit` highlights points only when $p < α$
    (`highlight = (shapley_vals > gamma) & (p_values < alpha)`). "No points are highlighted" is
    therefore implied by $p$ = 0.44, not separate evidence.
  - Suggested opening, in keeping with 4.6's "a rank is not proof": "As far as this check can
    tell, yes."
- **T4. [13] 1.4, `given`: mirror the edit.** "As in Notebooks 4 and 5, `b0` and `b1` are
  written in the centered form: each participant's value is drawn directly…". In the
  shared-slope models, `b1` has no participant values. Suggested: "`b0`, and in the varying-slope
  models `b1`, are written in the centered form…".
- **T5. [71] 5.2 solution.** The answer opens "No." and then explains the two names before
  giving the evidence. Moving the naming sentence after the numbers would read more directly.
- **T6. [0] intro, `given`: mirror the edit, keeping the self-work badge URL. Optional
  capstone bridge.**
  - NB06–11 spent six notebooks on skewed likelihoods (lognormal, ex-Gaussian), and NB12 never
    mentions them.
  - A student finishing the course may wonder why it returns to Gaussian/Student-t.
  - One clause would orient them. For example, after the first sentence: "Notebooks 6–11
    changed the *shape* of the likelihood to describe the skew of reaction times; this notebook
    returns to Notebooks 4 and 5's models and changes only how heavy its tails are."
  - This is not required, since the notebook is standalone by design (plan). Do not add any
    comparison with those models.

---

## The questions in my brief: answers

- **`b1`/`mu_b1`.** The rename is complete and consistent in 1.1, 1.4, 1.5, 1.7, 1.8 and 5.2, in
  both files. No leftover in either direction. 5.2's two-names explanation is correct.
- **1. Statistical correctness.**
  - The priors are identical to NB4/05's. The `sd_y` scale correction from 25 to 50 is right,
    and verified against both notebooks and the pre-revision code.
  - The Student-t parameterization is correct. The Gamma(2, 0.1) Bambi default is confirmed,
    and so are its probabilities.
  - The Gaussian models reproduce NB4/NB5's committed posteriors.
- **2. LOO material.**
  - 2.1, 4.1, 4.3 and 4.6 are technically correct and match arviz-stats 1.3.2 and arviz-plots
    1.3.1: fields, columns, the `p_worse`/`p_better` switch, the `diag_*` meanings, `plot_compare`'s
    ±`dse` bars and `plot_loo_pit`'s $p$/α label.
  - 5.1's caution is stated at the right strength.
  - Gaps: the clustered-data caveat on `dse` (finding 2), and 2.2's "needs" (finding 6).
- **3. Pareto-$k$ honesty.**
  - It is honest and well hedged for the Gaussian models, and the high $k$ is diagnosed rather
    than hidden.
  - For the Student-t models, 4.5 and 5.3 generalize from the cleanest of 13 realizations
    (finding 1).
- **4. Interaction.**
  - It is real and stable: each change alone gives +8 and +16, both together +54, in every run.
  - The mechanism is supported by residual structure (38% vs 3–4% trend variance; kurtosis 3.5
    vs 10–13) and by an ELPD decomposition.
  - Slightly too categorical, and its second paragraph is ungrounded (finding 5).
- **5. Conventions.** All correct:
  - 90% HDI summaries, and ETI LOO intervals explained by a real library limitation;
  - the mean as point estimate;
  - tags, headings and naming;
  - a retrospective ending with a factual "ends the sequence" sentence and no forward framing.
  - Only the Pareto-$k$ plot's axis label and y-range fall short (finding 7, optional).
- **6. Solution-cell facts.** Every number matches the committed output (tables below). No
  arithmetic error.
  - The only claims that fail elsewhere are finding 1's Student-t $k$ generalizations.
  - 4.5's question range for `gaussian_intercept` should be widened slightly (finding 1a).
- **7. Self-work/solved.** Exactly as intended: 20 differing cells (19 placeholders + badge), no
  outputs or leftover metadata, and both files valid.
- **8. As a student, and as a capstone.**
  - **Narrative.** It reads well: what changes and why; fit and check; which days are hard to
    predict; calibration; scoring and comparing; what the comparison means.
  - **Recall is supplied in place.** Every earlier-notebook fact a question needs is restated:
    - NB1's criteria (1.9);
    - NB3's ν = 7 (1.2);
    - NB4/05's models and priors (1.1, 1.4);
    - the bioassay notebook's Bambi (1.3).

    None needs to be open.
  - **New terms are defined where they first appear:** LOO, PSIS, importance sampling, ELPD,
    `p`, Pareto $k$, LOO-PIT, Δ-ECDF, stacking.
  - **5.3 is a genuine retrospective of the whole notebook.** Model, hard days, calibration,
    $k$, comparison and scope are all covered, not just section 4.
  - **It works as a capstone.** It returns to the course's core models with the course's most
    general new check, and ends with the scientific conclusion unchanged (≈ 11 ms/day).
  - **Only NB06–11 go unacknowledged** (T6, optional).

## Numbers and figures checked against output

- **1.3.** Mean 20.0; P(ν < 5) = 0.0902, P(ν > 30) = 0.199, P(ν < 2) = 0.0175.
- **1.7/1.9.**
  - 0 divergences in all four models; largest R-hat 1.01 (`student_t_slope`); smallest bulk ESS
    1,505.37.
  - "About 1,500 or more" holds in the committed run, and my same-seed rerun's smallest was
    1,541.
- **1.8 trace figure (viewed).** All six parameters show overlapping chain densities and
  stationary, well-mixed traces, including ν (mode ≈ 2.3, right tail to about 8). This matches
  1.9.
- **2.4.**
  - Committed LOO means per the implementer: 307 / 368 / 413. Mine: 303 / 378 / 415.
  - "About 310 / 370 / 410" holds.
  - 308's day 0 (251 vs 90% band 259–357 in my run) and day 3 (415 vs 300–388) are outside
    their bands, as stated.
- **2.3/2.5 grids (viewed).**
  - The pink tick is the mean, the dark and light blue bars are the 50% and 90% intervals, and
    observations are black. This matches 2.3.
  - Days are a continuous axis, with shared axes and participant titles.
  - The far misses (332 days 4 and 7, 308 day 5) are visible in both grids.
- **2.6.**
  - Mean 90% width is 95 → 71 ms, and mean 50% width 39 → 24 ms.
  - For participants 309 and 335, the 50% widths go from about 39 to about 22.5 ms, the two
    largest relative shrinks (0.57–0.58). The margin is thin: most participants shrink to
    0.57–0.59. The example holds, but any of several participants would serve.
- **3.3 (viewed).**
  - $p$ = 0.00 (α = 0.01); the dip is about −0.12 near 0.28, and the peak about +0.11 near 0.75.
  - Highlighted points appear at about 0.01, 0.14, 0.17 and 1.0: "both ends and along the dip"
    is fair.
  - The middle-half share is 72% committed and 70–72% across my 9 runs, so "about 73%" holds.
- **3.4 (viewed).** $p$ = 0.44; the curve stays within ±0.055; nothing is highlighted.
- **3.5.** `sd_y` is 25.71 vs 12.17, and ν is 2.62 [1.51, 3.73]. ν was 2.58–2.64 in every run.
- **4.2/4.5/4.4 table.**
  - ELPDs −706.7 / −690.7 / −698.5 / −652.7; largest $k$ 0.64 / 0.97 / 0.54 / 0.49.
  - Flagged: 308 day 5 (0.75), 332 day 4 (0.97), 332 day 7 (0.97) and 371 day 7 (0.71), which is
    2.8%.
  - All match the committed output. (Robustness is covered in finding 1.)
- **4.4 plots (viewed).** The line at 0.7 is present, with "2.8%/97.2%" and "100.0%" labels.
  This matches 4.4's text (see finding 7 for axes).
- **4.7/4.8.**
  - The gap is −38.02 (12.85), so 38.02 / 12.85 = 2.96; `p_worse` 1.0, weight 1.0.
  - "Four estimates wrong by about 10 each" is right: 38/4 = 9.5.
- **4.9/4.10.**
  - Single changes: +8.22 (5.34, 0.94) and +16.00 (9.71, 0.95), each < 2 `dse`.
  - With the other change present: +38.02 (12.85) and +45.81 (8.71).
  - Both changes together: +54.02.
  - 4.10's table is correct.
- **4.11.** ν is 6.30 [2.00, 10.25] vs 2.62. "About 6, 90% HDI about 2–10" holds.
- **5.2.**
  - Means 11.42 / 11.29 / 11.55 / 11.55, and `sd_b1` 7.34 / 7.91.
  - HDIs: 9.55–13.22 and 8.10–14.55 for the Gaussian pair; 9.83–13.11 and 8.24–14.69 for the
    Student-t pair ("similarly").
- **Cross-references.** Every "Question N.M" reference resolves, and says what is cited.

## Notes for the orchestrator (not notebook findings)

- **`03_execution_log.md`'s "bit-identical" result** was true for that run. In this session,
  though, a same-seed re-execution of the committed notebook is not bit-identical: sampling is
  deterministic here, but it produces a different realization. The log needs no correction, but
  do not expect bit-identity when re-executing for any fix.
- **`sleep/solved/README.md`'s "Validation status"** still says notebooks 6–12 "are being
  revised". The implementer flagged this for the commit that closes the pass.
