#import "course.typ": *
#import "diagrams/bioassay_model.typ": bioassay-model-graph
#import "diagrams/bayesian_workflow.typ": workflow-diagram
#import "diagrams/golf_geometry.typ": golf-geometry

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

// Logos and screenshots in images/: logos from each project's GitHub
// repository; screenshots of the linked sites; covers from the authors' book
// pages.
#let web(url) = text(size: 14pt, fill: gray, url)

#let tool(logo, role, url) = align(center, stack(
  spacing: 0.4em,
  box(height: 2.2cm, logo),
  text(size: 20pt, role),
  web(url),
))

== Four libraries, one workflow

#grid(
  columns: (1fr, 1fr),
  row-gutter: 1.2em,
  column-gutter: 1.5em,
  tool(image("images/logo_pymc.svg", height: 100%), [Write the model, sample the posterior], "pymc.io"),
  tool(image("images/logo_arviz.png", height: 100%), [Diagnose, summarize, and plot], "python.arviz.org"),
  tool(image("images/logo_preliz.png", height: 100%), [Choose and check priors], "preliz.readthedocs.io"),
  tool(image("images/logo_bambi.png", height: 100%), [Regression models from a formula], "bambinos.github.io/bambi"),
)

== Bambi: the same model as one formula

// A bare-bones version of section "## 8. Bambi" of bioassay/bioassay.ipynb.
#grid(
  columns: (1.8fr, 1fr),
  column-gutter: 0.8em,
  align: horizon,
  [
    #show raw.where(block: true): set text(size: 14pt)
    ```python
    priors = {
        "Intercept": bmb.Prior("Normal", mu=0, sigma=5),
        "dose": bmb.Prior("HalfNormal", sigma=5),
    }
    model = bmb.Model("p(deaths, n) ~ dose", data,
                      family="binomial", priors=priors)
    idata = model.fit()
    bmb.interpret.plot_predictions(model, idata, "dose")
    ```
  ],
  // Saved by section "## 8. Bambi" of bioassay/bioassay.ipynb.
  uncover("2-", image("figures/bioassay_bambi.svg", width: 100%)),
)

#speaker-note[
  Same priors, same posterior as the PyMC model: Bambi writes the PyMC model
  for us. Its plot evaluates the fitted curve on a fine grid of doses.
]

== Coding assistants can learn current PyMC practice

#grid(
  columns: (1.5fr, 1fr),
  column-gutter: 1.2em,
  align: horizon,
  [
    #image("images/site_pymc-modeling.png", width: 100%)
    #align(center, web("github.com/pymc-labs/pymc-modeling"))
  ],
  [
    Skill files from PyMC Labs that teach AI coding assistants current PyMC
    and ArviZ practice.

    We used them to build this course's notebooks.
  ],
)

== Where to ask, hire, and listen

#let place(shot, role, url) = align(center, stack(
  spacing: 0.5em,
  image(shot, width: 100%),
  text(size: 20pt, role),
  web(url),
))

#grid(
  columns: (1fr, 1fr, 1fr),
  column-gutter: 1em,
  place("images/site_discourse.png", [*Ask:* PyMC Discourse], "discourse.pymc.io"),
  place("images/site_pymc-labs.png", [*Hire:* PyMC Labs], "pymc-labs.com"),
  place("images/site_lbs.png", [*Listen:* Learning Bayesian Statistics], "learnbayesstats.com"),
)

== Books worth reading next

#let book(cover, authors, title) = align(center, stack(
  spacing: 0.4em,
  box(height: 6.5cm, image(cover, height: 100%)),
  text(size: 15pt, authors),
  text(size: 15pt, style: "italic", title),
))

#grid(
  columns: 5,
  column-gutter: 0.8em,
  book("images/cover_rethinking.png", [McElreath], [Statistical Rethinking]),
  book("images/cover_ros.png", [Gelman, Hill & Vehtari], [Regression and Other Stories]),
  book("images/cover_active-statistics.jpg", [Gelman & Vehtari], [Active Statistics]),
  book("images/cover_bap.png", [Martin], [Bayesian Analysis with Python]),
  book("images/cover_bayesian-workflow.png", [Gelman, Vehtari et al.], [Bayesian Workflow]),
)

= The Bayesian workflow

== The workflow starts with a four-step loop

#alternatives(
  workflow-diagram(spine-stage: 1),
  workflow-diagram(spine-stage: 2),
  workflow-diagram(spine-stage: 3),
  workflow-diagram(spine-stage: 4),
  workflow-diagram(spine-stage: 5),
)

#uncover("5-")[
  #align(center)[
    Even at this level, we allow for

    #text(size: 0.9em)[*different interpretations* · *iterative experimental design*]
  ]
]

#speaker-note[
  - Reveal the spine one step at a time: data, model, fit, interpretation.
  - The return arrows matter: interpretation can change the model, while a new
    interpretation or experiment can change what data we collect.
  - End by naming the two kinds of iteration without expanding them yet.
]

== Checks make each transition accountable

#alternatives(
  workflow-diagram(spine-stage: 5, reserve-checks: true),
  workflow-diagram(spine-stage: 5, check-stage: 1, reserve-checks: true),
  workflow-diagram(spine-stage: 5, check-stage: 2, reserve-checks: true),
  workflow-diagram(spine-stage: 5, check-stage: 3, reserve-checks: true),
)

#set text(size: 0.82em)

#grid(
  columns: 2,
  column-gutter: 1.2em,
  row-gutter: 0.35em,
  [*Validation* belongs at each step], [],
  uncover("2-")[*Prior predictive*], uncover("2-")[tests model coherence],
  uncover("3-")[*Diagnostics*], uncover("3-")[test whether fitting converged],
  uncover("4-")[*Posterior predictive*], uncover("4-")[tests fit to the observed data],
)

#speaker-note[
  - Keep the spine visible while adding one check at a time.
  - Prior predictive: can the assumptions generate plausible data before we fit?
  - Diagnostics: did the fitting algorithm explore the posterior reliably?
  - Posterior predictive: can the fitted model reproduce relevant features of
    what we observed?
]

== A failed check tells us where to return

#alternatives(
  workflow-diagram(spine-stage: 5, check-stage: 3),
  workflow-diagram(spine-stage: 5, check-stage: 3, repair-stage: 1),
  workflow-diagram(spine-stage: 5, check-stage: 3, repair-stage: 2),
  workflow-diagram(spine-stage: 5, check-stage: 3, repair-stage: 3),
)

#set text(size: 0.78em)

#grid(
  columns: (1.15fr, 2.85fr),
  column-gutter: 1.0em,
  row-gutter: 0.28em,
  [*A failed check*], [means something must change],
  uncover("2-")[*Prior predictive*], uncover("2-")[revisit assumptions about the model or data],
  uncover("3-")[*Diagnostics*], uncover("3-")[revisit the model or the computation],
  uncover("4-")[*Posterior predictive*], uncover("4-")[reassess how the model represents the data],
)

#speaker-note[
  - A failed check is useful information, not a reason to hide the check.
  - Prior predictive failures send us back to assumptions and sometimes to our
    understanding of the measurement process.
  - Diagnostic failures may be computational, but often reveal difficult model
    geometry.
  - Posterior predictive failures are model criticism: identify the mismatch
    that matters scientifically before expanding the model.
]

== Model comparison asks which useful story predicts best

#let comparison-box(label, strong: false) = block(
  width: 100%,
  inset: (x: 0.55em, y: 0.45em),
  radius: 5pt,
  fill: if strong { rgb("#eb811b").lighten(82%) } else { rgb("#4f7d8a").lighten(88%) },
  stroke: 1pt + if strong { rgb("#eb811b") } else { rgb("#4f7d8a") },
  align(center, text(size: 15pt, weight: "semibold", label)),
)

#let loo-table = table(
  columns: (1.25fr, 0.9fr, 0.65fr, 0.8fr),
  align: (left, right, right, right),
  inset: (x: 0.38em, y: 0.32em),
  stroke: none,
  fill: (x, y) => if y == 3 { rgb("#eb811b").lighten(88%) } else { none },
  table.hline(stroke: 1pt),
  table.header[*Model*][*LOO*][*SE*][*$Delta$LOO*],
  table.hline(stroke: 0.5pt),
  [Model 1], [-124.8], [4.5], [13.0],
  [Model 2], [-112.4], [0.3], [0.6],
  [Model 3], [*-111.8*], [--], [*0.0*],
  table.hline(stroke: 1pt),
)

#grid(
  columns: (1.15fr, auto, 1.15fr, auto, 2.25fr),
  column-gutter: 0.55em,
  align: horizon,
  stack(
    spacing: 0.45em,
    comparison-box([Plausible model 1]),
    comparison-box([Plausible model 2]),
    comparison-box([Plausible model 3]),
  ),
  text(size: 26pt, fill: rgb("#eb811b"))[$arrow.r$],
  comparison-box([Model comparison], strong: true),
  text(size: 26pt, fill: rgb("#eb811b"))[$arrow.r$],
  align(center, stack(
    spacing: 0.4em,
    text(size: 15pt, weight: "semibold")[Leave-one-out cross-validation],
    loo-table,
    text(size: 11pt, fill: gray)[illustrative values; larger LOO is better],
  )),
)

#set text(size: 0.72em)
#grid(
  columns: (1fr, 1fr),
  column-gutter: 1.2em,
  row-gutter: 0.25em,
  [The workflow can lead to several *plausible models* with different interpretations.],
  [Model comparison is an essential tool in Bayesian data analysis.],
  [It is also a useful way to think about frequentist “null models.”],
  [*All models are wrong; some models are informative.*],
)

#speaker-note[
  The workflow rarely hands us one uniquely correct model. It often produces
  several scientifically plausible stories, and leave-one-out comparison asks
  how well each story predicts unseen observations. The uncertainty in the
  difference matters: a tiny difference relative to its standard error is not
  a decisive ranking. A frequentist null model can be treated as one more
  substantive competitor rather than as a privileged default.
]

= Working through the workflow: golf putting

== Two putting datasets let us fit, then genuinely predict

#let putting-data-state(show-broadie: false) = {
  grid(
    columns: (0.82fr, 1.55fr),
    column-gutter: 1.0em,
    align: horizon,
    [
      #image(
        "images/golf_putting_ink.png",
        width: 100%,
        alt: "Ink illustration of a golfer putting toward a nearby hole",
      )
      #text(size: 10pt, fill: gray)[AI-generated course illustration]

      #set text(size: 11pt)
      Berry (1996): professional putting summaries at rounded distances from 2 to 20 feet.

      #if show-broadie [
        Broadie (2018): a later, much larger dataset extending to 75 feet.
      ]
    ],
    stack(
      spacing: 0.45em,
      image("figures/01_logistic_baseline_setup.svg", width: 100%),
      if show-broadie {
        image("figures/02_angle_geometry_external-check-on-newer-data.svg", width: 100%)
      },
    ),
  )
}

#alternatives(
  putting-data-state(),
  putting-data-state(show-broadie: true),
)

#speaker-note[
  Begin with the small Berry dataset used in the original putting example:
  successes and attempts at each rounded distance from two to twenty feet.
  Then reveal Broadie's much larger and longer-range dataset. The second set is
  not merely more data for fitting; it gives us an honest external test of a
  model developed on the first dataset.
]

== Start simple: logistic regression shows what remains unexplained

#grid(
  columns: (0.92fr, 1.45fr),
  column-gutter: 0.9em,
  align: horizon,
  [
    #align(center)[
      $
        y_j & tilde "Binomial"(n_j, p_j) \
        "logit"(p_j) & = alpha + beta x_j
      $
    ]
    #block[
      #set text(size: 12.5pt)
      #show raw.where(block: true): set text(size: 12.5pt)
```python
with pm.Model() as model:
    alpha = pm.Normal("alpha", 0, 3)
    beta = pm.Normal("beta", 0, 0.5)
    logit_p = alpha + beta * distance
    pm.Binomial(
        "made", n=attempts,
        logit_p=logit_p,
        observed=made,
    )
```
    ]
  ],
  image("figures/01_logistic_baseline_posterior-fit.svg", width: 100%),
)

#set text(size: 0.68em)
#grid(
  columns: (1fr, 1fr, 1fr),
  column-gutter: 0.8em,
  [*Start simple.* It is usually best to begin with the smallest useful model.],
  [Prior and posterior predictive checks develop intuition for what it can generate.],
  [What it does and does not capture tells us how much remains to explain.],
)

#speaker-note[
  Logistic regression is deliberately generic: it captures a smooth decline
  without claiming why distance matters. That makes it an excellent first
  model. Prior predictive simulation reveals the implications of its priors;
  posterior predictive simulation reveals which features remain unexplained.
  The point is not to stop here, but to establish a transparent baseline.
]

== Geometry turns distance into a success probability

#grid(
  columns: (1.18fr, 1fr),
  column-gutter: 1.0em,
  align: horizon,
  [
    #golf-geometry
    #align(center, text(size: 12pt, fill: gray)[
      Redrawn from Gelman et al., _Bayesian Workflow_, Fig. 25.3
    ])
  ],
  [
    #align(center)[
      $
        theta(x) & = arcsin((R-r) / x) \
        p(x) & = 2 Phi(theta(x) / sigma) - 1
      $
    ]

    #set text(size: 0.78em)
    - A highly simplified model of putting physics
    - The only parameter is noise in the aiming angle, $sigma$
    - These counts overwhelm almost any reasonable prior
    - It is still healthy to ask what a reasonable prior implies
  ],
)

#speaker-note[
  The geometry says that the farther the ball is from the cup, the narrower the
  acceptable launch-angle cone becomes. Assume the actual launch angle is
  normally distributed around the intended line. Then a single parameter—the
  angular standard deviation—determines success probability at every distance.
  The dataset is informative enough that broad sensible priors give nearly the
  same posterior, but prior predictive reasoning is still part of the workflow.
]

== One angular-noise parameter fits the original data remarkably well

#grid(
  columns: (0.88fr, 1.48fr),
  column-gutter: 0.9em,
  align: horizon,
  [
    #block[
      #set text(size: 12.2pt)
      #show raw.where(block: true): set text(size: 12.2pt)
```python
with pm.Model() as model:
    sigma_deg = pm.LogNormal(
        "sigma_deg", log(2), 0.7
    )
    theta = pm.math.arcsin(
        (cup_radius - ball_radius)
        / distance
    )
    p = 2 * pm.math.invprobit(
        theta / deg2rad(sigma_deg)
    ) - 1
    pm.Binomial(
        "made", n=attempts,
        p=p, observed=made,
    )
```
    ]
  ],
  image("figures/02_angle_geometry_posterior-fit.svg", width: 100%),
)

#speaker-note[
  This is the payoff from using scientific structure. The code is only slightly
  more complicated than logistic regression, yet one interpretable parameter
  governs the entire curve. The fit to the Berry data is strong, so at this
  stage the angle-only model looks like an economical explanation.
]

== A trusted model earns a harder test on new data

#grid(
  columns: (1.65fr, 0.75fr),
  column-gutter: 1.0em,
  align: horizon,
  image("figures/02_angle_geometry_external-check-on-newer-data_2.svg", width: 100%),
  [
    #text(size: 0.92em, weight: "semibold")[
      When we have faith in a model, we can test it against new data as those
      data become available.
    ]
  ],
)

#align(bottom + right, text(size: 12pt, fill: gray)[
  Data: Broadie (2018); comparison follows _Bayesian Workflow_, §25.3
])

#speaker-note[
  Do not refit yet. Carry the posterior learned from the Berry data forward and
  predict the Broadie observations. Short putts are made more often than the old
  model predicts, while long putts are made less often. That structured failure
  is scientifically useful: it tells us exactly what the next model must add.
]

== Model 3: angle error plus distance error

== When a huge dataset exposes a small model failure

== Model 4: allow the model to be imperfect

== A better fit is not necessarily the end

== Where we stop the golf workflow today

= Preparing for active learning: sleep deprivation

== Repeated measurements create a multilevel problem

== Average effects and individual trajectories

== Your workflow for the sleep data
