# Plan: notebook 12 — Robust likelihoods and PSIS-LOO

Author: orchestrator (Plan step, per `sleep/REVISION_PLAYBOOK.md`).

## Teaching goal

From `sleep/solved/README.md`: "Gaussian versus Student-t likelihoods using LOO
predictive checks and PSIS-LOO comparison." This notebook is intentionally
**standalone** (the pre-revision intro already says so: "We fit four standalone models
here so the notebook does not depend on state from earlier notebooks"). It returns to
the **millisecond-scale, non-distributional** hierarchy (like NB4/05/09's mean
structure — a single shared `sd_y`, not a residual-scale hierarchy), and introduces
**LOO/PSIS model comparison** as new content — per playbook §3.5, treat this like NB1's
introduction of power-scaling: a `given-answer` explanatory question before the new
tool, then students use it.

## Structural content (already present in the pre-revision draft, keep it — it's
## substantively good and doesn't need rebuilding)

Four models, varying two things independently:
- likelihood: Gaussian vs. Student-t (with `nu ~ Gamma(2, 0.1)`, matching Bambi's own
  default degrees-of-freedom prior — keep this stated, it's good practice to name
  where a "default" actually comes from, per AGENTS.md's software-versioning
  transparency point);
- mean structure: varying-intercept-only vs. varying-intercept-and-slope.

All four share the same mean-structure priors as notebooks 4-05 (ms-scale) and a
single **population-only** `sd_y` (no residual-scale hierarchy here — this notebook
is not about distributional modeling, and adding one would be scope creep AGENTS.md
warns against). Fit all four, compute pointwise log-likelihood, compare via
`azs.loo`/`azs.compare`, and inspect Pareto-k diagnostics.

**Real diagnostic content already present, worth preserving honestly:** the
pre-revision fit shows `gaussian_slope`'s max Pareto-k at **1.27** (unreliable PSIS
estimate) and `gaussian_intercept`'s at 0.74 (borderline), while both Student-t models
are comfortably below 0.7. Per the `arviz-diagnostics` skill and AGENTS.md, **diagnose
this rather than hiding it** — a high Pareto-k is itself informative (it flags
observations the model finds hard to predict, which is exactly what motivates trying a
robust likelihood in the first place). Confirm this reproduces in Step 3a; if the
numbers differ from the pre-revision run, report the actual result.

## Scaffolding decision (playbook §3.5)

Model-building is `given` (a `build_model(family, varying_slope)` factory, matching
the pre-revision structure, renamed per convention below) — this notebook's new
content is LOO/PSIS-LOO itself, not model construction, which is thoroughly familiar
by now. Introduce `azs.loo`/`azs.compare`/Pareto-k the way NB1 introduced
power-scaling: a `given-answer` conceptual question, then students compute and read
the comparison. Interpretation of what the comparison does and does not establish
(playbook's LOO caution: same-participant held-out predictions, not new-participant
generalization; a rank is not proof) is the notebook's real teaching content.

## Structural plan (outline)

```
(intro) — standalone framing (explicit, matches the pre-revision point about not
   depending on earlier-notebook state); state the two questions this notebook asks:
   does a Student-t likelihood improve predictive calibration, and does allowing
   varying slopes help, independently of likelihood choice.

## 1. Four models to compare
   - what varies (likelihood x slope structure), what doesn't (mean-structure priors,
     from Notebook 4/05, ms-scale, renamed b0/b1/mu_b0/sd_b0/mu_b1/sd_b1 per
     convention)
   - the shared model-building function (given code)
   - why nu ~ Gamma(2, 0.1) for the Student-t models (given-answer: matches Bambi's
     documented default, cite it)
   - fit all four (given code), diagnostics check for each (criteria first)

## 2. Difficult-to-predict observations
   - given-answer: what PSIS-LOO intervals show, that ordinary posterior-predictive
     intervals don't
   - plot_loo_interval for the two slope models (given code, matches pre-revision)
   - which observations look hardest to predict, and does the likelihood choice change
     that picture

## 3. Robust predictive calibration
   - plot_loo_pit for the two slope models
   - verdict: does the Student-t likelihood improve calibration

## 4. Predictive comparison
   - given-answer: what azs.compare's ELPD difference, se, and weight columns mean,
     and what they do not establish (a rank is not proof; similar stacking weights
     don't mean model equivalence -- pymc-modeling skill)
   - compute loo for all four, azs.compare, plot_compare
   - Pareto-k diagnostics: read plot_khat honestly, including the high k for
     gaussian_slope if it reproduces -- do not omit or soften this
   - verdict: does Student-t help, does the varying slope help, independently

## 5. What this comparison actually answers
   - the prediction-target caution already in the pre-revision notebook (leave-one-
     observation-out from an already-observed participant, not new-participant
     generalization) -- keep this, it's exactly the playbook's LOO caution
   - retrospective summary: what the four-way comparison showed, what Pareto-k flagged,
     what this does and doesn't establish. This is also the LAST notebook in the
     sequence, so the summary may (briefly, factually) note it as the final comparison
     in the course's Bayesian-workflow sequence -- but still no "next notebook" framing,
     since there isn't one; end on what THIS notebook and its comparison showed.
```

## Model/code content

- Rename per established convention: `intercept`→`mu_b0` (population, hierarchical
  center) or `b0`/`mu_b0` depending on whether the model is intercept-only or
  intercept+slope — actually all four models are hierarchical in the intercept (per
  the pre-revision code, `participant_intercept` always present), so use
  `mu_b0`/`sd_b0`/`b0[participant]` throughout; `slope`→`mu_b1`/`sd_b1`/`b1[participant]`
  only in the `varying_slope=True` branch, else a single population `mu_b1`;
  `sigma`→`sd_y` (population-only, no hierarchy); Student-t's `nu` stays `nu` (PyMC's
  own parameter name, no log link needed since `pm.Gamma` already has positive
  support).
- **Attempt centered parameterization** for `b0`/`b1` (playbook §3.4) instead of the
  pre-revision's non-centered `_z` form — verify it samples cleanly for all four
  models before committing to it; if any of the four needs non-centering, decide
  per-model and say so.
- `mu_y = b0[pidx] + b1[pidx]*days` (or `mu_b1*days` when slope is population-only),
  identity link, ms-scale — no `mean_rt` needed here (Gaussian/Student-t: `mu_y` already
  is the expected value, per playbook §3.1).
- Keep `pm.compute_log_likelihood` calls per model (required for LOO).

## Self-work blanking plan

`given`: setup/data/plotting-helper cells; the `build_model` factory and the fit loop
(mechanical infrastructure, not new content); the LOO-interval and LOO-PIT plotting
calls. `exercise-question`+`solution`: the given-answer conceptual explanations (LOO
intervals, `azs.compare` columns), reading the diagnostics/Pareto-k honestly, and every
comparative verdict.

## Figures

None.

## Open questions / risks for the implementer

- Confirm centered parameterization samples cleanly for all four models — this
  notebook fits four separate models, so check each one, not just the most complex.
- Confirm the Pareto-k pattern (high for `gaussian_slope`) actually reproduces in this
  environment before writing about it; report the actual result either way, and do not
  soften or omit a high k if it appears.
- This notebook doesn't build on NB06-11's log-scale/distributional machinery at all —
  don't import conventions from those notebooks that don't apply here (no `mu_log_*`,
  no residual-scale hierarchy); its closest relative is NB04/05/09's ms-scale mean
  structure.
- Decide how much of the pre-revision structure's substance to keep vs. restructure
  into the Q&A worksheet format — the four-model comparison logic itself is good and
  shouldn't be diluted; focus restructuring effort on decomposing the LOO-specific
  interpretation into the established granular Q&A pattern.
