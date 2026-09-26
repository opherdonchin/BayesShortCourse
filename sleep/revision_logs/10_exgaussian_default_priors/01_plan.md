# Plan: notebook 10 — Priors that ignore the link function

Author: orchestrator (Plan step, per `sleep/REVISION_PLAYBOOK.md`).

## Teaching goal

From `sleep/solved/README.md`: "the same ex-Gaussian structure, but with naive priors
that ignore the log link (no software 'defaults' exist for a hand-written PyMC model,
so this notebook instead reuses the unscaled priors that made an earlier draft of
notebook 9 fail to sample cleanly, now as a deliberate demonstration)." **This notebook
is explicitly a failure demonstration** (playbook §3.5's NB10/11 exception: "explicitly
about priors going wrong... diagnostics sections are themselves the lesson... should
not follow the everything passes pattern"). Do not fix the sampling failure — diagnose
and interpret it honestly.

Structurally: **identical model to notebook 9**, except `mu_log_sd_y` and `log_nu` get
naive `Normal(0, 5)` priors (plausible-looking on paper, catastrophic once
exponentiated: `exp(Normal(0,5))` spans roughly 0.007 to 150,000 ms) instead of
notebook 9's elicited `Normal(log(30), 0.5)` and `Normal(log(50), 0.75)`. Everything
else — mean structure, `sd_y`/`log_sd_y` construction, `mean_rt`, the likelihood,
`target_accept` left at notebook 9's value unless the plan below says otherwise — is
reused verbatim.

## Why this will actually fail (confirmed empirically in notebook 9's own investigation)

Notebook 9's implementation notes (decision 5, "for the orchestrator, planning
NB10/11") already found that a wide/flat prior on `log_nu` makes the sampler
pathological: the likelihood is flat in `log_nu` as ν→0, and PyMC's `ExGaussian.logp`
switches to a pure Normal (zero gradient in ν) once `nu < 0.05*sigma`, so a naive prior
can push the sampler into a region with no useful gradient. This is very likely why the
pre-revision draft failed (max tree depth on every chain, R-hat up to 1.05, bulk ESS as
low as ~170, `nu_intercept` collapsing to a near-zero exponential component). **Confirm
this empirically in Step 3a rather than assuming** — but expect it, and do not
"succeed" by quietly raising `target_accept` or reparameterizing until it passes; that
would defeat the notebook's purpose.

## Scaffolding decision (playbook §3.5)

Given/recap-heavy: the mean structure and the residual-scale hierarchy's *construct*
are `given`, identical to notebook 9's. The only new model content is the two naive
priors, `given` as the deliberate manipulation under study (students don't "choose" a
bad prior — they're shown one and asked to diagnose its consequences, matching how NB2
supplied a deliberately narrow prior for students to diagnose). Scaffolding effort goes
into the **diagnostic and interpretive** questions: recognizing the failure, explaining
why it happens, and — the notebook's real point — showing that some things (population
mean/slope) can look deceptively fine while others (the tail) are badly broken.

## Structural plan (outline)

```
(intro) — link to NB09; state plainly that this notebook studies what happens when a
   prior looks reasonable on paper but was never translated into the units it
   actually constrains. No apology, no forward pointer.

## 1. Priors that ignore the link
   - the naive priors are supplied (given): mu_log_sd_y ~ Normal(0,5), log_nu ~ Normal(0,5)
   - what do these imply once exponentiated? (elicitation-in-reverse: translate the
     stated prior back into ms, the mirror of NB9's 1.12)
   - explicit link to NB09's criteria: would this pass Notebook 1's/9's plausibility
     checks if you had checked before fitting?

## 2. Check the prior implications
   - prior predictive check (given code, reused from NB09's pattern) -- take this
     seriously as a check that WOULD have caught the problem before fitting, per
     AGENTS.md's workflow (the point of prior predictive checks is to catch exactly
     this kind of mistake before spending compute on a bad fit)
   - verdict: does it meet Notebook 1's criteria? (expect a clear no)

## 3. Fit and diagnose: does the model still sample?
   - sample (given, notebook 9's settings -- do not preemptively raise target_accept)
   - diagnostics: report divergences, R-hat, ESS, tree-depth warnings honestly
   - explicit reading of what failed and what (surprisingly) didn't

## 4. What does the failure look like in the posterior?
   - compare mean-structure parameters (b0, b1) to Notebook 9's fit -- do they look
     reasonable despite the failure? (this is the dangerous-illusion teaching point)
   - what happened to nu specifically, and why (link to the flat-likelihood/logp-switch
     mechanism, if it can be explained at the right level for this course, or simply
     described phenomenologically if the mechanism is too deep to teach here)
   - would trusting the mean-structure numbers without checking diagnostics have been a
     mistake? (yes -- ties back to AGENTS.md's "diagnostics before interpretation" rule)

## 5. Summary
   - retrospective only: what this notebook demonstrated about priors, units, and the
     danger of only checking some parameters' plausibility. No reference to Notebook 11.
```

## Model/code content

- Reuse NB09's exact model code for everything except the two prior lines:
  `mu_log_sd_y = pm.Normal("mu_log_sd_y", mu=0, sigma=5)` (was
  `mu=np.log(30), sigma=0.5`), `log_nu = pm.Normal("log_nu", mu=0, sigma=5)` (was
  `mu=np.log(50), sigma=0.75`).
- **Confirmed from the actual pre-revision NB10 code** (not a guess): `sd_sd_log_sd_y`
  (the between-participant residual-scale prior) is *also* naive there —
  `Exponential(lam=0.20)`, i.e. scale 5, versus NB09's `lam=3`/scale `1/3`. Reuse this
  naive value too, framed explicitly as part of the same "ignore the link" mistake
  (a between-participant SD is exactly as scale-sensitive as a population center).
  Say so in-notebook (this is real content, not an oversight to silently correct).
  The pre-revision draft also used `target_accept=0.95, tune=2000` (less conservative
  than NB09's eventual `0.99`) — start there since that's what the pre-revision
  evidence (and the README's framing of NB10 as reusing "the unscaled priors that made
  an earlier draft of notebook 9 fail") is based on, and only note in the answer if
  Step 3a's actual behavior differs.
- `target_accept`: start at notebook 9's value (0.99) — if it still fails at that
  setting (likely, per NB09's own investigation), that itself is the point; report the
  failure rather than escalating further to force success.
- No new `pm.Deterministic`s beyond what NB09 already has.

## Self-work blanking plan

Given the heavy "given"/recap nature of this notebook (identical model to NB09 except
two prior lines, which are themselves supplied as the object of study), most code is
`given`. `exercise-question`+`solution`: the reverse-elicitation translation (what do
these priors imply in ms), the criteria verdict, reading the diagnostics honestly, and
the interpretive comparison with Notebook 9's fit (the "some things look fine, others
are badly broken" point) — this last one is the notebook's actual teaching content and
should not be given away.

## Figures

None.

## Open questions / risks for the implementer

- Confirm the failure actually reproduces in this environment before writing any
  diagnostic numbers — this is exactly the kind of claim that must come from real
  execution, not assumption, especially since the notebook's whole point rests on it.
- Decide how deep to go into *why* the sampler breaks (the flat-likelihood/logp-switch
  mechanism NB09's investigation found) — full mechanism may be too advanced for this
  course's level; a phenomenological description ("the tail becomes unidentifiable and
  the sampler cannot find consistent step sizes") may be more appropriate. Use
  judgment, but do not misstate the mechanism if you do include it.
- If `target_accept=0.99` doesn't reproduce a clear failure in this environment (e.g.
  if it happens to sample better here than in the pre-revision environment), do not
  paper over this — report what actually happens and adjust the notebook's claims to
  match, per playbook's "no silent decisions."
