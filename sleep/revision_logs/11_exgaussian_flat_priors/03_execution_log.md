# Execution log: notebook 11 — Flat priors and an improper posterior

Author: orchestrator (Step 3a of `sleep/REVISION_PLAYBOOK.md`).

## Environment

Same pinned-stack venv as notebooks 06-10. `jupyter nbconvert --execute --inplace`,
exit code checked directly (`echo "EXIT CODE: $?"` immediately after the command, no
intervening pipe). Exit code 0, 0 cell-execution errors across all 49 cells. Sampling
took within the implementer's reported range.

## Bit-identical reproduction confirmed on the first attempt

The implementation notes flagged a real risk: PyTensor/Numba's compiled-code cache
state can affect results on this notebook's pathological (near-improper) posterior,
even with a fixed seed, and the implementer could not guarantee which outcome a cold
cache in this container would reproduce. The container's cache was warm (notebooks
06-10 had already compiled overlapping PyTensor graphs), and the executed notebook
matched the implementer's "warm cache" prediction exactly on the first try — no second
run was needed:

- Diagnostics banner: `Divergences: 1488`, draws at max tree depth `25.2%`, average
  step size `0.0059`.
- Population summary (cell 22): `mu_b0` 262.23, `sd_b0` 33.17, `mu_b1` 10.72, `sd_b1`
  7.93, `mu_log_sd_y` 0.88 ± 3.39 [−5.00, 3.01], `sd_log_sd_y` 0.47, `log_nu` −139.82 ±
  124.00 [−320.11, 3.73], R-hat ranging 1.13-1.58 across these variables.
- Non-stuck-chain summary (cell 37, `coords={"chain": [0, 1, 2]}`): `mu_b0` 267.18
  [252.35, 281.24], `sd_b0` 34.26, `mu_b1` 11.48 [8.27, 14.55], `sd_b1` 7.49,
  `mu_log_sd_y` 2.83 [2.57, 3.11], `sd_log_sd_y` 0.63, `log_nu` −187.57 [−345.59,
  −14.46], bulk/tail ESS >1000 for every variable except `log_nu` (549.65/571.22),
  R-hat 1.00 throughout.

Every number in the executed output is bit-identical to what the notebook's own
`solution` cells report.

## Visual claims cross-checked against actual output

- **`log_nu` trace (cell 23, `plot_trace_dist`):** confirmed. The `log_nu` trace panel
  shows dense, wide sweeping between roughly −372 and 0 for three chains (0, 1, 2),
  with a thin band pinned near the top of the range — the fourth, stuck chain, holding
  near `log_nu ≈ 3.4`. This matches 3.1's solution text exactly: "the three chains that
  did not get stuck... spread their draws almost evenly between about −372 and about 0
  ... the stuck chain, 3, stays near 3.4."
- **Posterior predictive plot (cell 41, `plot_participants`):** confirmed. Participants
  are ordered by sorted numeric subject ID (308, 309, 310, 330, 331, 332, 333, ...),
  so panel 1 of the 6×3 grid is participant 308 and panel 6 is participant 332. Both
  panels show a visibly wider, more asymmetric 50%/90% band than their neighbors, with
  the band's lower edge pulled down away from the observed points — consistent with
  3.7's solution claim that the stuck chain's low-trajectory draws "pull a few 50%
  bands downward and make them lopsided, most visibly for participants 308 and 332."
  Participant 332's high point near day 4 (~450ms) is also visible, matching the
  cross-reference to Notebook 9's Question 5.3.

## Mechanism claim: a genuine, verified finding

The implementation notes' central technical claim — that the posterior is improper in
`log_nu` (the joint log density is exactly constant below each participant's switch
point, with exactly zero gradient) and that floating-point underflow of `nu**2` to 0
near `log_nu ≈ -372.55` produces the NaN gradient that PyMC reports as a divergence —
is consistent with the executed diagnostics: 99.87% of the 1,488 divergent draws report
an infinite energy error (matching a NaN-gradient origin rather than a step-size
origin, which is what distinguished notebook 10's failure mode). The three-chain
`log_nu` trace sweeping the full −372 to 0 range with no return pressure, and a fourth
chain trapped where the Gaussian part vanishes, is exactly the signature of two
independent improper directions rather than one. This is a substantive, verified
finding, not speculation dressed up as fact.

## Self-work notebook

Independently re-verified with a standalone structural script (49 cells in both files;
0 mismatches beyond the expected: cell 0's Colab badge URL, and the 12
`solution`-tagged cells replaced with bare `# answer here` / `- answer here`
placeholders in the self-work file). The self-work notebook itself is unexecuted (no
stray outputs or execution counts), as for every self-work notebook (playbook §2).

## Conclusion

No corrections needed from execution — every numeric and visual claim checked out
against real, bit-identical output, including the one flagged reproducibility risk
(warm-cache PyTensor compilation), which resolved on the first attempt. This notebook
does what a second, differently-mechanistic failure-demonstration notebook should: a
genuinely different failure mode from notebook 10 (improper posterior / floating-point
edge, not a likelihood discontinuity), correctly diagnosed and honestly reported, with
the added twist that some diagnostics (R-hat/ESS on the non-stuck chains) look
deceptively clean. Proceeding to fresh-eyes review (Step 3b).
