# Plan: notebook 06 — Lognormal regression

Author: orchestrator (Plan step, per `sleep/REVISION_PLAYBOOK.md`).

## Teaching goal

From `sleep/solved/README.md`: "why Gaussian-scale priors fail on a lognormal model and
how the likelihood changes interpretation." Refined given the shared report's finding
(§2.6) that NB5 explicitly does **not** claim a decisive Gaussian-likelihood failure —
NB5's ECDF check passed; what motivates NB6 is that (a) NB5's own *prior* predictive
reached below zero (a Gaussian likelihood has no positive-support guarantee), and (b) a
right-skewed, strictly-positive quantity like reaction time is a natural candidate for
multiplicative rather than additive variation. **The notebook's opening must not claim
the Gaussian model failed to fit** — it should motivate the lognormal alternative on
structural grounds (support, multiplicative variation), consistent with NB5's own
closing Q&A.

The concrete lesson is: parameters and priors live on a different scale once the
likelihood's link changes, and reusing a previous notebook's prior values verbatim is a
mistake that a prior predictive check should catch.

## Scaffolding decision (playbook §3.5)

NB2/NB3-style: the corrected model is new content the students build, following NB1's
granular worked-elicitation pattern for the two new log-scale priors (`b0`, `b1`) since
that elicitation *is* this notebook's lesson (playbook §3.5, "NB06 ... closest to
NB2/NB3"). The "wrong scale" demonstration model itself is `given` (a supplied
demonstration of what not to do, mirroring how NB2/NB3 supply an already-decided,
deliberately-flawed prior for students to diagnose) — the point is to interpret its
prior predictive failure, not to re-derive it. Diagnostics and posterior-predictive
code follow NB1-3's "students write it" pattern since that is unchanged workflow
machinery already familiar from NB1–05. Population trend uses `plot_population` (not
only `plot_participants`) because the model has no per-participant structure yet — same
justification as NB1's use of it for `mu` — so keep the definition.

## What changes vs. shared infrastructure (unchanged, copied from NB05)

Unchanged: `%pip` cell, imports (minus the still-present unused `Line2D`/`Patch`,
which get dropped per playbook §3.1's import-hygiene note), `RANDOM_SEED`, data-loading
cell, `LM_VISUALS`/`PARTICIPANT_DAY`, `plot_participants` (add `coords=None` per §3.7).
`plot_population` is kept and used (see above), with `y_obs="y"`.

Changes specific to this notebook: the likelihood (`pm.LogNormal`), the priors and
their elicitation, and the `mean_rt` Deterministic (§3.1's naming decision for a
non-identity link).

## Structural plan

```
(intro, unnumbered) — link back to NB5's actual finding (not a Gaussian failure claim);
   state this notebook's purpose: a positive-support, right-skewed likelihood.

## 1. Priors on the wrong scale
### 1.1 What does mu represent in a lognormal likelihood, and why is an intercept
    prior centered at 250 a problem there?                       [exercise-question]
    (answer: mu_y is the location of log(y); exp(250) is astronomically large)
### 1.2 The mis-scaled model is supplied.                        [given / given-answer]
    (bad_model, Gaussian-scale priors reused verbatim, tagged given)
### 1.3 Generate prior predictive draws from the mis-scaled model. [exercise-question/solution]
### 1.4 Do these prior predictions meet Notebook 1's plausibility criteria? [exercise-question]
    (answer: no — quote the actual finite-fraction/magnitude evidence from output)

## 2. Priors on the log scale
### 2.1 If almost all reaction times are plausible between 50 and 450 ms, what does
    that range imply on the log scale?                            [exercise-question]
    (worked elicitation, NB1-style: log(50)=3.91, log(450)=6.11, midpoint≈5.0,
    range/4≈0.55 -> Normal(5, 0.55) for b0)
### 2.2 Elicit a slope prior: how much daily multiplicative change is plausible?
    [exercise-question] (e.g. up to ~20%/day -> log(1.2)≈0.18, round -> Normal(0, 0.20))
### 2.3 Elicit sd_y: how much residual multiplicative spread is plausible?
    [exercise-question] (Exponential(scale=1/3), i.e. mean log-scale sd ≈0.33 — keep
    the existing value, state its mean explicitly per playbook §3.2)
### 2.4 Build the corrected lognormal model.                       [exercise-question/solution]
    (b0, b1, sd_y named vars; mu_y deterministic; mean_rt = exp(mu_y + sd_y**2/2);
    y = pm.LogNormal("y", mu=mu_y, sigma=sd_y, observed=..., dims="obs_id"))
### 2.5 Prior predictive check on the observable scale.            [exercise-question/solution]
### 2.6 Do these prior predictions meet the criteria, and what does the right skew
    imply for how the mean line sits relative to the bands?        [exercise-question]

## 3. Fit and diagnose
### 3.1 Sample from the posterior.                                 [exercise-question/solution]
### 3.2 Do the diagnostics meet Notebook 1's criteria?              [exercise-question]

## 4. Population effect under a lognormal likelihood
### 4.1 Which quantity is the expected reaction time in ms, and how does it differ
    from mu_y?                                                     [exercise-question]
    (mean_rt = exp(mu_y + sd_y**2/2) != mu_y; playbook §3.1 naming decision)
### 4.2 Plot the posterior population trend for mean_rt.            [exercise-question/solution]
    (plot_population(idata, "mean_rt"))
### 4.3 What is the credible range for baseline (day-0) mean reaction time?
    [exercise-question]

## 5. Predictive consequences of the likelihood
### 5.1 Generate posterior predictive draws and plot participant trajectories.
    [exercise-question/solution]
### 5.2 Does the model reproduce the participant-level data, including positivity
    and skew?                                                      [exercise-question]
### 5.3 Check the pooled marginal distribution (ECDF).              [exercise-question/solution]
    (azp.plot_ppc_dist(..., kind="ecdf"))
### 5.4 Does the lognormal model's fit differ meaningfully from what Notebook 5 found
    for the Gaussian model?                                        [exercise-question]
    (grounded answer, not a claim the Gaussian model failed; the honest comparison is
    what changes — positive support, no below-zero prior mass — not a corrected defect)

## 6. Sensitivity on the log scale
### 6.1 given-answer: why check prior sensitivity here.
### 6.2 The power-scaling bookkeeping is supplied.                 [given]
### 6.3 Compute and interpret psense_summary.                      [exercise-question/solution]
### 6.4 Are the conclusions sensitive to the log-scale prior choices? [exercise-question]

(closing) — forward pointer to Notebook 7 (hierarchical lognormal), as a Q&A per
playbook §3 "criteria first" pattern, not closing prose.
```

## Model/code content

- `pm.Exponential(..., scale=...)` throughout (§3.2): bad-model `sd_y` demo uses
  `scale=50` (unchanged from old `lam=0.02`); corrected model's `sd_y` uses
  `scale=1/3` (unchanged value from old `lam=3`, ≈0.333).
- No `target_accept` override unless Step 3a shows it's needed.
- `mu_y` for the log-scale location; `mean_rt = pm.math.exp(mu_y + sd_y**2 / 2)` per
  playbook §3.1.
- `pm.model_to_graphviz(model)` if a model-structure view is useful here; no
  `print(model)`.
- Diagnostics: divergences, `azs.summary(..., ci_prob=0.90, ci_kind="hdi", round_to=2)`,
  `azp.plot_trace_dist`.
- `azp.plot_ppc_dist(idata, var_names=["y"], kind="ecdf", ...)` (not `kde`).
- Any `azp.plot_dist`/`azp.plot_forest` call MUST include `ci_kind="hdi"` explicitly
  (playbook §3.7 — do not repeat the NB4/05 omission).

## Self-work blanking plan

`given`: setup/import/data/plotting-helper cells; the §1.2 mis-scaled demonstration
model (students diagnose it, not build it); the §6.2 power-scaling bookkeeping cell.
`exercise-question` + `solution`: everything else per the structural plan above —
elicitation reasoning, the corrected model build, sampling, diagnostics interpretation,
all plots and their verdict questions.

## Figures

None. No `save_slide_figure` call — `Slides/slide_deck.typ` does not reference this
notebook (playbook §1.7).

## Open questions / risks for the implementer

- Confirm via Step 3a whether the default `pm.sample` settings (no `target_accept`)
  sample the corrected lognormal model cleanly; if not, raise `target_accept` and add a
  Q&A explaining why, per playbook §3.3.
- The bad-model prior-predictive demonstration currently prints a `finite_fraction`/
  `log10` range because plotting raw overflowed values is uninformative. Keep a
  numeric summary only if the plot itself is unreadable (per shared report checklist
  item 22); otherwise prefer showing the plot and letting the criteria-based question
  carry the interpretation.
- §5.4's answer needs to be genuinely grounded in this notebook's own output (both
  models' ECDF/participant-level fits), not asserted from the plan — write it after
  Step 3a's execution, from the actual result.
