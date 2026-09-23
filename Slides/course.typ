// Shared presentation setup for the Short Bayes Course.
//
// Keep this file deliberately thin. `slide_deck.typ` should contain the
// teaching narrative; this file should contain only genuinely shared
// presentation setup and small reusable helpers.

#import "@preview/touying:0.6.1": *
#import themes.metropolis: *

#let course = (
  title: [A Short Practical Introduction to Bayesian Analysis],
  author: [Opher Donchin],
  date: [24–25 September 2026],
)

#let short-course-theme(body) = {
  show: metropolis-theme.with(
    aspect-ratio: "16-9",
    footer: self => self.info.title,
    config-info(
      title: course.title,
      author: course.author,
      date: course.date,
    ),
    config-colors(primary: rgb("#eb811b")),
  )

  set text(size: 22pt)
  set par(justify: false)

  body
}

#let course-title-slide() = title-slide()

#let course-outline() = components.adaptive-columns(
  outline(title: none, indent: 1em, depth: 1),
)
