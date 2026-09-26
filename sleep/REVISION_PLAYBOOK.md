# Notebook revision playbook

This playbook generalizes the process used to revise `sleep/01_linear_baseline.ipynb`
through `sleep/05_varying_intercept_slope.ipynb` (and their `solved/` counterparts) so
the same process can be applied consistently to the rest of a notebook sequence, and to
future sequences. It supplements `AGENTS.md`; where the two conflict, `AGENTS.md` wins.

Read this file before revising any notebook in a sequence that has an established
"revised" style (i.e. at least one notebook in the sequence has already gone through
this process). For the first notebook in a brand-new sequence, use `AGENTS.md` directly
and treat the result as the new reference style.

## What "revision" means here

Empirically, revising a notebook in this repository is **not** a mechanical refactor.
Comparing `sleep/01`–`05` before and after their "Revise ___ notebook" commits shows the
same recurring transformation:

1. **Decompose flowing sections into atomic, numbered sub-questions.** A pre-revision
   section like `## 6.1 Priors on the wrong scale` that mixes narrative, one code cell,
   and an embedded interpretation becomes a sequence of small cells, each answering one
   focused question (`### 1.3 Which quantities vary by participant?`, `### 1.4 Which
   parameter is the population-average slope?`, …), matching the granularity already
   visible in `sleep/05`. Each question is small enough that a student could answer it
   in one or two sentences, or one short plotting call.
2. **Add the explicit workflow checkpoints AGENTS.md requires** that a leaner
   pre-revision draft may have skipped or merged: an explicit "do the priors look
   plausible?" judgment question after prior predictive checks, an explicit "are the
   diagnostics clean (divergences / R-hat / ESS)?" question before interpreting the
   posterior, a clear separation between population-level uncertainty and
   participant-level / predictive variation.
3. **Keep the underlying model, plotting helpers, and data pipeline stable** unless the
   notebook's own teaching point requires a change. The `plot_population` /
   `plot_participants` helpers, `LM_VISUALS`, `PARTICIPANT_DAY`, the data-loading cell,
   and the `%pip install` / import preamble are copied verbatim from notebook to
   notebook (they were already brought to "ArviZ-native" style in an earlier pass, see
   `git log --oneline -- sleep/`). Do not redesign them while revising content unless a
   plan explicitly identifies a repository-wide convention change.
4. **Rewrite markdown prose** to be concise, question-driven, and to state interpretive
   conclusions in plain scientific language (e.g. "The 90% HDI for `mu_b1` is
   approximately 7.94–14.71 ms/day...") rather than only describing what a plot shows.
5. **Re-derive the `solved/` and self-work versions from one authored source.** The
   `solved/` notebook is written first, in full. The self-work notebook in `sleep/` is
   then produced by mechanically replacing selected cells with placeholders
   (`- answer here` for a markdown interpretation cell, `# answer here` for a code
   cell) while leaving **every other cell byte-identical**, including all setup,
   plotting-helper, and question-framing markdown cells, and the Colab badge URL
   (which does change, to point at `solved/`). Never author the two versions
   independently — that invites drift and doubles the work.
   - Which cells get blanked is a judgment call tied to the notebook's specific
     teaching goal, not a fixed rule. Compare `sleep/05` (interpretation-only notebook:
     the model itself is given, "The full model is supplied", so only interpretation
     and plotting-call cells are blanked) against a still-unrevised notebook like the
     pre-revision `sleep/06` (whole sections blanked wholesale). The revised convention
     is the fine-grained, per-question blanking demonstrated in `sleep/05`, not the
     coarse whole-section blanking it replaced.
6. **Update `sleep/README.md` and `sleep/solved/README.md`** only when a change is a
   genuine repository-wide convention (a new shared helper, a new modeling note that
   applies beyond one notebook) — not for content specific to a single notebook's
   narrative.
7. **Figures**: only regenerate/add a `Slides/figures/*.svg` output where the notebook
   already has a `save_slide_figure` call, or where `Slides/slide_deck.typ` newly
   references a figure from this notebook. As of this playbook's writing, only
   `sleep/01_linear_baseline.ipynb` saves a slide figure (`01_linear_baseline_data`),
   and `slide_deck.typ` does not yet reference notebooks 2–12. Do not invent new slide
   figures speculatively (AGENTS.md: "Save only figures the slides use or are about to
   use").

See `/tmp/.../scratchpad/revision_pattern_report.md` (generated once per playbook
refresh — regenerate with the diffing procedure below if it is not present) for the
full evidentiary detail behind these rules, including concrete before/after excerpts.

## Roles and artifacts (who does each step, and what they must leave behind)

Every step below produces a durable, git-committed artifact under
`sleep/revision_logs/<NN>_<slug>/`. Artifacts are not optional scaffolding — they are
the record of what was decided and why, for a human reviewer who was not watching the
work happen. Do not silently skip a step because it "seems obvious."

| Step | Who | Artifact |
|---|---|---|
| 1. Plan | Orchestrator (the primary session, or a `Plan`-type / high-reasoning agent with the full comparative context already loaded) | `sleep/revision_logs/<NN>_<slug>/01_plan.md` |
| 2. Implement | A general-purpose implementation agent (opus-tier for content quality), given the plan verbatim | Rewritten `sleep/solved/<NN>_*.ipynb` and `sleep/<NN>_*.ipynb`; `sleep/revision_logs/<NN>_<slug>/02_implementation_notes.md` |
| 3a. Execute & verify | Orchestrator, using the pinned-stack environment | `sleep/revision_logs/<NN>_<slug>/03_execution_log.md` (diagnostics summary, not raw logs) |
| 3b. Fresh-eyes review | A second, independently-briefed agent that did not write the notebook | `sleep/revision_logs/<NN>_<slug>/04_review.md` |
| 4. Fix loop | Implementation agent, given the review findings | Updated notebooks + note appended to `02_implementation_notes.md` |
| 5. Commit | Orchestrator | One commit per notebook pair, referencing the revision log directory |

Rationale for the tiering:

- **Plan** needs the broadest context (AGENTS.md, the diff-pattern report, the nearest
  already-revised notebook, the specific notebook's current content, the relevant
  PyMC-Labs skill summaries) and the judgment calls are genuinely hard to delegate
  cold — an agent starting from nothing tends to either under-decompose or invent
  content that doesn't match the established voice. Whoever already holds this context
  (typically the orchestrating session) should write the plan, or delegate to a
  high-reasoning `Plan`-type agent and hand it that context explicitly.
- **Implement** is well-scoped once a plan exists ("write these N atomic Q&A cells
  covering these points, in this order, reusing this model code") and benefits from a
  content-focused agent that can spend its full budget on notebook prose and code
  without re-deriving the plan.
- **Execution/diagnostics** is mechanical and must be done with real tool access to the
  pinned stack (`pymc==6.3.2`, `arviz-base==1.3.0`, `arviz-stats==1.3.2`,
  `arviz-plots[matplotlib]==1.3.1` under Python ≥3.12) — do not accept an agent's claim
  that a notebook "should sample fine" as a substitute for actually running it. Do not
  claim outputs are validated unless they were actually executed end-to-end in this
  session; report explicitly if the pinned stack could not be verified in the current
  environment.
- **Fresh-eyes review** exists because the implementer, having just written the
  notebook, is the worst-positioned party to notice that it drifted from the plan, from
  AGENTS.md's "Critiquing and improving teaching notebooks" checklist, or from the
  established voice. Brief the reviewer as if it knows nothing about the session's
  history; give it the plan, the AGENTS.md checklist, and the finished notebooks, and
  ask it to find problems, not to confirm the work is good.

## Step 1 — Plan

Before planning notebook `N`, gather (read in full, do not skim):

1. `AGENTS.md` (repository rules — already binding, re-read the "Bayesian workflow
   conventions", "Teaching and code style", and "Critiquing and improving teaching
   notebooks" sections specifically).
2. This playbook.
3. The nearest already-revised notebook, both `sleep/<N-1>_*.ipynb` (self-work) and
   `sleep/solved/<N-1>_*.ipynb` (solved) — the closest available style reference.
4. `sleep/solved/README.md` and `sleep/README.md` — the target conventions and the
   one-line description of what notebook `N` is supposed to teach.
5. The current (pre-revision) `sleep/<N>_*.ipynb` and `sleep/solved/<N>_*.ipynb`.
6. The relevant PyMC-Labs skill `SKILL.md` files (installed under
   `.agents/skills/` at the cloned-skills checkout, or wherever they were installed
   this session — see AGENTS.md's "PyMC / ArviZ skills" section) for any modeling,
   prior, diagnostic, or PyTensor work the notebook involves. Read the specific
   `references/*.md` a skill points to only if the notebook's content actually touches
   that topic (e.g. `references/hierarchical.md` for a varying-effects notebook).

Then write `sleep/revision_logs/<NN>_<slug>/01_plan.md` containing:

- **Teaching goal**: one or two sentences, taken from/refined from `solved/README.md`'s
  sequence description.
- **Structural plan**: the ordered list of numbered sections/sub-questions the revised
  notebook will have (e.g. "6.1 Priors on the wrong scale" → "6.1.1 ... / 6.1.2 ...").
  Number granularity should match the nearest revised notebook's granularity for a
  comparable teaching step (interpretation-heavy sections get many small questions;
  a single derivation might stay as one).
- **What changes and what doesn't**: explicitly call out (a) content unique to this
  notebook that will change, and (b) shared infrastructure (plotting helpers, data
  loading, preamble) that will be copied unchanged from the previous notebook. If you
  believe shared infrastructure itself needs to change, flag this as a **repository-wide
  convention change** and say so explicitly — do not change it silently, since it
  affects every other notebook in the sequence (see "No silent decisions" note below).
- **Model/code changes**: the actual statistical content — likelihood, priors (in their
  meaningful units, not just numbers), any new `pm.Deterministic`, sampling settings,
  diagnostics to check, prior-sensitivity approach, posterior-predictive approach.
  State *why*, tying back to the notebook's teaching goal.
- **Self-work blanking plan**: which cells will become `- answer here` / `# answer
  here` in the `sleep/` version, and which stay given (with a one-line justification,
  e.g. "the ex-Gaussian likelihood is new content this notebook introduces, so its
  `pm.Model` block is NOT given" vs "the plotting helpers are infrastructure, always
  given").
- **Figures**: state explicitly whether any `save_slide_figure` call is added, and why
  (default: no, per the Figures rule above).
- **Open questions/risks**: anything genuinely ambiguous that the implementer should
  make a judgment call on, or that the orchestrator should sanity-check before/after
  implementation.

## Step 2 — Implement

Hand the implementer the plan file path and this playbook. The implementer:

1. Writes `sleep/solved/<NN>_*.ipynb` in full, following the plan. Follow AGENTS.md's
   "Teaching and code style" and "Critiquing and improving teaching notebooks"
   sections while writing — these are not just review criteria, they are drafting
   criteria.
2. Derives `sleep/<NN>_*.ipynb` from the solved version per the blanking plan: copy the
   solved notebook, replace the designated cells' source with the placeholder text,
   clear all outputs and execution counts in the self-work version (outputs are
   intentionally cleared for self-work notebooks per AGENTS.md), and fix the Colab
   badge URL to point at the non-`solved/` path.
3. Leaves every non-blanked cell in the self-work notebook byte-identical in source to
   the solved notebook (verify this with a cell-source diff, e.g. adapt
   `nb_diff_files.py` from the analysis phase — do not eyeball it).
4. Writes `sleep/revision_logs/<NN>_<slug>/02_implementation_notes.md`: what was
   written, any deviation from the plan and why, any modeling choice that needed a
   judgment call beyond what the plan specified.
5. Does **not** hand-execute the notebook to produce outputs by copy-pasting numbers —
   leave that to Step 3a, which actually runs it. Placeholder/stale outputs at this
   point are fine; Step 3a overwrites them.

If the notebook's content requires touching PyTensor internals, custom likelihoods, GP,
or other advanced areas, consult the matching skill reference file first
(`pytensor-workflows`, or the relevant `pymc-modeling` reference) rather than
hand-rolling something AGENTS.md and the skills already cover.

## Step 3a — Execute and verify (orchestrator)

Use the pinned stack. If it is not already set up in the current environment:

```bash
python3.12 -m venv <scratch>/nbenv   # pymc==6.3.2 requires Python >=3.12
source <scratch>/nbenv/bin/activate
pip install pymc==6.3.2 arviz-base==1.3.0 arviz-stats==1.3.2 \
    "arviz-plots[matplotlib]==1.3.1" pandas==2.2.3 jupyter nbclient nbformat ipykernel
python -m ipykernel install --user --name nbenv
```

Execute the **solved** notebook top to bottom in place:

```bash
jupyter nbconvert --to notebook --execute --inplace \
    --ExecutePreprocessor.kernel_name=nbenv \
    --ExecutePreprocessor.timeout=2400 \
    sleep/solved/<NN>_*.ipynb
```

Then, from the executed notebook's saved outputs:

- Confirm zero cell-execution errors.
- Confirm zero divergences, or an explicit discussion in the notebook if divergences
  are part of the teaching point (e.g. a deliberately bad model in a "what goes wrong"
  section).
- Confirm R-hat ≈ 1.00 and adequate bulk/tail ESS for every reported parameter, per
  AGENTS.md ("For MCMC models, inspect at least divergences, R-hat, and effective
  sample size before substantive interpretation").
- Spot-check that prior/posterior predictive plots and any numeric claims written in
  markdown (e.g. "the 90% HDI is approximately X–Y ms/day") match the just-produced
  output, not a stale or invented number.
- The **self-work** notebook is not executed for grading (its model-building cells are
  intentionally incomplete); instead confirm it has cleared outputs and that its
  non-blanked cells still match the solved notebook exactly (structural check only).

Record a concise summary — not raw logs — in `03_execution_log.md`: environment used,
sampling settings, divergence/R-hat/ESS summary per model fit in the notebook, and any
number quoted in the notebook's markdown cross-checked against the actual output.

Do not skip this step or represent a notebook as validated without having actually run
it in this environment. If the pinned stack cannot be installed or executed (e.g. no
network, incompatible Python), say so explicitly in the log rather than presenting
untested output as validated — this mirrors the "no silent decisions" requirement: an
inability to validate is itself a fact the eventual reader needs, not something to
paper over.

## Step 3b — Fresh-eyes review

Brief a second agent that has **not** seen the implementation work. Give it://
- This playbook, AGENTS.md, the plan (`01_plan.md`), and the two finished notebooks.
- Explicit instruction to look for problems, using AGENTS.md's "Critiquing and
  improving teaching notebooks" section as a checklist (conceptual clarity, minimal
  first model, correct predictor/outcome support treatment, HDI/point-estimate
  conventions, graphical grammar consistency, whether posterior-predictive checks are
  genuinely on the observable-data scale, etc.), plus whether the self-work notebook's
  blanking choices make pedagogical sense.
- Instruction to write findings to `04_review.md`, ranked by severity, each with a
  concrete fix suggestion — not just "this could be clearer."

## Step 4 — Fix loop

Route real findings back to the implementer (or fix directly, for small/mechanical
issues, noting the fix in `02_implementation_notes.md`). Re-run Step 3a if any change
touches model code, sampling, or numeric claims. Iterate until the reviewer has no
remaining findings above a minor/stylistic level, or until remaining findings are
explicitly deferred with a stated reason.

## Step 5 — Commit

One commit per notebook pair (mirroring the existing history: `"Revise <topic>
notebook"`), including the notebook files and their `sleep/revision_logs/<NN>_<slug>/`
directory. Push after each notebook so work is not lost if the session ends early —
do not batch all seven remaining notebooks into one commit.

## No silent decisions

If applying this playbook to a specific notebook requires deviating from it — e.g. a
notebook's teaching goal genuinely needs a different section granularity, a shared
helper needs a repository-wide change, or the pinned stack cannot be verified — record
that deviation explicitly in the relevant artifact (`01_plan.md` or `03_execution_log.md`)
rather than silently improvising. This mirrors the standing instruction that internal
decisions to deviate from an agreed plan must be visibly recorded, not just acted on.
