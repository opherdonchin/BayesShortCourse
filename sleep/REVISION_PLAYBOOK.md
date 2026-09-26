# Notebook revision playbook

This playbook generalizes the process used to revise `sleep/01_linear_baseline.ipynb`
through `sleep/05_varying_intercept_slope.ipynb` (and their `solved/` counterparts) so
the same process can be applied consistently to the rest of a notebook sequence, and to
future sequences. It supplements `AGENTS.md`; where the two conflict, `AGENTS.md` wins.

The empirical basis for this playbook is
`sleep/revision_logs/_shared/nb01-05_revision_pattern_report.md`, a full-detail diff
analysis of all 10 notebook pairs across the four "Revise ___ notebook" commits. Read
that report for concrete before/after excerpts; this file distills it into decisions
and a repeatable process. Where this playbook makes a decision on something the report
flagged as an open question, that decision is recorded in §3 below — do not re-litigate
it per notebook without a real reason.

Read this file before revising any notebook in a sequence that has an established
"revised" style. For the first notebook in a brand-new sequence, use `AGENTS.md`
directly and treat the result as the new reference style.

## 1. What "revision" means here

Revising a notebook is **not** a mechanical refactor — it is content authorship inside
a fixed scaffold. The recurring transformation, evidenced across NB1–05:

1. **Decompose flowing sections into a two-level, tagged Q&A worksheet.** Cell counts
   grow 3–10×. The structure is `## N. <Stage>` sections, each containing several
   `### N.M <question or task>` cells, each followed by exactly one answer cell. See
   §2 for the exact tag scheme — it is not just a formatting choice, it is the
   mechanism that generates the student notebook.
2. **State criteria before checking them.** Before judging prior-predictive
   plausibility, sampling diagnostics, or posterior-predictive adequacy, state the
   numeric/qualitative criteria explicitly, then apply them. NB1 establishes the
   canonical wording for sampling criteria; later notebooks reference it ("criteria
   established in Notebook 1") rather than repeating it.
3. **Keep shared infrastructure stable.** `%pip install`, imports, `RANDOM_SEED`,
   data loading, and the plotting helpers change only when a notebook's own teaching
   point requires it, or when this playbook records a repository-wide convention
   change (§3). Do not redesign them opportunistically while writing content.
4. **Rewrite markdown to be concise, question-driven, and grounded in actual output.**
   Answers are short and declarative (a name, a bold term, or a verdict word plus 1–3
   sentences), and any number quoted must match the executed output, never be
   invented, hedged ("provided the executed notebook shows…"), or hard-coded from
   another notebook's run.
5. **Author the solved notebook once; derive the self-work notebook mechanically**
   from its cell tags (§2). Never write the two independently.
6. **Update `sleep/README.md` / `sleep/solved/README.md`** for genuine repository-wide
   convention changes, in the same change that introduces them — not per notebook's
   narrative content. The README currently contains statements that predate NB4–05's
   naming/parameterization changes (§3.7); correct these as part of the NB06–12 work,
   per the shared report §6.
7. **Figures**: only touch `Slides/figures/*.svg` where a notebook already has a
   `save_slide_figure` call, or `Slides/slide_deck.typ` newly references a figure from
   it. As of this writing only `sleep/01_linear_baseline.ipynb` saves one, and the
   deck does not yet reference notebooks 2–12. Do not add speculative figures.

## 2. The tag-driven solved → self-work mechanism

Every cell in a revised `solved/` notebook carries a `metadata.tags` entry. The
self-work notebook in `sleep/` is produced by copying the solved notebook cell-for-cell
and replacing every `solution`-tagged cell's source with a placeholder — nothing else
changes except the Colab badge URL (`solved/<NN>_*.ipynb` → `<NN>_*.ipynb`).

| Tag | Meaning | In self-work version |
|---|---|---|
| `section` | `## N. <Stage>` heading | kept verbatim |
| `exercise-question` | `### N.M <question/task>` prompt | kept verbatim |
| `exercise-question` + `given-answer` | A prompt whose answer is supplied (recall questions, or a rhetorical question introducing new material) | kept verbatim |
| `given` | Supplied explanation, criteria restatement, bookkeeping code, or (in interpretation-focused notebooks) the model/workflow code itself | kept verbatim |
| `solution` | The answer to an `exercise-question` | **replaced**: markdown → `- answer here`; code → `# answer here` |

Practical requirements when implementing:

- Tag every cell you write. An untagged cell is an error, not a third option — the
  older, untagged setup cells in NB1–02 are a pre-tag-scheme leftover, not something to
  imitate in NB06–12.
- Which cells are `given` vs `solution` is the real scaffolding decision (§3.5), and it
  is where a notebook's teaching goal is expressed. Decide it in the plan, not
  improvised while writing.
- After deriving the self-work notebook: clear all outputs and set
  `execution_count: null`; also strip any per-cell `metadata.execution` timestamps and
  notebook-level `metadata.widgets` copied from the solved run — the shared report
  found these leftover in NB1–05's student notebooks, and AGENTS.md asks to avoid
  metadata-only churn.
- Verify mechanically, don't eyeball it: after generating the self-work notebook,
  diff cell sources against the solved notebook (adapt `nb_diff_files.py`, described in
  §6) and confirm the only differences are the Colab badge and the `solution` cells.

## 3. Decisions on the shared report's open questions

The shared report (§7–8) flagged several items as `[JUDGEMENT]` or as unresolved
inconsistencies between NB1–03's style and NB4–05's (later, and more authoritative)
style. These are now decided, for consistency across NB06–12:

### 3.1 Renaming (repository-wide, apply from the first cell of NB06 onward)

| Old name (current NB06–12, and old NB1–3 before revision) | New name |
|---|---|
| observed `"Reaction"` | `y` (`y = pm.Normal("y", ..., observed=..., dims="obs_id")` or the notebook's actual likelihood) |
| `intercept` | `b0` (population models) / `mu_b0` + `b0[participant]` (hierarchical) |
| `slope` | `b1` (population models) / `mu_b1` + `b1[participant]` (hierarchical) |
| `sigma` (residual scale) | `sd_y` |
| `mu` (linear predictor / location) | `mu_y` |
| `participant_intercept_z`, `participant_intercept`, `participant_intercept_sd` | removed — see §3.4 (centered parameterization) |
| `population_mu` | removed — see §3.6 |

For notebooks 8–11 (distributional models with a residual-scale hierarchy) there is no
established precedent name yet; follow the `mu_<x>`/`sd_<x>` pattern used for the mean
structure (e.g. `mu_log_sd_y`/`sd_log_sd_y`, or whatever the actual parameterization
needs) and record the choice in that notebook's plan.

**Expected-value naming for a non-identity link (NB06–08 lognormal, NB09–11
ex-Gaussian):** `mu_y` is always the *location/linear-predictor* parameter (matching
NB4–05). Where the expected observable differs from `mu_y` (i.e. wherever the link is
not the identity), expose it as an explicit, separately named `pm.Deterministic`, e.g.
`mean_rt`, per the existing README formulas:
- lognormal: `mean_rt = pm.math.exp(mu_y + sd_y**2 / 2)`
- ex-Gaussian: `mean_rt = mu_y + nu`
For a Gaussian/Student-t notebook (NB12), `mu_y` already *is* the expected value, so no
separate `mean_rt` is needed there — matches NB4–05.

### 3.2 Prior constants and `pm.Exponential`

- Store every prior constant in a named variable: `mu_<param>`, `sd_<param>`,
  `nu_<param>`, and for hyperpriors `mu_mu_<param>`, `sd_mu_<param>`, `sd_sd_<param>`.
  Group them with a short comment above the `with pm.Model(...)` block (NB5's pattern).
- `pm.Exponential` is always parameterized with `scale=` (the prior mean), never
  `lam=`. State the elicited mean in the surrounding prose ("expect its mean to be
  around 50 ms").
- Reuse a prior value from an earlier notebook when the corresponding model component
  is unchanged, and say so explicitly ("the broad slope prior from Notebook 1"); supply
  it as a `given` cell rather than making students re-derive it. Do not silently change
  a carried-over prior's numeric value.

### 3.3 Sampling

`pm.sample(draws=1000, tune=1500, chains=4, random_seed=RANDOM_SEED)`, with no
`target_accept` override by default. If a specific notebook's model genuinely needs a
higher `target_accept` (the ex-Gaussian notebooks are the likely candidates), keep it,
but only after confirming default settings actually produce divergences, and explain
the need in a Q&A rather than setting it prophylactically.

### 3.4 Parameterization

Attempt the **centered** parameterization first for every hierarchical notebook
(NB07–12, currently all non-centered with `_z` variables in their pre-revision form).
Verify with diagnostics (0 divergences, R-hat ≈ 1.00, adequate ESS). If centered
sampling is genuinely unreliable for a given notebook, switch to non-centered and
explain why in the notebook itself — this is the README's own stated rule
("chosen according to the notebook's teaching purpose and verified with sampling
diagnostics rather than imposed as a course-wide rule"), not a NB4/05-only exception.

### 3.5 Scaffolding level (given vs. solution) — choose per notebook's teaching goal

Three established patterns, from NB1–05:
- **NB1-style** (write everything): appropriate when the notebook introduces a new
  core workflow step for the first time.
- **NB4-style** (incremental build: one model node per cell, with dims/indexing
  questions): appropriate only for a notebook introducing a genuinely new modeling
  *construct* (NB4 is the first hierarchical model). Do not replicate NB4's ~189-cell
  granularity elsewhere by default — it is justified there by being a "first
  encounter," not a general target cell count.
- **NB5-style** (model supplied as `given`; students interpret and plot): appropriate
  when the notebook's goal is reading/interpreting a model structure already familiar
  from a previous notebook, or when the new content is conceptual rather than
  mechanical.

Likely fits per the shared report (confirm/adjust in each notebook's plan against its
actual teaching goal from `sleep/solved/README.md`):
- NB06 (lognormal likelihood, log-scale priors): closest to NB2/NB3 — one likelihood
  component changes, students build it, with NB1-style elicitation Q&A for the new
  log-scale priors (this is exactly NB06's lesson).
- NB07 (hierarchical lognormal): closest to NB5 (reading a bigger, now-familiar
  hierarchical structure combined with an already-familiar lognormal likelihood).
- NB08 (distributional — participant residual-scale variation): a new modeling
  construct (distributional/scale hierarchy) — likely closer to NB4-style for the new
  piece specifically, NB5-style for the parts that are just reused hierarchy.
- NB09–11 (ex-Gaussian, informed vs. default vs. flat priors): the theme is prior
  choice, so prior-elicitation questions should carry the student work; NB10 and NB11
  are explicitly about priors going *wrong* (naive scale-blind priors, flat priors) —
  their diagnostics sections are themselves the lesson (see NB11 note in §3.8) and
  should not follow the "everything passes" pattern by default.
- NB12 (Gaussian vs Student-t, LOO): introduce `arviz_stats` LOO/comparison tools with
  a `given-answer` explanatory question, the way NB1 introduces power-scaling.

### 3.6 Deterministics

Remove `population_mu`/`population_mean_rt` unless a notebook's own question needs a
"typical participant" curve distinct from the participant-level trajectories already
shown. Add a new scientifically meaningful `pm.Deterministic` only when it answers a
stated question (NB5's `change_7` is the model: introduced, asked for its units and
interpretation, plotted in both prior and posterior). Don't add derived quantities
speculatively.

### 3.7 Diagnostics, plotting, and known bugs to avoid repeating

- Diagnostics: divergence count, then
  `azs.summary(idata, var_names=[...], ci_prob=0.90, ci_kind="hdi", round_to=2)`, then
  `azp.plot_trace_dist(...)`, then a "do these meet Notebook 1's criteria?" Q&A quoting
  actual values. For hierarchical notebooks, add an all-participant screen
  (`azs.summary(..., kind="diagnostics")` reduced to worst-case R-hat/ESS) plus a
  representative-subset (`first, middle, last` participant) trace/summary via `coords`.
- **Always pass `ci_kind="hdi"` explicitly to `azp.plot_dist` and `azp.plot_forest`.**
  `arviz-base`'s default is a 90%/89% **ETI**, not an HDI. NB4 and NB5 omitted this
  (see §4 — already fixed there as part of this same effort); do not repeat the
  omission in NB06–12.
- Use `pm.model_to_graphviz(model)` for a model's visual structure. **Do not use
  `print(model)`** as a substitute for a textual representation — in PyMC 6.3.2 it
  prints only `<pymc.model.core.Model object at 0x...>` (no `__str__`), which NB4
  incorrectly teaches as useful. If a textual form is wanted, use
  `print(model.str_repr())` or leave `model` as a cell's last expression.
- Posterior-predictive marginal checks use `azp.plot_ppc_dist(..., kind="ecdf", ...)`
  (NB5's convention; supersedes the `kind="kde"` still used in the current NB06–11).
- Plotting-helper cell: one `given`-tagged `### Plotting helper` cell defining
  `LM_VISUALS`, `PARTICIPANT_DAY`, and
  `def plot_participants(dt, group, var, coords=None)` (note the `coords=None`
  parameter, and `y_obs="y"` matching the rename). Define `plot_population` only if
  the notebook actually calls it for a population-level (non-participant-faceted)
  quantity — do not carry it forward unused (NB2 currently does; don't repeat that).
- `## Data` (not `### Data`) as the section heading — NB1's `### Data` is a
  one-off inconsistency the report flagged, not the target.

### 3.8 Section-heading style

Use NB5's short imperative/noun-phrase style for `## N. <Stage>` headings (no
question-mark suffix) — it is the later, more refined convention. Questions live in
the `### N.M` sub-headings, not the section title.

### 3.9 Notebook-specific teaching content — do not force into the template

Some things are genuinely specific to their notebook and should NOT be mechanically
imitated elsewhere: NB4's incremental one-node-per-cell build, NB4's baseline-vs-day-7
scatter and HDI-width comparison, NB3's Normal-vs-Student-t density plot, NB5's
`change_7`. Treat these as *examples of the kind of device available* (a supplied
comparison plot, a notebook-appropriate derived quantity), not as content to copy.

## 4. Known defects in NB4/NB05 — fixed, not your responsibility to redo

As part of preparing this playbook, two mechanical, unambiguous bugs found by the
shared report were fixed directly in already-committed NB04/NB05 (both `solved/` and,
where applicable, the self-work copy), since they violate an explicit, already-written
AGENTS.md rule and required no content/judgment change:

- Added the missing `ci_kind="hdi"` to the `azp.plot_dist`/`azp.plot_forest` calls in
  NB04 and NB05 that were silently plotting 90% ETIs while the surrounding text called
  them HDIs. Both notebooks were re-executed afterward to confirm sampling is
  unaffected (this only changes which interval a plot draws) and to regenerate the
  plot images.
- Fixed the self-work `sleep/01_linear_baseline.ipynb`'s `FIG_DIR` fallback path
  (`../../Slides/figures` → `../Slides/figures`; the notebook lives one directory
  higher than `sleep/solved/`, from which the path was copied unchanged).

These are recorded here so NB06–12 do not need to route around them, and so nobody
re-discovers the same bugs. Other issues the shared report found in NB1–05 (stale
numeric answers not matching committed output, hedged answers in NB4, the "recall,
then reveal" redundancy in NB2) were **left untouched** — they involve either
interpretation/authorial judgment or content the instructor wrote directly, and are out
of scope for a "remaining notebooks" pass. See
`sleep/revision_logs/_shared/known_issues_in_01-05.md` for the full, undisturbed list.

## 5. Roles and artifacts

Every notebook's work is recorded under `sleep/revision_logs/<NN>_<slug>/`. Artifacts
are the record of what was decided and why, for a reader who did not watch the work
happen — do not skip a step because it "seems obvious."

| Step | Who | Artifact |
|---|---|---|
| 1. Plan | Orchestrator (or a `Plan`-type/high-reasoning agent given this playbook, the shared report, and the specific notebook's context) | `sleep/revision_logs/<NN>_<slug>/01_plan.md` |
| 2. Implement | A content-focused implementation agent, given the plan verbatim | Rewritten `sleep/solved/<NN>_*.ipynb` and `sleep/<NN>_*.ipynb`; `02_implementation_notes.md` |
| 3a. Execute & verify | Orchestrator, using the pinned-stack environment | `03_execution_log.md` |
| 3b. Fresh-eyes review | A second, independently-briefed agent that did not write the notebook | `04_review.md` |
| 4. Fix loop | Implementer, given the review findings | Updated notebooks + note appended to `02_implementation_notes.md` |
| 5. Commit | Orchestrator | One commit per notebook pair |

Rationale: **Plan** needs the broadest context and the hardest-to-delegate judgment
calls (scaffolding level, section structure) — whoever already holds §1–3 of this
playbook in context should write it, since re-deriving it cold is exactly how the
inconsistencies in §8 of the shared report happened the first time. **Implement** is
then well-scoped and benefits from a content-focused agent free to spend its budget on
notebook prose/code. **Execution** must use the real pinned stack — do not accept "this
should sample fine" as a substitute for actually running it; if the stack can't be
verified, say so explicitly rather than presenting untested output as validated.
**Fresh-eyes review** exists because the implementer is the worst-positioned party to
notice its own drift from the plan or from AGENTS.md's "Critiquing and improving
teaching notebooks" checklist.

## 6. Step-by-step

### Step 1 — Plan

Read in full: `AGENTS.md` (esp. "Bayesian workflow conventions", "Teaching and code
style", "Critiquing and improving teaching notebooks"), this playbook, the shared
report, the nearest already-revised notebook pair (student + solved), the current
(pre-revision) notebook `N` pair, `sleep/solved/README.md` and `sleep/README.md`, and
the relevant PyMC-Labs skill `SKILL.md` (see AGENTS.md's "PyMC / ArviZ skills"
section) plus any specific `references/*.md` the notebook's content actually touches.

Write `sleep/revision_logs/<NN>_<slug>/01_plan.md`:
- **Teaching goal** (from `solved/README.md`'s sequence description, refined if needed).
- **Structural plan**: ordered `## N.` / `### N.M` outline.
- **Scaffolding decision** (§3.5): which pattern (NB1/NB4/NB5-style) and why, tied to
  the teaching goal — this determines the `given`/`solution` split, so decide it before
  writing cells, not after.
- **What changes vs. what's shared infrastructure** carried unchanged from the
  previous notebook.
- **Model/code content**: likelihood, priors in meaningful units, naming per §3.1,
  Deterministics per §3.6, sampling/diagnostics approach.
- **Figures**: explicit statement (default: none — §1.7).
- **Open questions/risks** for the implementer or orchestrator to resolve.

### Step 2 — Implement

Given the plan file:
1. Write `sleep/solved/<NN>_*.ipynb` in full, tagging every cell per §2.
2. Derive `sleep/<NN>_*.ipynb` mechanically per §2 (blank `solution` cells, fix the
   Colab badge, clear outputs/execution counts, strip leftover execution/widget
   metadata).
3. Verify the two notebooks differ only as intended (script-diff, don't eyeball).
4. Write `02_implementation_notes.md`: what was written, any deviation from the plan
   and why.
5. Leave execution to Step 3a — placeholder outputs at this point are fine.

Consult the relevant PyMC-Labs skill reference file (not just the top-level `SKILL.md`)
for anything beyond routine model-building: hierarchical parameterization choices,
distributional/likelihood questions, PyTensor shape issues, or LOO/model comparison.

### Step 3a — Execute and verify (orchestrator)

Pinned-stack setup (Python **≥3.12** is required — `pymc==6.3.2` does not install
under 3.11):

```bash
python3.12 -m venv <scratch>/nbenv
source <scratch>/nbenv/bin/activate
pip install pymc==6.3.2 arviz-base==1.3.0 arviz-stats==1.3.2 \
    "arviz-plots[matplotlib]==1.3.1" pandas==2.2.3 jupyter nbclient nbformat \
    ipykernel graphviz
python -m ipykernel install --user --name nbenv
```

`pm.model_to_graphviz` additionally needs the system Graphviz binary
(`apt-get install -y graphviz` on Debian/Ubuntu) — without it, execution halts partway
through any notebook that calls it, silently leaving the rest of the file stale.

Execute the **solved** notebook top to bottom in place, and check the exit status of
`jupyter nbconvert` itself, not of a pipe you ran it through:

```bash
jupyter nbconvert --to notebook --execute --inplace \
    --ExecutePreprocessor.kernel_name=nbenv \
    --ExecutePreprocessor.timeout=2400 \
    sleep/solved/<NN>_*.ipynb
echo "exit: $?"
```

(Piping through `tail`/`grep` hides a nonzero exit code behind the pipe's own status —
redirect to a log file and check `$?` directly, or inspect `${PIPESTATUS[0]}`.)

Then, from the executed notebook:
- Zero cell-execution errors (confirm from the actual exit code, per above).
- Zero divergences, or an explicit in-notebook discussion if divergences are the
  teaching point (e.g. a deliberately bad model, or NB11's failed-fit lesson).
- R-hat ≈ 1.00 and adequate bulk/tail ESS for every reported parameter.
- Every numeric claim in markdown matches the actual just-produced output.
- The self-work notebook: confirm cleared outputs and that non-blanked cells still
  match the solved notebook exactly.

Record a concise summary in `03_execution_log.md` — not raw logs.

### Step 3b — Fresh-eyes review

Brief a second, independently-primed agent with this playbook, AGENTS.md, the plan,
and the two finished notebooks. Ask it to find problems using AGENTS.md's "Critiquing
and improving teaching notebooks" checklist, plus whether the `given`/`solution` split
serves the notebook's stated teaching goal. Findings go in `04_review.md`, ranked by
severity, each with a concrete fix.

### Step 4 — Fix loop

Route findings back to implementation (or fix directly if small/mechanical, noted in
`02_implementation_notes.md`). Re-run Step 3a if anything touching model code,
sampling, or a numeric claim changed. Iterate until no remaining findings above minor/
stylistic, or until a deferral is explicitly justified.

### Step 5 — Commit

One commit per notebook pair (style: `"Revise <topic> notebook"`), including the
notebook files and their `sleep/revision_logs/<NN>_<slug>/` directory. Push after each
notebook — do not batch multiple notebooks into one commit, since the working session
may end before all seven are done.

## No silent decisions

Any real deviation from this playbook while revising a specific notebook — a
genuinely different section granularity, a shared-infrastructure change, an inability
to verify execution — gets recorded explicitly in that notebook's `01_plan.md` or
`03_execution_log.md`, not silently improvised. A decision that affects every future
notebook (not just the one being revised) belongs in this file, as an update to §3, not
buried in one notebook's plan.
