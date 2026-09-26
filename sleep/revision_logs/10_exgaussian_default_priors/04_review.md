# Fresh-eyes review: notebook 10 — Priors that ignore the log link

Reviewer: independent agent (Step 3b of `sleep/REVISION_PLAYBOOK.md`). I did not write this
notebook.

**Inputs read in full:**
- `AGENTS.md` and the playbook, including §3.5's carve-out for NB10/11 as failure
  demonstrations.
- `01_plan.md`, `02_implementation_notes.md` and `03_execution_log.md`.
- Both NB10 notebooks, cell by cell, with every executed output. I also viewed all 5 rendered
  figures.
- NB09 solved, in full, with its outputs, and NB09's `04_review.md`, for calibration.
- NB01's diagnostic criteria (Q4.1) and NB08's step-size sentence (Q3.2).

**Independent checks** (`scratchpad/review10/`, pinned venv `scratchpad/nbenv`):
- **Source.** I read `inspect.getsource(pm.ExGaussian.logp)` in PyMC 6.3.2. It uses
  `pt.switch(pt.gt(nu, 0.05 * sigma), <gamlss ex-Gaussian>, log_normal(value, mu, sigma))`.
  The switch is exactly as 4.5 states.
- **New fit.** I ran the smooth, exact-density model with **only the tail prior naive**
  (`nuonly`; NB09's scale-hierarchy priors), at 0.95 / 2,000 tuning draws. The implementer's
  smooth run changed all three priors, so it could not separate the tail prior's effect from
  the scale priors'. Their `sdonly` run gave 40 divergences from the scale priors alone.
- **Saved runs re-analyzed.** I used the implementer's saved `idata` from:
  - the literal notebook run, which matches the committed summary to every displayed digit;
  - the literal 0.99 / 1,500 run;
  - the smooth all-naive run.

  I did not re-run the notebook itself. The orchestrator did that, and the literal run
  reproduces the committed output.

**Verdict: ready to commit after small markdown-only fixes. Nothing is blocking.**
- The failure is presented honestly. "0 divergences, 100% maximum tree depth" is correctly
  called a failure: 3.4 says "a sampler can fail without diverging".
- 3.4 applies Notebook 1's criteria correctly.
- The notebook never blames the ex-Gaussian likelihood itself.
- The 4.5 mechanism is correct and survived my independent test.
- I recommend findings 1–3. Findings 4–7 are minor.
- No re-execution is needed.
- Findings 1a, 2, 3, 6 and 7 touch `exercise-question`, `given-answer` or `given` cells.
  Mirror them in the self-work file by re-running `derive_and_verify_nb10.py`.

**Cell references** use `[index]` in the 56-cell notebook, the question number and the cell
id. Ids are identical in both files.

---

## Findings (most severe first)

### 1. Moderate (coherence with the notebook's own central lesson): 4.3–4.4 and 5.1 interpret the failed fit right after telling the student not to

**Cells:**
- [48] 4.3 question (`a1a98841`), an `exercise-question`: mirror the edit;
- [51] 4.4 solution (`7e66abf7`);
- [55] 5.1 solution (`c4920da6`).

**The rule the notebook states.** 4.2 [47] ends: "The diagnostics are checked for the whole
fit before any posterior quantity is interpreted." 5.1 says: "a quantity from a fit that fails
its diagnostics cannot be reported, however plausible it looks."

**What the notebook then does.**
- The 4.4 question asks students to "Translate the 90% HDI of `log_nu` … into milliseconds
  and compare it with Notebook 9's". That parameter has the worst mixing in the fit: bulk ESS
  108, tail ESS 117, R-hat 1.03.
- The 4.4 answer then draws a substantive conclusion from it: "the data still show that the
  tail is at most about ten milliseconds".
- 5.1 repeats "that bound of about ten milliseconds" as a finding, one sentence before saying
  such quantities cannot be reported.

**Why it matters.** A careful student will see the notebook break its headline rule two cells
after stating it.

**The conclusions themselves are right.** This finding is about framing only.
- In the well-mixed smooth all-naive run, the posterior/prior mass ratio for `log_nu` is
  about 1.3 in every bin below 0, 2.5 in [1, 2), 0.9 in [2, 2.5) and 0.04 above 2.5.
- The use in 4.3–4.4 is also legitimate. It diagnoses *where* the prior rather than the data
  shaped the draws, qualitatively, and the upper bound is corroborated by NB09's converged
  fit.
- But the notebook never says this.

**The same gap leaves the missing posterior predictive check unexplained.** NB06–09 all had a
predictive section. The implementer's decision to omit one here is right, but nothing in the
notebook tells the student that the omission is deliberate.

**Fix:**
- (a) Prepend to the 4.3 question body:
  > A fit that fails its diagnostics is neither reported nor used for predictions, which is
  > why this notebook has no posterior predictive check. Its draws can still show, roughly,
  > where the data and where the prior shaped the posterior, and that helps explain the
  > failure.
- (b) In 4.4, replace "the data still show that the tail is at most about ten milliseconds"
  with:
  > even these poorly mixed draws agree with Notebook 9's well-sampled fit that the tail is
  > at most about ten milliseconds
- (c) In 5.1's "Posterior" bullet, replace "which the data bound only from above: below that
  bound of about ten milliseconds, the tail's posterior largely follows the prior" with:
  > which the data bound only from above, at about ten milliseconds as in Notebook 9; below
  > that, the tail's posterior largely follows the prior

### 2. Minor–moderate (a visible contradiction the notebook sends students into): the printed warning says "increase `target_accept`", but 3.1 says that makes this model worse, and nothing reconciles the two

**Cells:** [34] 3.3 (`049b1fa4`), an `exercise-question` + `given-answer`: mirror the edit.
The same issue shows in [29] 3.1 and [36] 3.4.

**The contradiction.**
- The sampling output prints four times: "Increase `max_treedepth`, increase `target_accept`
  or reparameterize."
- 3.4 explicitly tells students to "Read the warnings printed by the sampling cell".
- 3.1 says that, with Notebook 9's `target_accept=0.99`, "this model samples even worse".
- A student who follows the sampler's own advice, or simply wonders why the notebook does
  not, gets no explanation.

**The 3.1 claim is correct.** I re-analyzed the saved literal 0.99 / 1,500 run:
- step sizes are 0.0006–0.0009, against 0.0019–0.0033 at 0.95;
- 100% of draws reach the maximum tree depth;
- R-hat is 1.52–1.76 on every population parameter;
- `mu_b1`'s chain means are 11.1, 11.5, 14.3 and 11.5.

**The reason is simple, and the notebook already teaches every piece in 3.3.** A higher
`target_accept` makes the sampler take smaller steps (Notebook 8). Under the 1,023-step cap,
each draw then moves even less. So the fact is stated, but its visible reason is not.

**Fix:** append to 3.3:
> The warning's suggestion to increase `target_accept` would make the steps smaller still,
> which is why Notebook 9's `target_accept=0.99` makes this model sample worse
> (Question 3.1). Neither setting removes the cause, which Section 4 examines.

This also gives 3.1's "These settings are not the cause" a reason the student can follow.

### 3. Minor–moderate (level/pedagogy of the deepest claim): 4.5's key step, "the sampler cannot follow the jumps", rests on something the course never says

**Cells:**
- [34] 3.3 (`049b1fa4`);
- [52] 4.5 (`e763e938`), both `exercise-question` + `given-answer`: mirror the edits.

**The mechanism is correct.** My checks:
- **The source switch.** Confirmed in the PyMC 6.3.2 source.
- **Where the switches lie.** At each participant's posterior-mean `sd_y` (6.2–57.8 ms), the
  switch points are at `log_nu` from −1.18 to 1.06, well inside the posterior HDI of −6.4 to
  2.2.
- **"Could fail differently, for instance with divergences".** This claim is sound and now
  properly isolated. My smooth-density run with **only the naive tail prior** gave:
  - 127 divergences, against NB09's 3 at 0.95;
  - step sizes of 0.074–0.100;
  - 0% of draws at the maximum tree depth;
  - R-hat ≤ 1.004 and participant bulk ESS ≥ 1,356, in 30 s.

  So a smooth implementation fails with divergences because of the tail prior alone. It is
  not the scale priors, which confounded the implementer's all-naive smooth run.
- **Level.** The explanation is pitched about right. It reuses NB08's single-step-size
  sentence and 3.3's new tree-depth explanation, and it names the PyMC version, which serves
  AGENTS.md's software-versioning point. I would **not** use the implementer's fallback of
  shortening 4.5.

**Three small gaps make it harder to follow than it needs to be:**
- **What steers the path, and why a jump defeats it.** 3.3 says the path moves "in steps"
  but never says what steers them. Two new terms appear undefined:
  - 3.3's "gradient evaluation";
  - 4.5's "log density".

  Neither appears anywhere in NB01–09 (I grepped). This is the "technical term before
  definition" class NB09's review caught. Without "steered by the slope", "cannot follow the
  jumps accurately" is an unexplained step.
- **Why there are no divergences.** The notebook's headline is a failure *without*
  divergences, but it never says why. The jumps are small, up to about 0.4 on the
  log-density scale by the implementer's probe, far below what counts as a divergence. 4.5
  has every ingredient for this and stops one clause short.
- **The comparison that exonerates the likelihood.** In NB09, ν's 90% HDI (3.7–11 ms) lay
  above 5% of almost every participant's `sd_y`. The largest, participant 332's about 58 ms,
  gives a switch at about 2.9 ms. So the same likelihood, in the same software, sampled in
  half a minute. Saying so makes 4.5's "the cause would be the same: the prior" concrete, and
  puts the failure firmly on the priors.

**Fix:**
- In 3.3, change "follows a simulated path through the parameter space in steps of the size
  chosen during tuning (Notebook 8)" to:
  > follows a simulated path through the parameter space, steered at each step by the slope
  > (the gradient) of the log posterior density, in steps of the size chosen during tuning
  > (Notebook 8)
- In 4.5, change "At each participant's switch, the log density jumps slightly" to:
  > At each participant's switch, the log posterior density jumps slightly: far too little to
  > count as a divergence, but a path steered by slopes cannot see a jump coming.
- Append to 4.5's second paragraph:
  > Notebook 9's tail prior kept ν at several milliseconds, above almost every participant's
  > switch, and the same likelihood sampled in half a minute.

### 4. Minor (statistical precision; prior vs. data): 4.4's last sentence presents e^(mean of log ν) as "a tail of about 0.15 ms: effectively no tail at all"

**Cell:** [51] 4.4 solution (`7e66abf7`), last sentence.

**Why the value misleads.** From the literal-run `idata`:
- the posterior **mean** of ν is 1.6 ms;
- its **median** is 0.26 ms;
- e^(mean log ν) is 0.15 ms.

So "0.15 ms" is neither the mean, per the course's point-estimate convention, nor the median.
Question 1.3 of this very notebook teaches that "exponentiating the center of a log-scale
Normal gives the median". A student applying that rule here would misread 0.15 ms as the
posterior median, but this posterior is far from Normal.

**Why the wording misleads.** By the paragraph's own argument, the value is set by the prior.
Yet "effectively no tail at all" reads like a finding about reaction times. That is the "prior
vs. data" overstatement class from NB09's review.

**Fix:** replace the sentence with one of these, the first preferred:
> The prior's pull shows in the summary: the mean of `log_nu`, about −1.9, sits where the
> prior put its mass, not where the data point.

Or delete the sentence; the HDI discussion already makes the point.

### 5. Minor (argument strength): 4.2's "looks fine but can't be trusted" is sound but abstract; it misses the concrete link the notebook's own output supplies

**Cell:** [47] 4.2 solution (`e7522f80`).

**What 4.2 gets right.** Its logic is correct and appropriately worded. It says "nothing
guarantees that the parts that look fine are right", and does not claim they are wrong. That
matters: the smooth refits give `mu_b1` of about 11.4 [8.1, 14.6], so the interval happens to
be right.

**The problem.** Its evidence is mostly either abstract ("the joint posterior") or invisible
to the student (the 0.99 run). A direct link is visible in the notebook: `mu_b1` is the
population center of the participants' `b1` values, and `b1[332]` is the worst-mixing
parameter in the screen (3.5 and 3.7), with its chains disagreeing by about 2 ms/day.

**Nit.** 4.2 calls `mu_b1`'s R-hat of 1.01 "acceptable", while 3.4 put the same value "at the
limit of 1.01".

**Fix:** replace "But all parameters are sampled together: chains that have not explored…"
with:
> But all parameters are sampled together, and `mu_b1` is the center of the participants'
> `b1` values, including `b1[332]`, the worst-mixing parameter in the screen (Question 3.7).
> Chains that have not explored the posterior of `log_nu` or of participant 332 have not
> explored the joint posterior either, so nothing guarantees that the parts that look fine
> are right.

Optionally, change "look acceptable" to "would pass on their own".

### 6. Minor (Colab honesty): the notebook does not warn that a run this pathological can differ in detail on another computer

**Cell:** [29] 3.1 (`5cc16284`), `given`: mirror the edit.

**What the implementer found.** The notes show that even integer versus float prior constants
change the sampler's path with the same seed. They also say Colab may give a different worst
participant and different ESS and R-hat values. The qualitative failure is robust across the
seeds and constant types they tested.

**What the notebook says.** Nothing tells the student this.
- The solutions quote exact values: 332, 372 and 309; ESS 100–150; R-hat 1.02, 1.03 and 1.04.
- 3.6's solution code hard-codes `"332"`.
- A Colab student comparing their run with the solved notebook may find mismatches and
  conclude they made an error.

It is also a genuine teaching point, in keeping with AGENTS.md's reproducibility theme: a
well-mixed fit is reproducible in its conclusions, and a failed one is not reproducible even
in its details.

**Fix:** append to 3.1, after "that is part of the result.":
> When a sampler fails this badly, details such as the exact R-hat and ESS values, and even
> which participant comes out worst, can change from one computer to another; the overall
> pattern does not.

### 7. Minor (accuracy): the intro says Notebook 9 chose "those priors" in milliseconds, but one of the three was a unit-free carry-over

**Cell:** [0] intro (`b939c3db`), `given`: mirror the edit, keeping the self-work badge URL.

**The problem.** The intro says: "Notebook 9 chose the priors for the participants' Gaussian
standard deviations and for the tail mean in milliseconds, and only then translated them …
This notebook … changes only those priors." But of the three changed priors, `sd_log_sd_y`'s
was not chosen in milliseconds in NB09. It carried over from Notebook 8 as unit-free, as this
notebook's own 1.4 question says.

**Fix:** replace the first paragraph and the first clause of the second with:
> Notebook 9 chose its priors for a typical participant's Gaussian standard deviation and for
> the tail mean in milliseconds, and only then translated them to the log scale on which the
> model uses them; its prior for how much participants differ was a ratio carried over from
> Notebook 8.
>
> This notebook keeps Notebook 9's model and changes those three priors.

### Trivial (optional)

- **[36] 3.4 (`68952ad7`).** `sd_log_sd_y`'s ESS of 171 bulk and 220 tail also falls short of
  Notebook 1's "comfortably in the hundreds", but only `log_nu`'s ESS is mentioned. Suggested
  addition: "and `sd_log_sd_y` has only about 170 bulk effective draws". Also, "wanders slowly
  between about −15 and 2": the largest draw is 2.75 and the trace reaches about 2.5, so the
  wording is fine but could say "about 3".
- **[49] 4.3 figure.** The `log_nu` posterior KDE stops abruptly at its right end, near its
  highest point, because the drawing stops where the draws stop. 4.4's "the data only cut off
  the right side" is true: P(ν > 9 ms) is 0.75%. But the vertical cliff is partly drawing.
  4.4 already explains the bumps as noise; a half-clause could do the same for the edge. Not
  needed.
- **[27] 2.6 (`892cde7f`).** Criterion 5 is worded as "without making tails of several hundred
  milliseconds routine". Citing 1.3's "about 8% above a full second" would map the verdict
  onto that wording directly, instead of "allowing tails of seconds".

---

## The questions in my brief: answers

- **Tags.** Correct and complete. The 56 cells are:
  - 5 `section`;
  - 12 `exercise-question`, each followed immediately by exactly one `solution`;
  - 2 `exercise-question` + `given-answer` (3.3 and 4.5), in the NB09 5.6 pattern, with the
    answer in the question cell;
  - 25 `given`.

  There are no untagged or orphaned cells. Every question starts with `###` and every
  section with `##`.
- **Self-work derivation** (my own script):
  - the files have identical ids, types, tags and order;
  - exactly 13 cells differ: 12 `solution` cells, each exactly `- answer here` or
    `# answer here` of the right type, plus the badge URL, the only change in [0];
  - no outputs, null execution counts, and no `metadata.execution` or `metadata.widgets`;
  - no `given` code depends on a `solution` cell (3.6, 4.1 and 4.3 are terminal plots).
- **"0 divergences but 100% maximum tree depth"** is presented as a real failure, not
  "mostly fine": 3.4 says "that is the only criterion clearly met", and 5.1 agrees.
- **3.4 applies Notebook 1's criteria correctly.** Notebook 1's wording is: "R-hat no larger
  than about 1.01, bulk and tail ESS comfortably in the hundreds".
  - 1.02–1.03 fails, and 1.0053–1.0095 is fairly "at the limit";
  - `log_nu`'s 108/117 fails;
  - the trace verdict matches the figure: `log_nu` chain means are −2.24, −2.22, −1.38 and
    −1.72;
  - maximum tree depth is correctly added as a new diagnostic, via 3.3. 1,023 steps holds:
    every `n_steps` is 1,023 and the share of draws at the maximum is 99.925%.
- **4.2's argument** is sound, and correctly does not claim the interval is wrong; finding 5
  would make it concrete. `mu_b1` looks fine in this run because it is nearly uncorrelated
  with `log_nu`: the correlation is −0.01. That cannot be shown from the notebook, so I would
  not add it.
- **4.5's level.** It is appropriate; see finding 3. It builds only on NB08's step-size
  sentence and 3.3, and three one-clause additions close its gaps.
- **The two scratch-based claims.** Both are stated as plain facts, which is right. Both
  check out independently:
  - 3.1 "samples even worse": the saved 0.99 run above.
  - 4.5 "for instance with divergences": my `nuonly` smooth run, 127 divergences from the
    tail prior alone.

  **For the implementation notes**, record the `nuonly` smooth run as the cleaner evidence.
  In it, divergent draws are enriched at `log_nu` in [1, 3) with a small minimum `sd_y`:
  54% of divergences, against 13% of draws. That is NB09's steady-participant edge, reached
  with a step size tuned for the wide `log_nu` range. So "the cause would be the same" holds
  at the level of the root cause, the prior, but not as identical geometry. The notebook's
  wording is general enough to be correct.
- **Leftover names.** None. `Reaction` appears only in the axis label and in
  `observed=sleep["Reaction"]`. "intercept" and "slope" appear only in code comments. There
  is no `_z`, `lam=`, `print(model`, `residual_scale`, `sigma_intercept`, `nu_intercept`,
  `population_mu`, `plot_population`, `kind="kde"`, `\(` or `\[`.
- **Closing section.** 5.1 is purely retrospective, with no "Notebook 11", "next" or preview.
- **Not blaming the ex-Gaussian likelihood.** Every place attributes the failure to the
  priors: the intro, 2.1 ("any new failure comes from the three log-scale priors"), 3.1, 4.5
  ("These details belong to PyMC's current implementation … The cause would be the same:
  the prior") and 5.1 "Units". Finding 3's NB09 sentence would make this airtight.
- **No posterior predictive check.** Skipping it is right. The only gap is that the omission
  is never stated; finding 1a closes it in one sentence.

## Numbers and figures checked against output

- **Literal-run `idata`.** It reproduces the committed summary: `mu_b1` 11.20 [8.23, 14.52];
  `log_nu` −1.89 [−6.44, 2.18], ESS 108/117. Participant 332's chain means are:
  - `b0`: 286.8, 283.6, 284.2, 274.8, so one chain is about 10 ms lower;
  - `b1`: 8.72, 9.46, 8.71, 11.23, so one chain is about 2 ms/day higher.
- **1.3 and 1.4 (analytic).**
  - P(11 < ν < 220) is 17.5% ("about 18%"), and P(ν > 1 s) is 8.4%;
  - e^±10 gives 0.00005 ms to 22,026 ms;
  - 30/e^5 is 0.20 ms and 30·e^5 is 4,452 ms;
  - e^(1/3) is 1.40.
- **2.4.** The `sd_log_sd_y` draw ratio is 34.2067 / 2.2804 = 15.0, exactly the ratio of the
  Exponential scales. The ×15 claim is consistent.
- **Figures viewed.**
  - The prior predictive: a 1e51 axis; only row 2, panel 1 (333) is visible, from about −1.3
    to +1.2.
  - The population trace: `log_nu` wanders from about −15 to 2.5, and the chain densities
    differ.
  - 332's trace: one dash-dot chain is shifted in `b0` and `b1`.
  - `mu_b1`'s dist: HDI about 8.2–14.5. The label reads "11.0 mean", an ArviZ label rounding
    of 11.20 that no answer quotes.
  - The prior–posterior plot: `mu_log_sd_y` is a spike near 2.8; `log_nu` is prior-shaped on
    the left and bumpy.
- **4.4's "left side follows the prior; favors a few ms only slightly".** Supported by the
  smooth, well-mixed run with the notebook's own priors: posterior/prior ratio about 1.3 in
  every bin below 0, 1.65 in [0, 1), 2.5 in [1, 2) and 0.04 above 2.5. The failed run's
  bumps (for example 2.84 in [1, 2)) are sampling noise, as 4.4 says.
- **Cross-references.** All resolve and match the source: NB09 1.10, 1.12, 2.1, 2.4
  (log-center → median), 2.7 (333, about 2.3, about 145 s), 4.2 (8.0–14.6), 4.4 (3.7–11 ms;
  the lower end is prior-driven, the "approaches a Gaussian" argument), and NB09's committed
  33 s; NB08 3.2 (single step size chosen during tuning).
- **NB09-review mistake classes.**
  - Wrong cause for a plot feature: not repeated. 2.4's shared draw and 4.4's bumps are both
    verified.
  - Undefined term: repeated mildly, as "gradient" and "log density" (finding 3).
  - False novelty: not repeated. Tree depth and `plot_prior_posterior` really are new.
  - Prior-vs-data overstatement: repeated mildly (findings 1 and 4).
