# Execution log: notebook 08 — Distributional lognormal model

Author: orchestrator (Step 3a of `sleep/REVISION_PLAYBOOK.md`).

## Environment

Same pinned-stack venv as notebooks 06/07. `jupyter nbconvert --execute --inplace`,
exit code checked directly. 0 cell-execution errors across all 105 cells.

## The `target_accept=0.9` premise: independently re-confirmed, not trusted on the
## implementer's word

The implementation notes flagged that NUTS was not bit-reproducible across processes
in their own testing (default settings gave 0 divergences on their first run, 1 on
8 of 9 later runs) and asked for a fresh confirmation. Ran the notebook's exact model
with **default** `target_accept=0.8` three times in this environment, independently of
the notebook: **1 divergence in all 3 runs.** Confirms Q3.2's premise
("the sampler occasionally reports a divergence... with the default target_accept")
is accurate here, not a fluke of one process. The executed notebook (with
`target_accept=0.9`) shows **0 divergences**, R-hat ≤ 1.00, population ESS bulk
3651-5215 / tail 3077-3526 — matches the implementer's seed study (0/8 seeds diverged
at 0.9) closely.

## Diagnostics (as executed, target_accept=0.9)

- `mu_b0` 5.58 [5.53, 5.64], `sd_b0` 0.13 [0.09, 0.17], `mu_b1` 0.04 [0.03, 0.05],
  `sd_b1` 0.02 [0.02, 0.03] — matches NB07's fitted values closely, as expected since
  the mean-structure priors and data are identical.
- `mu_log_sd_y` −2.85 [−3.10, −2.62], `sd_log_sd_y` 0.59 [0.40, 0.80] — matches the
  implementation notes' predicted values almost exactly (−2.853/[−3.097,−2.616] and
  0.59/[0.395,0.795]).

## Visual/interpretive claims cross-checked against actual output

- **Prior-predictive spike attribution (2.7, the notes' highest-risk item):**
  visually inspected the executed plot (cell 51). **Exact match** to the predicted
  panel positions: participant 351 (row 3, panel 1) spikes on day 2; participant 371
  (row 3, panel 5) spikes on day 7; participant 335 (row 2, panel 3) shows the smaller
  predicted bump around day 6. The notebook's own answer (cell 55) correctly attributes
  both prominent spikes to a single extreme residual draw, explicitly ruling out slope
  (builds over days) and intercept (would raise the whole trajectory) — this is exactly
  the individual-cause-tracing discipline NB07's review had to correct after-the-fact;
  here it was done correctly the first time.
- **Prior-predictive plausibility verdict (2.6):** plot confirms the 50% band sits at
  or below ~200ms in every panel, below every observed point throughout — matches the
  "only partly... implausibly fast" verdict (cell 53), not a generous misreading.
- **Forest plot of participant `sd_y` (4.5/4.6):** visually confirmed 309 and 352 are
  the clear low outliers (~0.03, non-overlapping), 308 and 332 the clear high outliers
  (~0.14-0.17) — matches the "no overlap... five- to six-fold" claim.
- **ECDF (5.8):** observed line tracks within the replicated band across the full
  range — matches "broadly consistent" verdict.

## Section 6 (sensitivity) omission

Confirmed by grep: no `psense`/`compute_log_density`/power-scaling code anywhere in
the notebook, consistent with the implementation notes' documented decision (README's
psense list is currently "notebooks 1, 2, 3, 6, 7"; adding notebook 8 would be a
repository-wide README change, not a local addition). Agreed with this call — the one
notebook-specific sensitivity question (does the NB07-informed `mu_log_sd_y` center
drive the result?) is answered natively by the prior-vs-posterior comparison in 4.4,
without needing a new section.

## Naming precedent for distributional notebooks (playbook §3.1 update needed)

This notebook establishes the naming pattern for a residual-scale hierarchy:
`mu_log_sd_y`/`sd_log_sd_y` (hyperparameters), `log_sd_y` (centered participant-level
parameter, mirroring `b0`/`b1`'s form directly rather than a deviation), `sd_y =
exp(log_sd_y)` (a `pm.Deterministic`, participant-level, forest-plotted). No
observation-level `sd_y` deterministic — `sd_y[pidx]` is used directly in the
likelihood and in `mean_rt`. Recording this in the playbook now for NB09-11's plans
(see follow-up commit).

## Reusing NB07's fitted `sd_y` to center a new prior (decision 2): agreed as
## documented, not silently accepted

The implementation notes are explicit that this is meaningfully different from NB06/07
reusing an earlier *prior* (this reuses a *posterior* fitted to the same data) and
defend it as legitimate only because the new prior's range (×7) is far wider than what
it's centered on, so it fixes order-of-magnitude rather than encoding the fit itself —
backed by a scratch power-scaling check (sensitivity 0.039, not flagged) and by 4.4
showing the posterior HDI is a third of the prior's width with its center moving.
Q1.9 states this honestly in the notebook rather than presenting the choice as
ordinary prior reuse. No further action needed — this is exactly the kind of
judgment call the playbook's "no silent decisions" principle asks to surface, and it
was surfaced correctly.

## Self-work notebook

Independently re-verified (own script): 105 cells in both files, 0 mismatches.

## Conclusion

No corrections needed from execution — every flagged risk item checked out against
real output. Proceeding to fresh-eyes review (Step 3b).
