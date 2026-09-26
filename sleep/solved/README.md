# Sleep deprivation solved notebooks

These are the solved reference notebooks for the Sleep Deprivation example in the Short Bayes Course. They follow the model-building sequence from the sleep-study chapter using native PyMC and modular ArviZ, in the same style as `golf/`: an explicit `pm.Model`, `pm.Data` for predictors, `pm.Deterministic` for scientifically meaningful quantities, and `pm.sample_prior_predictive`/`pm.sample_posterior_predictive` for the predictive checks.

The source study's adaptation/training days are removed and original day 2 is recoded as `Days = 0`, the baseline measurement before sleep deprivation begins. `Days` is never centered, so the intercept prior (`b0`, or `mu_b0` in a hierarchical model) is directly a prior on baseline reaction time. The chapter's separate centered-predictor model is intentionally omitted.

Each notebook is organized as a two-level, tagged Q&A worksheet: `## N. <Stage>` workflow sections (Model, Prior predictive, Fit, Diagnose, Interpret, Posterior predictive, …), each containing several `### N.M <question or task>` cells, question numbering restarting at 1 in every notebook. Setup and data loading come before the numbered sections. The self-work notebook in `sleep/` is generated mechanically from this one by replacing every `solution`-tagged cell with a placeholder (`- answer here` / `# answer here`) — see `sleep/REVISION_PLAYBOOK.md` for the full tag scheme and process. The raw data trajectory plot appears only in notebook 1 and is also saved as the slide figure for the sleep-deprivation-data slide; later notebooks do not repeat it.

## Plotting grammar

Every prior and posterior predictive check uses one panel per participant (`plot_participants`), so the checks are on the observable data scale and use a continuous day axis with each participant's own observations overlaid — the same colours, HDI bands, and legend as `golf/`: an orange mean line, blue 50%/90% HDI bands, black observed points. Population-level trends (a single line, no faceting) use `plot_population` where a notebook actually needs it; it is defined only in notebooks that call it, not carried forward unused. Plotting helpers are defined once per notebook in a "Plotting helper" cell and reused throughout.

Hierarchical notebooks (4 onward) use `mu_y` for the per-observation location/linear-predictor parameter (fixed effects **and** participant-specific deviations together — there is no separate "typical participant" `population_mu`, unless a specific notebook's question calls for one). It is computed once during sampling — there is no post-hoc "predict" step.

The expected reaction time is a derived quantity whose formula depends on the likelihood. Where the link is the identity (Gaussian / Student-t), `mu_y` already *is* the expected reaction time. Otherwise it is exposed as its own explicit `pm.Deterministic`, `mean_rt`:

- Gaussian / Student-t: `mu_y`
- lognormal: `exp(mu_y + sd_y**2 / 2)` (`mean_rt`)
- ex-Gaussian: `mu_y + nu` (`mean_rt`)

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

The book's varying-intercept/varying-slope models use an LKJ prior for correlations among group-specific coefficients (notebooks 5, 7–12 here). We use independent hierarchical priors for participant intercepts and slopes instead — a deliberate simplification for a short course, not a software limitation — so these notebooks reproduce the varying-intercept/varying-slope structure but not the intercept–slope correlation parameter. Centered or non-centered parameterizations are chosen according to the notebook's teaching purpose and verified with sampling diagnostics rather than imposed as a course-wide rule.

`pm.ExGaussian(mu, sigma, nu)` matches the book's parameterization directly. Its expected response is `mu + nu`.

Prior sensitivity (power-scaling, notebooks 1, 2, 3, 6, 7) uses `pm.compute_log_likelihood` together with PyMC's own internal `compute_log_density(..., kind="prior")` — the same function `pm.compute_log_likelihood` itself calls with `kind="likelihood"`; there is no separate public `kind="prior"` wrapper yet.

## Validation status

Notebooks 1–5 were executed top to bottom against the pinned stack (`pandas==2.2.3`, `pymc==6.3.2`, `arviz-base==1.3.0`, `arviz-stats==1.3.2`, `arviz-plots==1.3.1`) — most recently under Python 3.12 as part of the notebook-revision effort in `sleep/REVISION_PLAYBOOK.md` — and saved with their outputs. Notebooks 6–12 are being revised to the same style (see `sleep/REVISION_PLAYBOOK.md`); this note will be updated once that pass is complete. Re-run in a fresh Colab runtime before a live lecture, consistent with `AGENTS.md`.
