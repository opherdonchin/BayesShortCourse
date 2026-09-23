#import "@preview/touying:0.6.1": *

#set document(
  title: [A Short Practical Introduction to Bayesian Analysis],
  author: [Opher Donchin],
)

= A Short Practical Introduction to Bayesian Analysis

== Today: from worked example to independent analysis

= A short worked example: dose response

== Four doses, twenty animals

== A generative model for mortality

== Priors: what could we have seen?

== Posterior: which dose-response curves remain plausible?

== LD50: the quantity we actually care about

== Posterior predictive: can the model reproduce the experiment?

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
