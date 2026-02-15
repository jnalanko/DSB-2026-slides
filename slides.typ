#import "@preview/polylux:0.4.0": *

// --- Configuration ---
#let accent-color = rgb("#2E86AB")
#let dark-color = rgb("#1B1B2F")
#let light-bg = rgb("#FAFAFA")

#set page(paper: "presentation-16-9")
#set text(size: 22pt, font: "New Computer Modern")
#show math.equation: set text(font: "New Computer Modern Math")
#show heading: set text(fill: dark-color)
#show link: set text(fill: accent-color)

// Slide number in bottom-right
#set page(footer: context {
  set align(right)
  set text(size: 12pt, fill: luma(150))
  toolbox.slide-number
})

// --- Title Slide ---
#slide[
  #set align(horizon + center)
  #set text(size: 36pt, weight: "bold", fill: dark-color)

  Your Presentation Title

  #v(0.5em)
  #set text(size: 20pt, weight: "regular", fill: luma(20))
  Subtitle or Conference Name

  #v(1em)
  #set text(size: 18pt)
  Author Name \
  #set text(size: 16pt, fill: luma(20))
  Institution or Affiliation \
  February 2026
]

// --- Outline ---
#slide[
  == Outline

  + Background & Motivation
  + Problem Formulation
  + Methodology
  + Results
  + Conclusion
]

// --- Background ---
#slide[
  == Background

- Way to index massive bacterial datasets
- Each genome is a color. Each k-mer is associated with a set of colors.
- The color set of a k-mer is the set of color associated with it.
- Interesting object: the set of distinct color sets
- Key to compressing the data structure

]

#slide[
== Color matrix
- Color matrix: rows are k-mers, column are colors
- So we want to build to distinct rows
- It’s easy to build the matrix column by column.
- But the query is row by row.
]

// --- Color Matrix Figure ---
#slide[
== Color matrix
  #set align(horizon + center)
  #set text(size: 17pt)
  #table(
      columns: (1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr),
      align: center,
      stroke: 0.5pt + luma(150),
      inset: 4pt,
      fill: (x, y) => {
        if x == 0 or y == 0 { luma(230) }
        else { none }
      },
      table.header(
        [], [$G_1$], [$G_2$], [$G_3$], [$G_4$], [$G_5$], [$G_6$], [$G_7$], [$G_8$],
      ),
      [`ACGTA`], [1], [0], [1], [1], [0], [0], [1], [0], // A: row 1
      [`CGTAC`], [1], [1], [0], [0], [1], [0], [0], [1],
      [`GTACG`], [0], [1], [1], [0], [0], [1], [0], [0], // B: row 3
      [`TACGT`], [1], [0], [1], [1], [0], [0], [1], [0], // A: row 4
      [`ACGTG`], [0], [0], [1], [0], [1], [1], [0], [1], // C: row 5
      [`TGCAA`], [1], [1], [0], [1], [0], [0], [0], [0],
      [`GCAAC`], [0], [1], [1], [0], [0], [1], [0], [0], // B: row 7
      [`CAACT`], [0], [0], [0], [1], [1], [0], [1], [1],
      [`TTGCA`], [1], [0], [1], [1], [0], [0], [1], [0], // A: row 9
      [`AACGT`], [0], [1], [1], [0], [1], [0], [1], [0],
      [`CGTAT`], [0], [0], [1], [0], [1], [1], [0], [1], // C: row 11
      [`GTATC`], [0], [0], [1], [0], [0], [1], [1], [0],
      [`TATCG`], [1], [1], [0], [0], [1], [0], [0], [0],
      [`ATCGA`], [0], [1], [1], [1], [0], [0], [1], [1],
      [`CGAAC`], [0], [0], [1], [0], [1], [1], [0], [1], // C: row 16
    )
]

// --- Color Matrix Highlighted ---
#let color-a = rgb("#FF6B6B").lighten(60%)
#let color-b = rgb("#4ECDC4").lighten(60%)
#let color-c = rgb("#FFD93D").lighten(40%)

#slide[
  == Color matrix
  #set align(horizon + center)
  #set text(size: 17pt)
  #table(
      columns: (1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr),
      align: center,
      stroke: 0.5pt + luma(150),
      inset: 4pt,
      fill: (x, y) => {
        if y == 0 { luma(230) }
        else if x == 0 and y not in (1, 4, 9, 3, 7, 5, 11, 15) { luma(230) }
        else if y in (1, 4, 9) { color-a }
        else if y in (3, 7) { color-b }
        else if y in (5, 11, 15) { color-c }
        else { none }
      },
      table.header(
        [], [$G_1$], [$G_2$], [$G_3$], [$G_4$], [$G_5$], [$G_6$], [$G_7$], [$G_8$],
      ),
      [`ACGTA`], [1], [0], [1], [1], [0], [0], [1], [0],
      [`CGTAC`], [1], [1], [0], [0], [1], [0], [0], [1],
      [`GTACG`], [0], [1], [1], [0], [0], [1], [0], [0],
      [`TACGT`], [1], [0], [1], [1], [0], [0], [1], [0],
      [`ACGTG`], [0], [0], [1], [0], [1], [1], [0], [1],
      [`TGCAA`], [1], [1], [0], [1], [0], [0], [0], [0],
      [`GCAAC`], [0], [1], [1], [0], [0], [1], [0], [0],
      [`CAACT`], [0], [0], [0], [1], [1], [0], [1], [1],
      [`TTGCA`], [1], [0], [1], [1], [0], [0], [1], [0],
      [`AACGT`], [0], [1], [1], [0], [1], [0], [1], [0],
      [`CGTAT`], [0], [0], [1], [0], [1], [1], [0], [1],
      [`GTATC`], [0], [0], [1], [0], [0], [1], [1], [0],
      [`TATCG`], [1], [1], [0], [0], [1], [0], [0], [0],
      [`ATCGA`], [0], [1], [1], [1], [0], [0], [1], [1],
      [`CGAAC`], [0], [0], [1], [0], [1], [1], [0], [1],
    )
]

// --- Color Matrix Highlighted + Fingerprint column ---
#slide[
  #set align(horizon + center)
  #set text(size: 15pt)
  #table(
      columns: (1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1.8fr),
      align: center,
      stroke: 0.5pt + luma(150),
      inset: 4pt,
      fill: (x, y) => {
        if y == 0 { luma(230) }
        else if x == 0 and y not in (1, 4, 9, 3, 7, 5, 11, 15) { luma(230) }
        else if y in (1, 4, 9) { color-a }
        else if y in (3, 7) { color-b }
        else if y in (5, 11, 15) { color-c }
        else { none }
      },
      table.header(
        [], [$G_1$], [$G_2$], [$G_3$], [$G_4$], [$G_5$], [$G_6$], [$G_7$], [$G_8$], [*Fingerprint*],
      ),
      [`ACGTA`], [1], [0], [1], [1], [0], [0], [1], [0], [*`1011010011`*],
      [`CGTAC`], [1], [1], [0], [0], [1], [0], [0], [1], [*`0110100101`*],
      [`GTACG`], [0], [1], [1], [0], [0], [1], [0], [0], [*`1100011110`*],
      [`TACGT`], [1], [0], [1], [1], [0], [0], [1], [0], [*`1011010011`*],
      [`ACGTG`], [0], [0], [1], [0], [1], [1], [0], [1], [*`0101110100`*],
      [`TGCAA`], [1], [1], [0], [1], [0], [0], [0], [0], [*`1001001010`*],
      [`GCAAC`], [0], [1], [1], [0], [0], [1], [0], [0], [*`1100011110`*],
      [`CAACT`], [0], [0], [0], [1], [1], [0], [1], [1], [*`0010111001`*],
      [`TTGCA`], [1], [0], [1], [1], [0], [0], [1], [0], [*`1011010011`*],
      [`AACGT`], [0], [1], [1], [0], [1], [0], [1], [0], [*`1110001100`*],
      [`CGTAT`], [0], [0], [1], [0], [1], [1], [0], [1], [*`0101110100`*],
      [`GTATC`], [0], [0], [1], [0], [0], [1], [1], [0], [*`0011000111`*],
      [`TATCG`], [1], [1], [0], [0], [1], [0], [0], [0], [*`1000110010`*],
      [`ATCGA`], [0], [1], [1], [1], [0], [0], [1], [1], [*`0100101011`*],
      [`CGAAC`], [0], [0], [1], [0], [1], [1], [0], [1], [*`0101110100`*],
    )
]

// --- K-mers + Fingerprints only (single table) ---
#slide[
  #set align(horizon + center)
  #set text(size: 15pt)
  #grid(
    columns: (1fr, 1fr),
    align: center + horizon,
    column-gutter: 24pt,
    table(
      columns: (auto, auto),
      align: center,
      stroke: 0.5pt + luma(150),
      inset: 5pt,
      fill: (x, y) => {
        if y == 0 { luma(230) }
        else if y in (1, 4, 9) { color-a }
        else if y in (3, 7) { color-b }
        else if y in (5, 11, 15) { color-c }
        else { none }
      },
      table.header(
        [*k-mer*], [*Fingerprint*],
      ),
      [`ACGTA`], [*`1011010011`*],
      [`CGTAC`], [*`0110100101`*],
      [`GTACG`], [*`1100011110`*],
      [`TACGT`], [*`1011010011`*],
      [`ACGTG`], [*`0101110100`*],
      [`TGCAA`], [*`1001001010`*],
      [`GCAAC`], [*`1100011110`*],
      [`CAACT`], [*`0010111001`*],
      [`TTGCA`], [*`1011010011`*],
      [`AACGT`], [*`1110001100`*],
      [`CGTAT`], [*`0101110100`*],
      [`GTATC`], [*`0011000111`*],
      [`TATCG`], [*`1000110010`*],
      [`ATCGA`], [*`0100101011`*],
      [`CGAAC`], [*`0101110100`*],
    ),
    [
      #text(size: 18pt)[*Color-set covering subset of k-mers*] \
      #v(0.5em)
      #table(
        columns: (auto, auto),
        align: center,
        stroke: 0.5pt + luma(150),
        inset: 5pt,
        fill: (x, y) => {
          if y == 0 { luma(230) }
          else if y == 4 { color-c }
          else if y == 8 { color-a }
          else if y == 9 { color-b }
          else { none }
        },
        table.header(
          [*k-mer*], [*Fingerprint*],
        ),
        [`CAACT`], [*`0010111001`*],
        [`GTATC`], [*`0011000111`*],
        [`ATCGA`], [*`0100101011`*],
        [`ACGTG`], [*`0101110100`*],
        [`CGTAC`], [*`0110100101`*],
        [`TATCG`], [*`1000110010`*],
        [`TGCAA`], [*`1001001010`*],
        [`ACGTA`], [*`1011010011`*],
        [`GTACG`], [*`1100011110`*],
        [`AACGT`], [*`1110001100`*],
      )
    ],
  )
]

#slide[
== Requirements for the fingerprint function $F$

- $F$ takes in a fingerprint and a color, and adds the color to the fingerprint.
- Given set ${c_1, c_2, c_3}$ the fingerprint is $F(F(F(0, c_1), c_2), c_3)$
- Commutative: $F(F(F(0, c_1), c_2), c_3) = F(F(F(0, c_3), c_2), c_1)$
- Atomically updateable: $x <- F(x, c)$ is an atomic CPU operation
- Collision-resistant

]

#slide[
== Fingerprinting scheme

#v(1.0em)

- *Initialization*: For each color, pick an $l$-bit fingerprint uniformly at random. Denote the fingerprint of color $c$ with $f(c)$.
- *Fingerprinting*: The fingerprint of a _set_ $A = {c_1, c_2, ..., c_m}$ is $F(A) = c_1 xor c_2 xor ... xor c_m$, where $xor$ is bitwise xor.
- *Wishlist*: Incremental #emoji.checkmark, Commutative #emoji.checkmark, Atomically updatable #emoji.checkmark, Collision-resistant: ?

]

#slide[
  == Collision analysis 

  #v(1.0em)

  The fingerprint function $F$ is *universal hash family* over the single-color fingerprint picks $f(c)$. By the union bound:

  #v(0.5em)

  #rect(
    width: 100%,
    inset: 16pt,
    radius: 4pt,
    stroke: accent-color,
    fill: accent-color.lighten(92%),
  )[
*Lemma 2.* _Given a set of distinct sets $A_0, dots, A_(N-1)$, the probability that there exists two sets $A_i != A_j$ such that $F(A_i) = F(A_j)$ is at most $N^2 / 2^(ell+1)$, where $l$ is the length of a fingerprint._
  ]

  For example, for $ell = 128$ and $N = 10^9$, we have a collision probability of at most $10^18$ / $2^129$ $ approx 1.47 dot 10^(-21)$.
]

