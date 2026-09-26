# Plan: notebook 08 — Distributional lognormal model

Author: orchestrator (Plan step, per `sleep/REVISION_PLAYBOOK.md`).

## Teaching goal

From `sleep/solved/README.md`: participant variation in residual scale. Extend NB07's
hierarchical lognormal model so residual variability (day-to-day noise around each
participant's own trajectory) can itself differ by participant, not just the mean
trajectory. This is a genuinely new modeling construct (a distributional/scale
hierarchy: a log-linear sub-model for `sd_y` itself), unlike NB07 which only combined
two already-familiar pieces.

## Scaffolding decision (playbook §3.5)

Mixed, matching the "new construct" guidance: the mean-structure hierarchy (`b0`,
`b1`) is `given`, copied unchanged from NB07 — students already built and interpreted
this twice (NB4/05, NB07). The **new** residual-scale hierarchy is where the notebook's
actual teaching content lives, so scaffold it more like NB4 (incremental, with
dims/elicitation questions) — but not at NB4's ~189-cell granularity; enough atomic
questions to genuinely engage with "why a log-link for a scale parameter", "what does
this hyperprior mean", and "how do I read a fitted scale hierarchy", not a
node-by-node rebuild of machinery already familiar (`pm.Normal`, `pm.Exponential`,
`dims="participant"` are not new by notebook 8).

## What changes vs. shared infrastructure

Unchanged from NB07: `%pip`, imports, `RANDOM_SEED`, data loading + participant index,
`LM_VISUALS`, `PARTICIPANT_DAY`, `plot_participants(dt, group, var, coords=None)`.
`mu_b0/sd_b0/b0[participant]` and `mu_b1/sd_b1/b1[participant]` hierarchy **and their
prior constants are reused verbatim from NB07** (`mu_mu_b0=5, sd_mu_b0=0.55,
sd_sd_b0=1/6, mu_mu_b1=0, sd_mu_b1=0.2, sd_sd_b1=0.05`) — say so explicitly, as a
`given` cell/comment, per playbook §3.2.

**Harmonization needed, flagged explicitly (do not carry silently):** the pre-revision
NB08 draft used `intercept ~ Normal(mu=5.5, sigma=0.55)` — a *different* population
center than NB06/07's `mu_b0 ~ Normal(mu=5, sigma=0.55)` (5.5 vs 5, i.e. ~245 ms vs
~150 ms median baseline), with no recorded rationale for the change. There is no
substantive reason a distributional extension should shift the mean-structure prior.
**Use NB07's value (5), not the pre-revision draft's 5.5**, and note in the notebook
(or at minimum in the implementation notes) that this was corrected for consistency.

New: the residual-scale hierarchy itself.

## Structural plan (outline — implementer has latitude on exact question count/phrasing,
## following NB07's granularity for the reused parts and something closer to NB4's for
## the genuinely new part)

```
(intro) — link to NB07; state the purpose: residual variability, not just the mean
   trajectory, may differ by participant.

## 1. Read the reused mean structure, then build the residual-scale hierarchy
   - short recap Q&A on b0/b1 (given, reused from NB07 -- do not re-teach it in depth)
   - model equations for the NEW piece: log(sd_y_i) = mu_log_sd_y + v[s[i]]
   - why a log link for a scale parameter (a scale must be positive; compare to why
     Notebook 6 used a log link for the mean)
   - elicit/explain mu_log_sd_y: motivate its value from Notebook 7's fitted sd_y
     (~0.08) -- this is legitimate informed prior construction from a previous
     analysis, the same move Notebook 6/7 made reusing Notebook 1's/6's priors, not
     post-hoc tuning to this notebook's own data
   - elicit/explain sd_log_sd_y (between-participant SD of log residual scale)
   - build the model: centered `v[participant] ~ Normal(mu_log_sd_y_or_0, sd_log_sd_y,
     dims="participant")` -- see naming note below -- and `sd_y = exp(mu_log_sd_y + v)[pidx]`
     or equivalent; `mean_rt` deterministic as before

## 2. Check the prior implications
   - parameter-level priors for the new hyperparameters
   - prior predictive check on the observable scale (reuse NB07's criteria + a new
     question about whether participant-to-participant spread in variability looks
     reasonable)

## 3. Fit and diagnose
   - sample; diagnostics for both hierarchies (population + all-participant screen +
     subset, per NB07's established pattern)

## 4. Participant-specific residual scales
   - forest plot of the per-participant residual scale (in ms terms if that's more
     interpretable than log-scale SD -- consider a Deterministic for this, e.g.
     `residual_scale = exp(mu_log_sd_y + v)`, if it answers a stated question)
   - credible range for the population-level and between-participant variation
   - does the data support meaningful heterogeneity in residual scale?

## 5. Predictive consequences
   - participant-level PPC (does allowing per-participant scale improve the
     description of day-to-day variability, compared to Notebook 7's shared sd_y?)
   - pooled ECDF

## 6. Sensitivity (only if the notebook's role in the README's psense list includes it
   -- currently README lists "notebooks 1, 2, 3, 6, 7" for psense, NOT 8; if NB08 is
   not meant to repeat power-scaling, omit this section rather than adding scope the
   README doesn't ask for -- flag this explicitly rather than deciding silently)

## 7. Summary
   - retrospective only, no reference to Notebook 9
```

## Model/code content

- Reuse NB07's `mu_b0/sd_b0/b0`, `mu_b1/sd_b1/b1` hierarchy and constants verbatim
  (corrected to `mu_mu_b0=5`, not the pre-revision draft's 5.5).
- New residual-scale hierarchy, naming per playbook §3.1's pattern for distributional
  notebooks (no established precedent yet — this notebook sets it):
  - `mu_log_sd_y`: population center of log residual scale (a genuine new
    hyperparameter to elicit, informed by NB07's fitted `sd_y`≈0.08 — i.e. center near
    `log(0.08)`≈−2.5, not the pre-revision draft's `sigma_intercept~Normal(0, 0.30)`,
    which centers on `exp(0)=1`, a residual multiplicative SD of ~e¹≈2.7 — implausibly
    large given what Notebook 7 already found. Flag and correct this too, same
    harmonization issue as the intercept.)
  - `sd_log_sd_y`: between-participant SD of log residual scale (Exponential, scale
    reused from the pre-revision draft's `participant_sigma_sd` unless Step 3a shows a
    reason to change).
  - `v` or `log_sd_y_dev`: centered participant deviation, `dims="participant"`
    (attempt centered first, per playbook §3.4).
  - `sd_y = pm.Deterministic("sd_y", pm.math.exp(mu_log_sd_y + v[pidx]), dims="obs_id")`
    or equivalent — a scientifically meaningful quantity, so keep it as a
    `pm.Deterministic`, and expose a participant-level version too if a question needs
    it (e.g. `residual_scale[participant]`, mirroring NB08's pre-revision
    `residual_scale`/`population_residual_scale` pair, but **drop the
    `population_residual_scale` "typical participant" twin unless a specific question
    needs it**, per playbook §3.6 — same treatment as `population_mu`).
  - `mean_rt = pm.Deterministic("mean_rt", pm.math.exp(mu_y + sd_y**2 / 2), dims="obs_id")`
    (now genuinely participant- and day-varying through both `mu_y` and `sd_y`).
- No `target_accept` by default; verify empirically (a two-hierarchy distributional
  model is more likely than NB07 to need it — if so, keep it with an explanation
  rather than forcing it off).

## Self-work blanking plan

`given`: setup/data/plotting-helper cells; the recap of the mean-structure hierarchy
(reused, not new content); diagnostics *code* (all-participant screen, subset) per
NB07's precedent. `exercise-question`+`solution`: the new residual-scale hierarchy's
elicitation and construction (this notebook's actual content), all interpretation,
predictive checks, and the closing summary.

## Figures

None.

## Open questions / risks for the implementer

- **Harmonize `mu_mu_b0` to 5 (not the pre-revision draft's 5.5)** and **`mu_log_sd_y`
  to something informed by NB07's fitted `sd_y`≈0.08 (not the draft's implied ~1)** —
  both flagged above. State the correction explicitly in the implementation notes.
- Confirm centered parameterization for the new residual-scale hierarchy samples
  cleanly; if not, fall back to non-centered with an explanation (playbook §3.4).
- Decide, and state explicitly, whether §6 (sensitivity) belongs in this notebook at
  all, since the current README's psense list is "notebooks 1, 2, 3, 6, 7" — adding
  NB08 would be a repository-wide README change, not a silent local addition.
- As with NB06/07: take a genuinely skeptical look at the executed prior-predictive
  plot before writing its verdict — do not default to a generous reading.
