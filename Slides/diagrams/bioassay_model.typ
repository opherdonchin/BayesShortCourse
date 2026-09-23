// Graphical model for the bioassay example (bioassay/*.ipynb).
//
// Open circle: unknown parameter. Double circle: deterministic quantity.
// Shaded circle: observed data. Plain symbol: fixed input. The plate repeats
// its contents for each dose group j.

#import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node

#let bioassay-model-graph = {
  let ink = rgb("#23373b")
  let observed = ink.lighten(80%)
  let circ = fletcher.shapes.circle

  diagram(
    spacing: (2.2em, 1.6em),
    node-stroke: 1pt + ink,
    edge-stroke: 1pt + ink,
    mark-scale: 80%,

    node((0, 0), $alpha$, name: <alpha>, shape: circ),
    node((1, 0), $beta$, name: <beta>, shape: circ),

    node((0.5, 1), $p_j$, name: <p>, shape: circ, extrude: (0, 3)),
    node((1.6, 1), $x_j$, name: <x>, stroke: none),
    node((0.5, 2), $y_j$, name: <y>, shape: circ, fill: observed),
    node((1.6, 2), $n_j$, name: <n>, stroke: none),

    edge(<alpha>, <p>, "-|>"),
    edge(<beta>, <p>, "-|>"),
    edge(<x>, <p>, "-|>"),
    edge(<p>, <y>, "-|>"),
    edge(<n>, <y>, "-|>"),

    // Plate over the four dose groups.
    node(
      (1.6, 2.7),
      text(size: 0.7em)[$j = 1, dots, 4$],
      name: <plate-label>,
      stroke: none,
    ),
    node(
      enclose: (<p>, <x>, <y>, <n>, <plate-label>),
      stroke: 0.75pt + ink,
      corner-radius: 6pt,
      inset: 6pt,
    ),
  )
}
