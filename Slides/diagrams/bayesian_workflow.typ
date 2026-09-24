// Reusable diagram for the three Bayesian Workflow slides.
//
// `spine-stage` reveals Data, Model, Fit, Interpret, then the return paths.
// `check-stage` reveals Prior predictive, Diagnostics, and Posterior predictive.
// `repair-stage` reveals the corrective paths from failed checks.

#import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node

#let workflow-diagram(
  spine-stage: 5,
  check-stage: 0,
  repair-stage: 0,
  reserve-checks: false,
) = {
  let primary = rgb("#eb811b")
  let ink = rgb("#23373b")
  let check = rgb("#4f7d8a")
  let repair = rgb("#24566a")
  let muted = luma(115)

  let spine-node(label, at, name, visible: true) = node(
    at,
    if visible {
      text(weight: "semibold", fill: ink, label)
    } else {
      hide(text(weight: "semibold", label))
    },
    name: name,
    width: 4.0cm,
    height: 1.15cm,
    fill: if visible { primary.lighten(82%) } else { none },
    stroke: if visible { 1.25pt + primary } else { none },
    corner-radius: 6pt,
  )

  let check-node(label, at, name, visible: true) = node(
    at,
    if visible {
      text(size: 0.72em, weight: "semibold", fill: ink, label)
    } else {
      hide(text(size: 0.72em, weight: "semibold", label))
    },
    name: name,
    width: 4.25cm,
    height: 1.35cm,
    fill: if visible { check.lighten(84%) } else { none },
    stroke: if visible { 1.15pt + check } else { none },
    corner-radius: 6pt,
  )

  align(center, diagram(
    spacing: (4.9em, 2.1em),
    node-stroke: 1.2pt + ink,
    edge-stroke: 1.35pt + primary,
    mark-scale: 78%,
    edge-corner-radius: 5pt,

    // Ghost nodes reserve a stable bounding box so reveals do not move the
    // diagram around the slide.
    spine-node([Data], (0, 1), <data>, visible: spine-stage >= 1),
    spine-node([Model], (1, 1), <model>, visible: spine-stage >= 2),
    spine-node([Fit], (2, 1), <fit>, visible: spine-stage >= 3),
    spine-node([Interpret], (3, 1), <interpret>, visible: spine-stage >= 4),

    if spine-stage >= 2 { edge(<data>, <model>, "->") },
    if spine-stage >= 3 { edge(<model>, <fit>, "->") },
    if spine-stage >= 4 { edge(<fit>, <interpret>, "->") },

    // The two return paths make the basic workflow a loop. They are muted on
    // the denser slides so the check and repair layers remain legible.
    if spine-stage >= 5 {
      edge(
        <interpret>, (3, 1.70), (1, 1.70), <model>, "->",
        stroke: 1.1pt + muted,
      )
      edge(
        <interpret>, (3, 2.05), (0, 2.05), <data>, "->",
        stroke: 1.1pt + muted,
      )
    },

    if reserve-checks or check-stage >= 1 {
      check-node([Prior predictive], (1, 0), <prior>, visible: check-stage >= 1)
    },
    if check-stage >= 1 {
      edge(<model>, <prior>, "->", stroke: 1.2pt + check)
    },
    if reserve-checks or check-stage >= 2 {
      check-node([Diagnostics], (2, 0), <diagnostics>, visible: check-stage >= 2)
    },
    if check-stage >= 2 {
      edge(<fit>, <diagnostics>, "->", stroke: 1.2pt + check)
    },
    if reserve-checks or check-stage >= 3 {
      check-node([Posterior predictive], (2, 2.65), <posterior>, visible: check-stage >= 3)
    },
    if check-stage >= 3 {
      edge(<fit>, <posterior>, "->", stroke: 1.2pt + check)
    },

    // Failed checks send us back to assumptions, data, or computation.
    if repair-stage >= 1 {
      edge(<prior>, <model>, "->", stroke: 1.35pt + repair, dash: "dashed", bend: 20deg)
      edge(<prior>, <data>, "->", stroke: 1.35pt + repair, dash: "dashed", bend: -28deg)
    },
    if repair-stage >= 2 {
      edge(<diagnostics>, <fit>, "->", stroke: 1.35pt + repair, dash: "dashed", bend: -20deg)
      edge(<diagnostics>, <model>, "->", stroke: 1.35pt + repair, dash: "dashed", bend: 28deg)
    },
    if repair-stage >= 3 {
      edge(<posterior>, <model>, "->", stroke: 1.35pt + repair, dash: "dashed", bend: -22deg)
      edge(<posterior>, <data>, "->", stroke: 1.35pt + repair, dash: "dashed", bend: -16deg)
    },
  ))
}
