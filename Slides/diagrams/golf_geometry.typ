// Top-down geometry for the angle-only putting model.
// Redrawn for the course from the construction in Bayesian Workflow, Fig. 25.3.

#let golf-geometry = {
  let svg = ```
  <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 900 420">
    <defs>
      <marker id="arrow" viewBox="0 0 10 10" refX="5" refY="5"
              markerWidth="7" markerHeight="7" orient="auto-start-reverse">
        <path d="M 0 0 L 10 5 L 0 10 z" fill="#23373b"/>
      </marker>
    </defs>

    <path d="M130 210 L720 126 L720 294 Z" fill="#eb811b" fill-opacity="0.12"/>
    <line x1="130" y1="210" x2="720" y2="126" stroke="#eb811b" stroke-width="5"/>
    <line x1="130" y1="210" x2="720" y2="294" stroke="#eb811b" stroke-width="5"/>
    <line x1="130" y1="210" x2="720" y2="210" stroke="#23373b" stroke-width="3" stroke-dasharray="12 10"/>

    <circle cx="130" cy="210" r="28" fill="#f7f7f5" stroke="#23373b" stroke-width="5"/>
    <circle cx="720" cy="210" r="92" fill="#4f7d8a" fill-opacity="0.12" stroke="#4f7d8a" stroke-width="6"/>
    <circle cx="720" cy="210" r="66" fill="none" stroke="#4f7d8a" stroke-width="4" stroke-dasharray="10 8"/>

    <line x1="170" y1="354" x2="680" y2="354" stroke="#23373b" stroke-width="3"
          marker-start="url(#arrow)" marker-end="url(#arrow)"/>
    <text x="425" y="390" font-family="Arial, sans-serif" font-size="34" fill="#23373b" text-anchor="middle">distance x</text>

    <line x1="720" y1="210" x2="720" y2="144" stroke="#23373b" stroke-width="3"
          marker-end="url(#arrow)"/>
    <text x="742" y="176" font-family="Arial, sans-serif" font-size="30" fill="#23373b">R-r</text>

    <text x="86" y="152" font-family="Arial, sans-serif" font-size="30" fill="#23373b">ball</text>
    <text x="676" y="88" font-family="Arial, sans-serif" font-size="30" fill="#4f7d8a">cup</text>
    <text x="300" y="185" font-family="Arial, sans-serif" font-size="28" fill="#eb811b">acceptable aiming error</text>
  </svg>
  ```.text

  align(center, image(bytes(svg), width: 100%, alt: "Top-down putting geometry showing the angular cone that reaches the hole"))
}
