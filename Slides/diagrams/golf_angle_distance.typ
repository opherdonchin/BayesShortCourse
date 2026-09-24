// Top-down geometry for the angle-and-distance putting model.
// Redrawn for the course from Bayesian Workflow, Fig. 25.6.

#let golf-angle-distance = {
  let svg = ```
  <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 980 430">
    <defs>
      <marker id="arrow" viewBox="0 0 10 10" refX="5" refY="5"
              markerWidth="7" markerHeight="7" orient="auto-start-reverse">
        <path d="M 0 0 L 10 5 L 0 10 z" fill="#23373b"/>
      </marker>
    </defs>

    <path d="M118 205 L650 132 L870 100 L870 310 L650 278 Z"
          fill="#eb811b" fill-opacity="0.16"/>
    <line x1="118" y1="205" x2="870" y2="100" stroke="#eb811b" stroke-width="5"/>
    <line x1="118" y1="205" x2="870" y2="310" stroke="#eb811b" stroke-width="5"/>
    <line x1="118" y1="205" x2="870" y2="205" stroke="#23373b" stroke-width="3"
          stroke-dasharray="12 10"/>

    <circle cx="118" cy="205" r="27" fill="#f7f7f5" stroke="#23373b" stroke-width="5"/>
    <circle cx="650" cy="205" r="87" fill="#4f7d8a" fill-opacity="0.12"
            stroke="#4f7d8a" stroke-width="6"/>
    <circle cx="650" cy="205" r="61" fill="none" stroke="#4f7d8a" stroke-width="4"
            stroke-dasharray="10 8"/>

    <line x1="650" y1="70" x2="870" y2="70" stroke="#23373b" stroke-width="3"
          marker-start="url(#arrow)" marker-end="url(#arrow)"/>
    <text x="760" y="50" font-family="Arial, sans-serif" font-size="29"
          fill="#23373b" text-anchor="middle">acceptable finish: 3 ft</text>

    <line x1="158" y1="355" x2="620" y2="355" stroke="#23373b" stroke-width="3"
          marker-start="url(#arrow)" marker-end="url(#arrow)"/>
    <text x="389" y="395" font-family="Arial, sans-serif" font-size="32"
          fill="#23373b" text-anchor="middle">distance x</text>

    <line x1="650" y1="335" x2="724" y2="335" stroke="#4f7d8a" stroke-width="4"
          marker-start="url(#arrow)" marker-end="url(#arrow)"/>
    <text x="687" y="320" font-family="Arial, sans-serif" font-size="27"
          fill="#4f7d8a" text-anchor="middle">aim 1 ft past</text>

    <text x="72" y="146" font-family="Arial, sans-serif" font-size="28" fill="#23373b">ball</text>
    <text x="612" y="100" font-family="Arial, sans-serif" font-size="28" fill="#4f7d8a">cup</text>
    <text x="380" y="177" font-family="Arial, sans-serif" font-size="26"
          fill="#eb811b" text-anchor="middle">right direction</text>
    <text x="785" y="235" font-family="Arial, sans-serif" font-size="26"
          fill="#eb811b" text-anchor="middle">right distance</text>
  </svg>
  ```.text

  align(center, image(bytes(svg), width: 100%, alt: "Top-down putting geometry showing the combination of acceptable direction and acceptable finishing distance"))
}
