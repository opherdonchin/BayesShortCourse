# Fresh-eyes review: notebook 11 — Flat population-level priors

Reviewer: independent agent (Step 3b of `sleep/REVISION_PLAYBOOK.md`). I did not write this
notebook.

**Inputs read in full:**
- `AGENTS.md` and the playbook, including §3.5's carve-out for NB10/11 as failure
  demonstrations and §3.10 (summarize, don't preview).
- `01_plan.md`, `02_implementation_notes.md` and `03_execution_log.md`.
- Both NB11 notebooks, cell by cell, with every executed output. I also viewed both rendered
  figures, the trace plot and the posterior predictive plot, and zoomed into parts of them.
- NB09 and NB10 solved, in full, with their outputs, and NB10's `04_review.md` as the template.
- The step-size sentences of NB08 (Q3.2), NB09 (Q3.2) and NB10 (Q4.5).

**Independent checks** (`scratchpad/review11/`, pinned venv `scratchpad/nbenv`):
- **Model from the notebook itself.** `setup_model.py` builds the model by `exec`ing the
  notebook's own data and model cells, with the local copy of the CSV in place of the URL. It
  does not use the implementer's copy of the model cell.
- **Matching run.** The implementer's saved warm-cache `idata` (`lit11_..._warm2.pkl`)
  reproduces the committed chain-means table to every displayed digit, with divergences of
  563 / 451 / 474 / 0. I used it as the notebook's run. The orchestrator had already confirmed
  that the notebook itself re-executes bit-identically, so I did not re-run the notebook.
- **Sampler's own function.** I probed with `model.logp_dlogp_function(ravel_inputs=True)`,
  the function PyMC's NUTS integrator calls (`arraystep.py`, `integration.py`). I did not use
  a separately compiled `compile_dlogp`.
- **Source reads.** `inspect.getsource(pm.ExGaussian.logp)` (PyMC 6.3.2); PyTensor's
  `TrueDiv` gradient; and arviz-plots' `plot_trace_dist` divergence handling.
- **Posterior predictive draws.** I regenerated them from the matching run with
  `RANDOM_SEED`. My 50% HDIs reproduce the implementer's figures exactly: 332 on day 7 is
  [252.8, 344.1], and 308 on day 4 is [280.5, 360.4].
- **All 12 saved scratch runs.** I re-tallied the stuck chains and divergences behind 2.1's
  and 2.5's test-run claims.

**Verdict: ready to commit after small markdown-only fixes. Nothing is blocking.**
- The central mechanism is **correct, and I verified it independently to the second decimal**
  (next section). It is not just plausible-sounding.
- Every number quoted in a solution matches the executed output or a saved run.
- NB10 and NB11 teach genuinely different failures.
- The closing section is a true retrospective, and the tag scheme and self-work derivation are
  clean.
- I recommend findings 1–4. Finding 1 is the one I would not skip: 3.1 misreads a plot feature
  that appears for the first time in the course and is never explained. Findings 5–6 are minor,
  and the rest trivial.
- **No re-execution is needed.** Every fix is markdown-only, and no numeric claim changes.
- Findings 1a, 2, 3b, 4b and 5 touch `given`, `exercise-question` or `given-answer` cells.
  Mirror them in the self-work file by re-running `derive_and_verify_nb11.py`.

**Cell references** use `[index]` in the 49-cell notebook, the question number and the cell
id. Ids are identical in both files.

---

## The mechanism, re-derived (brief items 1 and 2)

**1. The posterior is improper in `log_nu`. True, and not an artifact of PyMC's switch.**
- **PyMC 6.3.2's density.** `ExGaussian.logp` is
  `pt.switch(pt.gt(nu, 0.05 * sigma), <gamlss ex-Gaussian>, log_normal(value, mu, sigma))`,
  wrapped in `check_parameters(..., nu > 0)`. Below each participant's switch,
  `log(0.05 · sd_y)`, that participant's likelihood does not involve ν at all. `pm.Flat`
  contributes a constant, so the joint log density cannot depend on `log_nu` there.
- **Measured with the sampler's function, at one draw from each non-stuck chain.**
  - Chain 0, draw 100: the log density is exactly −780.002921 for every `log_nu` from −1.62
    (the draw's smallest switch) to −745.0, and the `log_nu` gradient is exactly `0.0` down to
    −372.56.
  - Chains 1 and 2 behave identically, with other constants.
  - The log density becomes −inf only below −745.2, where ν itself underflows to 0 and
    `nu > 0` fails.
- **Where the switches lie.** Across the notebook run's non-stuck draws, the smallest switch
  lies between −2.04 and −0.46. 3.2's "below about −3" is therefore safe. 99.67% of those
  draws lie below every participant's switch, which supports 3.8's "in almost every draw …
  effectively a Gaussian model".
- **The mathematics without the shortcut.** An exact density only levels off toward the
  Gaussian one as ν → 0; it never falls to zero. A flat prior over the resulting half-line has
  infinite mass, so the posterior is improper in any implementation. The switch only makes the
  constancy exact. The notebook's argument is right, but it leans on the switch (finding 3).
- **The second improper direction (2.5, 3.2, 4.1).** This is also true. At three chain-3 draws,
  shifting `mu_log_sd_y` and every `log_sd_y` down together left the log density unchanged to
  six decimals, all the way from `sd_y` ≈ 0.007 ms to 10⁻²⁴ ms: for example −724.381457 for
  every shift from 0 to −50. Raising `sd_y` to 1 ms changes it by only about 2–3 nats.
  - In chain 3, `mu_y` lies below the observation in 99.99% of (draw, observation) pairs. The
    rare exceptions are within about one `sd_y` (0.006 ms).
  - `sd_y` is 0.0066–0.0069 ms, and ν has a mean of 31.2 ms. These match 2.5's description.

**2. The floating-point wall is exactly where the notebook puts it.**
- **The threshold.** In float64, ν² rounds to 0 once it falls below half of the smallest
  subnormal, 4.94 × 10⁻³²⁴. That happens at log ν = ½·ln(2.47 × 10⁻³²⁴) = **−372.567**.
  - At −372.565, `np.exp(x)**2` is 5e−324; at −372.57 it is 0.0.
  - At the same three draws, the sampler's `log_nu` gradient is `0.0` at −372.56 and `nan` at
    −372.57, every time. The two thresholds coincide to 0.01.
- **Why it is NaN rather than infinity.** PyTensor's `TrueDiv` gradient with respect to the
  denominator is `-(gz * x) / (y * y)`. In the switch's unused branch, `gz` is 0 and
  `y * y` = ν² = 0, so the gradient evaluates 0/0 = NaN. 3.3's "Part of PyMC's slope
  calculation divides by that square, and once it is zero, the calculation produces *not a
  number*" is therefore **literally accurate**, not just a course-level simplification.
- **I reproduced it outside the model.** A bare vector-input `pm.logp(pm.ExGaussian.dist(...))`
  has the same NaN onset at −372.57, even in `FAST_COMPILE`. A scalar-input version is
  rewritten differently and stays finite, which is why the probe must use the model's own
  function.
- **The divergences are that wall.**
  - 99.87% of the 1,488 divergent draws have a non-finite `max_energy_error`; only 2 are finite.
  - P(divergent | `log_nu` bin) is 0.77 in [−400, −300), then 0.54, 0.39 and 0.35 moving up to
    [−100, 0).
- **The draws are uniform between the wall and the data.**
  - The pooled chains 0–2 have mean −187.6 and sd 106.7, against −185.4 and 107.7 for a uniform
    distribution over their range. The full 50-unit bins between −350 and 0 hold 374–428 draws
    each.
  - Successive draws move by a mean |Δ| of 71–75, so a single path can indeed cross much of the
    region, as 3.3 says.

**A correction to my brief, so the notebook is not "fixed" wrongly.** The brief says
"`exp(-372.55)` is near the smallest representable positive float64 magnitude ~1e-308". It is
not.
- e^−372.55 ≈ 1.6 × 10⁻¹⁶², far above the smallest normal float, 2.2 × 10⁻³⁰⁸.
- It is **ν²** ≈ 2.6 × 10⁻³²⁴ that sits at the bottom of the *subnormal* range and rounds to 0.

The notebook states this correctly: "the tail mean is about 10⁻¹⁶² ms, and its square is too
small to store", with the smallest positive number "about 5 × 10⁻³²⁴".

**Magnitude claims (brief item 5), all correct:**
- 3.1: e^−372 = 2.8 × 10⁻¹⁶² ≈ 10⁻¹⁶². The upper end of the draws is 1.14, or 3.1 ms, so
  "up to about 1 ms" holds for the bulk.
- 3.1 and 3.8: e^3.44 = 31.2 ms, "about 30 ms".
- 1.3: log 10 = 2.30.
- 1.2: P(50 < x < 450) under Normal(250, 100) is 95.4%.
- 2.4: NB09's ν HDI of 3.72–10.98 ms is 1.31–2.40 on the log scale.
- 3.8: NB09's `mu_b0` + ν = 259.91 + 7.44 = 267.35, and 267.18 − 259.91 = 7.3.
- 3.5 and 4.1: 563 + 451 + 474 = 1,488, and 1,488 / 3,000 = 49.6%.
- 4.1's "ruled out both regions": log ν = −3 is 9.2 SD below NB09's prior center, and
  `mu_log_sd_y` = −5 is 16.8 SD below.

The one near-miss is trivial and is listed as T3.

---

## Findings (most severe first)

### 1. Moderate (wrong reading of a plot feature; unexplained new visual): the black marks in the trace plot are divergences, but 3.1 reads them as "their draws", and the notebook never says what they are

**Cells:**
- [21] 2.2 (`e17de794`), `given`: mirror the edit;
- [32] 3.1 solution (`089b3d7c`);
- optionally [27] 2.4 solution (`3a003423`).

**What the marks are.** `azp.plot_trace_dist` draws two kinds of black marks, and **only when
there are divergences**. The source shows `trace_rug(..., mask=divergence_mask)`, with
default color `B1` and marker `|`:
- under each density, at the value of every **divergent** draw;
- along the bottom edge of each trace, at the divergent draw's position in the chain.

The figure confirms this. There are no marks at chain 3's values: none at `mu_log_sd_y` ≈ −5,
none at `sd_log_sd_y` ≈ 0 and none at `log_nu` ≈ 3.4. Chain 3 has 0 divergences.

**This is the first time students see these marks.** Every earlier notebook, NB01–NB10,
reports `Divergences: 0`; I checked each one's output. So NB11 is the first trace plot in the
course with any black marks, and here they are solid bars in all 14 panels. Nothing in the
notebook explains them.

**3.1 misreads them.** Its solution says: "under the density, their draws form a solid bar,
and their density is too low to see next to the stuck chain's narrow peak."
- The second half is right. A uniform density over 372 units is about 1/1,600 of chain 3's
  peak.
- The "solid bar" is the rug of the roughly 1,500 **divergent** draws, not the draws.
- The reading happens to point to the right range only because about half of these chains'
  draws diverge, spread across the whole range.
- A student who takes the bar to be "the draws" will be puzzled on the neighboring panels: why
  do chain 3's draws at `mu_log_sd_y` ≈ −5 have no bar?

This is the "wrong cause for a plot feature" class that NB09's review caught.

**The marks also hide chain 3 in two trace panels.** The bar is drawn along each trace
panel's lower edge. For `mu_log_sd_y` and `sd_log_sd_y`, chain 3 sits exactly there, at −5 and
0, so its trace line is completely covered (I zoomed in to check).
- 2.4's "its `mu_log_sd_y` stays near −5 … its `sd_log_sd_y` stays near 0" is correct, but
  only the density panels show it.
- In the `log_nu` trace, the bar sits near −370. A student could take it for draws piling up
  against the wall.

**Fix:**
- (a) Append to the 2.2 text:
  > Black marks in the trace plot show the draws that ended in a divergence: under each
  > density, at the draw's value, and along the bottom edge of each trace, at the draw's
  > position in the chain.
- (b) In 3.1, replace "under the density, their draws form a solid bar, and their density is
  too low to see next to the stuck chain's narrow peak" with:
  > under the density, the black marks of their divergent draws, about half of all their
  > draws, form a solid bar across the whole range, while their density is too low to see next
  > to the stuck chain's narrow peak
- (c) Optional, in 2.4, after "its `sd_log_sd_y` stays near 0", add:
  > (in those two trace panels, it is hidden under the black divergence marks; the narrow
  > peaks in the density panels show it)

### 2. Minor–moderate (cross-notebook coherence): 3.3 says the sampler "scales its steps for that parameter", which reads as contradicting NB08–NB10's "single step size for the whole posterior"

**Cell:** [35] 3.3 (`69444eba`), `exercise-question` + `given-answer`: mirror the edit.

**What the course has said so far.**
- NB08 Q3.2 and NB09 Q3.2: "the sampler chooses a single step size for the whole posterior
  during tuning".
- NB10 Q4.5, the notebook students have just finished, builds its explanation on the same
  point: "Because the sampler uses a single step size for the whole posterior (Notebook 8),
  every parameter then moves slowly."

**What 3.3 says.** Its second paragraph: "During tuning, the sampler learns how widely each
parameter ranges and scales its steps for that parameter accordingly."

**Why it matters.** Both statements are true. There is one global step size, measured in
units of each parameter's spread, which adapt_diag learns; the mean |Δ`log_nu`| of 71–75 per
draw confirms the scaling. But nothing reconciles them, and a student comparing NB10 4.5 with
NB11 3.3 will see a contradiction in how the sampler works. The NB10/NB11 contrast is exactly
what 3.3's last paragraph asks the student to understand.

**Fix:** replace that sentence with:
> The sampler's single step size (Notebook 8) is measured relative to how widely each
> parameter ranges, which it also learns during tuning.

The next sentence, "For `log_nu`, the range is hundreds of units, so a single path can carry
it a long way…", then follows unchanged.

### 3. Minor (argument robustness): 3.2's impropriety argument leans on PyMC's shortcut, so a student could conclude the improper posterior is a software artifact

**Cells:**
- [34] 3.2 solution (`3b2f00a2`);
- [33] 3.2 question (`47b951da`), `exercise-question`: mirror the edit (part b).

**(a) The answer.** "It does not change. … the ex-Gaussian is indistinguishable from a
Gaussian (Notebook 9, Question 4.4), and PyMC computes it with exactly the Gaussian formula
(Notebook 10, Question 4.5), whatever the value of ν."
- "Exactly constant" comes from the switch.
- 3.3 then says the lower *edge* is "the limit of the arithmetic, not anything in the model".
- A careful student could reasonably ask whether the *impropriety* is also PyMC's doing. It is
  not: an exact density only levels off at the Gaussian value, so the area is still infinite.
  The implementer's notes (mechanism point 1) say this, but the notebook does not.

**Fix (a):** append to the second paragraph of 3.2's answer, after "…nothing in the model
stops `log_nu` from decreasing.":
> This does not depend on PyMC's shortcut: computed exactly, the likelihood would only level
> off at its Gaussian value, never fall to zero, and the area would still be infinite.

**(b) The question.** It says "the $\operatorname{Normal}(0, 5)$ prior held the posterior back
from ever shorter tails (Question 4.4 there)". But NB10 4.4 says "nothing stops the posterior,
whose left side follows the prior's shape". Both are true at different scales, but side by
side they read as contradictory.

**Fix (b):** change the question's first sentence to:
> In Notebook 10, the data bounded the tail only from above; below that, the posterior followed
> the $\operatorname{Normal}(0, 5)$ prior, which kept it above about −15 (Question 4.4 there).

### 4. Minor (precision of the summary and of the NB10 contrast): 4.1 gives the PPC a reason that ignores the stuck chain, and its NB10 contrast overlooks that chain 3 shows NB10's own signature

**Cells:**
- [48] 4.1 solution (`38a1cdfe`);
- optionally [35] 3.3 (`69444eba`): mirror the edit.

**(a) "Deceptive results".** The bullet says "the posterior predictive check raised no clear
alarm, because in almost every draw the model was effectively a Gaussian model with no tail."
- The check used all four chains, so a quarter of its draws come from chain 3: a model with
  *no Gaussian part*.
- 3.7's own answer attributes the lopsided 50% bands of 308 and 332 to that chain.
- My regenerated draws confirm that the stuck chain actually made the check look *better*.
  With all four chains, only 332's day-4 point is outside its 90% band. With chains 0–2 alone,
  308's and 351's day-5 points also fall outside.
- The accurate reason is 3.7's: both extremes predict these data about as well as Notebook 9's
  model.

**Fix (a):** replace the clause with:
> and the posterior predictive check raised no clear alarm: a model with no tail, and even one
> with no Gaussian part, predicts these data about as well as Notebook 9's model

**(b) "Sampling".** The bullet ends: "Notebook 10's sampler failed with tiny steps and no
divergences; this one failed at the edge of what the computer can calculate." But chain 3 in
*this* notebook shows exactly NB10's signature, for a different cause, NB09's observation
walls (2.5):
- step size 0.00064;
- 100% of draws at the maximum tree depth;
- 0 divergences.

A student who compares 2.2's printout with NB10's may conclude that chain 3 is "Notebook 10's
failure again". Naming the difference sharpens the NB10/NB11 distinction, which is this
notebook's reason to exist.

**Fix (b):** in 4.1, change the sentence to:
> Notebook 10's sampler failed with tiny steps and no divergences, because of PyMC's switch;
> here, the stuck chain failed the same way for a different reason, the walls of Question 2.5,
> and the other three failed at the edge of what the computer can calculate.

Optionally append the same point to 3.3's last paragraph, before "The cause is the same…":
> The stuck chain, with its tiny steps and no divergences, looks like Notebook 10's chains, but
> its walls are the observations (Question 2.5), not the switch.

### 5. Minor (terminology consistency): "the four population-level parameters" excludes the between-participant SDs, but 2.2 and 2.5 call those population-level too

**Cells:**
- [0] intro (`b232434b`) and [9] 1.1 (`b474c893`), both `given`: mirror the edits, keeping
  the self-work badge URL.

**The conflict.**
- The intro says "the four population-level (or common-effect) parameters", and 1.1 says "Only
  the priors of the four population-level parameters change".
- 2.2's "Check population-level diagnostics" summarizes `sd_b0`, `sd_b1` and `sd_log_sd_y`.
- 2.5's "every population-level R-hat was 1.00" includes them too.
- The between-participant SDs are population-level hyperparameters, so "the four" suggests
  there are only four.

**Fix:**
- In 1.1, change "Only the priors of the four population-level parameters change" to:
  > Only the priors of four population-level parameters change
- In the intro, change "from the four population-level (or common-effect) parameters" to:
  > from four of the population-level (or common-effect) parameters

### 6. Minor (log accuracy, not the notebook): `03_execution_log.md` gives a wrong reason for the self-work notebook having no outputs

**File:** `03_execution_log.md`, "Self-work notebook" paragraph.

**The problem.** The log says the self-work notebook "cannot be run as-is (`pm.Flat` cannot
be prior-predictive-sampled, and 2.1-2.3 ask students to predict what fitting will do before
running it)". Neither reason is right:
- The self-work notebook runs top to bottom. Its placeholders are comments, and no `given`
  cell depends on a `solution` cell.
- It contains no `sample_prior_predictive` call.
- 2.1–2.3 are `given` cells, not prediction tasks.

Outputs are cleared because playbook §2 says so for every self-work notebook.

**Fix:** replace the parenthetical with:
> as for every self-work notebook (playbook §2)

### Trivial (optional)

- **T1. [27] 2.4 solution.** "R-hat reaches about 1.6 for `mu_log_sd_y`, `sd_log_sd_y`,
  `log_nu`…". `log_nu`'s value is 1.53. Suggested: "about 1.5–1.6".
- **T2. [28] 2.5, `given`: mirror the edit.** "the Gaussian standard deviations shrink to
  thousandths of a millisecond or less".
  - That is true of this run: 0.0066–0.0069 ms.
  - But 3 of the 16 stuck chains in the test runs had `mu_log_sd_y` of −4.1 to −4.5, which is
    0.011–0.017 ms.
  - This text is meant to be outcome-neutral for Colab runs, so "hundredths of a millisecond or
    less" is safer.
- **T3. [35] 3.3, `given-answer`: mirror the edit.** "At $\log \nu \approx -372.5$ … its square
  … becomes zero."
  - At exactly −372.50, ν² is still 5 × 10⁻³²⁴, the smallest subnormal.
  - It becomes 0 only below −372.567, and the sampler's gradient turns NaN between −372.56 and
    −372.57.
  - "≈ −372.6" would be exact. The course-level arithmetic, (10⁻¹⁶²)² = 10⁻³²⁴ < 5 × 10⁻³²⁴,
    works either way.
- **T4. [19] 2.1, `given`: mirror the edit.** "PyMC's default settings gave even more
  divergences." The test run used the default `target_accept` with 1,500 tuning draws, not
  PyMC's default of 1,000. "PyMC's default `target_accept`" is exact. The claim itself checks
  out: 2,804 divergences.
- **T5. [43] 3.7 solution (optional content).** Here the stuck chain drew participant 308's
  fast day-5 reaction time, one of Notebook 9's two exceptions, inside its 90% band. Without
  chain 3 it falls outside, at 290.1 against a band starting at 298.8. One clause could make
  the point that a failed fit can make the check look *better*. Finding 4a's fix already
  implies it, so skip this if brevity matters.
- **T6. [37] 3.4 solution code.** It hard-codes `coords={"chain": [0, 1, 2]}`, as NB10's 3.6
  hard-codes `"332"`. A Colab re-run of the solved notebook will often have different stuck
  chains: 9 of 10 test runs had one, in varying positions. An inline comment would help
  students who compare:
  ```python
  coords={"chain": [0, 1, 2]},  # the chains that did not get stuck in this run (Question 2.5)
  ```

---

## The questions in my brief: answers

- **1. Core mechanism.** It is correct. See "The mechanism, re-derived": the density is
  constant to six decimals with an exactly zero gradient, measured with the sampler's own
  function. The one gap is finding 3a, and it concerns the argument's presentation, not its
  truth.
- **2. Underflow explanation.** It is correct and exact. ν² underflows at −372.567, and the
  sampler's gradient turns NaN between −372.56 and −372.57, from a 0/0 in PyTensor's division
  gradient. The brief's own parenthetical conflates ν with ν² (see the correction above); the
  notebook does not.
- **3. NB10 vs NB11: distinct, not a restatement.**

  | | NB10 | NB11 |
  |---|---|---|
  | Priors | proper but naive | improper |
  | Prior predictive check | caught the problem | impossible (1.5) |
  | Posterior | proper, with its left side shaped by the prior | improper in two directions |
  | Step size | 0.0025 | 0.006–0.009 in non-stuck chains |
  | Maximum tree depth | 100% | about 0% in non-stuck chains |
  | Divergences | 0 | about 50% of non-stuck draws, at the NaN wall |
  | R-hat | about 1.03 | about 1.6, from a stuck chain |

  NB11 also adds three lessons NB10 does not have:
  - R-hat and ESS on a hand-picked subset certify nothing (3.4–3.5);
  - the posterior predictive check cannot see the failure (3.6–3.7);
  - the stuck chain answers a second unasked question (3.8).

  The shared thread, "a prior that puts its weight where the data carry no information", is
  stated once in 3.3 as the common cause, which is appropriate. There is some reinforcing
  repetition: "`mu_b1` looks like Notebook 9's but cannot be reported" and "no Notebook 9 in a
  real analysis". It is not redundant. Finding 4b would make the contrast sharper where it is
  currently blurred.
- **4. Conventions.**
  - **Naming.** Correct. `log_nu = pm.Flat("log_nu")` is population-only, with no `mu_log_nu`
    (grep: none). `mu_log_sd_y`, `sd_log_sd_y`, centered `log_sd_y` and the Deterministic
    `sd_y` follow playbook §3.1, and `nu` is a Deterministic. `mean_rt` is dropped, and 1.4
    says so.
  - **HDI and point estimate.** Summaries use `ci_prob=0.90, ci_kind="hdi"`. The PPC uses
    50%/90% HDIs with `point_estimate="mean"`. "median" appears nowhere.
  - **No forward-looking ending.** 4.1 is purely retrospective. There is no "Notebook 12",
    "next" or "later notebook".
  - **Tags.** 4 `section`; 19 `given`; 12 `exercise-question`, each followed immediately by
    exactly one `solution` (10 markdown, 2 code); 2 `exercise-question` + `given-answer` (2.5
    and 3.3), with the answer in the question cell. There are no untagged cells. Every local
    "Question N.M" reference resolves.
  - **Workflow steps.** All are visible: model (1.1, 1.4); priors (1.2–1.3); prior predictive,
    explicitly impossible (1.5); fit (2.1); diagnostics before interpretation (2.2–2.5);
    posterior quantities (3.1–3.5, 3.8); PPC (3.6–3.7); revision is implied by NB09's priors
    (4.1).
  - **Math and forbidden strings.** Math uses only `$`/`$$`. None of these appear: `print(model`,
    `lam=`, `kind="kde"`, `plot_population`, `population_mu` or `_z`.
- **5. Solution-cell facts.** Every number matches the output or a saved run (tables below).
  The errors are one plot misreading (finding 1) and precision issues (findings 4a and T1–T3).
  No arithmetic claim is wrong.
- **6. Self-work/solved consistency.** Verified by my own script:
  - 49 cells in each file, with identical ids, types, tags and order;
  - exactly 13 cells differ: the 12 `solution` cells, each exactly `- answer here` or
    `# answer here` of the right type, and cell 0, identical after the URL swap
    `sleep/solved/11_` → `sleep/11_`;
  - the self-work file has no outputs, null execution counts, and no `metadata.execution` or
    `metadata.widgets`;
  - both files pass `nbformat.validate`.

  The remaining top-level differences are the solved file's execution-time `widgets` and its
  `language_info.version` of 3.12.3 against 3.12.12. They match NB10's pair exactly, so this is
  not an issue.
- **7. Read as a student.** The narrative holds: intro, then what flat claims, then no prior
  check, then a fit that fails, then why (two improper directions), then what the draws still
  show, then why nothing can be reported, then the summary.
  - **Connection to NB09 and NB10.** Every NB09 and NB10 number a question needs is restated in
    the question itself: 8.0–14.6, 260, 2.8, 3.7–11 ms, 1.3–2.4, 11–220 ms, Normal(0, 5) and
    "about 20 units". Neither notebook needs to be open.
  - **Terms defined in place.** "Improper" (1.2), "NaN" (3.3), "flat region" (after 3.2) and
    "stuck" (2.5) are all defined where they appear. 2.1 uses "stuck" before 2.5 defines it but
    forward-references 2.5, which is acceptable.
  - **Gaps.** The divergence marks (finding 1) and the step-size contradiction (finding 2) are
    what a student would stumble on.
  - **The implementer's two level checks.** 2.5 is the right length: the stuck chain is on
    screen and must be explained where it first appears. 3.3's three paragraphs are each
    needed: the wall, the step scaling and `target_accept`, and the NB10 contrast. I would
    **not** use the shorter fallback.

## Numbers and figures checked against output

- **Matching run (`warm2.pkl`).** Chain means, per-chain divergences 563/451/474/0 and the
  summary all match the committed cells [22], [29] and [37].
  - Per-chain maximum-tree-depth shares are 0 / 0.1% / 0.7% / 100%, which supports "almost no
    draw" for the non-stuck chains.
  - Step sizes are 0.0056 / 0.0090 / 0.0083 / 0.00064.
  - `log_nu` ranges per chain: −371.98 to 1.12, −369.61 to −0.36, −371.63 to 1.14, and 3.18 to
    3.73.
- **2.1 and 2.5 test-run claims (12 saved runs).** At 0.97/2,500, 16 of 40 chains were stuck
  (40%), and 9 of 10 runs had at least one stuck chain. The run with no stuck chain had 1,932
  divergences and a largest population R-hat of 1.004. At the default `target_accept` with
  1,500 tuning draws, there were 2,804 divergences. At 0.99/1,500, 3 chains were stuck. All
  claims hold.
- **2.5's starting points.** The `jitter+adapt_diag` initial points have flat parameters of
  0 ± 1. The resulting `sd_y` is 0.35–3.9 ms and ν is 1.1–2.4 ms: "about 1 ms". Trajectories
  are near 0 ms. This holds.
- **1.5.** `pm.sample_prior_predictive` raises
  `NotImplementedError: Cannot sample from flat variable`. This holds.
- **Trace figure (viewed and zoomed).**
  - Chain 3 (dash-dot) is lower in `mu_b0` (about 246) and `mu_b1` (about 8.5).
  - It shows spikes at `mu_log_sd_y` ≈ −5 and `sd_log_sd_y` ≈ 0, visible in the density panels
    only (finding 1).
  - Its `log_nu` sits at about 3.4, at the top of the trace. The other three chains sweep −372
    to 0.
  - Black divergence rugs appear in every panel.
  - 2.4 and 3.1 match, apart from finding 1's misreading.
- **PPC figure (viewed, and compared with NB09's).**
  - The bands follow the trajectories as in NB09. Only 332's day-4 point (454 ms) lies outside
    its 90% HDI of 235.7–411.6.
  - The 50% bands of 308 and 332 are visibly pulled down and lopsided. For 332 on day 4, the
    50% HDI is 252.6–322.6 with a mean of 312.9.
  - 3.7's claims hold. See T5 for 308's day-5 point.
- **Cross-references.** All resolve and say what is cited:
  - NB09: 3.2 (walls), 3.5 (participant `coords`), 4.4 (approaches a Gaussian; `mu_b0` + ν),
    5.3 (PPC), 1.12's 11–220 ms, and the summary values of 8.03–14.61, 259.91, 2.79 and ν
    3.72–10.98;
  - NB10: 1.3, 2.6, 3.3 (tree depth; "steered by the slope"), 4.4 (see finding 3b) and 4.5
    (the switch).
- **NB09-review mistake classes.**
  - Wrong cause for a plot feature: repeated once (finding 1).
  - Undefined term or visual: repeated once, the divergence marks (finding 1). Finding 2 is a
    related contradiction.
  - False novelty: not repeated. Maximum tree depth and the slope are credited to NB10.
  - Prior-vs-data overstatement: not repeated. 3.1's "Only the upper end reflects the data"
    and 4.1's "the data determine the mean structure well" are both supported. The
    implementer's `meanflat` runs give `mu_b1` 11.4 [8.15, 14.71].
