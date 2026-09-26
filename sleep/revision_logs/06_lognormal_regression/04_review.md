# Fresh-eyes review: notebook 06 — Lognormal regression

Reviewer: independent agent (Step 3b of `sleep/REVISION_PLAYBOOK.md`). I did not write this
notebook. Inputs read in full: `AGENTS.md`, the playbook, `01_plan.md`,
`02_implementation_notes.md`, both NB06 notebooks cell by cell (including the executed
outputs and all five rendered plots), NB03 solved and self-work, and NB01, NB02, and NB05
solved for calibration. I also read the pre-revision NB06 (`c13156e`) to see where the
prior values came from.

**Verdict: nearly ready. Fix findings 1–2 before committing.** Every fix below is
markdown-only, so no re-execution is needed unless the instructor picks option B under
finding 1. The code, tags, derivation, naming, and diagnostics are clean. The main
problem is how the notebook reads its own corrected prior predictive plot. That matters
here more than elsewhere, because this notebook's lesson is the prior predictive check
itself.

Cell references give the index in the 80-cell notebook, the question number, and the cell
id. Ids are the same in both files.

---

## Findings (most severe first)

### 1. Major (content): the verdict on the corrected prior predictive understates what the plot shows

**Cells:** [36] 2.8 solution (`62be4c67`), [38] 2.9 solution (`d7401a15`), [79] 7.1
solution (`13880eff`), Priors bullet.

In the executed 2.7 plot, the **50% HDI band lies below about 150 ms on every day in every
panel, and below every observed reaction time**. At day 7 it runs from about 0 to 150 ms.
The 90% band's lower edge reaches almost 0 ms by day 7. So the prior's *most probable*
reaction times are implausibly fast, not just its tails. I checked this with a quick
simulation of the same priors: at baseline 27% of prior predictive reaction times are
below 100 ms, and at day 7 40% are below 100 ms and 24% are below 50 ms. The notebook
itself calls 50 ms the lower edge of plausibility. For comparison, NB1's Gaussian prior
has 10% (baseline) and 21% (day 7) below 100 ms, and its 50% band sits around 160–330 ms
with the data inside it.

The 2.8 answer ("Broadly, but with an important warning … mostly a plausible range") gives
the same verdict NB5 gave for a far milder problem: NB5's 90% bands dipped below zero on
some late days. The answer never mentions where the 50% band sits. The 2.9 answer explains
the low band only as a display feature ("Both displays are correct"). The 7.1 Priors bullet
calls the predictions "broadly plausible, although very permissive late in the week".
Students will see the dark band sitting under all the black points. The answer key should
address that directly, not model a generous reading of a prior predictive check in the
notebook meant to teach that skill.

There are two causes, and the notebook already contains both:
- 2.1 centres the median baseline at $e^5 \approx 150$ ms. The answer even points out that
  this is the geometric midpoint, not 250 ms, but never links it to the plot.
- 2.2's `sd_b1 = 0.2` compounds multiplicatively across days.

**Fix A (recommended minimum; prose only, uses only what the plot shows).** Replace 2.8's
answer with something like:

> Only partly. The scale mistake is gone: every prediction is a positive reaction time, and
> at baseline the 90% bands span roughly 20–350 ms. But the 50% bands lie below about
> 150 ms on every day, below every observed reaction time: the prior's most probable
> reaction times are implausibly fast. This follows from Question 2.1, which centred the
> median baseline reaction time on the geometric midpoint, about 150 ms, rather than on
> 250 ms. Because `b1` acts multiplicatively, its uncertainty also compounds across days:
> by day 7 the 50% band reaches almost zero and the 90% band extends to about a second.
> Positive support rules out negative reaction times, not implausible ones. Like the
> priors in Notebook 1, these are deliberately broad teaching priors; we proceed, and
> Section 6 checks whether they influence the posterior.

In 2.9, add one sentence: "The low position of the 50% band is not only a display effect:
it shows where most of the prior predictive probability lies (Question 2.8)." In the 7.1
Priors bullet, replace "broadly plausible, although very permissive late in the week" with
"always positive, but centred on implausibly fast reaction times and very permissive late
in the week".

**Option B (instructor decision; needs re-execution and re-checking every number).**
Tighten the priors so the corrected prior actually passes: for example `sd_b1 ≈ 0.08`
(see finding 2), and/or centre `b0` on log(250) ≈ 5.5 by eliciting the median rather than
the 50–450 ms range midpoint. In the same simulation, `sd_b1 = 0.08` alone cuts day-7
draws below 50 ms from 24% to 11%. Adding a `Normal(5.5, 0.45)` `b0` cuts it to 3%.
6.4 shows the posterior is insensitive to these priors, so the conclusions would not
change. Weighing against B: the pre-revision notebook attributes `Normal(5, 0.55)` to "the
chapter" (old cell 17), and the plan fixed the values. So A is the default unless the
instructor wants B.

### 2. Moderate (accuracy): "expressing similar beliefs" is not true, and the slope range in 2.2 appears from nowhere

**Cells:** [79] 7.1 solution (`13880eff`), Priors bullet; [23] 2.2 question (`99fa1c53`);
[24] 2.2 solution (`f6e7c4b7`).

7.1 says "Expressing similar beliefs on the log scale gave … $b_1 \sim$ Normal(0, 0.2)".
But NB1's slope belief was ±40 ms/day. At a baseline near 250 ms that is about ±16% per
day, or ±0.15 on the log scale (sd ≈ 0.075). 2.2 instead stipulates ×0.67 to ×1.5 per
day (±50%, sd 0.2), which is about 2.7 times broader. The `b0` centre also moved from
250 ms to about 150 ms. A student who asks "why not just translate Notebook 1's ±40 ms/day?"
gets no answer anywhere. The implementer flagged this mismatch (implementation notes,
"Slope elicitation framing"), but the notebook text does not acknowledge it.

**Fix (if option A is chosen for finding 1):**
- Add a sentence to the 2.2 solution: "This is deliberately broader than Notebook 1's
  slope prior: ±40 ms/day at a baseline near 250 ms is only about ±16% per day."
- In 7.1, replace "Expressing similar beliefs on the log scale gave" with "Re-eliciting
  the priors on the log scale gave".

**If option B is chosen,** re-derive 2.2 from NB1's ±40 ms/day. The "similar beliefs"
wording then becomes true.

### 3. Minor (accuracy): 2.9's description of the mean line does not match the plot

**Cells:** [37] 2.9 question (`0e23e6b9`, which also appears in the self-work notebook);
[38] 2.9 solution (`d7401a15`).

- The answer says large draws make the mean line "jumpy at later days". In the executed
  plot, the largest spike is at **day 3** (bottom row, second panel, about 1,400 ms), and
  two middle-row panels jump at **day 0**. Suggested replacement: "A few very large draws
  also make the mean line jump on individual days. This model has no participant-specific
  parameters, so every panel shows the same prior predictive distribution, and these
  differences between panels are only simulation noise." The second sentence answers the
  question students will ask about the 1,400 ms spike.
- The question says "The orange line is the prior predictive mean". Under
  `arviz-variat`, C1 renders **pink** in every plot in this notebook; `b1`'s trace uses
  the same colour. Drop the colour word ("The line is the prior predictive mean; the
  bands are HDIs") or say "pink". NB06 is the first notebook to put this colour word in
  student-facing prose; NB1 and NB2 have it only in a code comment. `sleep/solved/README.md`
  ("an orange mean line") has the same mismatch; correct it in a course-wide pass, not
  here.

### 4. Minor (clarity): "also" in 5.6 reads as if this model were hierarchical

**Cells:** [67] 5.6 solution (`7680b969`); [79] 7.1 solution (`13880eff`), Predictive
checks bullet.

"That model also had participant-specific intercepts and slopes" is easy to misread as
"both models had them". Suggested wording: "Unlike this notebook's model, Notebook 5's
model also had participant-specific intercepts and slopes, so the comparison is not
like-for-like; on these data the marginal check does not decisively favour either
likelihood." The 7.1 bullet repeats the comparison ("reproduced about as well as by the
Gaussian likelihood in Notebook 5") without the caveat. Add "(a hierarchical model, so
only a rough comparison)" or drop the comparison from the summary.

### 5. Minor (grounding): 1.6 claims all three criteria fail, but the evidence shown covers only two

**Cell:** [19] 1.6 solution (`735270b4`).

The supplied summary gives only a pooled median and a pooled share of draws between 50 ms
and 1 s. That supports criteria 1 and 2. Nothing shown addresses criterion 3 (plausible
changes across days). Add one sentence so the verdict rests on something visible: "The
slope prior is just as extreme: a daily effect of $b_1 = 20$, well inside
Normal(0, 20), would multiply reaction time by $e^{20} \approx 5 \times 10^8$ in a
single day."

### 6. Minor (convention): 1.5 reports a median without saying why

**Cells:** [16] 1.5 given markdown (`32e0c61a`); [17] 1.5 given code (`75a34351`).

AGENTS.md says to use the mean, not the median, as the point estimate in summaries. The
median is the right choice here, because enough draws overflow to `inf` that the mean is
infinite. But that reason appears only in the implementation notes, so the notebook looks
like it breaks the convention. Add a clause to [16]: "Some draws are so large that they
overflow to infinity, so the summary reports the median rather than the mean." [16] is
`given`, so apply the same edit to the self-work copy.

---

## Considered, not recommended for this pass

- **ECDF labels** ([65] `c570ab7f`): the plot is titled with the variable name `y` and has
  no x-axis label, where AGENTS.md prefers scientific labels. NB5's ECDF looks the same,
  so the graphical grammar is consistent. If this is fixed, fix it in NB5–NB06 and later
  notebooks together, not in NB06 alone.
- **`round_to=2` for log-scale parameters** ([43] `d7df975b`): `b1` shows as
  0.04 [0.03, 0.05], essentially one significant figure for the notebook's key effect.
  `round_to=3` would make 4.4's "3–5% per day" more precise. The playbook (§3.7) fixes
  `round_to=2`, so this is a playbook-level question for NB06–08, not an NB06 fix.
- **4.1 partly repeats 2.5's prompt**, which already names `mean_rt` as the expected
  reaction time and gives its formula. This is the same recall pattern NB1 uses (5.8), and
  the second half of 4.1 (median vs. mean, the 1.5% gap) adds real content. Acceptable.

## Checked and found sound

- **Tags:** every one of the 80 cells is tagged: 7 `section`, 27 `exercise-question`,
  3 `exercise-question`+`given-answer`, 15 `given`, 28 `solution`. Each tag matches the
  cell's role. The given-answer patterns (inline answer in 5.4; question plus a separate
  `given` cell in 6.1; question plus given code in 6.2) all have NB1 or NB3 precedent.
- **Self-work derivation (checked with my own script):** same cell count, ids, types,
  order, and tags. All 28 `solution` cells are exactly `- answer here` / `# answer here`.
  Every other cell's source is byte-identical, except cell 0, which differs only by the
  badge URL. The self-work file has no outputs, null execution counts, no
  `metadata.execution`, and no `metadata.widgets`. The solved file keeps its execution
  metadata and widgets, as NB1–05 solved do.
- **Naming:** no leftover `Reaction`/`intercept`/`slope`/`sigma`/`mu` as variable names in
  code or prose. The remaining hits are the data column `sleep["Reaction"]`, PyMC's
  `sigma=` argument, and ordinary prose ("one intercept, one slope").
- **Closing section:** 7.1 is purely retrospective. There is no reference to Notebook 7,
  "next", or any preview anywhere, so the §3.10 correction was actually applied.
- **Conventions:** 90% HDIs throughout, with `ci_kind="hdi"` explicit in the summary and
  helpers. The mean is the point estimate in every plot (the 1.5 median is covered by
  finding 6). Exponentials use `scale=`, prior constants are named, sampling uses the
  default settings, and there is no `print(model)`. There are no unused imports
  (`Line2D`/`Patch` are gone), and `plot_population` is defined because 4.2 uses it.
  Section headings follow NB5's style. LaTeX uses `$`/`$$` only and renders correctly.
- **Workflow and teaching checklist:** prior and posterior predictive checks are both on
  the observable scale, using the same `plot_participants` grammar. Uncertainty about the
  mean (4.2–4.3) is kept separate from predictive variation (5.1–5.2). The ECDF criteria
  are stated before the plot (5.4). The intro does not claim the Gaussian model failed.
  Every `mean_rt` and `mu_y` is either used or asked about. Numbers I re-derived by hand
  are correct: log(50) and log(450), $e^5$, $e^{1/3}$, $e^{0.17^2/2}$ ≈ 1.5%, $e^{250}$, and
  the age of the universe in ms.
- **Scaffolding:** the `given`/`solution` split serves the stated goal. Students do the
  new work: diagnosing the scale mistake, eliciting the log-scale priors, adding
  `mean_rt`, and the multiplicative reading of `b1`. The flawed demonstration model and
  the power-scaling bookkeeping are supplied. Every name a later `given` cell depends on
  (`bad_prior`, `prior`, `model`, `coords`) is named in the prompt, and `idata` follows
  NB3's precedent.
