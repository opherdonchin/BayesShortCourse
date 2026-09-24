# Sleep deprivation solved notebooks

These are the solved reference notebooks for the Sleep Deprivation example in the Short Bayes Course. They follow the model-building sequence from the sleep-study chapter using native PyMC and modular ArviZ, in the same style as `golf/`: an explicit `pm.Model`, `pm.Data` for predictors, `pm.Deterministic` for scientifically meaningful quantities, and `pm.sample_prior_predictive`/`pm.sample_posterior_predictive` for the predictive checks.

The source study's adaptation/training days are removed and original day 2 is recoded as `Days = 0`, the baseline measurement before sleep deprivation begins. `Days` is never centered, so the `intercept` prior is directly a prior on baseline reaction time. The chapter's separate centered-predictor model is intentionally omitted.

Each notebook is organized around numbered scientific questions (`1.1`, `1.2`, … in notebook 1; `2.1`, `2.2`, … in notebook 2). Setup and data loading come before the numbered questions. The raw data trajectory plot appears only in notebook 1 and is also saved as the slide figure for the sleep-deprivation-data slide; later notebooks do not repeat it.

## Plotting grammar

Every prior and posterior predictive check uses one panel per participant (`plot_participants`), so the checks are on the observable data scale and use a continuous day axis with each participant's own observations overlaid — the same colours, HDI bands, and legend as `golf/`: an orange mean line, blue 50%/90% HDI bands, black observed points. Population-level trends (a single line, no faceting) use `plot_population`. Both helpers are defined once per notebook in a "Plotting helpers" cell and reused throughout.

Hierarchical notebooks (4 onward) define two `pm.Deterministic`s for the mean structure: `population_mu`/`population_mean_rt` (fixed effects only, the "typical participant") and `mu`/`mean_rt` (includes participant-specific deviations). Both are computed once during sampling — there is no post-hoc "predict" step.

The expected reaction time is a derived quantity whose formula depends on the likelihood, always exposed as an explicit `pm.Deterministic`:

- Gaussian / Student-t: `mu`
- lognormal: `exp(mu + sigma**2 / 2)` (`mean_rt`)
- ex-Gaussian: `mu + nu` (`mean_rt`)

## Sequence

1. `01_linear_baseline.ipynb` — Gaussian population regression, prior predictive implications, posterior effect, predictive adequacy, and prior sensitivity.
2. `02_informative_slope_prior.ipynb` — deliberately tight slope prior and how strongly the data can overcome it.
3. `03_heavy_tailed_slope_prior.ipynb` — heavy-tailed slope prior and the consequences of prior tail behavior.
4. `04_varying_intercept.ipynb` — participant baseline differences and partial pooling.
5. `05_varying_intercept_slope.ipynb` — participant baseline and deprivation-response differences.
6. `06_lognormal_regression.ipynb` — why Gaussian-scale priors fail on a lognormal model and how the likelihood changes interpretation.
7. `07_lognormal_varying_intercept_slope.ipynb` — hierarchical lognormal model.
8. `08_lognormal_distributional.ipynb` — participant variation in residual scale.
9. `09_exgaussian_distributional.ipynb` — informed-prior ex-Gaussian distributional model, with priors chosen in milliseconds rather than guessed on the log-link scale.
10. `10_exgaussian_default_priors.ipynb` — the same ex-Gaussian structure, but with naive priors that ignore the log link (no software "defaults" exist for a hand-written PyMC model, so this notebook instead reuses the unscaled priors that made an earlier draft of notebook 9 fail to sample cleanly, now as a deliberate demonstration).
11. `11_exgaussian_flat_priors.ipynb` — deliberately flat common-effect priors, with the same hierarchical priors as notebook 9.
12. `12_robust_student_t_and_loo.ipynb` — Gaussian versus Student-t likelihoods using LOO predictive checks and PSIS-LOO comparison.

## Modeling notes

The book's varying-intercept/varying-slope models use an LKJ prior for correlations among group-specific coefficients (notebooks 5, 7–12 here). We use independent, non-centered hierarchical priors for participant intercepts and slopes instead — a deliberate simplification for a short course, not a software limitation — so these notebooks reproduce the varying-intercept/varying-slope structure but not the intercept–slope correlation parameter.

`pm.ExGaussian(mu, sigma, nu)` matches the book's parameterization directly. Its expected response is `mu + nu`.

Prior sensitivity (power-scaling, notebooks 1, 2, 3, 6, 7) uses `pm.compute_log_likelihood` together with PyMC's own internal `compute_log_density(..., kind="prior")` — the same function `pm.compute_log_likelihood` itself calls with `kind="likelihood"`; there is no separate public `kind="prior"` wrapper yet.

## Validation status

All 12 notebooks were executed top to bottom against the pinned stack (`pandas==2.2.3`, `pymc==6.3.2`, `arviz-base==1.3.0`, `arviz-stats==1.3.2`, `arviz-plots==1.3.1`) in a local environment matching the notebooks' own `%pip` cell, and saved with their outputs. Re-run in a fresh Colab runtime before a live lecture, consistent with `AGENTS.md`.
