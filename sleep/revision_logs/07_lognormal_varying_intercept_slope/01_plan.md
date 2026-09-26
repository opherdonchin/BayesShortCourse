# Plan: notebook 07 — Hierarchical lognormal regression

Author: orchestrator (Plan step, per `sleep/REVISION_PLAYBOOK.md`).

## Teaching goal

From `sleep/solved/README.md`: hierarchical lognormal model. Combine two things each
already familiar on their own (the varying-intercept/-slope hierarchy from NB4/05, the
lognormal likelihood from NB6) into one model, and read/interpret it — not re-derive
either piece from scratch.

## Scaffolding decision (playbook §3.5)

NB5-style: the model is supplied (`given`), students interpret and plot, exactly as
NB5 did for the Gaussian hierarchy. Justification: both components are individually
established by this point (hierarchy: NB4/05; lognormal: NB6), so the new content is
reading a combined structure and its consequences, not building either piece.
Diagnostics setup (all-participant screen, subset trace/summary via `coords`) is also
`given` code with `exercise-question` verdicts, per NB5's pattern — the mechanics were
taught in NB4/05, only the reading is new here.

## What changes vs. shared infrastructure

Unchanged from NB06: `%pip`, imports, `RANDOM_SEED`, data loading, `LM_VISUALS`,
`PARTICIPANT_DAY`, `plot_participants(dt, group, var, coords=None)`. `plot_population`
is **not** needed here (no notebook question calls for a population-only, non-faceted
view — NB4/05 only used it for the "typical participant" curve, which playbook §3.6
says to drop by default) — drop its definition unless a specific question in this
notebook's plan needs it.

Unchanged from NB04/05: the participant-index construction (`participants`,
`participant_to_idx`, `participant_idx`, with the three `assert`s, NB05's pattern) goes
in the data cell, `given`.

New: combining the hierarchy with `pm.LogNormal`, and the resulting `mean_rt`.

## Structural plan

```
(intro, unnumbered) — link to NB6 (lognormal) and NB5 (hierarchy); state this
   notebook's purpose: read a model that combines both, not build either from scratch.

## 1. Read the hierarchical lognormal model
### 1.1 The model is supplied.                                    [given / given-answer]
    (display math, then code: centered hierarchy for both intercept and slope --
    see "Model/code content" below -- plus mu_y, mean_rt, pm.LogNormal likelihood)
### 1.2 Which quantities vary by participant?                      [exercise-question]
### 1.3 Which parameter is the population-average daily effect, and on what scale?
    [exercise-question] (mu_b1, log scale -- link back to NB6's multiplicative reading)
### 1.4 Which parameters describe the population distributions of intercepts and
    slopes?                                                        [exercise-question]
### 1.5 What does mean_rt represent here, and how does it differ from mu_y?
    [exercise-question] (bridges NB6's mean_rt lesson to the hierarchical case --
    mean_rt is now per-participant, not just per-day)

## 2. Check the prior implications
### 2.1 Parameter-level priors are plotted.                        [given]
    (plot_dist for mu_b0, sd_b0, mu_b1, sd_b1, sd_y, ci_kind="hdi")
### 2.2 Do these hyperparameter priors look reasonable?             [exercise-question]
### 2.3 Prior predictive draws and the observable-scale check are supplied.  [given]
### 2.4 Do the prior predictions meet Notebook 1's criteria, extended for
    participant heterogeneity?                                     [exercise-question]

## 3. Fit and diagnose the hierarchy
### 3.1 Sample from the posterior.                                 [given]
### 3.2 Population-level diagnostics.                               [given code /
    exercise-question verdict]
### 3.3 All-participant screen and a representative subset.        [given code /
    exercise-question verdict]

## 4. Examine the fitted hierarchy
### 4.1 Population daily effect: plot and credible range.          [exercise-question/solution]
    (mu_b1, ci_kind="hdi")
### 4.2 Participant-to-participant variation in the daily effect: plot and credible
    range.                                                         [exercise-question/solution]
    (sd_b1)
### 4.3 Participant-specific daily effects.                        [exercise-question/solution]
    (plot_forest, b1, ci_kind="hdi")
### 4.4 Does the data support meaningful heterogeneity?             [exercise-question]

## 5. Predictive consequences
### 5.1 Participant-level posterior predictive check.               [exercise-question/solution]
### 5.2 Does the model reproduce participant-level trajectories, including
    positivity?                                                    [exercise-question]
### 5.3 Pooled marginal check (ECDF).                               [exercise-question/solution]
### 5.4 Verdict, with an explicit (not implicit) comparison to Notebook 6's
    non-hierarchical lognormal model.                               [exercise-question]

## 6. Sensitivity of the hierarchical scales
### 6.1 given-answer: why check this here.
### 6.2 Bookkeeping supplied.                                       [given]
### 6.3 Compute psense_summary.                                     [exercise-question/solution]
### 6.4 Are any hyperparameters sensitive to their priors?          [exercise-question]
    (old pre-revision NB7 found a "potential prior-data conflict" flag for both
    participant-scale hyperparameters under non-centered + target_accept=0.95 --
    re-check under centered + default settings at execution; report honestly
    whichever way it comes out, do not paper over a real flag)

## 7. Summary
### 7.1 What has this notebook shown?                               [exercise-question/solution]
    (retrospective only -- no reference to Notebook 8)
```

## Model/code content

- **Centered** parameterization for both hierarchies (playbook §3.4 — attempt first):
  ```python
  mu_b0 = pm.Normal("mu_b0", mu=mu_mu_b0, sigma=sd_mu_b0)
  sd_b0 = pm.Exponential("sd_b0", scale=sd_sd_b0)
  b0 = pm.Normal("b0", mu=mu_b0, sigma=sd_b0, dims="participant")

  mu_b1 = pm.Normal("mu_b1", mu=mu_mu_b1, sigma=sd_mu_b1)
  sd_b1 = pm.Exponential("sd_b1", scale=sd_sd_b1)
  b1 = pm.Normal("b1", mu=mu_b1, sigma=sd_b1, dims="participant")

  sd_y = pm.Exponential("sd_y", scale=mu_sd_y)

  mu_y = pm.Deterministic("mu_y", b0[pidx] + b1[pidx] * days, dims="obs_id")
  mean_rt = pm.Deterministic("mean_rt", pm.math.exp(mu_y + sd_y**2 / 2), dims="obs_id")
  y = pm.LogNormal("y", mu=mu_y, sigma=sd_y, observed=..., dims="obs_id")
  ```
  No `population_mu`/`population_mean_rt` (playbook §3.6 — drop unless a question
  needs a "typical participant" curve; none does here since every question is about
  either a hyperparameter or a per-participant quantity).
- Hyperprior values, reused from the pre-revision notebook unless Step 3a's execution
  shows a reason to change: `mu_mu_b0=5, sd_mu_b0=0.55` (NB6's `b0` prior, now the
  population center); `sd_sd_b0`: old value was `Exponential(lam=6)`→scale ≈0.167;
  `mu_mu_b1=0, sd_mu_b1=0.2` (NB6's `b1` prior); `sd_sd_b1`: old
  `Exponential(lam=10)`→scale=0.1.
  **Open question (flagged, not decided here):** the old notebook's residual-scale
  prior (`sigma`/`sd_y`, `Exponential(lam=6)`→scale≈0.167) is narrower than NB6's
  `sd_y` prior (scale=1/3). This might be a deliberate, justified belief (residual
  noise after accounting for participant structure is plausibly smaller than pooled
  residual noise with no participant structure), or it might be an unexamined
  inconsistency in the pre-revision notebook. Decide and state the reasoning
  explicitly in the notebook (a Q&A, or a supplied-cell comment) rather than silently
  picking one; this is exactly the kind of thing playbook §3.2's "do not silently
  change a carried-over prior's value" is about.
- No `target_accept` override by default (playbook §3.3); the pre-revision notebook
  used `target_accept=0.95` with a non-centered parameterization — test whether the
  centered version samples cleanly with defaults before deciding whether to keep it.

## Self-work blanking plan

`given`: setup/data/plotting-helper cells; the model (§1.1, following NB5's precedent);
prior predictive generation and its observable-scale plot (§2.3, `given` since NB5-style
supplies this); sampling (§3.1); the diagnostics *code* for §3.2/§3.3 (all-participant
screen, subset trace/summary) — but the verdict questions after them are
`exercise-question`/`solution`; the power-scaling bookkeeping (§6.2).
`exercise-question`+`solution`: all interpretation — what varies by participant, credible
ranges, forest plots, PPC verdicts, the sensitivity verdict, the closing summary.

## Figures

None.

## Open questions / risks for the implementer

- The `sd_y` prior inconsistency noted above — decide and justify explicitly.
- Confirm centered parameterization samples cleanly (0 divergences, R-hat, ESS) before
  committing to it; if not, fall back to non-centered with an explicit explanation
  (playbook §3.4).
- Re-check whether the "potential prior-data conflict" `psense` flag from the
  pre-revision notebook (for both participant-scale hyperparameters) persists under
  the new parameterization/settings — report the actual result, whichever way it goes;
  do not assume it will disappear or persist without checking.
- §5.4's comparison to Notebook 6 must be grounded in this notebook's own actual
  output, written after Step 3a, not asserted from the plan.
