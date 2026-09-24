# Bayesian Workflow section — content and design specification

## Teaching purpose

Introduce the Bayesian workflow as a progressively enriched loop before the
course applies it to the golf-putting notebooks. The three slides should give
students one stable visual map that answers, in order:

1. What are the main steps?
2. Where do the checks belong?
3. What should we revisit when a check fails?

## Audience and tone

- Short-course learners with mixed statistical backgrounds.
- Academic and instructional, but visually direct rather than text-heavy.
- The diagram carries the explanation; visible prose is limited to the
  interpretive point for each reveal.

## Visual system

- Preserve the existing 16:9 Touying Metropolis theme.
- Use the course orange (`#eb811b`) for the workflow spine.
- Use a quiet blue for validation checks and a darker blue dashed line for
  corrective return paths.
- Use the same node positions on all three slides so additions read as layers
  on one diagram rather than as new diagrams.
- Build the vector diagram in `Slides/diagrams/bayesian_workflow.typ` and import
  it into `Slides/slide_deck.typ`.

## Slide sequence

### 1. The workflow starts with a four-step loop

Reveal Data → Model → Fit → Interpret, then reveal return arrows from
Interpret to Model and Data. Finish with two implications: different
interpretations and iterative experimental design.

### 2. Checks make each transition accountable

Start from the complete spine. Add Prior predictive, Diagnostics, and
Posterior predictive in sequence, together with one short statement of what
each check tests.

### 3. A failed check tells us where to return

Start from the spine plus all checks. Add corrective return paths in sequence:
prior predictive to Model/Data, diagnostics to Fit/Model, and posterior
predictive to Model/Data. Pair each reveal with its modeling implication.

## Delivery checks

- Compile the complete deck without warnings or missing assets.
- Inspect every overlay of these three slides for clipping, overlap, contrast,
  and projection readability.
- Check the transition into the golf-putting workflow section.
- Keep speaker notes focused on what to say during each reveal.
