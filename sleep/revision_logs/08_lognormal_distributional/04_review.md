# Fresh-eyes review: notebook 08 — Distributional lognormal model

Reviewer: independent agent (Step 3b of `sleep/REVISION_PLAYBOOK.md`). I did not write this
notebook.

**Inputs read in full:**
- `AGENTS.md` and the playbook, including the new distributional-naming block in §3.1;
- `01_plan.md`, `02_implementation_notes.md` and `03_execution_log.md`;
- both NB08 notebooks, cell by cell, including every executed output and all 9 rendered
  figures plus the graphviz SVG;
- NB07 solved (text, outputs and figures) and NB07's `04_review.md`, for calibration;
- the NB01–07 solved notebooks, grepped for how divergences, step size and "funnel" were
  introduced.

**Independent checks.** I did not rely on the execution log. Scripts are in
`scratchpad/review08/`, and I ran them in the pinned venv (`scratchpad/nbenv`):
- `repro.py` executes the solved notebook's **literal code cells**, with only `DATA_URL`
  pointed at the local CSV. My posterior matches the committed summary to every displayed
  digit.
- `diff.py` is my own solved → self-work diff.
- `spikes.py` re-draws the prior with every variable. The `y` draws are identical to the
  notebook's. It then attributes each prior-predictive spike to its responsible draw.
- `funnel.py` measures the geometry that 3.2 invokes and locates the default-settings
  divergence.
- `ppc.py` computes posterior-predictive coverage and band widths.
- `priorbands.py` computes the prior-predictive band edges.
- `nb07fit.py` is an independent NB07 refit for the cross-notebook comparisons.
- `wideprior.py` refits with a near-flat `mu_log_sd_y` prior, to test judgment call B.

**Verdict: ready to commit. Nothing here is blocking.** I recommend findings 1–5 before
committing. They are all markdown-only, so no re-execution is needed. Finding 6 corrects
the log only, and findings 7–8 are optional polish.

The notebook avoids all three mistakes that NB07's review caught (see the end of this
file). Every number and plot reading I checked matches the actual output. The two
judgment calls are presented honestly, and the reasoning behind them holds up when
tested.

Cell references give `[index in the 105-cell notebook]`, the question number and the cell
id. The ids are the same in both files. Where a finding touches an `exercise-question` or
`given` cell (findings 1 and 3), the edit must also be made in the self-work file: re-run
`derive_and_verify_nb08.py`. Edits to `solution` cells change the solved file only.

---

## Findings (most severe first)

### 1. Minor–moderate (pedagogy): 3.2 asks students to explain sampler geometry the course has never taught

**Cells:** [61] 3.2 question (`5b289960`), [62] 3.2 solution (`95bdf221`).

NB01 sets "no divergences" as a criterion but never says what a divergence *is*. NB01–07
never mention step size, `target_accept`, curvature or a funnel (grepped). 3.2 is
therefore the course's first explanation of why HMC diverges. The question gives half the
background: "a higher `target_accept` makes the sampler take smaller steps". It never
states the other half, which the answer relies on: tuning picks **one** step size for the
whole posterior, and a divergence means that step was too large for the local curvature.
Without it, "why could that make a single step size hard to choose?" is a guess for most
students. The first half of the question, how precisely eight observations pin down `b0`
and `b1` at small versus large `sd_y`, is well posed and answerable.

The mechanism in the answer is **correct**. I tested it; see judgment call D below.

**Fix (question cell; mirror it in the self-work file).** Insert one sentence after
"although Notebook 7's model sampled cleanly.":

> During tuning, the sampler chooses a single step size for the whole posterior; a
> divergence signals that somewhere this step was too large for how sharply the posterior
> curves there.

*Optional:* add "(You can check this by removing `target_accept=0.9` from Question 3.1
and re-running it.)". Self-work students otherwise never see the divergence that motivates
the question. Rerunning takes about 10 s.

*Alternative:* re-tag 3.2 as `exercise-question`+`given-answer` and move the answer into
it. Playbook §2 lists "a rhetorical question introducing new material" as a given-answer
case. I prefer the one-sentence fix, because the first half of the question is a good
student exercise.

### 2. Minor (accuracy): the summary implies Notebook 7's prior predictive had no single-day spikes

**Cells:** [104] 6.1 solution (`450046b9`), "Priors" bullet. Optionally also [55] 2.7
solution (`e17c93fe`).

"The prior predictive check looks much as it did in Notebook 7, **apart from** rare
single-day spikes produced by the upper tail of the `sd_log_sd_y` prior." NB07 had one.
In NB07's 2.5, as fixed by its review, participant 335's day-0 spike is "a single extreme
residual, which requires a draw from the far upper tail of the `sd_y` prior". So the
phenomenon is shared. Only its source changed: NB07's shared `sd_y`, versus one
participant's scale inflated by a large `sd_log_sd_y`. The summary should not describe it
as new.

**Fix:** replace the last sentence of the "Priors" bullet with:

> The prior predictive check looks much as it did in Notebook 7, including rare single-day
> spikes from one extreme residual; here they arise when a draw from the upper tail of the
> `sd_log_sd_y` prior gives one participant an extreme residual scale.

*Optional continuity in 2.7:* append to the answer's final parenthesis: "…has the same
cause, as did participant 335's day-0 spike in Notebook 7, there through the shared `sd_y`
prior."

### 3. Minor (clarity): 2.4 says a residual scale near 1 is "effectively excluded", then 2.7 shows participants' scales of about 5

**Cells:** [49] 2.4 solution (`2ade4972`). Also touches the criterion wording in [43] 2.1
(`032c8a06`, a `given` cell).

2.4's sentence sits in the `mu_log_sd_y` paragraph, so it means the **typical** scale.
That is true: P(`mu_log_sd_y` > 0) is about 0. But 2.1's criterion says "without making
residual scales near 1 … routine", which does not say whether it means typical or
individual scales. Four cells later, 2.7 attributes the spikes to individual `sd_y` = 5.1
and 5.8. A careful student will see a contradiction.

My prior draws show that individual scales above 1 do occur, but not routinely:
- 2.6% of joint draws have at least one participant with `sd_y` > 1;
- 0.2% of participant-draws have `sd_y` > 1.

So the criterion *is* met, and only the wording needs tightening.

**Fix (markdown).** In 2.4, change the sentence to:

> A *typical* residual scale near 1 (Question 1.7) is effectively excluded.

*Optional:* make the same distinction in 2.1: "without making residual scales near 1
(Question 1.7), for the typical participant or routinely for individual participants, or
enormous differences between participants, routine". This cell is `given`, so edit both
files.

### 4. Minor (overstatement): 4.4 says values of `sd_log_sd_y` below 0.4 are "ruled out"

**Cell:** [81] 4.4 solution (`3743e541`).

0.4 is the posterior 90% HDI's own lower edge; the unrounded value is 0.395. In my
reproduction, P(`sd_log_sd_y` < 0.4 | data) = **4.2%**. Values below 0.3 really are
excluded: P = 0.08%. The rest of the sentence is right: the prior put 70% of its mass
below 0.4.

**Fix:** replace "values below about 0.4, which the prior considered most likely, are
ruled out" with:

> values below about 0.4, which the prior considered most likely, now lie outside the
> 90% HDI, and values below about 0.3 are effectively ruled out

### 5. Minor (loose thread from omitting the sensitivity section): 2.6 cites Notebook 7's acceptance of the broad priors, but not the check that backed it

**Cell:** [53] 2.6 solution (`a84fccab`), second paragraph.

2.6 gives an "Only partly" verdict and proceeds because the mean-structure priors were
"accepted … as deliberately broad teaching priors" in NB07. NB07's acceptance (its 2.5)
was explicitly conditional: "We proceed, and Section 6 checks whether they influence the
posterior". Its 6.4 then found no sensitivity. NB08 drops its own sensitivity section,
which is a sound decision (see C below). This is therefore the one place a student could
fairly ask, "why is it fine to proceed on priors that fail the criteria?". The answer
already exists and costs half a sentence. The fitted mean structure is essentially NB07's:
`mu_b0` 5.58 vs 5.59, and `sd_b0`, `mu_b1` and `sd_b1` agree to two decimals. So NB07's
result carries over.

**Fix:**

> These features come from the mean-structure priors, carried over unchanged from
> Notebook 7, where we accepted them as deliberately broad teaching priors and its
> power-scaling check showed that they do not drive the posterior. The new residual-scale
> priors barely change the bands.

### 6. Minor (record only, not in the notebook): the divergence-location evidence in the implementation notes has no evidential weight

**Files:** `02_implementation_notes.md`, decision 5, "Diagnosis"; the Step-3a record.

The notes support the "within-participant funnel" diagnosis with: "They occur where some
participant's `log_sd_y` is in its lower tail, for example 371 at its 4th percentile". My
default-settings run reproduced the same single divergence: 371 at the 3.9th percentile,
and `sd_log_sd_y` at the 31st. But this carries no information. At a *random* posterior
draw, the lowest of the 18 participants' `log_sd_y` percentiles has a median of **3.8%**.
52% of random draws have some participant at or below the 4th percentile. At the divergent
draw, 352, one of the two steadiest participants with the strongest funnel, is at its
**99th** percentile, in its wide region.

The diagnosis still stands, on the notes' *other* evidence, the quintile analysis, which I
reproduced (D below). One divergence in 4,000 draws cannot be localized. The notebook's
3.2 text claims only a mechanism, not a location, so no notebook change is needed.

**Fix:** in decision 5, replace the "They occur where…" sentence with:

> A single divergence cannot be localized (at a random draw, some participant's
> `log_sd_y` is typically below its 4th percentile), so the diagnosis rests on the
> geometry below.

Keep the quintile evidence and the observation that the classic neck is absent.

### 7. Optional (scaffolding): 1.11 and 1.12 split familiar mechanics into two exercises

**Cells:** [28]–[29] 1.11 (`25ab8e6c`, `ac93c54e`), [30]–[31] 1.12 (`90ca9a51`,
`daa4518a`).

The NB4-lite scaffolding generally serves the goal well; see "Checked and found sound".
These two cells are the one place where it reproduces NB4 granularity for machinery
students already know.
- 1.11 is three assignments. The values come from 1.8 and 1.10, and the names are given in
  the prompt.
- 1.12 is one `pm.Normal` and one `pm.Exponential(scale=...)`.

Merging them removes a cell pair without losing anything:

> ### 1.11 Store the prior constants and add the population parameters of the residual-scale hierarchy.
>
> Assign the values from Questions 1.8 and 1.10 to `mu_mu_log_sd_y`, `sd_mu_log_sd_y`, and
> `sd_sd_log_sd_y`, following the naming pattern of the mean-structure constants. Then, in
> a `with model:` block, add `mu_log_sd_y` and `sd_log_sd_y`.

Renumber 1.13–1.17 to 1.12–1.16. By my grep, no in-notebook reference cites 1.12–1.17. The
only citation of 1.11 is in [30], the cell being merged away. This is optional. The split
is not wrong, and renumbering carries its own risk.

### 8. Trivial

- **[23] 1.8** (`ba1a4e36`): "between about 3% and 25% per residual standard deviation".
  The 25% is $e^{0.22}-1$. Elsewhere the notebook reads a small scale directly as a
  percentage: 2.4 gives 0.19 → "about 20%", and 4.2 gives 0.075 → "7.5%". "about 3% and
  22%" keeps one convention.
- **[49] 2.4** (`2ade4972`): "$e^{-1.7} \approx 0.19$". It is 0.18. The 0.19 comes from
  the unrounded HDI edge, −1.67. Write "≈ 0.18".
- **[55] 2.7** (`e17c93fe`): "To raise a mean of 500 draws by 1.5–2.5 s". 351's day-2
  panel mean is 2,858 ms against about 200 ms on neighbouring panels, a rise of about
  2.65 s. The one responsible draw is 1,330 s, which matches the answer's "1,300 s". Write
  "1.5–2.7 s".
- **[85] 4.6** (`5832963d`): "five- to six-fold" is right from the unrounded means:
  0.027 vs 0.142 and 0.164, which is ×5.2–5.9. But the rounded values in the same sentence
  (0.03 vs 0.14 and 0.16) give ×4.7–5.3. Quote "about 0.027" for the steadiest pair.

---

## The implementation's judgment calls: reviewed

**A. Harmonizing the mean-structure priors to NB07's values: agree.** Only the
implementation notes record the change. That meets the plan ("note in the notebook, or at
minimum in the implementation notes"), and it is correct: students never saw the
pre-revision 5.5, 1/3 or 0.2.
- The notebook's own statements are all true as written: [10] "with the same prior
  constants"; the [11] comments "from Notebook 7"; [43] "Notebook 7's and were examined
  there".
- I checked the constants against NB07's model cell: `5, 0.55, 1/6, 0, 0.2, 0.05`.
- The pre-revision draft's only rationale was "a separate refit choice". Reusing the
  earlier prior is exactly playbook §3.2.

The only follow-on is finding 5.

**B. Centering `mu_log_sd_y` on NB07's *fitted* `sd_y`: agree. The disclosure is honest,
and the claim is now tested.** 1.9 names the double use of the data plainly ("Only with
care, because it uses the same observations twice"), rather than presenting it as
ordinary prior reuse. It promises that 4.4 will check it, and 4.4 does.

I tested the claim that "the data, not Notebook 7's estimate, will decide" directly. A
refit with `sd_mu_log_sd_y = 5`, ten times wider and effectively flat over the plausible
range, gives:

| Prior on `mu_log_sd_y` | `mu_log_sd_y` mean [90% HDI] | `sd_log_sd_y` mean [90% HDI] |
|---|---|---|
| Normal(−2.5, 0.5), as in the notebook | −2.85 [−3.10, −2.62] | 0.59 [0.40, 0.80] |
| Normal(−2.5, 5), near-flat | −2.89 [−3.15, −2.61] | 0.60 [0.41, 0.81] |

The NB07-informed center moves the posterior by 0.04 on the log scale, about 4% of the
typical residual scale. The double use is real but negligible here.

One further point supports the reasoning. NB07's shared `sd_y` behaves like a root mean
square of the participants' scales: the RMS of NB08's participant `sd_y` means is 0.075,
against NB07's 0.079. That lies above the median participant's scale. So the prior center
was expected to be slightly high, and the posterior moved down, which is exactly what 4.2
explains ("pulled up by the most variable participants"). The notebook does not need to
say this; adding it would be added sophistication.

**C. Omitting a sensitivity/power-scaling section: agree. There is no dangling promise.**
- "sensitiv", "power" and `psense` appear nowhere in either notebook.
- The only forward reference to a check, 1.9's "Question 4.4 checks this", is delivered.
- The one related gap is finding 5.
- The implementer's scratch `psense` flag on `sd_log_sd_y` (prior–data conflict) is not
  hidden. 4.4 states its substance: "participants differ in variability more than the
  prior expected". It also states its direction: the Exponential prior pulls the estimate
  *down*, so the heterogeneity conclusion is conservative. That reasoning is correct.

**D. `target_accept=0.9` and the "within-participant funnel": statistically sound.**
- **Premise.** A fourth independent confirmation: my default-settings run gives exactly 1
  divergence. The adapted step size falls from 0.24–0.29 at 0.8 to 0.16–0.20 at 0.9, and
  the mean tree depth rises from 4.2 to 4.9. "Occasionally" is the right word, since the
  notes found 2 of 8 seeds.
- **The geometry exists and matches the question's focus on 309.** Across quintiles of a
  participant's own `log_sd_y`, the conditional SD of that participant's `b0` and `b1`
  changes by:
  - 2.4–2.7× for the steadiest participants, 309, 352, 334 and 335;
  - only 1.3–1.5× for the most variable, 308 and 332.

  The steadier the participant, the more their likelihood rather than the population
  prior sets `b0` and `b1`, and so the more their precision tracks `sd_y`.
- **It is not the classic hierarchical neck.** The SD of `log_sd_y[309]` is flat,
  0.32–0.35, across quintiles of `sd_log_sd_y`.
- **The answer is at the right level for a teaching notebook.** One global step size
  cannot suit regions whose curvature differs by a factor of about 2–3, and a smaller step
  removes the occasional divergence. The answer hedges appropriately ("can be too
  large", "occasionally"), and its NB07 contrast is right: NB07's `sd_y` HDI spans ×1.25,
  so it gives no comparable variation.
- **What remains** is pedagogical (finding 1) and a record correction (finding 6).

## NB07's three review errors: not repeated

1. **Spike attribution.** I verified each spike individually from the re-drawn prior.
   Each is a single extreme residual:
   - **351, day 2:** one draw of 1,330 s; `sd_y` 5.14, `sd_log_sd_y` 1.37, `b1` −0.11.
   - **371, day 7:** 747 s; `sd_y` 5.75, `sd_log_sd_y` 1.93, `b1` = −0.056. So it is
     **not** a slope effect, despite being on day 7.
   - **335, day 6:** 67 s; `sd_y` 1.91, `sd_log_sd_y` 1.44.

   The panel positions stated in 2.7 are right. "In these draws it exceeds 1.3" is right,
   and P(`sd_log_sd_y` > 1.3) is about 2% under the prior. The next-largest excess is a
   gradual slope rise in 330 over days 6–7 (`b1` = 0.97), about 180 ms. It is not visually
   salient on the plot, so its omission from 2.7 is fine.
2. **"Independent" vs "exchangeable".** 2.8 says exchangeable and cites NB07's corrected
   2.6. The word "independent" appears nowhere in the notebook.
3. **HDIs quoted from the rounded table.** Every HDI claim matches the unrounded value:
   - `mu_log_sd_y` [−3.097, −2.616] → "−3.1 to −2.6";
   - `sd_log_sd_y` [0.395, 0.795] → "0.4–0.8";
   - the 4.6 forest values, read from the plot: 309 [0.012, 0.041], 352 [0.013, 0.042],
     308 [0.090, 0.191], 332 [0.105, 0.225];
   - NB07's `sd_y` [0.070, 0.088] → "roughly 0.07–0.09", a factor of about 1.3.

   No value from the `round_to=2` table where rounding distorts (`mu_b1`, `sd_b1`) is
   quoted anywhere.

## Considered, not recommended for this pass

- **In-sample posterior-predictive coverage.** 63% of observations fall inside their 50%
  band, and 2 of 144 lie outside the 90% band. So the bands are still somewhat wide on
  average. NB07 had 75% inside the 50% band. 5.5's "bands now match that participant's
  own day-to-day scatter" is a fair visual reading of a large improvement, and in-sample
  checks are conservative by construction. Quantifying this would add sophistication that
  AGENTS.md treats as a cost.
- **Prior-predictive support.** 31% of prior-predictive draws are below 100 ms, so
  "Every prediction is a positive reaction time" answers the support criterion narrowly.
  But the verdict, "Only partly … implausibly fast", is right, the issue is inherited from
  NB06/07, and it is a course-wide call.
- **A reference line at NB07's shared `sd_y` (0.08) on the 4.5 forest plot.** It would
  show the motivating mismatch at a glance: too wide for 309 and 352, too narrow for 308
  and 332. It is a nice device, but it is an addition, and 4.2 and 4.6 already make the
  point in words.
- **Axis labels.** The forest plot's "variable/participant" labels and the ECDF's `y`
  title with no x-label are inherited from NB05–07 and were deferred course-wide by NB06's
  review.
- **The diagnostic subset (308/337/372) has no steady participant**, although the funnel
  is strongest for steady participants. The all-participant screen covers them: minimum
  ESS 2,707 bulk and 1,813 tail.

## Checked and found sound

- **Tags.** All 105 cells are tagged:
  - 6 `section`;
  - 36 `exercise-question`, each followed by exactly one `solution`;
  - 1 `exercise-question`+`given-answer` (5.6, following the NB06/07 pattern);
  - 26 `given`.

  The `## Setup`, `## Data` and `### Plotting helper` headers are `given`, as in NB07.
  Every tag matches the cell's role.
- **Self-work derivation (my own script):**
  - The two files have the same cell count, ids, types, order and tags.
  - Exactly 37 cells differ: the 36 `solution` cells, each exactly `- answer here` or
    `# answer here` of the right type, plus the badge URL in cell 0.
  - The self-work file has no outputs, null execution counts, no `metadata.execution` and
    no `metadata.widgets`.
  - Both files pass `nbformat.validate`, and their ids are unique.
  - The solved file's `widgets` and per-cell `execution` metadata are nbconvert artefacts,
    exactly as in NB05–07 solved.
  - Every `given` cell depends only on node names that the questions specify: 1.12, 1.13
    and 1.15 name `mu_log_sd_y`, `sd_log_sd_y`, `log_sd_y`, `sd_y`, `mean_rt` and `y`.
- **Naming and removed constructs.** A grep of both files for `Reaction`, `intercept`,
  `slope`, `sigma_intercept`, `residual_scale`, `population_residual`, `population_mu`,
  `_z`, `print(model`, `lam=`, `plot_population`, `compute_log_density`, `\(`/`\[`,
  "next", "Notebook 9–12" and "ex-Gaussian" finds only:
  - the data column, in `observed=`;
  - the helper's y-label;
  - PyMC's `sigma=` argument;
  - ordinary prose ("intercepts and slopes").
- **Playbook §3.1 distributional naming.** The notebook matches the block exactly:
  - `mu_log_sd_y` and `sd_log_sd_y`;
  - a centered `log_sd_y` with `dims="participant"`;
  - `sd_y = pm.Deterministic("sd_y", pm.math.exp(log_sd_y), dims="participant")`;
  - `sd_y[pidx]` in both `y` and `mean_rt`;
  - no observation-level `sd_y`, and no `residual_scale` pair;
  - constants `mu_mu_/sd_mu_/sd_sd_log_sd_y`.
- **Closing section.** 6.1 is purely retrospective, with no "Notebook 9", no "next" and
  no preview.
- **Conventions:**
  - 90% HDIs with `ci_kind="hdi"` passed explicitly to both summaries, both `plot_dist`
    calls, `plot_forest` and the helper;
  - the mean as the point estimate throughout. `plot_forest` inherits the mean from the
    `arviz-base` rcParam `stats.point_estimate`, as in NB07;
  - `pm.Exponential(scale=...)` with named constants;
  - the centered parameterization;
  - `pm.model_to_graphviz`. The SVG's nodes and edges match 1.17: `sd_y` sits in the
    participant plate and feeds `y` and `mean_rt`;
  - an ECDF posterior-predictive check;
  - the helper with `coords=None`, and no `plot_population`;
  - `## Data`, NB5-style section headings, and `$`/`$$` math only;
  - no slide figures, per the plan.
- **Numbers against my reproduction.** All match, apart from findings 4 and 8:
  - *Diagnostics:* 0 divergences at 0.9; R-hat 1.00; the population ESS minima are 3,651
    bulk and 3,077 tail.
  - *Prior predictive, 2.6:* the day-0 90% edges are 26–49 and 322–362 ms; the largest
    50% upper edge is 208 ms; 100% of observations lie above their 50% band; on day 7 the
    50% lower edges are 0.5–2.7 ms and the 90% upper edges are 1,244–1,534 ms.
  - *2.4:* the prior HDIs are [−3.24, −1.67] and [0, 0.81].
  - *4.2:* 13 of 18 participants lie below NB07's `sd_y`.
  - *4.6:* ±8 and ±45 ms at 300 ms.
  - *5.2:* `b1[332]` moves from 0.016 in NB07 to 0.026 in NB08, toward `mu_b1` = 0.036.
  - *5.4:* the 90% predictive widths are 21–25 ms for 309, 148–223 ms for 308 and 168–208
    ms for 332.
  - *5.5:* the only observations outside the 90% band are 332 on day 4 and 370 on day 3,
    which misses by 1 ms.
- **Figures against the text.** Prior dist (2.3), prior predictive (2.5), both trace plots,
  posterior dist (4.1), forest (4.5), `mean_rt` (5.1, compared side by side with NB07's
  5.1), posterior predictive (5.3, compared with NB07's 5.3) and ECDF (5.7). Every visual
  claim holds, including the panel positions and 332's slightly steeper line in 5.2.
- **Cross-references.** Every in-notebook "Question N.M" resolves. The NB07 references are
  accurate: its 2.6 on exchangeability; its 5.1; and 2.5's "deliberately broad teaching
  priors" (but see finding 5).
- **Workflow checklist:**
  - The prior and posterior predictive checks are on the observable scale and use the same
    `plot_participants` grammar.
  - `mean_rt` is defined (1.15), plotted (5.1) and interpreted (5.2).
  - `mean_rt` is kept distinct from predictive `y` in both directions. 5.2 reads band width
    as uncertainty about the expected trajectory, and 5.4 as residual scatter. This
    distinction carries the notebook's key contrast: the expected trajectories barely move,
    but how precisely each is known, and how widely individual reaction times scatter,
    become participant-specific.
  - Criteria are stated before every check: 2.1, including the new residual-scale
    criterion, the 3.4 prompt, the 5.5 prompt and 5.6.
- **Scaffolding.** The split serves the stated goal:
  - The reused mean structure is supplied as a partial `model` (NB5-style).
  - The new construct gets eight conceptual and elicitation questions (1.3–1.10), each
    aimed at the new idea: what $sd_{y,s}$ is, why a log link, what $e^{\mu}$ means, why
    pool, why zero is not neutral, how to elicit, whether reusing NB07 is legitimate, and
    between-participant factors.
  - It also gets four short code tasks in NB4's `with model:` style. Finding 7 is the only
    place where machinery is over-split.
  - Section 4 turns the fitted scales into proportional and millisecond readings.
  - Section 5 ties them back to NB07's motivating mismatch.
- **Prose.** Answers are declarative and short, in NB1–03/NB06 style, with no hedging. The
  longest, 2.7 and 3.2, earn their length.
