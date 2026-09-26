# Implementation notes: notebook 10 — Priors that ignore the log link

Author: implementation agent (Step 2 of `sleep/REVISION_PLAYBOOK.md`).

**This notebook is a deliberate failure demonstration.** Its model was not tuned,
reparameterized, or given a higher `target_accept` to make it sample. The failed diagnostics
are the lesson.

## Execution status

The repository copy of the solved notebook is **unexecuted**: outputs are empty and execution
counts are null, leaving the committed run to Step 3a. Every number and plot reading in the
answers nevertheless comes from real executions of the notebook's own code in the pinned venv
(`scratchpad/nbenv`: `pymc==6.3.2`, `arviz-base==1.3.0`, `arviz-stats==1.3.2`,
`arviz-plots==1.3.1`, Python 3.12):

- **Four `jupyter nbconvert --execute` runs** of scratch copies (`exec_copy`, `exec_copy2`,
  `exec_copy3`, `exec_final`), with the `nbenv` kernel and the real `DATA_URL`. Every run
  exited 0, with 0 cell errors, and every printed number was bit-identical. The notebook is
  deterministic in this environment.
- **Two headless literal runs** (`lit10.py`, `lit10_099.py`). These reproduced the same
  posterior, and I saved `idata` from them for unrounded analysis.

The final repository file differs from the last executed copy in one markdown sentence only:
the sampling time in 3.4, reworded to match the measured 333–355 s.

**Important for Step 3a:**
- The notebook's integer prior constants (`= 0`, `= 5`) give a **different, equally
  failing** sampler run from my first scratch fits, which used float constants (`0.0`,
  `5.0`) with the same seed. On a posterior this pathological, last-bit differences in the
  compiled graph change the sampler's path.
- Within this environment, the notebook's own code is reproducible. Four executions were
  bit-identical.
- Colab (different CPU) may therefore produce different *details*, such as which
  participant is worst and the exact ESS values, while the qualitative failure is robust (see
  the seed and constant table below).
- The question and `given` texts are worded so that they do not depend on these details.
  Only the `solution` answers quote run-specific numbers.

## What was written

- **`sleep/solved/10_exgaussian_default_priors.ipynb`:** 56 cells (41 markdown, 15 code),
  every cell tagged:
  - 5 `section`;
  - 12 `exercise-question`, each followed by exactly one `solution`;
  - 2 `exercise-question` + `given-answer`: 3.3 (tree depth) and 4.5 (sampler mechanism);
  - 25 `given`;
  - 12 `solution` (9 markdown, 3 code).
- **How the solved notebook was built:** `scratchpad/nb10/build_nb10.py`, NB09's builder
  pattern:
  - stable hashed ids (`sleep10-<key>`);
  - top-level metadata taken from the pre-revision file (it had no `widgets`);
  - `json.dump(..., indent=1, ensure_ascii=False, sort_keys=True)` plus a trailing newline.
- **`sleep/10_exgaussian_default_priors.ipynb`:** derived mechanically by
  `scratchpad/nb10/derive_and_verify_nb10.py`, NB09's script with the file names changed:
  - `solution` cells become `- answer here` or `# answer here`;
  - the badge points to `sleep/10_...`;
  - outputs are cleared and execution counts are null;
  - there is no `metadata.execution` and no `metadata.widgets`.
- **Verified by script** (`derive_and_verify_nb10.py`, `check_nb10.py`):
  - exactly 13 cells differ (12 `solution` + 1 badge), and every other cell is
    byte-identical;
  - the two files have identical ids, types, tags and order;
  - both pass `nbformat.validate`, ids are unique, and both files end in a trailing newline;
  - Q→A adjacency holds, questions are `###` headings and sections are `##` headings;
  - every in-notebook "Question N.M" reference resolves;
  - math uses only `$`/`$$`;
  - none of these appear: `print(model`, `lam=`, `kind="kde"`, `plot_population`,
    `population_mu`, `_z`, `residual_scale`, `sigma_intercept`, `nu_intercept`,
    "Notebook 10/11/12", "next notebook";
  - "Reaction" appears only in the axis label and `observed=sleep["Reaction"]`;
  - notebooks cited: 1, 5, 8, 9.

### Section structure

| Section | Content (Q = student answers, G = given) |
|---|---|
| Title, Setup, Data, Plotting helper | G. NB09's cells verbatim. The intro says the priors are chosen for the student as a deliberate demonstration (NB02's framing), with no forward pointer. |
| 1. Priors that ignore the link | 1.1 model math, plus a **table of the three changed priors** against NB09's (G) · 1.2 whole model in one supplied cell, NB09's values in the comments (G code) · 1.3 **reverse elicitation**: what does Normal(0, 5) on `log_nu` say in ms? (Q) · 1.4 what does Exponential(scale=5) on `sd_log_sd_y` say, and does "unit-free" mean harmless? (Q) |
| 2. Check the prior implications | 2.1 NB09's five criteria, listed (G) · 2.2 prior draws (G) · 2.3 `plot_participants` prior predictive (G) · 2.4 what the plot shows: the 1e51 axis, participant 333, the same random draw as NB09's 2.7 (Q) · 2.5 per-experiment extreme-value summary (G code, NB06-style) · 2.6 criteria verdict (Q) |
| 3. Fit and diagnose the model | 3.1 sampling (G), with a note that NB09's settings do worse · 3.2 divergences + share at max tree depth + step size + summary + trace (G) · 3.3 what "maximum tree depth" means (given-answer) · 3.4 population verdict (Q) · 3.5 all-participant screen, sorted by bulk ESS (G) · 3.6 trace of the screen's worst participant (Q code) · 3.7 participant verdict (Q) |
| 4. Examine the failed fit | 4.1 `plot_dist` `mu_b1` (Q code) · 4.2 would it be safe to report? (Q) · 4.3 `azp.plot_prior_posterior` for `mu_log_sd_y` and `log_nu` (Q code) · 4.4 what the data vs the prior determined (Q) · 4.5 why the sampler struggles (given-answer) |
| 5. Summary | 5.1 retrospective only (Q). No reference to any later notebook. |

**Scaffolding follows the plan.**
- The model is `given` (NB5-style), and the naive priors are supplied as the object of
  study, as in NB02.
- The student work is:
  - the reverse elicitation (1.3, 1.4);
  - reading the prior-predictive failure (2.4, 2.6);
  - reading the diagnostics honestly (3.4, 3.7);
  - the "looks fine but isn't" interpretation (4.2);
  - the data-vs-prior attribution (4.4);
  - three short plotting tasks (3.6, 4.1, 4.3).
- The two mechanism explanations are `given-answer`, because students cannot derive them
  (see decision 4).

## What the failure actually looked like (notebook code, `RANDOM_SEED`)

**Prior predictive.** This is forward sampling, so it is not chaotic and matched every
scratch run exactly.
- The plot's shared y-axis is in units of 1e51 ms. Only participant 333's mean line is
  visible: min −1.336e51, max +1.159e51. Every band and observation is flat at 0.
- It is the **same random draw (#455)** that made 333 zigzag in NB09's 2.7:
  - `sd_log_sd_y` there was 2.2804, here 34.2067 (exactly ×15, the ratio of the Exponential
    scales);
  - `mu_log_sd_y` 4.1747 → 7.7349 (same standard-normal draw, z = 1.547);
  - `sd_y[333]` 145,388 ms → 3.99e53 ms.

  Verified by drawing both priors with the same seed.
- 44% of simulated experiments contain a reaction time > 10 s, and 41% one < −10 s. The
  median experiment's slowest reaction time is 4,632 ms.
- For comparison (scratch only, not quoted in the notebook), NB09's priors give 0.4% and
  0.4%, and a median slowest of 635 ms.

**Sampling** (`target_accept=0.95`, `tune=2000`, 4 × 1000 draws, 2 jobs):
- **0 divergences.**
- Max tree depth on 99.9% of draws (printed "100%"), with every chain warned. Average step
  size 0.0025 (by chain: 0.0021, 0.0026, 0.0033, 0.0019).
- PyMC also warns "R-hat > 1.01 for some parameters" and "ESS per chain < 100 for some
  parameters".
- 333–355 s per run (342 s when running alone), against NB09's committed 33 s.

Population summary (displayed, `round_to=2`; unrounded R-hat in brackets):

| | mean | 90% HDI | ess_bulk | ess_tail | r_hat |
|---|---|---|---|---|---|
| mu_b0 | 264.69 | 250.36, 278.04 | 569 | 748 | 1.01 (1.0095) |
| sd_b0 | 33.92 | 24.70, 44.00 | 455 | 709 | 1.01 (1.0086) |
| mu_b1 | 11.20 | 8.23, 14.52 | 576 | 817 | 1.01 (1.0064) |
| sd_b1 | 7.36 | 4.95, 9.72 | 445 | 766 | 1.01 (1.0053) |
| mu_log_sd_y | 2.80 | 2.50, 3.13 | 412 | 435 | 1.02 (1.0160) |
| sd_log_sd_y | 0.71 | 0.44, 0.98 | 171 | 220 | 1.03 (1.0334) |
| log_nu | −1.89 | −6.44, 2.18 | 108 | 117 | 1.03 (1.0254) |

**Participant screen** (five smallest bulk ESS):

| parameter | ess_bulk | r_hat |
|---|---|---|
| b1[332] | 101 | 1.04 |
| b0[372] | 116 | 1.03 |
| b1[309] | 134 | 1.04 |
| b0[309] | 140 | 1.04 |
| b1[372] | 148 | 1.03 |

- 30 of the 54 participant-level parameters have unrounded R-hat > 1.01, spread over 15 of
  18 participants (scratch only).
- For participant 332, chain 3 sits apart from the others:
  - `b0` chain means 286.8, 283.6, 284.2, 274.8;
  - `b1` chain means 8.7, 9.5, 8.7, 11.2.

**`nu` itself** (scratch): median 0.26 ms, 95th percentile 6.8 ms, 99th percentile 8.6 ms,
P(ν < 1 ms) = 63%, P(ν < 0.1 ms) = 40%. The `log_nu` draws range from −15.8 to 2.75. In 50%
of draws, ν is below 5% of *every* participant's `sd_y`, i.e. in PyMC's Gaussian-branch
region.

**Against the pre-revision notebook** (non-centered, different machine): same kind of failure,
slightly different numbers.
- It hit max tree depth on every chain, with R-hat up to 1.05 (slope) and bulk ESS about 170,
  and took 397 s.
- Its `nu_intercept` was −2.25 (sd 3.44), against −1.89 (sd 3.23) here.
- The worst R-hat is now at participant level (1.04) rather than on the population slope.

## Settings, seeds and attribution: scratch evidence (`scratchpad/nb10/`)

All runs use 4 chains, 1000 draws and 2 jobs.

| Run | Constants | Divergences | Max-depth share | Step size | Worst R-hat (pop / participant) | `log_nu` mean [90% HDI], bulk ESS | Time |
|---|---|---|---|---|---|---|---|
| **Notebook** (0.95, tune 2000, `RANDOM_SEED`) | int | 0 | 99.9% | 0.0019–0.0033 | 1.033 / 1.042 | −1.89 [−6.44, 2.18], 108 | 333–355 s |
| 0.95, 2000, `RANDOM_SEED` | float | 0 | ~100% | 0.0012–0.0017 | 1.021 / 1.051 (b0[309]) | −2.25 [−7.13, 2.26], 197 | 334 s |
| 0.95, 2000, seed 1 | float | 0 | ~100% | 0.0013–0.0026 | 1.016 / 1.030 (333/335/352) | −2.27 [−7.21, 2.24], 185 | 328 s |
| **NB09 settings** (0.99, tune 1500) | int (literal) and float: identical | 0 | 100% | 0.0006–0.0009 | **2.19 / 2.69**; all 54 participant params > 1.02; bulk ESS 5–10 | −0.04 [−1.97, 2.69], 7 | 276–287 s |
| Only `log_nu` naive ("nuonly") | float | 0 | ≥99.8% | 0.0018–0.0033 | 1.012 / 1.053 (b0[349]) | −2.60 [−7.59, 2.02], 308 | 334 s |
| Only scale hierarchy naive ("sdonly") | float | **40** | 0% | 0.066–0.104 | 1.007 / 1.008 | 2.05 [1.56, 2.61] (ν ≈ 8 ms), 908 | 30 s |
| All naive, **smooth exact ex-Gaussian logp** (diagnosis only) | float | **58** | 0% | 0.066–0.078 | 1.010 / 1.005 | −2.10 [−7.19, 2.29] | 34 s |

What this establishes:

1. **The failure is robust.** It appears across both seeds and with both int and float
   constants, always as:
   - 0 divergences;
   - essentially every draw at the maximum tree depth;
   - step size ~0.001–0.003;
   - R-hat > 1.01 and low ESS for `log_nu` and several participants.

   Only the details move, such as which participant is worst.
2. **NB09's settings make it worse, not better.** The claim in 3.1 and the parenthetical in
   4.2 rest on this. With `target_accept=0.99` and `tune=1500`, the four chains end up in
   different places:
   - `mu_b1` chain means 11.1, 11.5, 14.3, 11.5 (R-hat 1.53);
   - `log_nu` chain means −0.6, −0.9, −0.5, 1.9.

   I ran this with the notebook's literal code, and the float-constant version gave the
   identical result.
3. **Attribution.**
   - **The `log_nu` prior alone reproduces the tree-depth failure** (nuonly).
   - The two naive scale-hierarchy priors alone do **not** cause it (sdonly: fast, R-hat ≤
     1.01). They are not harmless either:
     - 40 divergences, against 3 for NB09's model at 0.95 (NB09 notes);
     - `sd_log_sd_y` moves to 0.93 [0.49, 1.32], against NB09's 0.76 [0.47, 1.03];
     - presumably because the wider between-participant prior lets steady participants'
       `sd_y` shrink further into NB09's sharp-edge regime.

   The notebook therefore attributes the tree-depth failure and the prior-shaped posterior
   to the tail prior (4.4, 4.5). It never says the scale-hierarchy priors "did no harm". It
   says only that, in this fit, `mu_log_sd_y`'s posterior was data-dominated. That is shown
   in 4.3's plot and holds in every run: 2.80–2.89, against NB09's 2.79.
4. **Mechanism.** It is the discontinuity at PyMC's `ExGaussian.logp` switch, not flatness
   alone.
   - PyMC 6.3.2 computes the ex-Gaussian with the gamlss formula when `nu > 0.05*sigma` and
     with a plain Normal otherwise (`inspect.getsource(pm.ExGaussian.logp)`).
   - `probe10.py` evaluated the joint logp along `log_nu` at a posterior draw:
     - below the switch points (≈ −1.3 to 0.9 at that draw), the gradient equals the prior's
       exactly (−log_nu/25): the data carry no information there;
     - at a switch point, the logp jumps by up to ~0.38 nats;
     - the mean |energy error| peaks (0.23–0.24) for `log_nu` in [−2, 1), exactly where the
       switch points lie, against ≤ 0.05 below −4.
   - `fit10_smooth.py` replaced the likelihood with an **exact, smooth** ex-Gaussian logp.
     It is written with `erfcx` for numerical stability and checked against
     `scipy.stats.exponnorm` to 1e-7.
     - With the same naive priors, step size, tree depth and R-hat all recover (0.07, ~6,
       ≤ 1.01), in 34 s. The posterior is the same.
     - There are 58 divergences instead: the geometry is still hard.

   So the tiny step size, and with it the maximum tree depth and the low ESS, comes from the
   switch's jumps. The root cause is the prior putting much of its mass where the likelihood
   is flat, which makes the sampler cross those jumps constantly. 4.5 says this at course
   level, names the software version, and says that another implementation could fail
   differently, "for instance with divergences" (this smooth run).
5. **The posterior's left side has the prior's shape.** Posterior-to-prior mass ratios per
   `log_nu` bin are roughly constant at 1.2–1.4 for `log_nu` < 0 in every run, including the
   well-mixed smooth one. They rise to ~1.6–2.5 for [0, 2), where the data mildly favor tails
   of a few ms, and collapse above 2. This supports 4.4's statements:
   - "left side follows the prior's shape";
   - "the data favor tails of a few milliseconds only slightly over shorter ones";
   - the bumps are sampling noise, since the smooth run's posterior is smooth.

## Deviations from the plan and judgment calls (flagged)

1. **Sampler settings: `target_accept=0.95`, `tune=2000` (the brief's instruction).**
   - The plan is internally inconsistent. Its "Model/code content" section says to start at
     0.95/2000 (the pre-revision draft). The next bullet says to start at NB09's 0.99.
   - I used the brief's 0.95/2000 in the notebook, and ran 0.99/1500 as well.
   - Because a student comparing with NB09 would naturally suspect the lower
     `target_accept`, the 3.1 `given` text says so explicitly: NB09's settings make this
     model "sample even worse". 4.2 adds that at 0.99 "this model's chains did not agree even
     on `mu_b1`".
   - **Orchestrator:** if you prefer the notebook to use NB09's exact 0.99/1500, the failure
     is far more dramatic (R-hat up to 2.7, ESS 5–10). But `mu_b1` then visibly fails too,
     which removes 4.2's "looks safe but isn't" lesson, and answers 3.4, 3.7, 4.2, 4.4 and
     5.1 would need rewriting. I recommend keeping 0.95/2000.
2. **`mean_rt` dropped** from the model. No question uses it (AGENTS: every Deterministic
   should be used), and 1.2 says it is left out. `mu_y`, `sd_y` and `nu` stay, as parts of
   the likelihood.
3. **All three naive priors are supplied**, including `sd_log_sd_y ~ Exponential(scale=5)`,
   as the plan instructs, with a table against NB09's values (1.1) and NB09's constants in
   code comments (1.2). 1.4 frames it as the same mistake: unit-free is not meaning-free,
   since 5 on the log scale is a ratio of about 150.
4. **Mechanism depth (plan open question).** The plan suggested describing the failure
   phenomenologically ("the tail becomes unidentifiable…") if the mechanism is too deep.
   - My experiments show that a flatness-only story would be **wrong**: with a smooth logp,
     the flat region is traversed easily.
   - So 4.5 (`given-answer`) names the PyMC 6.3.2 switch in two sentences and ties it to the
     global step size (NB08's "single step size" sentence) and to 3.3's tree-depth
     explanation.
   - The statistical cause, "the prior put much of its probability where the data carry no
     information", is the part students answer themselves (4.4).
   - **The reviewer should check that this is at the right level.** The fallback would be to
     shorten 4.5 to its last paragraph plus one sentence: "PyMC's density calculation for
     this region makes the sampler take tiny steps."
5. **"Maximum tree depth" is newly explained** (3.3, `given-answer`). A grep confirms that
   the term has never been explained in NB01–09. It appears only as raw warning text in
   golf/03 and pre-revision NB11. The wording uses "path", not "trajectory", because
   "trajectory" means a participant's reaction-time trajectory throughout this course.
6. **Diagnostics cell additions** (3.2): the share of draws at maximum tree depth and the
   average step size are printed from `sample_stats`.
   - NB09's committed progress bar is an ipywidget, so its text output shows no step size or
     gradient counts.
   - Printing them grounds 3.3 and 4.5 in visible output.
   - Divergences are also printed; with 0 of them, the headline lesson is "a sampler can fail
     without diverging".
7. **Participant diagnostics:** the screen shows the five worst rows, sorted by bulk ESS,
   instead of NB09's three-number table plus a first/middle/last subset.
   - Students then plot the trace of the screen's first-row participant (3.6), which is a
     `coords` task.
   - The question text does not name the participant, so it stays correct if Colab's run
     differs. In the float-constant scratch run the worst participant was 309, and with seed
     1 it was 333, 335 or 352.
8. **No parameter-level prior `plot_dist`** (NB09's 2.3).
   - For `nu` with this prior, the plot is a spike at 0 on an axis running to ~650,000 ms.
     Its 90% HDI of about 0–450 ms looks deceptively tame, and its mean of about 3,500 ms
     lies outside it.
   - The ms translation is done analytically in 1.3 and 1.4 instead, which is the
     notebook's core exercise. The observable-scale check follows in 2.3.
9. **Prior-predictive numeric summary (2.5).** It follows NB06's precedent for an unreadable
   prior-predictive plot. It answers the one question the plot cannot: whether the problem
   is one rare draw, as in NB09's 2.7, or routine.
10. **`azp.plot_prior_posterior`** (4.3) is new to the course. It is introduced in the
    question text and needs `idata["prior"] = prior["prior"]`, which the question text
    supplies. Hence 2.2 draws `mu_log_sd_y` and `log_nu` as well as `y`.
    - The two parameters have **the identical Normal(0, 5) prior**. In this fit, one
      posterior is a data-dominated spike and the other is prior-shaped: a controlled
      comparison inside a single model.
    - The KDE's right edge for `log_nu` is cut off, a boundary effect, and its left side is
      bumpy because of the low ESS. 4.4 says the bumps are not real features.
11. **Not included:**
    - a posterior predictive check. The fit fails its diagnostics, and interpreting
      predictions from it would contradict the notebook's own lesson; the plan's outline
      has none;
    - `pm.model_to_graphviz`, because the structure is NB09's and no question needs it;
    - prior sensitivity;
    - slide figures, per the plan.
12. **Title** "Priors that ignore the log link". It uses the term NB09 defined. The
    pre-revision said "link function". The intro explains the file name ("default_priors")
    in one clause: "the kind of prior written by default rather than by thinking about the
    quantity it constrains". It makes no claim about any software's defaults.

## For Step 3a: every claim and its basis

"Notebook run" means the four bit-identical nbconvert executions of the notebook's code.
"Scratch" means scripts in `scratchpad/nb10/`.

| # | Cell(s) | Claim | Basis | Confidence / action if it differs |
|---|---|---|---|---|
| 1 | 1.3 answer | Median ν = 1 ms; 95% range e^±10 ≈ 0.00005 ms to 22,000 ms (22 s), "almost nine orders of magnitude"; NB09's 11–220 ms holds ~18% of this prior; half below 1 ms; ~8% above 1 s | Analytic: P(11 < ν < 220) = 17.5%, P(ν > 1 s) = 8.4%; e^20 = 4.9e8 | Certain |
| 2 | 1.4 answer | e^5 ≈ 150 vs e^(1/3) ≈ 1.4; at 30 ms typical, ±1 SD gives ≈ 0.2 ms and 4.5 s | Analytic: 30/148.4 = 0.20, 30 × 148.4 = 4,452 ms | Certain |
| 3 | 2.4 answer | Axis in units of 1e51 ms; only 333's mean line visible, from about −1.3e51 to +1.2e51; same draw as NB09's 2.7; `sd_log_sd_y` 2.3 → 34 (×15); `sd_y[333]` 145 s → ~4e53 ms | Notebook-run figure; scratch recomputation of the mean line with the notebook's exact call (−1.336e51 / 1.159e51); draw-#455 check with both priors | High. Forward sampling is deterministic, and every run matched. **Look at the figure.** |
| 4 | 2.5 output, 2.6 answer | 44% above 10 s, 41% below −10 s, median slowest 4,632 ms → "about 4.6 s" | Notebook-run printout | Certain in this environment |
| 5 | 3.1 given text | NB09's 0.99/1500 makes this model "sample even worse" | Literal 0.99/1500 run: pop R-hat up to 2.19, participant 2.69, bulk ESS 5–10 | High (same result with int and float constants). **Re-run once if you want to confirm.** It is outside the notebook's own output, like NB09's 3.2 claim about default settings. |
| 6 | 3.4 answer | 0 divergences; every chain warned; ~every draw at max depth (printed 100%); R-hat 1.02 (`mu_log_sd_y`), 1.03 (`sd_log_sd_y`, `log_nu`), others 1.01; `log_nu` ESS ~110/120; trace between about −15 and 2; the chains' `log_nu` densities differ; 5–6 min vs NB09's 33 s | Notebook-run output and trace figure; times 333, 342, 351, 355 s | High in this environment. **If Step 3a's numbers differ** (a different machine), update the numbers in 3.4, 3.7, 4.2, 4.4 and 5.1, and 3.6's `coords`. The qualitative claims hold in every run. |
| 7 | 3.3 given-answer | Max depth 10 → 1,023 steps; each step needs a gradient evaluation | PyMC NUTS default `max_treedepth=10`; the progress bar showed "1023" grad evals per draw in the literal run | Certain |
| 8 | 3.6 code, 3.7 answer | Worst five rows are from 332, 372, 309, with ESS ~100–150 and R-hat 1.03–1.04; one of 332's chains has `b0` ~10 ms lower and `b1` ~2 ms/day higher | Notebook-run screen; per-chain means (286.8, 283.6, 284.2, 274.8; 8.7, 9.5, 8.7, 11.2); figure viewed | High in this environment. **If the screen's first row is a different participant, change the `coords` in 3.6 and rewrite 3.7.** |
| 9 | 4.2 answer | HDI ≈ 8.2–14.5 vs NB09's 8.0–14.6; `mu_b1` R-hat 1.01, ESS ~580/820; at 0.99 the chains disagreed on `mu_b1` | Notebook-run summary; NB09's committed 4.2 (8.0–14.6); the 0.99 run (row 5 of the settings table) | High |
| 10 | 4.3 figure, 4.4 answer | `mu_log_sd_y` is a narrow peak near 2.8 (e^2.8 ≈ 16 ms), ≈ NB09's 2.79; `log_nu` HDI −6.4 to 2.2 → 0.002–9 ms; upper end close to NB09's 11; left side follows the prior, and the bumps are noise; mean −1.9 → ~0.15 ms; "favor a few ms only slightly" | Summary; figure viewed; posterior/prior bin ratios (attribution point 5); probe gradient | High |
| 11 | 4.5 given-answer | The PyMC 6.3.2 switch at ν < 5% of σ; jumps in the range the paths cross; step size shrinks "to a few thousandths"; the global step size makes every parameter slow; another implementation "could fail differently, for instance with divergences" | `pm.ExGaussian.logp` source; `probe10.py`; step sizes 0.0019–0.0033; smooth-logp run (58 divergences) | High for the facts. **The level of detail is a reviewer judgment (deviation 4).** |
| 12 | 5.1 | Restates items 1–10; "Notebook 9's higher `target_accept` made it worse" (item 5); R-hat reached 1.04 (participant screen) | As above | High |

## Notes for the orchestrator (not stated in the notebook)

- **NB11 planning.**
  - NB10 now teaches maximum tree depth (3.3) and the ExGaussian switch mechanism (4.5).
  - Pre-revision NB11's output also shows tree-depth warnings. If NB11 keeps NB09's tail
    prior (the README says "the same hierarchical priors as notebook 9"), its failure mode
    will differ.
  - The sdonly run is relevant there: naive scale priors alone gave 40 divergences, not
    tree depth.
- **Int vs float constants.** On pathological posteriors, sampler output depends on graph
  details, such as integer versus float literals, even with a fixed seed. This is worth
  knowing whenever an executed failure notebook's numbers are quoted.
- **Colab runtime.** Sampling takes about 5–6 minutes on 2 cores. 3.1 warns students.

## Scratch files (`scratchpad/nb10/`)

- **Builders and checks:** `build_nb10.py`, `derive_and_verify_nb10.py`, `check_nb10.py`,
  `dump_exec.py`.
- **Model and fits:**
  - `model10.py` (variants `naive`, `nuonly`, `sdonly`, `nb09`);
  - `fit10.py`, `fit10_smooth.py`;
  - `fit_*.log`, `idata_*.pkl`.
- **Literal runs:** `lit10_make.py`, `lit10.py`, `lit10_099.py`, `lit10*.log`,
  `lit10_idata*.pkl`, `post10.py`.
- **Prior analysis:** `prior10.py`, `priorstats10.py`, `prior_pred_naive.png`,
  `prior_dist_naive.png`.
- **Mechanism:** `probe10.py`, `probe_grid.npy`, `render10.py`, `r_*.png`.
- **Executed copies:** `exec_copy*.ipynb`, `exec_final.ipynb`, `exec_cell*.png`,
  `nbconvert*.log`.

## Fix loop (Step 4, applied by orchestrator after fresh-eyes review)

Review verdict: ready to commit after markdown fixes, nothing blocking. Applied
findings 1-7 from `04_review.md`:

- **Finding 1 (moderate):** the notebook told students a failed fit's quantities
  "cannot be reported" (4.2/5.1), then interpreted `log_nu`'s HDI two cells later
  without acknowledging the tension. Added a framing sentence to 4.3 explaining that
  the failed fit's draws can still show *where* the prior vs. the data shaped the
  posterior (which is legitimate) and that this is also why there's no posterior
  predictive check; reworded 4.4 and 5.1 to attribute the "~10ms bound" claim to
  agreement with notebook 9's converged fit, not to trusting this fit's own numbers.
- **Finding 2:** the printed sampler warning says "increase target_accept" while 3.1
  says that makes things worse, with nothing reconciling the two. Appended one
  sentence to 3.3 explaining why (smaller steps under a fixed tree-depth cap move even
  less).
- **Finding 3:** 4.5's mechanism explanation used "gradient" and "log density" without
  ever saying what steers the sampler's path or why a density jump defeats it (the
  same "undefined term" class notebook 9's review caught). Added one clause to 3.3
  (path "steered by the slope (the gradient) of the log posterior density") and
  extended 4.5 to say the jumps are too small to register as divergences but still
  defeat a gradient-steered path, plus a concrete closing sentence contrasting with
  notebook 9 (same likelihood, sampled in half a minute, because its tail prior kept ν
  above the switch point).
- **Finding 4:** 4.4 called `exp(mean of log_nu)` ≈ 0.15ms "the tail: effectively no
  tail at all" — neither the posterior mean (1.6ms) nor median (0.26ms) by the
  notebook's own point-estimate convention, and phrased as a finding about reaction
  times rather than about where the prior pulled the estimate. Replaced with a
  sentence correctly framing it as the prior's pull.
- **Finding 5:** 4.2's "looks fine but can't be trusted" argument was abstract; made it
  concrete by naming `b1[332]` (the screen's worst-mixing parameter) as the actual
  channel through which `mu_b1`'s apparent health is not independent of the failure.
- **Finding 6:** added one sentence to 3.1 warning that exact diagnostic values (and
  even which participant is worst) can differ on another machine when a sampler fails
  this badly, though the qualitative pattern won't.
- **Finding 7:** the intro said notebook 9 chose "those priors" (plural, meaning all
  three changed here) in milliseconds, but one of the three (`sd_log_sd_y`) was
  actually a unit-free ratio carried over from notebook 8, not elicited in ms. Fixed
  the intro's first two paragraphs to state this accurately.
- **Trivial:** added `sd_log_sd_y`'s low bulk ESS (~170) to 3.4's diagnostic verdict,
  alongside `log_nu`'s, since it also falls short of Notebook 1's "comfortably in the
  hundreds" criterion.

Not applied (review's own "optional"/"not needed" trivial items): the 2.6 criterion
cross-reference rewording and the 4.3 figure's KDE-edge clarification — both marked
by the reviewer as not needed.

Re-verified structural consistency (self-work vs. solved) after all fixes: 0
mismatches.
