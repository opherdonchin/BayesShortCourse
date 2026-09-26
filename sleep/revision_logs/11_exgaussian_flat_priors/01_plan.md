# Plan: notebook 11 — Flat common-effect priors

Author: orchestrator (Plan step, per `sleep/REVISION_PLAYBOOK.md`).

## Teaching goal

From `sleep/solved/README.md`: "deliberately flat common-effect priors, with the same
hierarchical priors as notebook 9." **This is the second and more extreme
failure-demonstration notebook** (playbook §3.5's NB10/11 exception applies even more
strongly here — the pre-revision draft got 2033 divergences out of 4000 draws). Do not
fix it. Diagnose and interpret the failure honestly; the point is to show that a
flexible hierarchical model can contain directions the data barely identify once
regularization is removed, and that trusting a "reasonable-looking" fit without
checking diagnostics would be a real mistake here.

Structurally: **identical model to notebook 9**, except the four **common-effect**
(population-level, non-hierarchical) parameters become improper flat priors:
`pm.Flat("mu_b0")`, `pm.Flat("mu_b1")`, `pm.Flat("mu_log_sd_y")`, `pm.Flat("log_nu")`
(confirmed from the actual pre-revision code: `intercept`, `slope`, `sigma_intercept`,
`nu_intercept` all become `pm.Flat(...)`). The **participant-level hierarchical
priors** (`sd_b0`, `b0[participant]`; `sd_b1`, `b1[participant]`; `sd_log_sd_y`,
`log_sd_y[participant]`) are kept exactly as in notebook 9 — unchanged.

## A structural consequence: no prior predictive check is possible

Improper flat priors have no proper prior distribution to sample from, so
`pm.sample_prior_predictive` cannot produce a meaningful check here — this is itself
part of the lesson (the pre-revision notebook already made this point explicitly: "That
absence is itself part of the lesson"). Keep this framing. Do not substitute a fake or
partial prior predictive check to fill the gap.

## Scaffolding decision (playbook §3.5)

Heavily `given`/recap: the model (with the flat-prior substitution as the object of
study, not something students choose) is supplied. Diagnostic and interpretive
questions carry the content: recognizing what "improper" means and why no prior
predictive check exists, reading a genuinely failed fit's diagnostics honestly
(divergence count likely in the thousands, R-hat, ESS), and — the real point —
identifying which parameters still look "reasonable" despite the failure (mean
structure, likely) versus which are essentially unidentified (the tail `nu`,
following notebook 10's pattern, likely worse here).

## Structural plan (outline)

```
(intro) — link to Notebook 9 (and implicitly Notebook 10, without naming it forward --
   phrase as "removing prior information entirely" as a further step past a merely
   naive prior). State plainly: this model is not being recommended, it's being
   diagnosed.

## 1. Removing prior information
   - what does pm.Flat represent, and why is there no proper prior distribution
   - the model is supplied (given): four common-effect parameters become Flat,
     hierarchical priors unchanged from Notebook 9
   - why no prior predictive check is possible here (explicit, not glossed over)

## 2. Fit and diagnose: can this model be sampled reliably?
   - sample (given, notebook 9's target_accept as a starting point per the plan below)
   - report divergences/R-hat/ESS honestly, whatever they turn out to be
   - explicit criteria check against Notebook 1's diagnostic standards (expect a clear
     failure)

## 3. Reading a failed fit
   - shown only as an illustration (echo the pre-revision framing: "these plots are
     not evidence" once divergences are this severe) -- posterior plots, PPC
   - which parameters still look superficially reasonable, and why that is misleading
   - what happened to nu specifically, and why (weaker identification than even
     Notebook 10, since the common-effect regularization is now entirely gone)

## 4. Summary
   - retrospective only: what removing prior regularization did to computational
     reliability and to identifiability, and why trusting a flexible model's fit
     without diagnostics would be a mistake here specifically. No reference to
     Notebook 12.
```

## Model/code content

- Reuse NB09's exact model code, replacing only:
  `mu_b0 = pm.Flat("mu_b0")`, `mu_b1 = pm.Flat("mu_b1")`,
  `mu_log_sd_y = pm.Flat("mu_log_sd_y")`, `log_nu = pm.Flat("log_nu")`.
  Everything else (`sd_b0`, `b0`, `sd_b1`, `b1`, `sd_log_sd_y`, `log_sd_y`, `sd_y`,
  `nu`, `mu_y`, `mean_rt`, the `pm.ExGaussian` likelihood) is identical to notebook 9.
- No `pm.sample_prior_predictive` call/section — structurally absent, not stubbed out.
- `target_accept`: the pre-revision draft used `0.97, tune=2500` (confirm this against
  the actual pre-revision code, don't assume from this plan). Start there, matching
  what the README's framing is based on, and report what actually happens rather than
  escalating further to force a cleaner result.

## Self-work blanking plan

Almost entirely `given` (the model, since it's the object of study, not a construction
task; the sampling and diagnostic code). `exercise-question`+`solution`: what `pm.Flat`
means and why there's no prior predictive check, reading the diagnostics honestly,
identifying which parameters look deceptively fine versus which are unidentified, and
the closing summary.

## Figures

None.

## Open questions / risks for the implementer

- Confirm the actual pre-revision `target_accept`/`tune` settings from the real code,
  not this plan's recollection.
- Confirm the failure actually reproduces in this environment before writing any
  diagnostic numbers — required, not optional, given the notebook's entire content
  depends on what actually happens here.
- Given notebook 10 will have just demonstrated a milder version of prior-driven
  sampling failure, calibrate how much mechanism to re-explain here versus referencing
  notebook 10's explanation — but do NOT reference notebook 10 by number in a way that
  presumes the student read it in a specific order beyond what the README's stated
  sequence already implies (a factual "as in Notebook 10" reference is fine and
  expected; a forward-looking tone is not, per §3.10 — this notebook itself must still
  end retrospectively).
- Decide whether `nu`'s fate here (likely even more poorly identified than in notebook
  10, since the common-effect prior that indirectly regularized it is now gone) can be
  explained at this course's level, or should be described phenomenologically.
