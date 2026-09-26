# Implementation notes: notebook 09 — Ex-Gaussian distributional model

Author: implementation agent (Step 2 of `sleep/REVISION_PLAYBOOK.md`).

**Execution status.** The repository copy of the solved notebook is unexecuted: its outputs
are empty and its execution counts are null, which leaves the executed record to Step 3a.
The numbers and plot readings in the answers are nevertheless real output, not
approximations. I checked them in two ways, both in the pinned venv (`scratchpad/nbenv`:
`pymc==6.3.2`, `arviz-*` 1.3.x):

1. `scratchpad/nb09/lit09.py` runs the solved notebook's **literal code cells** headless,
   with `DATA_URL` pointed at the local CSV. It exits 0.
2. A scratch **copy** of the solved notebook (`scratchpad/nb09/exec_copy.ipynb`) was
   executed with `jupyter nbconvert --execute`, the `nbenv` kernel and the real `DATA_URL`:
   - exit 0, 0 cell errors, sequential execution counts 1–24;
   - every summary value identical to run 1;
   - the prior-predictive figure identical as well.

   The repository file was not touched by this run.

With `RANDOM_SEED`, the posterior was bit-identical across 5 separate processes in this
environment (3 seed-study runs, the literal run and the nbconvert run). This differs from
NB08, which saw process-to-process variation. Step 3a should therefore see the same
numbers, apart from the caveat in decision 3.

## What was written

- `sleep/solved/09_exgaussian_distributional.ipynb`: 103 cells (79 markdown, 24 code), every
  cell tagged:
  - 6 `section`;
  - 33 `exercise-question`, each followed immediately by exactly one `solution`;
  - 1 `exercise-question`+`given-answer` (5.6, the ECDF criteria, the NB06–08 pattern);
  - 30 `given` (15 markdown, 15 code);
  - 33 `solution` (24 markdown, 9 code).

  The builder is `scratchpad/nb09/build_nb09.py`, which follows NB08's builder:
  - cell ids are stable hashes of per-cell keys;
  - top-level metadata is the pre-revision file's, minus `widgets`;
  - JSON is written with `indent=1, ensure_ascii=False, sort_keys=True` plus a trailing
    newline. `sort_keys` matches nbformat's writer, which avoids key-order churn when
    Step 3a re-saves the file.
- `sleep/09_exgaussian_distributional.ipynb` was derived mechanically by
  `scratchpad/nb09/derive_and_verify_nb09.py`, NB08's script with only the file names
  changed:
  - the 33 `solution` cells become `- answer here` / `# answer here`;
  - the badge points to `sleep/09_...`;
  - outputs are cleared and execution counts are null;
  - there is no `metadata.execution` and no `metadata.widgets`.
- **Verified by script** (`derive_and_verify_nb09.py`, `check_nb09.py`):
  - 34 differing cells (33 solution + 1 badge), with every other cell byte-identical;
  - identical ids, types and tags in the two files;
  - both files pass `nbformat.validate`, and ids are unique;
  - Q→A adjacency holds;
  - only `$`/`$$` math;
  - every in-notebook "Question N.M" reference resolves;
  - no `print(model)`, `lam=`, `_z`, `population_mu`, `plot_population`, `residual_scale`,
    `sigma_intercept`, `nu_intercept`, `compute_log_density`/`psense`, `kind="kde"`,
    "next notebook", or "Notebook 10/11/12" anywhere;
  - "Reaction" appears only in axis labels and `observed=sleep["Reaction"]`;
  - other notebooks cited: 1, 5, 8, "1–5", "5–8", "6–8".

### Section structure

| Section | Questions (Q = student answers, G = given) |
|---|---|
| Title/intro, Setup, Data, Plotting helper | G. NB08's setup, data and helper cells verbatim, including the panel-order sentence. The intro contrasts NB06–08's log transform with a skewed likelihood, with no forward pointer. |
| 1. Build the ex-Gaussian model | 1.1 model math + $y = g + e$ decomposition (G) · 1.2 **supplied density figure**, ν = 5/50/150 ms with dashed means (G code) · 1.3 what ν is · 1.4 why $\mathrm{E}[y] = \mu_y + \nu$ · 1.5 can y be negative (vs lognormal) · 1.6 **why no log link for $\mu_y$ (the plan's explicit contrast question)** · 1.7 supplied NB05 mean structure as a partial model (G code) · 1.8 what `b0`/`b1` mean now · 1.9 supplied residual-scale hierarchy + its ms elicitation (G md + G code) · 1.10 how it differs from NB08 (units; why `sd_log_sd_y` carries over) · 1.11 **why ν has no participant subscript** · 1.12 elicit the tail prior from ms · 1.13 add `log_nu`, `nu` (code) · 1.14 add `mean_rt`, `y` (code) · 1.15 graphviz (G) · 1.16 read the graph |
| 2. Check the prior implications | 2.1 criteria: NB1's, plus residual-scale and tail criteria (G) · 2.2 prior draws (G) · 2.3 `plot_dist` of `mu_log_sd_y`, `sd_log_sd_y`, `nu` (code) · 2.4 are they reasonable (ms translation; HDI vs elicited range; mean vs median) · 2.5 prior predictive plot (G) · 2.6 NB1 criteria verdict vs NB05 and NB06–08 · 2.7 **participant 333's zigzag** (cause traced individually) |
| 3. Fit and diagnose the model | 3.1 sample, `target_accept=0.99` (G) · 3.2 **why so high** (the hard-left-edge mechanism) · 3.3 population diagnostics + trace (G) · 3.4 verdict · 3.5 all-participant screen incl. `log_sd_y` + subset 308/337/372 (G) · 3.6 verdict |
| 4. Examine the fitted ex-Gaussian components | 4.1 `plot_dist` `mu_b1` (code) · 4.2 credible range in ms/day vs NB05, and why ms · 4.3 `plot_dist` `nu` (code) · 4.4 how long the tail is; prior→posterior; what the data do and do not pin down; `mu_b0` offset · 4.5 what a short tail means for shape; why it is short · 4.6 forest of `sd_y` (code) · 4.7 heterogeneity in ms, and total SD $\sqrt{sd_y^2+\nu^2}$ |
| 5. Predictive consequences | 5.1 `mean_rt` per participant (code) · 5.2 what the bands are; how `mu_y` would differ · 5.3 PPC (code) · 5.4 `mean_rt` → `y`; band widths constant vs NB08's widening · 5.5 participant-level verdict vs NB05's shared SD · 5.6 ECDF criteria (given-answer) · 5.7 ECDF (code) · 5.8 verdict; where the pooled skew comes from |
| 6. Summary | 6.1 retrospective only: likelihood, priors, sampling, fitted components, predictive checks. There is no reference to any later notebook. |

**Scaffolding follows the plan's mixed decision.**
- *Mean structure* (NB05) and *residual-scale hierarchy* (NB08's construct): supplied as
  `given` code, each with a short recap Q&A (1.8, 1.10) that makes the student notice
  what changed.
- *The ex-Gaussian likelihood and tail*: NB1/NB4-style. Conceptual questions 1.3–1.6,
  1.11 and 1.12, then two short `with model:` code tasks (1.13, 1.14).
- Following NB08 review finding 7, "store constants" and "add nodes" are merged into one
  task (1.13) instead of being split.
- Sampling, diagnostics code and the prior-predictive generation and plot are `given`.
- Posterior plots, the PPC code and every interpretation are `solution`.

## Decisions on the plan's open questions

### 1. Mean-structure values: verified to match, so no harmonization was needed

I checked the pre-revision NB09 code directly, not the plan's summary of it:

| Pre-revision NB09 | = | NB05 constant |
|---|---|---|
| `intercept ~ Normal(250, 100)` | = | `mu_mu_b0 = 250`, `sd_mu_b0 = 100` |
| `participant_intercept_sd ~ Exponential(lam=0.04)` | = scale 25 = | `sd_sd_b0 = 25` |
| `slope ~ Normal(0, 20)` | = | `mu_mu_b1 = 0`, `sd_mu_b1 = 20` |
| `participant_slope_sd ~ Exponential(lam=0.10)` | = scale 10 = | `sd_sd_b1 = 10` |

All four match. The only structural change from NB05's mean structure is that NB05's
`change_7` Deterministic is **dropped**, because no question in this notebook uses it
(playbook §3.6).

The fitted mean structure confirms the reuse. `mu_b1` is 11.26 [8.03, 14.61] ms/day,
against NB05's committed 11.30 [8.07, 14.62]. `mu_b0` is 259.9, against NB05's 267.9. The
≈8 ms offset is ν (7.4), exactly as 1.8 predicts: `mu_b0` is now the Gaussian location, not
the expected baseline. Q4.4 says this, using the notebook's own summary values.

One wrinkle: NB05's own 4.3 *answer* says "7.94–14.71", a stale number
(`_shared/known_issues`). NB09 4.2 compares only against NB05's summary interval, so it
does not repeat the stale figure.

### 2. Why ν has no participant hierarchy while `sd_y` does: decided, and tested empirically

**In-notebook (Q1.11).**
- Separating a tail from Gaussian scatter needs the *shape* of the residual distribution.
  Eight observations per participant, which already have to fit an intercept, a slope and
  an SD, cannot show that shape. The shared tail is informed by the asymmetry of all 144
  residuals.
- Sharing the tail is a modeling choice: participants may differ in how *variable* they
  are, but are assumed to share one tail.
- A per-participant ν would mostly echo its population distribution. It would compete with
  that participant's `b0` and `sd_y`, and would make sampling harder for little gain.

**Scratch evidence** (`fit09.py … pnu`: a full fourth hierarchy with `log_nu[participant]`,
`sd_log_nu ~ Exponential(scale=1/3)`, `target_accept=0.95`):
- `sd_log_nu` posterior median **0.236**, against a prior median of **0.231**. Its 5% and
  95% quantiles are 0.045 and 0.88, against 0.017 and 1.0 for the prior. The data carry
  essentially no information about between-participant tail differences.
- All 18 participant ν have means of 6.4–10.6 ms and near-identical 90% HDIs of about
  1–2 to 11–17 ms. This is complete pooling in all but name.
- Sampling broke down: **167 divergences**, R-hat up to 1.085 (`sd_log_nu`) and minimum
  participant tail ESS **50**.

`sd_y`, by contrast, is strongly identified per participant:
- the posterior means run from 5 to 58 ms;
- the 90% HDIs of 309 (1–10) and of 308/332 (31–68, 36–80) do not overlap;
- `sd_log_sd_y` is 0.76 [0.47, 1.03].

So the asymmetry is data-driven, not only a teaching simplification. **For the
orchestrator:** this is the right fixed template for NB10/11.

### 3. `target_accept`: default settings diverge, and 0.99 is needed

The sampler is kept centered throughout (playbook §3.4). Divergence counts with the full
NB09 model and `tune=1500`, `draws=1000`:

| Setting | Runs | Divergences |
|---|---|---|
| default (0.8), `RANDOM_SEED` | 2 processes | **14, 38** (not reproducible at the default) |
| 0.9, `RANDOM_SEED` | 1 | 4 |
| 0.95, `RANDOM_SEED` | 1 | 3 |
| 0.95, seeds 1–5 | 5 | 1, 10, 1, 4, 0 |
| non-centered `log_sd_y`, default | 1 | 18 (non-centering does not help) |
| **0.99, `RANDOM_SEED`** | **3 processes** | **0, 0, 0** (bit-identical) |
| 0.99, seeds 1–10 | 10 | 0 in 8 seeds; **1** in seeds 2 and 6 |

At 0.99: the step size is about 0.04–0.06 (against 0.18–0.27 at the default), the mean
tree depth is about 6.4, and a fit takes about 33 s here.

**Diagnosis** (`divloc09.py`, `divloc09b.py`, `edge09.py`). The divergences are **not** at
PyMC's `ExGaussian.logp` switch to a pure Normal when `nu < 0.05*sigma`: the minimum
ν/`sd_y` ratio at divergent draws is well above 0.05. They concentrate where a *steady*
participant's `sd_y` (309, 349, 352) is in its lowest 0–3%, well below 1 ms, so that
ν/`sd_y` is about 10–30.
- In that regime the ex-Gaussian approaches a shifted exponential, with a nearly hard
  lower edge at `mu_y`.
- Evidence: in the lowest 3% of `sd_y[309]` draws, 309's smallest residual `y − mu_y` is
  squeezed to [−0.05, 2.0] ms (10th–90th percentile), against [−3.5, 3.8] ms in typical
  draws.
- 22 of the 38 default-setting divergences fall in that 3% of draws (against about 3%
  of all draws — the fresh-eyes review's own localization check, `04_review.md`, found
  26/38 with a slightly different threshold and confirmed the enrichment is real, not
  an artifact of an uninformative baseline).
- This happens because the shared ~7 ms tail can explain much of a steady participant's
  scatter, so the likelihood for their `log_sd_y` is flat toward zero and the posterior
  reaches the hard-edge region.

This is Q3.2's mechanism. Its answer is phrased at the level of Q1.2's density figure: the
left edge becomes vertical, so moving `mu_y` down is penalized gradually and moving it up
past an observation is penalized abruptly, which creates sharp edges in `b0`/`b1`.

**Decision.** Keep the centered form with `target_accept=0.99` in the given sampling cell,
and explain it in Q3.2. This follows playbook §3.3: default divergences were confirmed
first, then a higher value was used and the need explained in a Q&A. Q3.2's answer also
states honestly that other seeds occasionally show a single divergence even at 0.99.

**Posterior stability.** Across all settings and seeds above, including the diverging
ones, the reported quantities are stable to about their MCSE:
- `mu_b1` 11.26–11.34;
- `nu` mean 7.36–7.52;
- `mu_log_sd_y` 2.78–2.79;
- `sd_log_sd_y` 0.75–0.77.

The rare divergences do not visibly bias the quantities students interpret.

**Alternatives considered and rejected:**
- Non-centering `log_sd_y`: 18 divergences at the default.
- Tightening `sd_sd_log_sd_y` to keep steady participants' `sd_y` away from zero:
  data-driven prior tuning, and it would worsen the existing prior–data conflict (decision
  5).
- Changing the location parameterization to `mean_rt = b0 + b1·days`: the edge still
  involves ν, and it would break §3.1's `mu_y`-as-location convention.

### 4. Prior-predictive plausibility: a genuinely skeptical look, with every feature traced

I read the plot with ArviZ's own HDI (the plot's computation), not by eye (`priorbands09.py`
and a direct `azs.hdi` recomputation).
- Baseline median edges: 50% [208, 363] and 90% [94, 526] ms.
- 93.8% of observations lie inside their own panel's 50% band.
- 90% lower edge below zero: 0/18 panels on day 4, 6/18 on day 5, 12/18 on day 6, 18/18
  on day 7. The last one only just: its maximum is −1 ms, hence the text's "reach zero or
  below".
- Verdict: "Broadly, with the same warning as Notebook 5". This is not a generous reading.
  The negative late-week predictions are real, and they are attributed rather than
  waved away.
- **Attribution of the negatives:** 90% of day-7 negative draws have a negative *location*
  `mu_y` (87% with `b1` < −20 ms/day, median −36); only 6% involve `sd_y` > 100 ms. So
  they come from NB05's mean-structure priors, not from the new likelihood priors, as the
  answer says.
- **The zigzag (2.7), traced individually (`spikes09.py`).** The only anomalous panel is
  participant 333 (row 2, panel 1). Its day means are 578, −173, 326, 650, 116, 65, 407
  and 731 ms. **All eight** days are dominated by **one** draw, #455:
  - `sd_log_sd_y` = 2.28, the largest of the 500 draws;
  - `mu_log_sd_y` = 4.17;
  - `sd_y[333]` = **145,388 ms**;
  - the residuals are +130, −243, +7, +175, −97, −121, +51 and +211 s;
  - `b1[333]` = −22.7 contributes only about −0.3 ms to the panel mean, and ν = 127 is
    negligible.

  This is new relative to NB08, whose spikes could only go up (lognormal); here the
  Gaussian part makes them go both ways. The other 17 panels' mean lines stay between 295
  and 351 ms.

### 5. A substantive finding the plan did not anticipate: the fitted tail is short, and its lower end is prior-driven

- Posterior ν = 7.44 [3.72, 10.98] ms, against a prior median of 50 and a 90% HDI of about
  9–127.
- Analytic prior P(ν < 11) ≈ 2%.
- So the posterior sits where the prior put only about 2% of its mass: a strong prior–data
  conflict, which the data resolve.
- **Wide-prior check** (`fit09.py … widenu`, `sd_log_nu = 2`): ν = 3.67, 90% HDI [0.07,
  6.84], P(ν < 1) = 13%. So the data bound the tail from **above** (≲ 10–12 ms) but
  cannot distinguish a few-millisecond tail from none; the base model's lower end (~4 ms)
  comes from the prior.
- Q4.4 says exactly this, arguing it from the density figure (ν → 0 is Gaussian) and from
  the posterior sitting in the prior's lower tail, not from the scratch run.
- **I did not change the tail prior after seeing this.** It is the plan's elicitation, kept
  as instructed. Changing it would be the data-driven tuning AGENTS.md warns against. The
  notebook reports the conflict instead: 4.4, 4.5 and the summary.
- Q4.5 offers a substantive reason. The observations are **session-average** reaction
  times (lme4's documented definition of `Reaction`: "Average reaction time (ms)").
  Averaging removes most single-response skew.
- The pooled right skew is still reproduced (5.8). Observed skewness is 0.44; replicated
  skewness has a median of 0.35 [0.04, 0.69], with P(rep ≥ obs) = 0.28. It comes mainly
  from the mean structure: the pooled skewness of the fitted `mean_rt` alone is about 0.30.
- `sd_log_sd_y`: the posterior is 0.76 [0.47, 1.03], against a prior HDI of [0, 0.80]. It
  is centered near the prior's upper end, as in NB08 but more strongly: prior
  P(> 0.47) = 0.24, posterior 0.97. 4.7 says so.

**For the orchestrator, planning NB10/11 (not stated in the notebook).** The wide-prior
fit's sampler was pathological: step size about 0.002, *every* chain hit the maximum tree
depth, and it took 287 s. There are two reasons:
- the likelihood is flat in `log_nu` as ν → 0;
- PyMC's `logp` switches to a pure Normal (zero gradient in ν) for `nu < 0.05*sigma`.

Naive or flat priors on `log_nu` will push the sampler into that region, which is likely
part of why the pre-revision "unscaled priors" failed (README, NB10 entry).

## Other decisions and deviations from the plan

- **Tail naming deviates from the plan's `mu_log_nu`-as-parameter.** The parameter is
  `log_nu`, with constants `mu_log_nu = np.log(50)` and `sd_log_nu = 0.75`, and
  `nu = pm.Deterministic("nu", pm.math.exp(log_nu))`. Reasons:
  - playbook §3.1: a population-only parameter carries the bare name (`b0`, as in NB1),
    while the `mu_` prefix denotes a *population center* of a participant-level
    distribution (`mu_b0`, `mu_log_sd_y`);
  - playbook §3.2: a prior's constants are `mu_<param>`/`sd_<param>`;
  - with the plan's naming, the constants would be `mu_mu_log_nu`/`sd_mu_log_nu`, which
    implies a hierarchy that does not exist;
  - `log_nu` → `nu` mirrors `log_sd_y` → `sd_y` exactly.

  **Orchestrator:** if accepted, record it in playbook §3.1 for NB10/11. If not, reverting
  is a mechanical rename in cells 1.13 and 1.16 and the graph reading.
- **Added a supplied density figure (1.2, `given`).** It shows three ex-Gaussians
  (σ = 30 ms; ν = 5, 50, 150 ms) via native `pm.logp(pm.ExGaussian.dist(...), rt)`, with
  dashed means. It is a device of the kind playbook §3.9 cites (NB3's density
  comparison). The ex-Gaussian is new, and 1.3, 1.4, 3.2, 4.4 and 4.5 all read from this
  figure. Verified values: modes 255, 278 and 294 ms; means 255, 300 and 400 ms.
  - **PyTensor pitfall found and guarded against.** With Python-int arguments
    (`mu=250, sigma=30`), PyTensor stores 30 as **int8**, so `sigma**2` in the ex-Gaussian
    logp overflows to −124 and the density is silently wrong: the ν = 5 curve reaches
    log-densities of about +35, i.e. densities of order 1e15, near 100 ms. Float literals are correct, and match SciPy `exponnorm` exactly.
  - The cell uses floats and a one-line comment explains why.
  - The model itself is unaffected, because its `mu`/`sigma`/`nu` are float tensors.
  - Worth knowing course-wide wherever a density is evaluated from int literals.
- **The residual-scale elicitation is supplied, not a student task** (1.9, `given`). This
  follows the plan: the construct is a recap. The student ms→log elicitation is the tail
  prior (1.12), and 1.10 makes students explain the unit contrast with NB08: center 3.4
  vs −2.5, while the `sd_log_sd_y` prior carries over *because* ratios are unit-free.
  - The code writes `mu_mu_log_sd_y = np.log(30)` and `mu_log_nu = np.log(50)`, so the
    millisecond origin of each prior stays visible (README: "priors chosen in
    milliseconds").
  - The sd elicitation range is stated as 95% between 11 and 80 ms (= e^{3.4±1}). The
    tail's is 11–220 ms (= e^{3.9±1.5}). I chose the 95% convention (NB1, NB08) over the
    pre-revision intro's 90% ranges.
- **Questions added beyond the plan's outline**, each tied to a rule or a real risk:
  - 1.5: negative support, which the PyMC-Labs likelihoods reference flags for ExGaussian;
  - 1.8: `b0`'s meaning shifts by ν, while `b1`'s does not;
  - 1.10: the NB08 unit contrast;
  - 2.7: the individually traced zigzag;
  - 3.2: `target_accept`;
  - 4.5: shape, and why the tail is short;
  - 5.2: `mean_rt` vs `mu_y`, which is AGENTS' mean-vs-predictive rule and closes 1.4 with
    the fitted ν;
  - 5.4: additive, constant-width bands vs NB08's widening bands.
- **No prior-sensitivity section**, as in NB08 and for the same reasons: README's psense
  list; not in the plan. The question that matters here, how far the data moved ν from
  its prior, is answered natively in 4.4.
- **Diagnostics include `nu` (a Deterministic) rather than `log_nu`** in the population
  summary and trace. Rank-normalized R-hat and bulk/tail ESS are invariant under the
  monotone transform, and `nu` is the interpretable quantity whose HDI 4.4 reads.
- **Plotting helper, imports and data cells are NB08's, verbatim**, including the
  panel-order sentence the plan asked for. No `plot_population`, and no `scipy` import.

## For Step 3a: every plot- and number-based claim, with its basis

"Scratch" means `lit09.py` or the nbconvert copy. The two agree exactly, and the posterior
is bit-identical across 5 processes here. Confidence refers to agreement with Step 3a's
execution.

| # | Cell(s) | Claim | Basis | Confidence / what to do if it fails |
|---|---|---|---|---|
| 1 | 1.2 fig, 1.3, 1.4 | Peaks ≈ 255/280/295 ms; means exactly 255/300/400; the left side keeps the steep rise; fast RTs don't become more common | Modes 255, 278, 294; P(y < 200) = 3.6%, 1.0%, 0.4%; figure viewed | Certain (deterministic) |
| 2 | 1.16 | The participant plate holds `b0`, `b1`, `log_sd_y`, `sd_y`; `log_nu`/`nu` are outside the plates; `nu` feeds `y` and `mean_rt`; `sd_y` does **not** feed `mean_rt` | Rendered graph (`lit_graph.png`) | Certain |
| 3 | 2.4 | `mu_log_sd_y` prior 90% HDI ≈ 2.6–4.2 (→ 13–67 ms); `sd_log_sd_y` mostly < 0.8; `nu` HDI "about 9 to 130 ms"; `nu` mean ≈ 64 | [2.601, 4.208]; [0, 0.803]; [8.68, 126.68]; 64.18 (plot label "64.0") | High (prior draws are identical across processes) |
| 4 | 2.6 | Baseline 50% ≈ 210–360, 90% ≈ 95–530 ms; almost every obs inside its own 50% band; 90% lower edges reach ≤ 0 in every panel by day 7 and in a third on day 5; negatives come mainly from mean-structure slopes | `azs.hdi`: medians [208, 363], [94, 526]; 93.8%; 18/18 (max −1 ms) and 6/18; attribution in decision 4 | High. **Look at the plot**: one day-7 panel is only at −1 ms, which is why the text says "reach zero or below". |
| 5 | 2.7 (question text too) | 333 (row 2, panel 1) zigzags from about −170 to above 700 ms; other panels stay near 300; one draw with `sd_y` ≈ 145 s; `sd_log_sd_y` ≈ 2.3, the largest of 500 | Decision 4; confirmed in both the literal and nbconvert figures | High. **If the prior plot differs, rewrite 2.7 and re-trace the cause** (`spikes09.py`). |
| 6 | 3.2 (question text) | Default gives "more than a dozen divergences"; "0.95 usually still leaves a few"; divergences occur mostly where a steady participant's Gaussian SD is very small | Decision 3 tables | **Please re-confirm once** with default settings and `RANDOM_SEED` (playbook §3.3). The default count is itself not reproducible (14 vs 38). |
| 7 | 3.4, 3.6 | 0 divergences; population R-hat 1.00; ESS all > 1,600 (bulk min 1,683, `nu`; tail min 2,153); screen R-hat 1.00, min ESS > 1,700 (1,938 / 1,722); traces well mixed | Summary output (identical in the nbconvert copy); traces viewed | High for this environment. **Main uncertainty:** 2/10 other seeds gave 1 divergence at 0.99. If Step 3a's run shows 1, do **not** change the seed. Edit 3.4's "no divergences" to state the single divergence honestly (3.2 already prepares for it). |
| 8 | 4.2, 6.1 | `mu_b1` 90% HDI ≈ 8.0–14.6 ms/day, essentially NB05's | [8.033, 14.606]; NB05's summary [8.07, 14.62] | High. The `plot_dist` label shows "11.0 mean" (2 significant figures); no answer quotes that mean. |
| 9 | 4.4, 6.1 | `nu` HDI ≈ 3.7–11 ms, mean ≈ 7.4; far below the prior; the lower end is prior-driven; `mu_b0` ≈ 260 vs NB05 ≈ 268, offset ≈ 8 ≈ ν | [3.725, 10.983]; 7.44; wide-prior check (decision 5); `mu_b0` 259.91 vs NB05 267.89 | High |
| 10 | 4.5 | Typical Gaussian SD ≈ e^{2.8} ≈ 16 ms; typical distribution ≈ the ν = 5 ms curve; the tail matters only for the steadiest participants; observations are session averages | `mu_log_sd_y` mean 2.786 → 16.2 ms; ex-Gaussian skewness 0.15 (typical) vs 0.01/1.26/1.89 for the figure's curves, 1.08 for 309; lme4 documentation | High for the numbers. The "single responses have long right tails / averaging removes skew" sentence is domain knowledge, not notebook output. **Reviewer may want to soften or cut it.** |
| 11 | 4.7, 6.1 | 309 ≈ 5 ms (HDI 1–10); 335/352 ≈ 7.5; 308 ≈ 49 (31–68); 332 ≈ 58 (36–80); roughly tenfold; `sd_log_sd_y` HDI 0.47–1.03, centered near the prior's upper end; total SD ≈ 10 (309) vs 58 (332), six-fold | Forest plot viewed; unrounded HDIs [0.9, 9.6], [30.8, 68.1], [35.7, 80.4]; [0.469, 1.033]; mean of √(sd_y² + ν²) is 9.6 and 58.2 | High |
| 12 | 5.2 | The `mu_y` plot would be shifted down by ν ≈ 7 ms with bands of almost the same width | mean(`mean_rt` − `mu_y`) = 7.44; median 90% width 27.9 vs 27.1 (ratio 1.02) | High |
| 13 | 5.4 | 90% predictive bands 170–220 ms wide (308, 332) and about 35 ms (309); roughly constant across the week; NB08's 308 band widened from about 150 to about 220 ms; nearly symmetric | NB09: 308 169–190, 332 197–221, 309 32–35; median asymmetry 0.01 ms. NB08: 148 → 223 from NB08's scratch posterior (`scratchpad/nb08/idata.pkl`), not its committed output. | High for NB09. NB08's numbers are approximate ("about"). |
| 14 | 5.5 | NB05's bands were ≈ 90–100 ms for everyone; the clearest misses are 308 day 5 (below) and 332 day 4 (above); others are at the edge (350 d4 misses by 0.9 ms; 351 d5 by 1.9 ms); no persistent pattern; essentially no negative replicates | NB05 refit (seed as notebook): widths 87–100, outside-90% set {308 d3, d5; 332 d4, d7; 370 d3; 371 d4}. NB09: 4 outside the 90% band; 9 of 576,000 replicates < 0. | High |
| 15 | 5.8, 6.1 | The ECDF is broadly consistent in both tails; the pooled skew is reproduced, mainly via the mean structure | ECDF figure viewed; skewness numbers in decision 5 | High |
| 16 | 1.x, 3.2 answer | Definitional and structural answers. 3.2's mechanism is backed by `edge09.py` (decision 3). | — | High |

## Not done in this step

- No execution of the repository notebook; that is Step 3a.
- No README or playbook change, and no other notebook touched. Suggested follow-ups for the
  orchestrator:
  - record the `log_nu` naming in playbook §3.1 if accepted;
  - optionally note NB09's `target_accept=0.99` in the README modeling notes;
  - carry decision 2's evidence into the NB10/11 plans, since the tail stays
    population-only there, together with decision 5's warning about the ν → 0 region
    under naive or flat `log_nu` priors;
  - note the int8 overflow pitfall in `pm.logp(pm.ExGaussian.dist(...))` (and generally
    any `sigma**2` on small int literals) if density plots appear elsewhere.
- Scratch scripts, logs and figures are in `scratchpad/nb09/`:
  - builders and checks: `build_nb09.py`, `derive_and_verify_nb09.py`, `check_nb09.py`;
  - model and fitting: `model09.py`, `fit09.py` (tags `base`, `nc`, `widenu`, `pnu`),
    `seeds09.sh`, `seeds09b.sh`, `seeds09*.log`, `checks09.log`;
  - analysis: `divloc09.py`, `divloc09b.py`, `edge09.py`, `prior09.py`, `priorbands09.py`,
    `spikes09.py`, `post09.py`;
  - literal and nbconvert runs: `lit09_make.py`, `lit09.py`, `lit09.log`, `lit_*.png`,
    `exec_copy.ipynb`, `exec_cell*.png`.
