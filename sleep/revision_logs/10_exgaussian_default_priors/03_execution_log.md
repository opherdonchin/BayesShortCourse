# Execution log: notebook 10 — Priors that ignore the log link

Author: orchestrator (Step 3a of `sleep/REVISION_PLAYBOOK.md`).

## Environment

Same pinned-stack venv as notebooks 06-09. `jupyter nbconvert --execute --inplace`,
exit code checked directly. 0 cell-execution errors across all 56 cells. Sampling took
339 seconds (within the implementer's reported 333-355s range).

## Bit-identical reproduction confirmed

Every number in the executed notebook matches the implementation notes' predicted
values exactly: 100% of draws at max tree depth, average step size 0.0025, population
summary (`mu_b0` 264.69, `sd_b0` 33.92, `mu_b1` 11.20 [8.23, 14.52], `sd_b1` 7.36,
`mu_log_sd_y` 2.80 [2.50, 3.13], `sd_log_sd_y` 0.71 [0.44, 0.98], `log_nu` −1.89
[−6.44, 2.18], bulk ESS 108), and the participant screen (worst: `b1[332]` ESS 100.85,
matching the notebook's own `coords={"participant": ["332"]}` choice in 3.6's solution
code). This confirms the implementer's claim of bit-reproducibility across 4 separate
nbconvert runs plus this one — 5 for 5.

## The `target_accept=0.95` judgment call: agreed

The plan I wrote was internally inconsistent (one line said start at the pre-revision
draft's 0.95/2000, another referenced notebook 9's 0.99 as if it were the same
suggestion). The implementer correctly caught this, used 0.95/2000 (the actual
pre-revision setting), and flagged the choice with strong reasoning: at notebook 9's
0.99/1500, *every* parameter fails including the mean-structure ones (population R-hat
up to 2.19, chains disagreeing even on `mu_b1`), which would remove the specific
"`mu_b1` looks deceptively fine but the tail is badly broken" lesson that 4.2 is built
around. Agreed — keeping 0.95/2000 is the right call, and it matches what the README's
framing (reusing the pre-revision draft's failure) is actually based on.

## Visual claims cross-checked against actual output

- **Prior predictive (2.3/2.4):** visually confirmed the y-axis in units of 1e51 ms,
  with only participant 333's panel (row 2, panel 1) showing a visible zigzag (down to
  about −1.3, up to about 1.2, in units of 1e51) — every other panel flat at zero.
  Exact match to the predicted description, including the identification of this as
  the same random draw (#455) that produced notebook 9's much smaller zigzag.
- **Prior-vs-posterior comparison (4.3):** visually confirmed `mu_log_sd_y` shows a
  sharp, narrow, clearly data-dominated posterior spike against a nearly flat wide
  prior, while `log_nu`'s posterior largely retains the prior's shape on the left with
  a modest, bumpy rightward shift — matches the "one parameter data-dominated, one
  prior-shaped, inside a single model" teaching point exactly.

## Mechanism claim (4.5): a genuine, verified finding

The implementer's claim that the failure comes from a discontinuity in PyMC 6.3.2's
`ExGaussian.logp` (switching to a plain-Normal formula once ν < 5% of σ), rather than
flatness alone, is backed by real evidence in the implementation notes (a smooth,
exact-density refit recovers step size/tree-depth/R-hat while keeping the same naive
priors, producing divergences instead — proving the discontinuity, not the flat
region itself, causes the tiny-step-size failure mode). This is a substantive,
verified piece of content, not speculation dressed up as fact.

## Self-work notebook

Independently re-verified (own script): 56 cells in both files, 0 mismatches.

## Conclusion

No corrections needed from execution — every claim checked out against real,
bit-identical output. This notebook does exactly what a failure-demonstration notebook
should: it fails, honestly, for a well-understood and correctly-explained reason.
Proceeding to fresh-eyes review (Step 3b).
