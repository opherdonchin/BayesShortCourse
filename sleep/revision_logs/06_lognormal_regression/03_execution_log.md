# Execution log: notebook 06 — Lognormal regression

Author: orchestrator (Step 3a of `sleep/REVISION_PLAYBOOK.md`).

## Environment

`python3.12 -m venv` with `pymc==6.3.2`, `arviz-base==1.3.0`, `arviz-stats==1.3.2`,
`arviz-plots[matplotlib]==1.3.1`, `pandas==2.2.3`, plus `jupyter`/`nbclient`/`nbformat`/
`ipykernel`/`graphviz` (matches the notebook's own `%pip` cell plus the tooling needed
to execute it). Executed via:

```
jupyter nbconvert --to notebook --execute --inplace \
    --ExecutePreprocessor.kernel_name=nbenv \
    --ExecutePreprocessor.timeout=2400 \
    sleep/solved/06_lognormal_regression.ipynb
```

Exit code 0. 0 cell-execution errors (checked programmatically over all 80 cells, not
just the tail of the log).

## Diagnostics

- Mis-scaled ("bad") model: no sampling — prior predictive only, as intended (the
  point is that it's unusable, not that it should be fit).
- Corrected model, `pm.sample(draws=1000, tune=1500, chains=4, random_seed=RANDOM_SEED)`,
  **no `target_accept` override** (per playbook §3.3 — confirmed unnecessary):
  - Divergences: **0**
  - `b0`: mean 5.59, 90% HDI [5.54, 5.63], R-hat 1.00, ESS bulk 1964 / tail 1951
  - `b1`: mean 0.04, 90% HDI [0.03, 0.05], R-hat 1.00, ESS bulk 2015 / tail 1977
  - `sd_y`: mean 0.17, 90% HDI [0.15, 0.18], R-hat 1.00, ESS bulk 2456 / tail 2136
  - All comfortably clear AGENTS.md's screening thresholds.
- Power-scaling (`psense_summary`): `b0` 0.007/0.108, `b1` 0.006/0.111, `sd_y`
  0.005/0.123 — all far below the 0.05 threshold, `diagnosis` column all ✓.

## Cross-checks against the implementer's flagged "uncertain" items

(See `02_implementation_notes.md`'s "To check during execution" table.)

| Item | Predicted | Actual | Verdict |
|---|---|---|---|
| 1.6 (bad-model prior predictive) | median >10^100 ms, ~0.2% plausible | median 2.9e+107 ms, 0.2% | matches |
| 3.3 diagnostics | 0 divergences, R-hat 1.00, ESS >1000 | 0 divergences, R-hat 1.00, ESS 1950-2456 | matches |
| 4.1/4.4 `sd_y`≈0.17, `b1` HDI≈0.03-0.05 | as stated | `sd_y`=0.17, `b1` HDI [0.03,0.05] | matches exactly |
| 6.4 sensitivity | all far below 0.05, all ✓ | 0.005-0.123, all ✓ | matches |
| 5.6 ECDF verdict (flagged **least certain**) | "broadly consistent, no persistent tail displacement" | Visually inspected the executed plot (cell 65): observed ECDF tracks within the posterior-predictive ECDF band across the full range, no visible systematic tail displacement | **confirmed** — text stands as written, no correction needed |
| 2.8/2.9 prior-predictive band claims | day-0 ~20-350ms, day-7 to ~1s, mean line jumpy late-week | Visually inspected the executed plot (cell 34): 90% band reaches roughly 1000-1500ms by day 7, one panel shows a sharp mean-line spike around day 3, consistent with the "jumpy"/"very permissive late in the week" description | matches, close enough that no text change is needed |

Also independently spot-checked (not flagged by the implementer, checked anyway):
cell 53 (4.3, mean-vs-predictive-uncertainty question) and cell 62 (5.3, participant-level
PPC verdict) against the population `mean_rt` plot (cell 51) and posterior-predictive
participant panels (cell 58) — both plots visually confirm the text (tight `mean_rt`
band with most raw points outside it; several participants sit systematically above or
below their posterior-predictive band, matching the "whole participants sit
systematically above or below the bands" claim).

## Self-work notebook

`sleep/06_lognormal_regression.ipynb`: valid JSON, 80 cells (matches solved), all
outputs cleared. Re-verified independently of the implementer's own script: diffed
non-`solution` cell sources against the solved notebook — identical except cell 0's
Colab badge URL, as expected.

## Conclusion

No corrections needed from execution. Proceeding to fresh-eyes review (Step 3b) before
commit.
