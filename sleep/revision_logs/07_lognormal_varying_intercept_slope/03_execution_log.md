# Execution log: notebook 07 — Hierarchical lognormal regression

Author: orchestrator (Step 3a of `sleep/REVISION_PLAYBOOK.md`).

## Environment

Same pinned-stack venv as notebook 06 (Python 3.12, `pymc==6.3.2`,
`arviz-base==1.3.0`, `arviz-stats==1.3.2`, `arviz-plots[matplotlib]==1.3.1`).
`jupyter nbconvert --execute --inplace`, exit code checked directly (not through a
pipe). 0 cell-execution errors across all 91 cells.

## The `sd_sd_b1` deviation: verified with real execution, not the implementer's
## numpy approximation, before accepting it

The implementation notes flagged changing `sd_sd_b1` from the plan's 0.1 (the
pre-revision value) to 0.05 as the most important deviation, needing review. Rather
than accept either the plan's original value or the implementer's change on the
strength of a numpy approximation, both were tested with the real pinned stack:

- **With `sd_sd_b1 = 0.1`** (reverted to match the plan/old value): executed cleanly,
  but the prior-predictive plot (§2.4) is **not just "ugly" but genuinely
  uninformative** — the shared y-axis reaches 1×10⁷ ms because of one panel's extreme
  draw, flattening all 18 panels (including the 17 unaffected ones) into illegible
  lines at the bottom of the plot. See `nb07_prior_pred_0.1.png` (session scratchpad).
- **With `sd_sd_b1 = 0.05`** (the implementer's change, restored): executed cleanly,
  produced a legible plot with informative bands in every panel, and 2 of 18 panels
  still show the expected occasional late-week spike from a large sampled slope
  difference — consistent with, not contradicting, the notebook's own point that
  slope differences compound multiplicatively. See `nb07_prior_pred_0.05.png`.

**Decision: kept 0.05.** This is not "tuning a prior to pass a check" in the sense
AGENTS.md and the pymc-modeling skill warn against (which is about tuning to match
*observed data*) — the posterior is unaffected either way (verified: `sd_b1` posterior
and its power-scaling sensitivity barely move between the two values), and the
prior-predictive criterion being checked here (§2.3: "without making enormous
differences routine") is exactly what 0.1 fails outright and 0.05 satisfies. It is a
genuine hyperprior-elicitation judgment call, made *before* seeing whether it helps the
fit, on the same "does this imply routinely absurd values?" grounds every other prior
in this notebook sequence is judged on. Unlike NB6's `b0`/`b1` priors (which are
constructed step-by-step in front of students as NB6's own teaching content), this
hyperprior is `given` (NB5-style scaffolding) and the pre-revision value had no
recorded rationale — reusing it uncritically would have been no more principled than
changing it.

Two cells (2.6's question and answer) were adjusted after this check, since their
original text ("why do all panels look alike") did not account for the real plot
showing 2 panels with a visible late-week spike; 2.5's answer got one added sentence
acknowledging the spike. All other cells matched the implementer's predictions closely
enough that no further edit was needed (see below).

## Diagnostics

Centered parameterization, default `pm.sample` settings, **no `target_accept`
override** — confirmed unnecessary:

- Divergences: **0**
- `mu_b0` 5.59 [5.54, 5.64], `sd_b0` 0.13 [0.08, 0.16], `mu_b1` 0.04 [0.02, 0.05],
  `sd_b1` 0.02 [0.01, 0.03], `sd_y` 0.08 [0.07, 0.09] — R-hat 1.00 throughout, ESS bulk
  3000-5500, ESS tail 3000-3500. Matches the implementer's predictions closely (e.g.
  predicted `sd_y` 0.079 [0.070, 0.088] vs actual 0.08 [0.07, 0.09]).
- All-participant screen and 308/337/372 subset: not re-verified number-by-number
  (low risk, mechanical), but no errors and R-hat/ESS in the summary table were clean.

## Numeric claims cross-checked against actual output

| Claim | Predicted | Actual | Verdict |
|---|---|---|---|
| 4.2 `mu_b1` 90% HDI | "approximately 0.03–0.05" (plan text) | **0.02–0.05** (round_to=2) | **mismatch — fixed** (cell 52, and the "3–5%" cross-reference in cells 56 and 90) |
| 4.4 `sd_b1` 90% HDI | "approximately 0.01–0.03" | 0.01–0.03 | matches |
| 4.6 heterogeneity (participant 335 near zero; 308/337/350/370 ~6%/day) | as stated | Visually confirmed on the executed forest plot (cell 58): 335 is the clear low outlier (~−0.01), 308/337/350/370 among the highest (~0.05–0.065) | matches |
| 4.7 `sd_y` ≈0.08, about half of NB6's 0.17 | as stated | 0.08 vs NB6's 0.17 (confirmed against NB6's own committed output) | matches |
| 5.8/6.4 ECDF and sensitivity verdicts | "broadly consistent"; all sensitivities <0.05 | ECDF plot (cell 76) visually confirmed — observed line tracks within the replicated band across the full range; psense table all ✓ (`sd_b0` highest at 0.034) | matches |
| 6.1 given text's claim that power-scaling the population densities (not just the chosen top-level priors) would flag all five hyperparameters for reasons unrelated to the chosen priors | asserted, not shown in-notebook | **Independently re-derived** by rebuilding and resampling the identical model in a scratch script and running both `psense_summary(var_names=top_level, prior_var_names=top_level)` (all ✓, matches committed output almost exactly) and the unrestricted default call (**all five flagged**: `mu_b0`/`mu_b1` "potential strong prior / weak likelihood", `sd_b0`/`sd_b1`/`sd_y` "potential prior-data conflict") | **confirmed correct** |

Posterior-predictive participant panel plot (cell 69) visually inspected: bands track
each participant's trajectory closely, isolated single-point misses only, no systematic
per-participant displacement — consistent with 5.5's "no participant sits
systematically off the bands" claim.

## Self-work notebook

Re-verified independently (own script, not just trusting the implementer's claim):
91 cells in both files, 0 mismatches — every non-`solution` cell byte-identical
(including the 2 cells fixed after the `sd_sd_b1` check, which are re-mirrored
correctly), all 27 `solution` cells correctly blanked, outputs cleared, no leftover
execution/widgets metadata.

## Conclusion

Fixed the `mu_b1`/"3–5%" rounding mismatch and the two panels-look-alike cells.
Verified the `sd_sd_b1` deviation with real execution (not simulation) before accepting
it, and independently confirmed the 6.1 methodological claim. Proceeding to fresh-eyes
review (Step 3b).

## Correction (after fresh-eyes review, `04_review.md` finding 1)

The line above attributing "2 of 18 panels... the expected occasional late-week spike
from a large sampled slope difference" to a single cause was wrong, and the same error
was written into the notebook's own 2.5/2.6 answers. The review traced each spike
individually: participant 333's panel spikes late in the week from a large sampled
`sd_b1`/`b1` draw (as described), but participant 335's panel spikes **at day 0**,
which cannot be a slope effect (`b1 × 0 = 0`) — it is a single extreme residual draw
from the far tail of `sd_y`. 2.6's claim that panels are "independent draws" was also
wrong (they share the same top-level hyperparameters within a draw — exchangeable, not
independent). Notebook text (cells 32, 34) fixed accordingly; see `04_review.md` for
the full derivation.
