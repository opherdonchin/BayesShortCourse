# Execution log: notebook 09 — Ex-Gaussian distributional model

Author: orchestrator (Step 3a of `sleep/REVISION_PLAYBOOK.md`).

## Environment

Same pinned-stack venv as notebooks 06-08. `jupyter nbconvert --execute --inplace`,
exit code checked directly. 0 cell-execution errors across all 103 cells.

## Posterior: bit-identical to the implementer's predictions

Executed values matched the implementation notes' predicted table **exactly**, to every
displayed digit: `mu_b0` 259.91, `sd_b0` 33.83, `mu_b1` 11.26 [8.03, 14.61], `nu` 7.44
[3.72, 10.98], `mu_log_sd_y` 2.79 [2.45, 3.08], `sd_log_sd_y` 0.76 [0.47, 1.03], **0
divergences** at `target_accept=0.99`. This confirms the implementer's claim of
bit-reproducibility across processes for this model in this environment (unlike NB08,
which showed process-to-process variation).

## The `target_accept=0.99` / default-divergence premise: independently re-confirmed

Rebuilt the exact model from the notebook's code in a standalone script (not reusing the
implementer's scratch scripts) and ran it with **default** `target_accept=0.8`: **38
divergences** — confirms Q3.2's "more than a dozen divergences" claim robustly (38 ≫
12), consistent with the implementer's own two runs (14 and 38 — noted as "not
reproducible at the default" itself, but always heavily divergent).

## Visual/interpretive claims cross-checked against actual output

- **Density figure (1.2):** visually confirmed three clean ex-Gaussian curves (ν = 5,
  50, 150 ms) with dashed mean lines at 255/300/400 ms, steep shared left edge,
  progressively longer right tail — matches the description exactly.
- **Prior-predictive spike (2.7):** visually confirmed the dramatic zigzag in
  participant 333's panel (row 2, panel 1) — the mean line swings from below zero up
  past 700ms and back across the week, matching the predicted per-day values (578,
  −173, 326, 650, 116, 65, 407, 731 ms) and clearly distinct from all 17 other panels,
  which stay near 300ms throughout.
- **Forest plot of `sd_y` (4.6/4.7):** visually confirmed 309 and 352/335 as the clear
  low outliers (~5-7ms), 308 and 332 as the clear high outliers (~49-58ms,
  non-overlapping) — matches the "roughly tenfold" heterogeneity claim.
- **ECDF (5.7/5.8):** observed line tracks within the replicated band across the full
  range — matches "broadly consistent" verdict.

## Naming and playbook updates

Accepted the implementer's `log_nu`/`mu_log_nu`/`sd_log_nu` naming (deviating from the
plan's `mu_log_nu`-as-parameter suggestion) — well-justified: a population-only
parameter takes the bare name per playbook convention (mirrors `log_sd_y`→`sd_y`), and
the plan's naming would have implied a hierarchy that doesn't exist. Recorded this,
plus the important correction that NB09-11's mean structure is ms-scale/identity-link
(unlike NB06-08's log-scale mean structure) since only the scale/tail parameters need
transforms here, in playbook §3.1.

## Structural decision confirmed by evidence, not asserted

The implementation notes justify giving `sd_y` a participant hierarchy while keeping
`nu` population-only with real evidence (a scratch fit giving `nu` its own hierarchy
showed the between-participant SD barely moved from its prior and produced 167
divergences, vs. `sd_y`'s clearly-identified per-participant spread) — this becomes the
fixed structural template for notebooks 10 and 11 per the README's description of them
as reusing notebook 9's model. Noted for those notebooks' plans.

## Self-work notebook

Independently re-verified (own script): 103 cells in both files, 0 mismatches.

## Conclusion

No corrections needed from execution — every flagged risk item checked out against
real, independently-reproduced output. Proceeding to fresh-eyes review (Step 3b).
