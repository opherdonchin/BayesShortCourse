# Repository agent instructions

This repository contains teaching materials for a short practical course in Bayesian analysis. Preserve the pedagogical sequence, keep the statistical model visible, and prefer clear, idiomatic PyMC/ArviZ workflows over custom implementations.

## PyMC / ArviZ skills

Before editing PyMC, PyTensor, ArviZ, prior-predictive, posterior-predictive, diagnostic, or other Bayesian-analysis code, load and follow the relevant skills from the PyMC Labs `pymc-modeling` skills repository:

- https://github.com/pymc-labs/pymc-modeling
- `skills/pymc-modeling` for model specification, inference, and prediction
- `skills/prior-elicitation` for prior choice and prior predictive checks
- `skills/arviz-diagnostics` for diagnostics and predictive checks
- `skills/pytensor-workflows` when PyTensor internals, shapes, graphs, or custom Ops are involved

If these skills are not already available to the agent, install them before doing the relevant work. A robust approach is to clone `pymc-labs/pymc-modeling` to a temporary/local checkout and, from that checkout, run:

```bash
npx skills add .
```

Alternatively, copy the relevant complete skill directories into the agent's supported skills location. Keep each skill directory intact, including its references and scripts. Do not vendor or commit the cloned skills repository into this course repository unless explicitly asked.

Prefer current native PyMC and ArviZ functionality documented by those skills over hand-written substitutes.

## Google Colab environment

- Jupyter notebooks are intended primarily for Google Colab.
- Target the current Colab Python/PyMC/ArviZ environment.
- Avoid pinning package versions. Use the current Colab versions unless a demonstrated incompatibility requires otherwise.
- If a version pin is genuinely necessary, keep it as narrow as possible and explain the reason in the notebook.
- Do not replace a working Colab environment merely to match versions used elsewhere.
- Notebooks should run top-to-bottom from a fresh Colab runtime without relying on hidden state or execution out of order.
- Keep setup and imports near the beginning of the notebook.
- Use a fixed random seed for stochastic examples unless randomness itself is part of the lesson.

## Notebook outputs

- Commit notebooks with their executed outputs intact by default.
- Outputs should correspond to the committed code and should be regenerated after substantive changes.
- The main exception is a notebook intentionally designed for students to work through. Such notebooks may have selected or all outputs cleared when that is pedagogically useful.
- If outputs are intentionally omitted, make that intention clear in the notebook or accompanying README rather than treating cleared outputs as the repository default.
- Avoid notebook churn caused only by irrelevant metadata changes or gratuitous reformatting.

## Colab notebook math

- In Markdown cells, use `$...$` for inline math and `$$...$$` for display math.
- Do not use `\(...\)` or `\[...\]` as math delimiters in notebooks.
- Apply this rule only to Markdown/text math; do not alter unrelated dollar signs or backslashes in code cells.

## Bayesian workflow conventions

Teaching notebooks should normally make the Bayesian workflow explicit:

1. formulate the scientific question and generative model;
2. make prior assumptions explicit;
3. inspect prior implications with prior predictive simulation;
4. fit the model;
5. inspect sampling diagnostics before interpreting the posterior;
6. examine scientifically meaningful posterior quantities;
7. use posterior predictive simulation/checks to assess what the fitted model predicts;
8. revise or expand the model when the checks expose an important mismatch.

For MCMC models, inspect at least divergences, R-hat, and effective sample size before substantive interpretation.

Prefer scientifically meaningful `pm.Deterministic` quantities when a derived quantity is part of the inferential question. Distinguish posterior uncertainty about parameters or average effects from posterior predictive variation for future or individual observations.

Use 90% HDIs in course material unless the notebook has a substantive reason to use a different interval.

## Teaching and code style

- Prefer the shortest clear native PyMC/ArviZ implementation that exposes the statistical idea.
- Do not hand-code summaries, predictive simulations, diagnostics, or plots when a current native PyMC/ArviZ operation expresses the same idea clearly.
- Keep the statistical model visible in the notebook; do not hide the central teaching content behind helper functions.
- Favor code students can read, run, and modify interactively.
- Explain parameters in terms of their scientific meaning, not only their computational role.
- Keep Markdown concise and pedagogical rather than documentation-heavy.
- Preserve a clear narrative from scientific question to model to inference to predictive checking.

## Repository hygiene

- Do not alter observed data merely to improve model fit.
- Clearly identify synthetic or simulated data as such.
- When modifying one notebook in a sequence, check whether the same convention or fix should be propagated to related notebooks.
- Do not rename, reorganize, or substantially restructure teaching notebooks without a substantive reason.
- Preserve Colab badges and working repository-relative paths.
