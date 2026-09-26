# Fresh-eyes review: notebook 07 — Hierarchical lognormal regression

Reviewer: independent agent (Step 3b of `sleep/REVISION_PLAYBOOK.md`). I did not write this
notebook.

**Inputs read in full:**
- `AGENTS.md` and the playbook;
- `01_plan.md`, `02_implementation_notes.md` and `03_execution_log.md`;
- both NB07 notebooks, cell by cell, including every executed output and all 11 rendered
  figures;
- NB05 solved and NB06 solved, plus NB06's `04_review.md`, for calibration.

**Independent checks:** I did not rely on the execution log's two spot checks. I rebuilt
the model in the pinned venv (`scratchpad/nbenv`) from the notebook's exact code and
`RANDOM_SEED`, in scripts under `scratchpad/review07/`, and re-derived the numbers the
prose quotes:
- the prior predictive draws. My reproduction of the 2.4 plot is identical to the
  committed one;
- the posterior, which matches the committed summary to the displayed precision;
- the posterior predictive misses;
- the ECDF.

**Verdict: not ready to commit as-is. Fix finding 1 before committing, and preferably
finding 2 as well.** Both are markdown-only, so no re-execution is needed. The code, tags,
self-work derivation, naming, diagnostics and closing section are clean. Most numbers in
the prose match the output.

As with NB06, the main problem is how the answer key reads its own prior predictive plot.
Here the problem is in the text added *after* execution to explain the plot's spikes.

Cell references give `[index in the 91-cell notebook]`, the question number and the cell
id. The ids are the same in both files.

---

## Findings (most severe first)

### 1. Major (accuracy): 2.5 and 2.6 attribute both prior-predictive spikes to slope differences, but one spike is at day 0

**Cells:** [32] 2.5 solution (`9fe8ab92`), [34] 2.6 solution (`df43e5fa`). Also the
record in `03_execution_log.md` and the last paragraph of `02_implementation_notes.md`.

The 2.4 plot [30] shows two spiking mean lines, and they have different causes:
- **Participant 333** (middle row, 1st panel). The mean rises over days 5–7 to about
  4,800 ms. This is a slope effect, as the text says. In one draw (#455), `sd_b1` = 0.342,
  which is the largest of the 500 prior draws and about 7× the prior mean. In that draw
  `b1[333]` = 1.47, which is 3.4 of that draw's `sd_b1` above `mu_b1`. That one simulated
  trajectory runs from 79 ms to 2.2 million ms. On day 7, this single draw contributes
  4,316 ms of the 4,838 ms panel mean.
- **Participant 335** (middle row, 3rd panel). The mean spikes to about 1,250 ms **at
  day 0** and is back to normal by day 1. This **cannot** be a slope difference, because
  `b1` × 0 = 0. It cannot be the intercept either, because a large `b0` would raise every
  day. It is one extreme residual: draw #126 has `sd_y` = 2.14, the largest of the 500
  draws and in the far tail of Notebook 6's `Exponential(scale=1/3)`. With that `sd_y`, a
  3.2-SD residual produced a single 529,343 ms (9-minute) reaction time.

Yet 2.5 says "A couple of panels also show the mean line spike sharply upward late in the
week: a rare, large sampled slope difference compounding over seven days". 2.6 says "The
one or two panels with a sharp late-week spike … are the same distribution's rare, large
sampled slope differences". A student looking at panel 335 sees a day-0 spike, and the
answer key tells them it is a slope effect.

2.6 has three further conceptual slips:
- **"every panel is an independent draw from that same prior predictive distribution".**
  Within each prior draw, all participants share `mu_b0`, `sd_b0`, `mu_b1`, `sd_b1` and
  `sd_y`. So the panels are exchangeable, which the same sentence bolds, but **not
  independent**. In a hierarchical notebook this distinction is the whole point of partial
  pooling. NB05 1.7 teaches exchangeability without claiming independence.
- **"made visible because there are 18 independent draws to look at".** Each panel
  summarizes 500 draws, and each spike is one draw out of a panel's 500. The spikes show
  up because a mean is sensitive to a single extreme draw. NB06 2.9 already taught this
  ("A few very large draws also make the mean line jump on individual days").
- **"Most panels look similar because that shared distribution is fairly narrow through
  midweek".** At days 3–4 the 90% bands span roughly 5–600 ms, which is not narrow. The
  panels look alike because the HDI bands summarize the bulk of 500 draws, which the rare
  extreme draws do not move.

This is the same kind of error NB06's review caught (its finding 3: 2.9 said "jumpy at
later days" when the spikes were at days 0 and 3). It entered through the post-execution
edit. The execution log says "2 of 18 panels still show the expected occasional late-week
spike from a large sampled slope difference". It is **not** leftover text from the
`sd_sd_b1 = 0.1` version. See "The `sd_sd_b1` change" below.

**Fix (markdown only).** In 2.5, replace the sentence beginning "A couple of panels also
show …" with:

> Two panels also show the mean line spiking, for different reasons. In participant 333's
> panel (middle row, first), the mean climbs to almost 5 s by day 7, growing over days
> 5–7: in one of that panel's 500 draws, a very large sampled slope compounds over the
> week, which is exactly the risk Question 2.3 warned about. In participant 335's panel
> (middle row, third), the spike is at day 0 and gone by day 1. It cannot come from the
> slope, which has no effect at day 0, or from the intercept, which would persist across
> days. It is a single extreme residual, which requires a draw from the far upper tail of
> the `sd_y` prior.

Replace the first paragraph of 2.6's answer with:

> Before seeing the data, participants are **exchangeable**: every participant's `b0` and
> `b1` come from the same population distribution, so every panel shows the same prior
> predictive distribution. (The panels are not independent: within each draw, all
> participants share the same `mu_b0`, `sd_b0`, `mu_b1`, `sd_b1`, and `sd_y`.) The HDI
> bands describe the bulk of each panel's 500 draws, so they look alike. The mean line
> does not: as in Notebook 6, a single extreme draw can dominate it. The two spikes are
> such draws, one with a very large slope and one with a very large residual (Question
> 2.5). They are rare events in the same shared distribution, not different kinds of
> participant.

Keep 2.6's second paragraph. The 2.6 *question* [33] is fine as written.

Also correct the spike description in `03_execution_log.md`, and the "2 of 18 panels"
sentence in `02_implementation_notes.md`, so the record does not keep the error. Panel
positions are needed here because the panels are unlabelled; see finding 3.

The corrected version is also a better teaching moment than the original. Reading a
spike's *shape* to tell which component produced it uses both halves of the combined
model: the hierarchy's `b1` (the late-week spike) and the lognormal residual `sd_y` (the
day-0 spike).

### 2. Moderate (accuracy): the rounded summary makes the headline effect's HDI half again as wide as the plot students just drew

**Cells:**
- [51] 4.2 question (`c067def3`) and [52] 4.2 solution (`c7d00489`);
- [55] 4.4 question (`0012d568`) and [56] 4.4 solution (`c585a0cd`);
- [90] 7.1 solution (`d8e8c079`), "Fitted hierarchy" bullet.

The `mu_b1` 90% HDI is **0.025–0.046**: my reproduction gives [0.0250, 0.0455]. The 4.1
plot [50], drawn one cell earlier, shows its HDI bar from about 0.025 to about 0.045 on
an axis ticked at 0.02, 0.03, 0.04 and 0.05. With `round_to=2`, the 3.2 table prints
0.02–0.05. So 4.2 answers "**0.02–0.05** … about **2–5%**". That interval is about 3
points wide against a true 2.1, roughly 45% too wide. It is also for the notebook's
central scientific quantity, and it contradicts the plot on screen.

The execution log's "fix" moved the answer from 0.03–0.05 toward the rounded table, not
toward the value. 4.4 has the same issue on a smaller scale. `sd_b1`'s HDI is 0.014–0.031
(the 4.3 plot [54] shows about 0.0135–0.030), and the answer says "1–3 percentage points".
The errors carry into "a center of 2–5% per day" (4.4) and "about 2–5% per day" (7.1).

**Fix (markdown only):**
- Point both questions at the plots the student has just made. For 4.2: "Read the 90% HDI
  from your plot in Question 4.1 (the summary in Question 3.2 rounds it to two decimals),
  and express it as a percentage change per day." Make the matching edit to 4.4.
- Update the answers:
  - 4.2: "approximately **0.025–0.045**: … about **2.5–4.5%** per day";
  - 4.4: "approximately **0.015–0.03**: … about **1.5–3 percentage points per day**. That
    is large relative to a center of 2.5–4.5% per day";
  - 7.1: "about 2.5–4.5% per day".

**Alternative (course-wide):** `round_to=3` in the 3.2 summary. NB06's review deferred
this to a playbook-level decision for NB06–08, and this is the concrete case it
anticipated. If adopted, apply it to NB06 as well: NB06 4.4 says "3–5%" from a table
showing 0.03–0.05.

### 3. Minor–moderate (verifiability): answers name participants in panels that carry no participant labels

**Cells:** [73] 5.5 solution (`7b9a6cab`), which names 308, 332 and 309 in the
posterior-predictive panels. Also finding 1's fix, which needs to name 333 and 335. The
helper is in [7] (`d2db3b6e`).

`plot_participants` draws 18 untitled panels; `plot_lm` adds no titles. NB05 and NB06 have
the same helper. But their prose never needed to identify a *panel*: they name
participants only in forest plots and trace subsets, which are labelled. NB07 is the first
notebook whose answer key points at specific panels by ID, and a student cannot check
those claims against the figure.

**Fix, option (a): prose only, no re-execution.** Identify panels by position, and state
once that panels run in participant-ID order. For example: "308 (first panel) and 332
(sixth) … 309 (second)".

**Fix, option (b): better for students, but it changes shared infrastructure.** I tested
this in the pinned venv, both on the full 18-panel grid and with a `coords` subset. Add two
lines after `pc.add_legend(...)` in the helper:

```python
    for participant, ax in zip(pc.viz["participant"].values, pc.viz["plot"].values):
        ax.set_title(participant, fontsize="small")
```

This needs re-execution. Per playbook §1.3 and AGENTS.md's propagation rule, it should be
applied to NB05 and NB06 in the same pass, so it is an orchestrator call. If (b) is not
adopted now, use (a).

### 4. Minor (a generous reading): the shared residual scale is a systematic participant-level mismatch, not just isolated misses

**Cells:** [73] 5.5 solution (`7b9a6cab`); [90] 7.1 solution (`d8e8c079`), "Predictive
checks" bullet.

The misses in 5.5 are exactly right. By my count, 6 of 144 observations (4.2%) fall
outside the 90% bands: 308 on days 3 and 5, 332 on days 4 and 7, 370 on day 3, and 371 on
day 4. But Notebook 1's third criterion is residual variation, "emphasizing discrepancies
that persist across a participant's observations". Here the discrepancy does persist:
- Each participant's residual SD around their own fitted trajectory (log scale) ranges
  from **0.018 (309)** to **0.150 (308)** and **0.175 (332)**, against one shared
  `sd_y` ≈ 0.08.
- The plot shows this directly. 309's points hug the line inside bands that are visibly
  too wide, while 308's and 332's scatter past bands that are too narrow.

The answer's last sentence names the cause ("all participants share one residual scale
`sd_y`"). But the verdict frames what remains as "isolated observations". 7.1 repeats that
framing and drops the cause.

**Fix:** Replace the second paragraph of 5.5 with:

> The remaining misses are isolated observations, but they are not spread evenly: they
> fall in participants whose reaction times jump from day to day, such as 308 and 332,
> while the observations of steadier participants, such as 309, sit well inside the bands.
> This is a mild but systematic mismatch in residual variation: all participants share one
> residual scale `sd_y`, which is too large for the steadiest participants and too small
> for the most variable ones.

In the 7.1 "Predictive checks" bullet, replace everything after "each participant's level
and rate of change are reproduced" with:

> …; what remains is a mismatch in residual variation, because one shared `sd_y` is too
> large for the steadiest participants and too small for the most variable ones.

This is a finding about this notebook's own model, not a preview. Do not mention
Notebook 8.

### 5. Minor (optional; teaching goal): the notebook never compares its fitted results with Notebook 5

**Cell:** [52] 4.2 solution (`c7d00489`).

The stated goal is to combine NB5's hierarchy with NB6's likelihood. The notebook compares
its results with NB6 throughout (4.2, 4.7, 5.5, 5.8) but never with NB5's fitted effect.
One sentence would close that loop and also show what is new about the combination: in
milliseconds, a participant's daily change is baseline × rate. At the population center,
$e^{\mu_{b0}} \approx 270$ ms, so 3.6% per day is about 10 ms/day at baseline. Averaged
over the week it is about 11 ms/day, which agrees with Notebook 5's `mu_b1` of 11.3
ms/day.

Suggested addition to 4.2:

> In milliseconds, this is about 10 ms per day at the population's baseline of roughly
> 270 ms, and about 11 ms per day averaged over the week, close to Notebook 5's estimate.

This is optional. AGENTS.md treats added content as a cost, and the plan scoped the
comparisons to NB6.

### 6. Trivial

- [28] 2.3 solution (`3f7549d8`): "`sd_b1` is mostly below about 0.11". The plotted 90%
  HDI [26] ends at 0.12 (500 draws; the analytic value is 0.115). Say "about 0.12" to
  match what students see. The "about 0.4" for `sd_b0` matches (0.39).
- [79] `## 6. Sensitivity of the hierarchical scales` (`a4eddabe`): the section
  power-scales all five top-level priors, including `mu_b0`, `mu_b1` and `sd_y`. "Prior
  sensitivity" would describe it more accurately. No figure depends on this heading.

---

## The `sd_sd_b1` change (0.1 → 0.05): reviewed; I agree with accepting it

I read the reasoning in `02` and `03` rather than taking the number on trust.
- The text is **coherent with 0.05 throughout**, with no leftover 0.1-era text:
  - 1.2 says the scale priors are new and are examined in Section 2;
  - 2.3's numbers all follow from scale 0.05: prior mean 0.05, $e^{0.35} \approx 1.4$,
    about ×2 near the upper end, and an HDI endpoint of about 0.12 (finding 6);
  - 2.5 calls the spike rare, not routine;
  - 7.1's "much tighter" matches.
- 2.3 presents the tighter slope-variation prior as motivated by compounding over days.
  That is the actual reason it was chosen, so the presentation is honest. Students never
  saw 0.1, so the change needs no disclosure.
- What I found adds one point to the decision. Even at 0.05, the late-week spike comes
  from the single largest `sd_b1` draw (0.342). The day-0 spike comes from the tail of
  NB6's carried-over `sd_y` prior, not from the new hierarchy priors. So the remaining
  display roughness cannot be blamed on the 0.05 choice, and nothing here argues for
  changing it further.

## Considered, not recommended for this pass

- **ECDF labels** [76]: the plot is titled `y` and has no x-axis label. This is the same
  as NB5 and NB06; NB06's review deferred it to a course-wide pass.
- **Subset trace plot** [45]: there is no legend mapping colours to 308, 337 and 372. This
  is inherited from NB5, and the colours are irrelevant to a mixing verdict.
- **6.1's power-scaling rationale** [81]: I did not re-run the unrestricted
  `psense_summary`, because the execution log did. The reasoning is sound. The population
  densities are the pooling mechanism. The implementer showed that the flags change with
  the parameterization of the same posterior, so they do not measure the chosen top-level
  priors.
- **The mean line above the 50% band** in 2.4: NB06 2.9 teaches why. With finding 1's fix,
  2.6 points back to it, which is enough.

## Checked and found sound

- **Tags.** All 91 cells are tagged: 7 `section`, 27 `exercise-question`, 27 `solution`,
  27 `given`, and 3 `exercise-question`+`given-answer`. Every `exercise-question` is
  followed by exactly one `solution`. Every tag matches the cell's role. The given-answer
  patterns in 5.6, 6.1+[81] and 6.2 follow NB06's precedent.
- **Self-work derivation (my own script).** The two files have the same cell count, ids,
  types, order and tags.
  - All 27 `solution` cells are exactly `- answer here` / `# answer here`.
  - Every other cell is byte-identical, except cell 0, which differs only by the badge
    URL.
  - The self-work file has no outputs, null execution counts, no `metadata.execution` and
    no `metadata.widgets`.
  - Both files pass `nbformat.validate`, and their cell ids are unique.
  - No `given` cell depends on a name created in a `solution` cell.
- **Naming.** Grep hits for `Reaction`, `intercept`, `slope` and `sigma` are only:
  - the data column;
  - PyMC's `sigma=` argument;
  - ordinary prose ("varying intercepts and slopes").

  There is no `participant_intercept*`, `population_mu`, `target_accept`, `print(model)`,
  `lam=`, `_z`, or `\(`/`\[` math anywhere.
- **Closing section.** 7.1 is purely retrospective. There is no "Notebook 8", no "next"
  and no preview anywhere in the notebook.
- **Numbers against my reproduction.** All match, apart from findings 1, 2 and 6.
  - *Diagnostics:* 0 divergences; R-hat 1.00; population ESS ≥ 2,985; participant screen
    minimum tail ESS 2,602.
  - *Prior predictive (2.5):* the largest 50% HDI upper edge on any panel or day is 181 ms,
    below the minimum observation of 203 ms. On day 7, the 50% lower edges are 0–4 ms and
    the 90% upper edges are 1.09–1.55 s.
  - *Posterior (4.6, 4.7):* the `b1` means are 335 −0.005; 308 0.057; 337 0.058;
    370 0.058; 350 0.063. `sd_y` is 0.079, and `mean_rt` is 0.31% above the median.
  - *Posterior predictive:* 22.9% of observations fall outside the `mean_rt` 90% band
    (5.2); the median band widths are 34 ms for `mean_rt` and 86 ms for the predictive
    band. The 5.5 misses are as listed under finding 4.
  - *ECDF (5.8):* the observed ECDF lies inside the pointwise 95% posterior-predictive
    band at every point of a 150–650 ms grid.
  - *Sensitivity (6.4):* `sd_b0` 0.034 is the largest; nothing is flagged.
- **Conventions:**
  - 90% HDIs, with `ci_kind="hdi"` passed explicitly to every summary, `plot_dist`,
    `plot_forest` and helper call;
  - the mean as the point estimate throughout;
  - `pm.Exponential(scale=...)` and named prior constants;
  - the centered parameterization with default sampling;
  - `pm.model_to_graphviz` (the nodes are correct, including `mean_rt`);
  - no unused `plot_population`.
- **Workflow checklist:**
  - Prior and posterior predictive checks are on the observable scale and use the same
    `plot_participants` grammar.
  - Uncertainty about the mean (5.1–5.2, `mean_rt`) is kept separate from predictive
    variation (5.3–5.4, `y`).
  - Criteria are stated before each check (2.1, 3.3, 5.6).
  - NB06's `mu_y`/`mean_rt` distinction carries over correctly and is extended to the
    participant level (1.7, 5.1).
  - NB05's hierarchy-reading pattern (1.3–1.5, the 3.4 subset, the `b1` forest) carries
    over.
  - `mean_rt` is defined, asked about, plotted and interpreted.
- **Scaffolding.** The NB5-style split fits the goal. Students repeat a small amount of
  NB05 mechanics (4.1, 4.3, 4.5, 3.3, 3.5) as practice. Most student work is about the
  combination itself:
  - proportional readings of `sd_b0` and `sd_b1` (1.5, 2.3, 4.2, 4.4);
  - why `sd_y` shrinks (1.6, 4.7);
  - participant-level `mean_rt` (1.7, 5.1);
  - the explicit NB6 comparisons (5.5, 5.8).

  Finding 5 names the one missing link, to NB5's results.
- **Prose.** Answers are declarative and short, with no hedging ("provided that…"), in
  NB1–03/NB06 style. The exceptions are 2.5 and 2.6, which are long; finding 1's
  replacement text is about the same length.
