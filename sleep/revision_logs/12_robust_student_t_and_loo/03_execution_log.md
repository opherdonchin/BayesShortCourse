# Execution log: notebook 12 — Robust likelihoods and PSIS-LOO

Author: orchestrator (Step 3a of `sleep/REVISION_PLAYBOOK.md`).

## The `mu_b1`/`b1` naming decision

The implementer flagged a real tension (deviation 1): the plan named the pooled slope
in the intercept-only models `mu_b1`, but the playbook's §3.1 table reserves `mu_`
for the center of a participant-level hierarchy, and the pooled slope has no
participant-level dimension in those two models. I checked `sleep/solved/
04_varying_intercept.ipynb` directly: its own code is `b1 = pm.Normal("b1",
mu=mu_b1, sigma=sd_b1)` — a bare `b1`, matching the table, not the plan's `mu_b1`.
I asked the implementer to rename to match NB4's precedent: `b1` in the
`varying_slope=False` branch, `mu_b1`/`sd_b1`/`b1[participant]` unchanged in the
`varying_slope=True` branch, propagated through 1.1, 1.5, 1.7's screen/summaries,
1.8's trace call, and 5.2's cross-model comparison (which now states explicitly that
the same population-average quantity is called `b1` in the shared-slope models and
`mu_b1` in the varying-slope models, and why). Confirmed in the committed code
(`build_model`, cell 14) and in the executed summaries (cell 20's output): the two
intercept-only models' tables now show `b1`, the two slope models show `mu_b1`/
`sd_b1`, exactly as intended.

## Environment

Same pinned-stack venv as notebooks 06-11. Copied `sleep/solved/12_robust_student_t_
and_loo.ipynb` to a scratch path and executed it independently of the implementer's
own run, via `jupyter nbconvert --execute --inplace`, exit code checked directly.
Exit code 0, 0 cell-execution errors across all 16 code cells.

## Bit-identical reproduction confirmed

Compared every text/text-plain output between my independent execution and the
committed notebook, cell by cell (73 code-cell outputs in each). The only differences
are the four sampler wall-clock timing lines ("took N seconds"), which vary run to
run and carry no numeric claim. Every other output — diagnostics screen, population
summaries (all four models), Pareto-k tables, `azs.compare` tables, `plot_khat`
percentage labels — is character-for-character identical.

## Independent numeric verification

- **Gamma(2, 0.1) prior claims (1.3):** re-derived analytically with `scipy.stats.gamma`
  (shape=2, scale=10): mean 20.0, P(ν<5) = 9.02%, P(ν>30) = 19.9%, P(ν<2) = 1.75%.
  Matches the notebook's "about 9%", "about 20%", "about 2%" exactly.
- **Bambi citation (1.3):** read the implementer's saved Bambi 0.21.0 source directly
  (`scratchpad/nb12/bambi/src/bambi/defaults/families.py` and `distributions.py`).
  Confirmed independently: the `"t"` family's `default_priors` maps `"nu": "Gamma"`,
  and the `"Gamma"` default-prior-constants entry is `{"alpha": 2, "beta": 0.1}`. The
  citation is accurate, not just plausible-sounding.
- **Sampling diagnostics (1.7/1.9):** re-verified from my own execution's output: 0
  divergences in all four models, largest R-hat 1.0053 (`student_t_slope`), smallest
  bulk ESS 1505 (`student_t_intercept`'s `b1`) — matches the implementation notes'
  table exactly.
- **Pareto-k (4.4/4.5):** matches the implementer's reported values: `gaussian_slope`
  largest k = 0.97 (4 observations flagged, 2.8%), `gaussian_intercept` largest k =
  0.64 (borderline per the notebook's own cross-seed check), both Student-t models
  below 0.55. The implementer's seed-robustness table (5 runs) and exact-LOO refit
  check (summed PSIS error always < 2 against a 38-point gap) support the "does not
  change the ranking" claim in 4.8 — I did not re-run these myself, but the reasoning
  and the executed notebook's own numbers are internally consistent, and the claims in
  the question text are written to hold regardless of which seed a Colab run lands on.
- **`azs.compare` (4.7/4.10):** `student_t_slope` best; `gaussian_slope` −38.02 (dse
  12.85), `student_t_intercept` −45.81 (8.71), `gaussian_intercept` −54.02 (9.57).
  Reference-comparison table (4.9): `student_t_intercept` +8.22 (5.34), `gaussian_
  slope` +16.00 (9.71), `student_t_slope` +54.02 (9.57) vs. `gaussian_intercept`. All
  match the executed output.
- **5.2 cross-model comparison:** `b1`/`mu_b1` posterior means 11.3-11.6 ms/day across
  all four models; 90% HDI 9.55-13.22 (`gaussian_intercept`'s `b1`) vs. 8.10-14.55
  (`gaussian_slope`'s `mu_b1`) — matches the executed summaries in cell 20's output.

## Visual claims cross-checked against actual output

- **Pareto-k plots (cell 53):** confirmed. `gaussian_slope`'s panel shows two points
  near k≈0.97 (well above the 0.7 threshold line), one near 0.75, one just above the
  line, with "2.8%" labeled — matches 4.5's text. `student_t_slope`'s panel shows
  every point below about 0.5, "100.0%" below threshold.
- **LOO-PIT plots (cell 40):** confirmed. `gaussian_slope`: p=0.00, a dip to about
  −0.12 near LOO-PIT≈0.3 and a peak to about +0.11 near 0.75-0.8, with red-highlighted
  points at both ends and near the dip — matches 3.3's solution exactly. `student_t_
  slope`: p=0.44, deviations within about ±0.05, no highlighted points — matches 3.4.
- **LOO-interval participant panels (cells 30/34):** confirmed the participant-panel
  layout (18 panels, one per participant, per AGENTS.md's "no observation indices when
  predictor values are available"). Participant 332's day-4 point sits visibly outside
  the 90% band (the high ~454ms point), and participant 308's day-5 point sits below
  its band — matches 2.4's description of the two clearest misses.

## Self-work / solved structural consistency

Independently re-verified with a standalone script (mirroring the pattern used for
notebooks 06-11): 74 cells in both files, 0 mismatches beyond the expected — cell 0's
Colab badge URL, and the 19 `solution`-tagged cells replaced with bare `# answer here`
/ `- answer here` placeholders. Tag counts match the implementation notes exactly (24
`given`, 19 `exercise-question`+`solution` pairs, 7 `exercise-question`+`given-answer`,
5 `section`). The self-work notebook has no stray outputs or execution counts. Both
files pass `nbformat.validate`.

## AGENTS.md / playbook convention checks

- Closing section (5.3) is a genuine retrospective — five bullet findings plus a
  one-sentence factual note that this ends the sequence, no forward-looking framing.
- 90% HDI (`ci_prob=0.90`) used throughout for ordinary summaries; LOO intervals use
  `ci_probs=(0.50, 0.90)`, the course's established 50%/90% convention for predictive
  bands (matches `plot_participants`' own convention elsewhere in the course).
  `point_estimate="mean"` used consistently; no `median` found anywhere in code cells.
- Naming: `mu_b0`/`sd_b0`/`b0[participant]` (always hierarchical, all four models);
  `b1` (population-only, shared-slope models) vs. `mu_b1`/`sd_b1`/`b1[participant]`
  (varying-slope models), now resolved per the decision above; `sd_y` population-only;
  `nu` Student-t's own parameter name, no log link (Gamma already has positive
  support) — all correct per §3.1.
- `mu_y = b0[pidx] + b1 * days` or `b0[pidx] + b1[pidx] * days`, identity link,
  ms-scale, no `mean_rt` (correct — Gaussian/Student-t's `mu_y` already is the
  expected value, per §3.1's NB12-specific note).

## Conclusion

No corrections needed beyond the `mu_b1`/`b1` naming fix already applied and verified
above. Every numeric and visual claim checked out against real, bit-identical output,
including two claims I verified from first principles independent of the
implementer's own tooling (the Gamma(2,0.1) probabilities, and the Bambi source
citation). Proceeding to fresh-eyes review (Step 3b) — this is the final notebook in
the sequence, so the review should also check the notebook reads coherently as the
course's closing piece.
