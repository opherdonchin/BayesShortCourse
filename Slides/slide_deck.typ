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
  // Saved by section "## 1. Data" of bioassay/bioassay.ipynb; the second
  // version adds the 50% line that defines LD50.
  alternatives(
    image("figures/bioassay_data.svg", height: 8.5cm),
    image("figures/bioassay_data_2.svg", height: 8.5cm),
  ),
)


#align(bottom + right, text(size: 12pt, fill: gray)[
  Data: Racine-Poon et al. (1986); Gelman & Vehtari, _Bayesian Workflow_, §3.5
])

== A generative model for mortality

// Equations, graph, and code are three views of the same model; reveal them
// in that order. The code is a bare-bones version of the model cell in
// bioassay/bioassay.ipynb.
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

#uncover("3-")[
```python
with pm.Model() as model:
    alpha = pm.Normal("alpha", mu=0, sigma=5)
    beta = pm.HalfNormal("beta", sigma=5)
    logit_p = alpha + beta * dose
    pm.Binomial("deaths", n=n, logit_p=logit_p, observed=deaths)
```
]

== Priors: what could we have seen?

#grid(
  columns: (1.4fr, 1fr),
  column-gutter: 1.2em,
  align: horizon,
  // Saved by section "## 3. Prior predictive" of bioassay/bioassay.ipynb.
  image("figures/bioassay_prior-predictive.svg", width: 100%),
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
  - Not confined: the band spans the whole 0--5 range, so the model could
    have accommodated very different results.
]

== Sampling and diagnostics

Fitting the model means drawing samples from the posterior distribution.

```python
with model:
    idata = pm.sample(draws=1000, chains=4)
```

#uncover("2-", grid(
  columns: (auto, 1fr),
  column-gutter: 1.2em,
  align: horizon,
  // Saved by section "## 4. Fit and diagnose" of bioassay/bioassay.ipynb.
  image("figures/bioassay_fit-and-diagnose.svg", height: 6.5cm),
  // Values from the notebook's azs.summary of alpha and beta.
  [
    Check before interpreting:
    - 0 divergences
    - $hat(R) = 1.00$
    - ESS > 1,300 of 4,000 draws
  ],
))

#speaker-note[
  Like a bootstrap, the result is a cloud of draws rather than a single
  estimate, and every summary is computed from that cloud. The bootstrap
  resamples the data; MCMC samples parameter values from the posterior.
]

== Posterior: which dose-response curves remain plausible?

The bands show uncertainty about the mean number of deaths.

// Saved by section "## 5. Posterior dose-response fit" of
// bioassay/bioassay.ipynb; the second figure is the same display under
// the prior.
#alternatives(
  align(center, image("figures/bioassay_posterior-dose-response-fit.svg", height: 9.5cm)),
  grid(
    columns: (1fr, 1fr),
    column-gutter: 1em,
    align(center)[
      *Prior*
      #image("figures/bioassay_posterior-dose-response-fit_2.svg", width: 100%)
    ],
    align(center)[
      *Posterior*
      #image("figures/bioassay_posterior-dose-response-fit.svg", width: 100%)
    ],
  ),
)

== LD50: the quantity we actually care about

#grid(
  columns: (1.2fr, 1fr),
  column-gutter: 1.2em,
  align: horizon,
  [
    - Any quantity can be computed from the parameters:
      - $"LD50" = -alpha \/ beta$
        - Once for every posterior draw.
    #uncover("2-")[- So every quantity comes with its own uncertainty.]
    #uncover("3-")[- Here _how well_ we know LD50 matters as much as its value.]
  ],
  [
    // Saved by section "## 6. LD50" of bioassay/bioassay.ipynb.
    #image("figures/bioassay_ld50.svg", width: 100%)
    // Values from the notebook's azs.summary of LD50_mg_ml.
    #align(center, text(size: 18pt)[
      mean 930 mg/ml \
      90% HDI 716--1,119 mg/ml
    ])
  ],
)

#speaker-note[
  Racine-Poon et al. (1986) cite a Swiss poison regulation that sorts toxins
  into hazard categories by LD50. The whole posterior falls inside one category
  (Bayesian Workflow, Fig. 3.2), so no further experiment is needed. A wider
  posterior that straddled a boundary would call for more data.
]

== Posterior predictive: can the model reproduce the experiment?

#grid(
  columns: (1.15fr, 1fr),
  column-gutter: 1.2em,
  align: horizon,
  // Saved by section "## 7. Posterior predictive" of bioassay/bioassay.ipynb.
  image("figures/bioassay_posterior-predictive.svg", width: 100%),
  [
    This is what the model predicts we could have seen, _after_ fitting.
    #uncover("2-")[- A workflow check meant to be done before looking at the posterior.]
    #uncover("3-")[- Workflow is not lockstep: going back to check is always fine.]
    #uncover("4-")[- We understand data better than we understand parameters.]
  ],
)

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
