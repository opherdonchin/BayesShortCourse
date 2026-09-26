# Plan: notebook 09 — Ex-Gaussian distributional model

Author: orchestrator (Plan step, per `sleep/REVISION_PLAYBOOK.md`).

## Teaching goal

From `sleep/solved/README.md`: "informed-prior ex-Gaussian distributional model, with
priors chosen in milliseconds rather than guessed on the log-link scale." Represent
right skew directly with `pm.ExGaussian` (a Gaussian component plus an independent
exponential tail) instead of a log transform. This is the first ex-Gaussian notebook —
NB10 and NB11 explicitly reuse this notebook's model structure with different priors
(per README: NB10 "repeats notebook 9's structure" with naive priors, NB11 "the same
hierarchical priors as notebook 9" with flat common effects). **Whatever structural
choices this plan makes (which parameters get participant hierarchies, the model's
overall shape) become the fixed template for NB10/11 — get them right here, not as a
per-notebook improvisation later.**

## Key structural fact: this model does NOT need a log link for its mean

Unlike NB06-08, `pm.ExGaussian`'s `mu` parameter has full support on the real line and
is already on the millisecond scale — no transform needed for the mean structure
itself. Only `sigma` (must be positive) and `nu` (the exponential tail's mean, must be
positive) need a log link. So the mean-structure hierarchy reverts to NB4/05's
**millisecond-scale** naming and values (`b0`/`b1` in ms, not the log-scale `b0`/`b1`
of NB06-08) — **make this contrast an explicit question**, since a student who has just
done three log-scale notebooks needs to notice the mean structure is back on the
natural scale while the new scale/tail parameters are not.

## Scaffolding decision (playbook §3.5)

Mixed:
- **Mean-structure hierarchy (`b0`/`b1`, ms-scale):** `given`, reused verbatim from
  NB05 (same values, same centered hierarchy) — a light recap, not re-taught in depth,
  since students already built this twice.
- **Residual-scale hierarchy (Gaussian-component `sd_y`):** this *construct* (a
  log-linear participant hierarchy for a scale parameter) was just built in NB08.
  Supply it as `given` here too, with a brief recap Q&A connecting it to NB08's
  naming, rather than re-deriving it from scratch (would repeat NB08's teaching load
  for no new content).
- **The ex-Gaussian likelihood itself and the tail parameter `nu`:** genuinely new.
  Scaffold this NB1/NB4-style — students engage with what `nu` means, why it's
  population-only (no participant hierarchy, unlike `sd_y`) here, its own log-linear
  prior, and `mean_rt = mu_y + nu`.

## What changes vs. shared infrastructure

Unchanged: `%pip`, imports, `RANDOM_SEED`, data loading + participant index,
`LM_VISUALS`, `PARTICIPANT_DAY`, `plot_participants(dt, group, var, coords=None)`
(carry forward NB08's added sentence noting panels run in participant order, since
this notebook's spikes/heterogeneity questions will likely reference specific
panels too). No `plot_population` unless a question needs it.

## Structural plan (outline)

```
(intro) — link to NB08 (participant residual-scale heterogeneity) and the broader
   arc (NB06-08 used a log-transformed mean; this notebook instead represents skew
   directly via the likelihood's shape). State purpose plainly, no forward pointer
   to NB10/11 (that's for the closing section rule, §3.10 -- but also good practice
   for the intro, which should stand on its own).

## 1. Represent skew with an ex-Gaussian likelihood
   - what pm.ExGaussian(mu, sigma, nu) represents: Gaussian(mu, sigma) + Exponential(nu)
   - why mu needs no log link here, unlike Notebooks 6-8 (the explicit contrast question)
   - mean-structure hierarchy is supplied, reused from Notebook 5 (light recap)
   - the residual-scale hierarchy (sd_y) is supplied, reused from Notebook 8's
     construct (light recap connecting the two notebooks' naming)
   - what nu represents (the exponential tail's mean) and why mean_rt = mu_y + nu,
     not mu_y alone
   - why nu is population-only here (no participant subscript) -- a modeling choice,
     not a limitation; ask what would change if it did vary by participant
   - elicit mu_log_nu from a stated plausible tail-mean range (in ms)
   - build the tail piece: mu_log_nu (population log-scale center), nu = exp(mu_log_nu)
   - assemble the full model

## 2. Check the prior implications
   - criteria (given, referencing Notebook 1's + Notebook 8's residual-variability one)
   - prior predictive draws + plot (given, following NB08's pattern)
   - verdict -- take a genuinely skeptical look before writing this, per NB06/07/08's
     established practice
   - if a spike or other visual feature appears, trace its actual cause individually
     (NB07's review lesson) rather than assuming a pattern from a previous notebook

## 3. Fit and diagnose
   - sample; explain target_accept only if empirically needed (test default first)
   - population diagnostics + all-participant screen + subset (given code, NB08 pattern)

## 4. Examine the fitted ex-Gaussian components
   - population daily effect (mu_b1, in ms/day -- note the contrast with NB06-08's
     percentage/day reading, since this model's slope is back in ms)
   - participant residual scales (sd_y forest, as in NB08)
   - the fitted tail (nu): credible range, what it implies about right skew in ms

## 5. Predictive consequences
   - participant-level PPC
   - pooled ECDF

## 6. Summary
   - retrospective only: what the ex-Gaussian likelihood represents that the lognormal
     models didn't, what the fitted components say, what the predictive checks show.
     No reference to Notebook 10 or 11.
```

## Model/code content

- Mean-structure hierarchy: reuse NB05's exact naming and values —
  `mu_mu_b0=250, sd_mu_b0=100, sd_sd_b0=25, mu_mu_b1=0, sd_mu_b1=20, sd_sd_b1=10`
  (these already match the pre-revision draft's values, so no harmonization
  correction is needed here, unlike NB08's mean-structure situation — confirm this in
  the implementation notes rather than assuming).
- Residual-scale hierarchy: reuse NB08's naming pattern (`mu_log_sd_y`, `sd_log_sd_y`,
  `log_sd_y`, `sd_y = exp(log_sd_y)`). The pre-revision draft's values
  (`sigma_intercept~Normal(log(30), 0.5)`, i.e. `mu_mu_log_sd_y = log(30) ≈ 3.4`,
  `sd_mu_log_sd_y = 0.5`; `participant_sigma_sd~Exponential(lam=3)`, i.e.
  `sd_sd_log_sd_y = 1/3`) are a **fresh elicitation for this notebook** (not reusing
  another notebook's fit — NB09 is the first ex-Gaussian notebook), stated in ms as
  the pre-revision intro already does ("residual SD around 30 ms, 90% range ~13-68
  ms... participants' residual SDs typically differ by a factor of about 1.4"). Keep
  these values; present the elicitation explicitly.
- Tail: `mu_log_nu ~ Normal(mu=log(50), sigma=0.75)` (fresh elicitation, ~15-170ms 90%
  range per the pre-revision intro), `nu = pm.Deterministic("nu", pm.math.exp(mu_log_nu))`
  — **no participant dimension** (population-only, a deliberate simplification to keep
  the notebook from having three simultaneous participant hierarchies).
- `mu_y = pm.Deterministic("mu_y", b0[pidx] + b1[pidx] * days, dims="obs_id")` (ms
  scale, identity link).
- `mean_rt = pm.Deterministic("mean_rt", mu_y + nu, dims="obs_id")` (playbook §3.1's
  ex-Gaussian formula).
- `y = pm.ExGaussian("y", mu=mu_y, sigma=sd_y[pidx], nu=nu, observed=..., dims="obs_id")`.
- Centered parameterization throughout (playbook §3.4); no `target_accept` override
  unless Step 3a shows it's needed (the pre-revision draft used 0.95 and got 6
  divergences even then — test carefully, and if divergences persist, this is
  legitimate content, not a bug, given the model's real complexity).

## Self-work blanking plan

`given`: setup/data/plotting-helper cells; the mean-structure hierarchy recap; the
residual-scale hierarchy recap; sampling and diagnostics code (all-participant screen +
subset, NB08 pattern); prior predictive generation + plot.
`exercise-question`+`solution`: the ex-Gaussian-specific content (what `nu` means, why
no participant dimension, the elicitation, `mean_rt` formula, building the tail piece
and the full likelihood), all interpretation, all verdicts, the closing summary.

## Figures

None.

## Open questions / risks for the implementer

- Confirm NB05's mean-structure values really do match the pre-revision draft's
  (250/100, 0/20, scale 25, scale 10) before asserting no harmonization is needed —
  don't assume from this plan, check the actual pre-revision NB09 code.
- Test whether the model samples cleanly with default `target_accept` before adding
  one — the pre-revision draft needed 0.95 and still had divergences under the old
  non-centered parameterization; the centered version may behave differently.
- Take a genuinely skeptical look at the prior-predictive plot's plausibility and any
  spikes before writing the verdict, per the now-established practice in NB06-08.
- State explicitly (in the implementation notes, and in-notebook if it's a genuine
  teaching point) why `nu` has no participant hierarchy while `sd_y` does — this is a
  real asymmetry in the model that a careful student will notice.
