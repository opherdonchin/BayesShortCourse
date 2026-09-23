#import "course.typ": *
#import "diagrams/bioassay_model.typ": bioassay-model-graph

#show: short-course-theme

#course-title-slide()

== Today: from worked example to independent analysis

== Outline <touying:hidden>

#course-outline()

= A short worked example
Dose response

// Bioassay data: Racine-Poon et al. (1986), as in bioassay/*.ipynb.
#let bioassay = (
  dose: (-0.86, -0.30, -0.05, 0.73),
  animals: (5, 5, 5, 5),
  deaths: (0, 1, 3, 5),
)

#let two-decimals(x) = {
  let s = str(x)
  if s.split(".").last().len() == 1 { s + "0" } else { s }
}

#let bioassay-table = table(
  columns: 3,
  align: (right, center, center),
  stroke: none,
  inset: (x: 0.6em, y: 0.4em),
  table.hline(),
  table.header[*log dose*][*rats*][*deaths*],
  table.hline(stroke: 0.5pt),
  ..bioassay.dose.zip(bioassay.animals, bioassay.deaths)
    .map(((x, n, y)) => (two-decimals(x), str(n), str(y)))
    .flatten(),
  table.hline(),
)

== Four doses, twenty animals

A toxin is given to rats at four doses, five rats per dose.

#grid(
  columns: (auto, 1fr),
  column-gutter: 1.5em,
  align: horizon,
  bioassay-table,
  // Saved by section "## 1. Data" of bioassay/bioassay_lean.ipynb; the second
  // version adds the 50% line that defines LD50.
  alternatives(
    image("figures/bioassay_lean_data.svg", height: 8.5cm),
    image("figures/bioassay_lean_data_2.svg", height: 8.5cm),
  ),
)


#align(bottom + right, text(size: 12pt, fill: gray)[
  Data: Racine-Poon et al. (1986); Gelman & Vehtari, _Bayesian Workflow_, §3.5
])

== A generative model for mortality

// Equations, graph, and code are three views of the same model; reveal them
// in that order. The code is a bare-bones version of the model cell in
// bioassay/bioassay_lean.ipynb.
#grid(
  columns: (1fr, auto),
  column-gutter: 1.5em,
  align: horizon,
  $
    y_j & tilde "Binomial"(n_j, p_j) \
    "logit"(p_j) & = alpha + beta x_j \
    alpha & tilde "Normal"(0, 5) \
    beta & tilde "HalfNormal"(5)
  $,
  uncover("2-", bioassay-model-graph),
)

#uncover("3-", block(
  width: 100%,
  fill: luma(242),
  inset: 0.6em,
  radius: 4pt,
  text(size: 18pt)[```python
  with pm.Model() as model:
      alpha = pm.Normal("alpha", mu=0, sigma=5)
      beta = pm.HalfNormal("beta", sigma=5)
      logit_p = alpha + beta * dose
      pm.Binomial("deaths", n=n, logit_p=logit_p, observed=deaths)
  ```],
))

== Priors: what could we have seen?

Draw $alpha, beta$ from the priors #sym.arrow simulate deaths at each dose
#sym.arrow look, _before_ fitting.

#grid(
  columns: (1.4fr, 1fr),
  column-gutter: 1.2em,
  align: horizon,
  // Saved by section "## 3. Prior predictive" of bioassay/bioassay_lean.ipynb.
  image("figures/bioassay_lean_prior-predictive.svg", width: 100%),
  [
    Prior predictive data should not

    #uncover("2-")[- violate common sense]
    #uncover("3-")[- make our data highly unlikely]
    #uncover("4-")[- confine the model to our data]
  ],
)

#speaker-note[
  - Common sense: simulated deaths rise with dose, but the 90% band covers
    0--5 at every dose, so even the lowest dose could kill every rat. Would
    anyone design a study that way?
  - Our data: every observed count lies inside the 90% band.
  - Not confined: the bands span the whole 0--5 range, so the model could
    have accommodated very different results.
]

== Sampling and diagnostics

// In this slide, we can show the code that calls the sampler and the resultiing trace and diagnostics. The code is a bare-bones version of the sampling cell in bioassay/bioassay_lean.ipynb. In addition, we should include a bit of text saying that 'fitting the model' means sampling the posterior distribution. This isn't something to dwell on in the slides or to try to explain in any depth. But the fact should be out there. We can relate this to the frequentist bootstr

== Posterior: which dose-response curves remain plausible?

== LD50: the quantity we actually care about

== Posterior predictive: can the model reproduce the experiment?

The same plot as the prior predictive, but the simulated deaths now come from
the posterior.

// Saved by section "## 6. Posterior predictive" of bioassay/bioassay_lean.ipynb.
#align(center, image("figures/bioassay_lean_posterior-predictive.svg", height: 75%))

= The Bayesian toolkit

== Probability distributions as model components

== Posterior draws as a computational object

== Prior predictive, posterior, and posterior predictive simulation

== Diagnostics before interpretation

= The Bayesian workflow

== Build → simulate → fit → check → revise

== Model checking: where does the model fail?

== Model revision is part of the analysis

= Working through the workflow: golf putting

== Model 1: a logistic curve for putting success

== Model 2: geometry of aiming error

== A model can fit and still predict badly

== New data: a test we did not tune for

== Model 3: angle error plus distance error

== When a huge dataset exposes a small model failure

== Model 4: allow the model to be imperfect

== A better fit is not necessarily the end

== Where we stop the golf workflow today

= Preparing for active learning: sleep deprivation

== Repeated measurements create a multilevel problem

== Average effects and individual trajectories

== Your workflow for the sleep data
