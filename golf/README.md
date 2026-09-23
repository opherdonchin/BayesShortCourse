# Golf putting example

This directory turns the golf-putting case study from Gelman et al.'s *Bayesian Workflow* into a sequence of short PyMC notebooks. Each notebook is standalone and repeats the workflow for one model: prior predictive checking, fitting, computational diagnostics, posterior predictive criticism, and a decision to revise or stop.

## Recommended teaching path

1. `01_logistic_baseline.ipynb` — generic logistic baseline; revise toward mechanism.
2. `02_angle_geometry.ipynb` — geometry-only model; fit to the old data, then test without refitting on newer data.
3. `03_angle_and_distance.ipynb` — adds distance control; the literal Binomial observation model is too rigid for the huge aggregated counts.
4. `04_normal_discrepancy.ipynb` — adds model discrepancy; predictively adequate but uses a Normal approximation.

Those four notebooks are the main course spine. The remaining notebooks continue the model-expansion story:

5. `05_logit_discrepancy.ipynb` — exact Binomial with local logit errors; reject the discrepancy structure.
6. `06_proportional_discrepancy.ipynb` — local proportional downward errors; suggests revising fixed geometry.
7. `07_learn_distance_tolerance.ipynb` — estimate distance tolerance; no obvious predictive failure.
8. `08_learn_overshoot.ipynb` — estimate overshoot too; little predictive change, strong posterior dependence.

The book later explores simplified discrepancy models and PSIS-LOO model comparison. Those are intentionally omitted here because the short course emphasizes model building, checking, and revision rather than model selection.

## Data

- `data/berry_1996_putting.csv` — the classic 2–20 ft professional putting summary data used in Berry (1996).
- `data/broadie_2018_putting.csv` — the later, much larger summary dataset used by Broadie (2018).

Every notebook loads these files from the public raw URL of this repository, so it runs directly in Colab without relying on a local checkout.

## Sources

- Gelman et al. (2026), *Bayesian Workflow*, Ch. 25, “Model building and expansion: Golf putting.”
- PyMC example gallery, “Model building and expansion for golf putting.”
- Berry, D. A. (1996), *Statistics: A Bayesian Perspective*.
- Broadie, M. (2018), *Every Shot Counts*.
