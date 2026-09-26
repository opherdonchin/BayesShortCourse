# Fresh-eyes review: notebook 09 — Ex-Gaussian distributional model

Reviewer: independent agent (Step 3b of `sleep/REVISION_PLAYBOOK.md`). I did not write this
notebook.

**Inputs read in full:**
- `AGENTS.md` and the playbook, including the two §3.1 additions this notebook established:
  - the ms-scale/identity mean structure for NB09–11;
  - the `log_<param>` naming for population-only log-linear parameters.
- `01_plan.md`, `02_implementation_notes.md` and `03_execution_log.md`.
- Both NB09 notebooks, cell by cell. That covers every executed output, all 11 rendered
  figures and the graphviz SVG. I parsed the SVG's nodes and edges; I did not only look at
  the picture.
- NB08 solved (text and outputs) and NB08's `04_review.md`, for calibration.
- NB05 solved (model cell, summaries, and the 2.5 and 4.3 answers).
- NB01–08 solved, grepped for "link".

**Independent checks.** My scripts are in `scratchpad/review09/`. None of them reuses the
implementer's or the orchestrator's scripts, and I ran them in the pinned venv
(`scratchpad/nbenv`):
- `repro.py` executes the solved notebook's **literal code cells**, with only `DATA_URL`
  pointed at the local CSV. It reproduces the committed posterior to every displayed digit:
  - 0 divergences;
  - `mu_b0` 259.91, `mu_b1` 11.26 [8.03, 14.61], `nu` 7.44 [3.72, 10.98];
  - `mu_log_sd_y` 2.79 and `sd_log_sd_y` 0.76 [0.47, 1.03].
- `diff.py` is my own solved → self-work diff and tag audit.
- `checks.py` computes the tail probabilities, the `sd_y` HDIs, the total SDs and the prior
  HDIs.
- `pred.py` computes the posterior- and prior-predictive band edges and widths, the coverage,
  the negatives and participant 333's prior means.
- `divloc.py` refits at the **default** `target_accept` and localizes the divergences
  against a random-draw baseline. This is the test NB08's review found missing there.
- `widenu.py` refits with a wide tail prior, `sd_log_nu = 2`, to test 4.4's
  "the lower end is prior-driven" claim myself.

**Verdict: ready to commit after small markdown fixes. Nothing is blocking.**
- I recommend findings 1–4. They are markdown-only, so no re-execution is needed.
- Finding 2 touches an `exercise-question` cell, so re-derive the self-work file afterwards.
- Finding 5 is trivial polish.

Every number I checked matches the executed output. The three substantive decisions all
hold up under independent testing. The notebook does **not** repeat any of NB08's three
review findings in the form they took there. Finding 3 is a milder cousin of NB08's
"implies something is new" finding.

Cell references give `[index in the 103-cell notebook]`, the question number and the cell
id. The ids are the same in both files. Edits to `solution` cells change the solved file
only. Edits to `exercise-question` or `given` cells must be mirrored in the self-work file:
re-run `derive_and_verify_nb09.py`.

---

## Findings (most severe first)

### 1. Minor–moderate (accuracy, and it blurs the notebook's central ms-vs-log contrast): the summary credits the plausible prior-predictive center to the log-translated priors

**Cell:** [102] 6.1 solution (`c4ad670e`), "Priors" bullet.

> Priors chosen in milliseconds and translated to the log scale gave prior predictions
> centered on plausible reaction times, unlike the log-scale priors of Notebooks 6–8, which
> centered baseline reaction times near 150 ms.

The priors that center the prior predictions are the **mean-structure** priors,
`mu_b0 ~ Normal(250, 100)`. They are Notebook 5's, in milliseconds, and are **not**
translated to any log scale. That is exactly the point of 1.6 and 1.7. The priors that
*were* chosen in ms and translated to the log scale, `mu_log_sd_y` and `log_nu`, govern
the spread and skew of the predictions, not their center.

The tail prior does shift the center up, by its prior mean of about 64 ms, but not through
any log translation. The day-0 50% band edges, with medians of 208 and 363 ms, sit around
`mu_b0` plus that shift.

Why this matters more than a wording slip:
- The notebook's key new lesson, per 1.6, is that the mean structure is back on the natural
  scale and only the positive parameters go through a log link. This bullet merges the two
  kinds of prior into one.
- The README frames NB10's lesson around priors that "ignore the log link". So a student
  should leave NB09 knowing which priors the log translation actually applies to.
- 2.6's own wording is correct: it attributes the 150 ms center to NB06–08's "log-scale
  baseline prior".

**Fix:** replace the bullet's first sentence with:

> The mean-structure priors are Notebook 5's, already in milliseconds, so the prior
> predictions are centered on plausible reaction times, unlike Notebooks 6–8, whose
> log-scale baseline prior centered them near 150 ms. The new priors, for the Gaussian
> standard deviations and the tail mean, were chosen in milliseconds and translated to the
> log scale, and allow plausible amounts of scatter and skew (Question 2.4).

Keep the bullet's remaining sentence ("As in Notebook 5, the broad mean-structure
priors…") unchanged.

### 2. Minor–moderate (pedagogy): "log link" first appears, undefined, in 1.6's title, and is applied retroactively to NB06–08

**Cells:**
- [18] 1.6 question (`af2c5129`), an `exercise-question`, so mirror the edit in the
  self-work file;
- the term is then used in [19], [27] 1.10 ("The log link does the same job in both
  notebooks"), [30] 1.12 and [102].

"Link" appears **nowhere** in NB01–08 (grepped). NB06–08 described the lognormal as
modeling log reaction time. NB08 described its `log sd_y` hierarchy without naming it. So
NB09's 1.6 asks "Why does $\mu_{y,i}$ need no log link here, unlike in Notebooks 6–8?"
using a term the student has never been given.

The term also labels two different constructions:
- NB06–08's log-scale location. Strictly this is the lognormal's own parameterization,
  and a GLM or brms user would call its `mu` identity-linked.
- NB08's and NB09's exponentiated scale and tail parameters.

The informal usage is defensible and matches the README. But the term matters beyond this
notebook: the README describes NB10 as priors "that ignore the log link". NB09 is where
the term should be defined, once.

The 1.6 question body already contains almost all the needed content. 1.12's "we give it a
log link: a Normal prior for $\log \nu$" comes six questions later, too late to serve as
the definition.

**Fix (question cell; mirror it in the self-work file).** Replace the 1.6 question body
with:

> In Notebooks 6–8, $b_0$ and $b_1$ were on the log scale: the lognormal's location is the
> log of the median reaction time, so the mean structure reached milliseconds only through
> exponentiation. Modeling a quantity on the log scale and exponentiating it in this way is
> called a **log link**; Notebook 8 used one for `sd_y`. What scale are `b0` and `b1` on
> now, and which parameters of this model do need a log link?

With this change, the answer in [19] needs no edit.

### 3. Minor (novelty framing, a milder cousin of NB08 review finding 2): 5.5 says each participant's bands "now" match their scatter, crediting only the contrast with NB05

**Cell:** [94] 5.5 solution (`3480f3ac`).

> Each participant's level and rate of change are reproduced, as in Notebook 5, and each
> participant's bands **now** match their own day-to-day scatter.

The question rightly asks for a comparison with NB05, because this model's residual
variation is additive in ms, as NB05's was. But participant-specific bands are not new
here: NB08 introduced them. NB08's own 5.5 was "resolving the mismatch Notebook 7 left".
As written, a student could read 5.5 as this notebook's achievement. The intro ([0]) and
the summary do not make this mistake; this one sentence does.

**Fix:** change the first sentence to:

> Yes. Each participant's level and rate of change are reproduced, as in Notebook 5, and,
> as in Notebook 8, each participant's bands match their own day-to-day scatter.

The following NB05 comparison is good and should stay: "In Notebook 5 every participant's
90% band was roughly 90–100 ms wide…".

### 4. Minor (honesty nuance): 4.4 attributes only the *lower end* of the tail interval to the prior, but the prior also roughly doubles the mean that 4.5, 5.2 and 5.4 then quote

**Cell:** [77] 4.4 solution (`61159259`), second paragraph.

4.4 says three things:
- "The data mainly establish the upper end: the tail is at most about a dozen
  milliseconds."
- "They cannot distinguish a tail of a few milliseconds from no tail at all."
- "The lower end of the interval, near 4 ms, is where the lower tail of the prior stops
  the posterior."

All three are correct, and I reproduced their basis (decision iii below). But the prior's
influence is not confined to the *lower end*. The prior density on $\log\nu$ rises by
about 3.6 nats, a factor of about 37, between ν = 4 and ν = 11 ms, so it tilts the whole
posterior upward inside its HDI.

A refit with a wider tail prior (`sd_log_nu = 2`, same center) moves the posterior
**center** down to a few milliseconds:

| Run | ν mean | 90% HDI | Other |
|---|---|---|---|
| Implementer | 3.7 | [0.07, 6.8] | |
| Mine | 2.1 | lower edge 0.3 | P(ν < 3) = 75%; 95th percentile 5.1 ms |

Both wide-prior fits are pathological:
- the step size is about 0.001;
- every iteration hits the maximum tree depth;
- my R-hat for ν is 1.42.

So their exact values are not trustworthy, and indeed differ. But they agree in direction:
without the informative prior, the fitted tail is a few milliseconds or less. The
notebook's "about 7 ms" is roughly double what the data alone suggest. That value is quoted
in 4.5, 5.2 and 5.4, and it is also the source of 4.4's own 8 ms `mu_b0` offset. The
notebook describes only "the lower end of the interval" as prior-driven, so a student would
reasonably read the 7 ms mean as the data's estimate.

This is not an overclaim in the summary. 6.1 quotes only the data-driven upper bound: "at
most about a dozen milliseconds". The issue is confined to one sentence in 4.4.

**Fix:** extend the paragraph's last sentence:

> The lower end of the interval, near 4 ms, is where the lower tail of the prior stops the
> posterior, and the prior also holds up the mean of about 7 ms: what the data establish is
> the upper bound.

Leave 4.5, 5.2 and 5.4 unchanged. "About 7 ms" is a correct statement about this fitted
model, and 4.4 will then have told the student how to read it.

### 5. Trivial

- **[23] 1.8** (`10d26ec4`). The question asks whether "`mu_b0` is still the typical
  baseline" and whether "`b1` is still the daily change". The answer opens "`b1` is, but
  `b0` is not." Write "`b1` still is; `b0` and `mu_b0` are not." so that it answers what
  was asked. The paragraph already covers `mu_b0` at its end.
- **[102] 6.1** (`c4ad670e`), "Fitted components". "about 8–14.6 ms/day" should be
  "about 8.0–14.6 ms/day", to match 4.2 and the unrounded 8.03.
- **[51] 2.6** (`5bbb17f2`). The paragraph first says the negatives "come **mainly** from
  the broad mean-structure priors", then that "the new residual-scale and tail priors **do
  not cause** them". The implementer's attribution found 90% of day-7 negative draws
  driven by a negative `mu_y`, and about 6% involving `sd_y` > 100 ms. "are not their main
  source" is accurate and keeps the sentence consistent with "mainly".

---

## The implementation's substantive decisions: reviewed

**(i) Mean-structure constants verified against NB05 directly: agree.**
- I compared NB05 solved's model cell with NB09's [21]. The constants are identical:
  `250/100/25` and `0/20/10`. The variable names, centered form, `pm.Data` nodes and `mu_y`
  Deterministic are the same too.
- NB05's `change_7` is correctly dropped, because no NB09 question uses it (§3.6).
- The added code comments, "(ms), from Notebook 5", are accurate and help the ms-vs-log
  contrast.
- The fitted `mu_b1`, 11.26 [8.03, 14.61], against NB05's committed 11.30 [8.07, 14.62],
  confirms the reuse.
- The playbook's §3.1 correction matches what the notebook actually does: ms-scale
  `b0`/`b1`, with a log link only on `sd_y` and `nu`.

**(ii) Keeping `nu` population-only: agree.** The reasoning is sound, and my own evidence
points the same way.
- 1.11's argument is the right one at course level. Separating a tail from Gaussian
  scatter needs the *shape* of the residual distribution, and eight observations that also
  fit `b0`, `b1` and `sd_y` cannot show it.
- I did not re-run the implementer's per-participant-`nu` fit, with its 167 divergences and
  `sd_log_nu` posterior ≈ prior. But my wide-prior refit (see iii) shows that even the
  **pooled** tail, informed by all 144 observations, has a likelihood that is nearly flat
  toward ν → 0. A per-participant tail from eight observations would a fortiori carry
  essentially no information. This is consistent with the implementer's finding.
- The naming follows the new §3.1 block exactly: `log_nu`, constants `mu_log_nu` and
  `sd_log_nu`, and `nu = pm.Deterministic("nu", pm.math.exp(log_nu))`. The graph confirms
  that `log_nu → nu → {y, mean_rt}` lies outside both plates.

**(iii) The short tail and its prior-driven lower end: agree, and the disclosure is honest.**
My numbers from `checks.py`:
- Posterior ν is 7.44, 90% HDI [3.72, 10.98].
- P(ν > 12) = 3.6% and P(ν > 13) = 1.6%, so "at most about a dozen milliseconds" is a
  fair, not overstated, reading of an HDI edge.
- Analytic prior P(ν < 11) = 2.2%.
- The prior puts only 2.5% of its mass below the posterior's 95th percentile, so "the
  posterior lies almost entirely in the lower tail of the prior" is exact.
- The wide-prior refit (`widenu.py`, `sd_log_nu = 2`) points the same way as the
  implementer's:
  - ν has a mean of 2.1 and a 90% HDI lower edge of 0.3 ms;
  - P(ν < 1) = 22% and P(ν < 3) = 75%;
  - P(ν > 12) = 0, with a 95th percentile of 5.1 ms.

  The implementer's run gave a mean of 3.7 and [0.07, 6.84]. Both runs are pathological:
  - the step size is about 0.001;
  - every iteration hits the maximum tree depth;
  - my R-hat for ν is 1.42 and it took 285 s.

  So the exact values are unreliable and differ, but they agree qualitatively. The data
  bound the tail from above, and the likelihood is nearly flat toward ν → 0. The base
  model's lower end, and much of its center, come from the prior (finding 4).
- **For NB10/11 planning (record only):** this independently confirms decision 5's warning.
  A weakly informative `log_nu` prior alone drives this model into a near-unsampleable
  region.

The implementer was right not to retune the prior. The notebook reports the conflict in
4.4, 4.5 and 6.1 instead of hiding it. "At most about a dozen" is a *conservative*
data-driven bound: the prior pushes ν upward, so the likelihood alone would put the upper
end lower still. Finding 4 is the only refinement.

The session-average explanation in 4.5 checks out:
- lme4 documents `Reaction` as "Average reaction time (ms)".
- The CLT argument is standard.
- It is clearly framed as "part of the reason", not as a result.

I would keep it. It is the one sentence that makes the surprising finding scientifically
intelligible.

**(iv) `target_accept=0.99` and the "near-vertical left edge": statistically correct, and
the evidence carries weight this time.**
- **Premise.** My default-settings refit gives **38 divergences**, the same count as the
  orchestrator's run with the same seed. PyMC also warns that R-hat > 1.01 for some
  parameters, so the default is not merely cosmetically imperfect. The adapted step size is
  0.18–0.24 at 0.8, against 0.04–0.06 at 0.99.
- **Mechanism (analytic).** As `sd_y` → 0 with ν fixed, the ex-Gaussian tends to a
  shifted exponential on [`mu_y`, ∞). Its log-likelihood in `mu_y`:
  - falls **linearly**, with slope 1/ν, as `mu_y` moves down away from the observations;
  - falls **quadratically with curvature ~1/`sd_y`²** once `mu_y` passes above an
    observation.

  That is precisely 3.2's "penalized gradually, through the tail" versus "penalized
  abruptly", and it gives each steady participant's (`b0`, `b1`) posterior sharp,
  high-curvature edges. The answer's level of explanation is right for the course.
- **Localization, tested against a random-draw baseline.** This is the check whose absence
  weakened NB08's evidence. Take the draws in which participant 309, 349 or 352 has
  `sd_y` below its own 3rd posterior percentile:
  - they are **26 of the 38** divergent draws, against **8.4%** of all draws;
  - for 309 alone, 23/38 against 3.4%;
  - for 349 alone, 24/38 against 4.5%.

  For comparison, *any* participant below its 3rd percentile is 32/38 against 37.6%, which
  is uninformative, as NB08's review warned. So the steady-participant enrichment is real.
  349 is as implicated as 309, but "such as 309" in the question is fine.
- **Taught background.** The 3.2 question reuses NB08's step-size sentence ("As in
  Notebook 8, the sampler chooses a single step size…"). The course has now taught this
  sentence, so NB08 finding 1 is not repeated. The "imagine the Gaussian part becoming very
  narrow" prompt ties the geometry to the supplied density figure, which is good
  scaffolding.
- "Even at 0.99, a different random seed occasionally produces a single divergence" is
  honest and matches the implementer's seed study.

**Implementation notes, record only.** Decision 3's "22 of the 38 default-setting
divergences fall in that 3% of draws" states no baseline. My run above supplies it and
supports the claim strongly. No change is needed, but a future reader of the notes would
benefit from one added clause, e.g. "(against about 3% of all draws)".

## NB08's three review findings: not repeated

1. **Question assuming untaught sampler background.** Not repeated. See (iv): 3.2 carries
   NB08's step-size sentence and grounds the new geometry in Question 1.2's figure.
2. **Summary implying something is new that an earlier notebook already had.** Not
   repeated in 6.1:
   - the "Priors" bullet credits Notebook 5 for the sub-zero bands;
   - 2.7 credits NB08's same-origin spikes and says only the *direction* is new;
   - 4.7 says "as in Notebook 8";
   - 5.8 says "as in Notebooks 5–8".

   The one lapse is finding 3 (5.5's "now").
3. **HDI-edge value called "ruled out"/"excluded".** Not repeated. Grepping both files for
   "ruled out", "rule out", "exclude" and "excluded" finds only "the data cannot rule out a
   very small Gaussian standard deviation", which runs the safe direction. The HDI-edge
   phrasings are:
   - "at most about a dozen milliseconds", with P(ν > 12) = 3.6%;
   - "a factor of about 4.5 either way";
   - the forest-plot HDIs, quoted from unrounded values: 309 [0.91, 9.59] → "roughly
     1–10"; 308 [30.8, 68.1] → "31–68"; 332 [35.7, 80.4] → "36–80".

   None is overstated.

## Considered, not recommended for this pass

- **A tail that varies with days.** In the PVT literature, lapses, the tail, are what
  sleep loss increases most. 1.8 states the constant-ν assumption explicitly ("Because ν
  does not change with days…"). With session-average data and a fitted tail of a few ms,
  adding a days-effect on ν would be added sophistication, which AGENTS.md treats as a cost.
- **2.7's hard-coded panel details depend on the prior draw.** This is robust for
  self-work students:
  - 1.13 and 1.14 fix the node names and order;
  - the cell structure forces `log_nu` before `y`;
  - Deterministics consume no RNG.

  So a correct student model reproduces the solution's prior draws. This is the same
  situation as NB08's 2.7.
- **The diagnostic subset (308/337/372) contains no steady participant**, although the
  edge geometry is at 309 and 349. The all-participant screen covers them: minimum bulk ESS
  1,938 and tail 1,722. This is the same deferral as NB08.
- **1.9's 30 ms center is close to NB05's fitted `sd_y` (25.8 ms) from the same data.** It
  is presented as a round-number elicitation in ms with a broad range (11–80 ms), not as
  reuse of a fit, so NB08's double-use discussion does not apply.
- **One excursion in the population trace.** In one chain near draw 760, `sd_b1` reaches
  about 23 while `mu_b1` dips to about 2. R-hat is 1.00 and ESS is above 3,000, so 3.4's
  "well-mixed" is fair.
- **Axis labels** (the forest plot's "variable/participant" and the ECDF's missing x-label)
  and the course-wide `pandas==2.2.3` pin are inherited, and were deferred course-wide.

## Checked and found sound

- **Tags.** All 103 cells are tagged:
  - 6 `section`;
  - 33 `exercise-question`, each followed immediately by exactly one `solution`;
  - 1 `exercise-question`+`given-answer` (5.6, following the NB06–08 pattern);
  - 30 `given`.

  No solution is orphaned, every question cell starts with `###`, and every tag matches the
  cell's role.
- **Self-work derivation** (checked with my own script):
  - The two files have the same cell count, ids, types, order and tags.
  - Exactly 34 cells differ: the 33 `solution` cells, each exactly `- answer here` or
    `# answer here` of the right type, plus the badge URL in [0], which is the only change
    in that cell.
  - The self-work file has no outputs, null execution counts, no `metadata.execution` and
    no `metadata.widgets`.
  - Every `given` cell in the self-work file depends only on names that the questions
    specify: `nu` and `y` (1.13 and 1.14), used by [43], [60] and [56].
- **Names and removed constructs.** A grep of both files for the following finds only
  benign hits:
  - pre-revision names: `Reaction`, `intercept`, `slope`, `sigma_intercept`,
    `nu_intercept`, `residual_scale`, `population_mu`, `_z`;
  - removed constructs: `print(model`, `lam=`, `kind="kde"`, `plot_population`,
    `\(`/`\[`;
  - forward references: "next", "Notebook 9–12";
  - `mu_log_nu`.

  The hits are:
  - `Reaction` only in axis labels and `observed=sleep["Reaction"]`;
  - "intercept"/"slope" only in code comments and ordinary prose;
  - `mu_log_nu` only as the prior constant, per §3.1.
- **Closing section.** 6.1 is purely retrospective. It does not mention Notebook 10 or 11,
  and it contains no "next" and no preview.
- **Conventions:**
  - 90% HDIs with `ci_kind="hdi"` in both summaries, all three `plot_dist` calls,
    `plot_forest` and the helper;
  - the mean as the point estimate;
  - `pm.Exponential(scale=...)` with named constants;
  - the centered parameterization;
  - `pm.model_to_graphviz`, whose nodes and edges I checked against 1.16: `sd_y` feeds `y`
    only; `nu` feeds `y` and `mean_rt`;
  - an ECDF posterior-predictive check;
  - the helper with `coords=None`, and no `plot_population`;
  - `$`/`$$` math only;
  - no slide figures, per the plan.
- **`mean_rt` versus predictive variation.** `mean_rt = mu_y + nu` is defined in 1.14,
  plotted in 5.1 and read in 5.2 as uncertainty about the expected trajectory. 5.4 then
  reads the residual scatter separately. 5.2's "a plot of `mu_y` would be shifted down by
  about 7 ms, with bands of almost the same width" is right: the mean of `mean_rt − mu_y` is
  7.44.
- **Graphical grammar.** The prior and posterior predictive checks both use
  `plot_participants(..., "y")` on the ms scale, with the same HDI levels, point estimate
  and layout as NB05–08.
- **Teaching the ms-vs-log contrast.** Apart from findings 1 and 2, it is taught clearly
  and repeatedly, in places that match NB06–08's own vocabulary:
  - the intro [0];
  - 1.6, the explicit contrast question;
  - the 1.7 code comments;
  - 1.8, where `b1` is still in ms/day but `b0` has shifted by ν;
  - 1.10, where the `sd_y` units change but `sd_log_sd_y` is unit-free;
  - 4.2, ms/day versus NB06–08's %/day;
  - 5.4, constant-width versus widening bands.
- **Scaffolding.** The mixed split serves the stated goal:
  - The reused mean structure and residual-scale hierarchy are supplied, each with one
    recap question (1.8 and 1.10) that makes the student notice what changed.
  - The genuinely new likelihood and tail get four conceptual questions (1.3–1.6), a
    design question (1.11), a ms→log elicitation (1.12) and two short `with model:` tasks.
    The tasks are merged per NB08 review finding 7.
  - The supplied density figure (1.2) earns its place: 1.3, 1.4, 3.2, 4.4 and 4.5 all
    read from it.
- **Numbers, checked against my reproduction.** All match, apart from finding 5's two
  rounding and precision nits:
  - *1.2 and 1.4 (SciPy `exponnorm`):* modes 254.9, 277.9 and 293.9; means 255, 300 and
    400; skewness 0.009, 1.26 and 1.89.
  - *4.5:* typical fitted skewness 0.145, so it resembles the ν = 5 curve.
  - *2.4:* prior `mu_log_sd_y` HDI [2.60, 4.21] → 13–67 ms; `sd_log_sd_y` [0, 0.80]; ν
    HDI [8.7, 126.7], mean 64.2 (plot label 64.0).
  - *2.6:* day-0 median band edges 208–363 (50%) and 94–526 (90%) ms; 93.75% of
    observations inside their own 50% band; 90% lower edges ≤ 0 in 6/18 panels on day 5
    and 18/18 on day 7 (maximum −1.1 ms, hence "zero or below").
  - *2.7:* 333's panel means are 578, −173, 326, 650, 116, 65, 407 and 731; the other
    panels' means lie between 295 and 351.
  - *3.4 and 3.6:* bulk ESS minimum 1,683 (`nu`), tail minimum 2,153; screen 1,938 / 1,722.
  - *4.7:*
    - `sd_y` for 309 is 5.3 [0.9, 9.6], 335 7.5, 352 7.6, 308 49.5 [30.8, 68.1] and 332
      57.6 [35.7, 80.4];
    - total SD 9.6 (309) against 58.2 (332), a ratio of 6.1;
    - `sd_log_sd_y` [0.469, 1.033].
  - *5.4:* 90% PPC widths 169–190 (308), 198–221 (332) and 32–35 (309); median band
    asymmetry 0.01 ms.
  - *5.5:* outside the 90% band are 308 d5 (below), 332 d4 (above), and 350 d4 and 351 d5
    (by 0.9 and 1.9 ms, "at the edge"); 9 of 576,000 replicates are negative.
- **Figures against the text.** I viewed:
  - the density (1.2);
  - the prior dists (2.3), with the ν mean label at 64.0;
  - the prior predictive (2.5), with 333's zigzag at row 2, panel 1;
  - the population trace (3.3);
  - the ν posterior (4.3);
  - the forest (4.6);
  - `mean_rt` (5.1);
  - the PPC (5.3), with roughly constant widths, 308 d5 below the band and 332 d4 above
    it;
  - the ECDF (5.7).

  Every visual claim holds.
- **Cross-references.** Every in-notebook "Question N.M" resolves. The citations of other
  notebooks are accurate:
  - NB05's 2.5 on sub-zero bands;
  - NB08's 1.5 on log-center → median;
  - NB08's generous `sd_log_sd_y` upper end;
  - NB08's step-size sentence.
