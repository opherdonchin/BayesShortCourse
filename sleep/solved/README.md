# Sleep deprivation solved notebooks

These are the solved reference notebooks for the Sleep Deprivation example in the Short Bayes Course. They follow the model-building sequence from the sleep-study chapter while using Bambi with the course-wide pinned PyMC/ArviZ environment.

The source study's adaptation/training days are removed and original day 2 is recoded as `Days = 0`, the baseline measurement before sleep deprivation begins. Every Bambi model sets `center_predictors=False`, so the `Intercept` prior is directly a prior on baseline reaction time. The chapter's separate centered-predictor model is intentionally omitted.

Each notebook is organized around numbered scientific questions (`1.1`, `1.2`, … in notebook 1; `2.1`, `2.2`, … in notebook 2). Setup and data loading come before the numbered questions. The raw data trajectory plot appears only in notebook 1; later notebooks do not repeat it.

## Sequence

1. `01_linear_baseline.ipynb` — Gaussian population regression, prior predictive implications, posterior effect, predictive adequacy, and prior sensitivity.
2. `02_informative_slope_prior.ipynb` — deliberately tight slope prior and how strongly the data can overcome it.
3. `03_heavy_tailed_slope_prior.ipynb` — heavy-tailed slope prior and the consequences of prior tail behavior.
4. `04_varying_intercept.ipynb` — participant baseline differences and partial pooling.
5. `05_varying_intercept_slope.ipynb` — participant baseline and deprivation-response differences.
6. `06_lognormal_regression.ipynb` — why Gaussian-scale priors fail on a lognormal model and how the likelihood changes interpretation.
7. `07_lognormal_varying_intercept_slope.ipynb` — hierarchical lognormal model.
8. `08_lognormal_distributional.ipynb` — participant variation in residual scale.
9. `09_exgaussian_distributional.ipynb` — informed-prior ex-Gaussian distributional model.
10. `10_exgaussian_default_priors.ipynb` — the same ex-Gaussian structure with Bambi defaults.
11. `11_exgaussian_flat_priors.ipynb` — deliberately flat common/distributional priors.
12. `12_robust_student_t_and_loo.ipynb` — Gaussian versus Student-t likelihoods using LOO predictive checks and PSIS-LOO comparison.

## Bambi differences from the book

The book's `brms` varying-intercept/varying-slope models use an LKJ prior for correlations among group-specific coefficients. Bambi 0.21 represents these group-specific terms with independent hierarchical priors, so `(1 + Days | Subject)` reproduces varying intercepts and slopes but not the intercept–slope correlation parameter.

Bambi's built-in ex-Gaussian follows PyMC's `mu`, `sigma`, `nu` parameterization. Its expected response is `mu + nu`, so notebooks 9–11 preserve the book's model-building idea while using Bambi's native parameter meanings.

## Validation status

The notebook JSON and Python syntax have been checked. Full top-to-bottom execution should still be performed in a fresh Colab runtime before treating the saved outputs as final, consistent with `AGENTS.md`.
