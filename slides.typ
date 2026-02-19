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

  Constructing distinct color sets of $k$-mers via fingerprinting

  #v(0.5em)
  #set text(size: 22pt, weight: "regular", fill: luma(20))
  DSB 2026 

  #v(1em)
  #set text(size: 22pt)
  #underline[Jarno N. Alanko], Simon J. Puglisi \
  #set text(size: 22pt, fill: luma(20))
  University of Helsinki \
]

// --- Background ---
#slide[
  == Colored $k$-mers 

- Way to index massive bacterial datasets.
- Each genome is a color. Each $k$-mer is associated with a set of colors (the *color set* of the $k$-mer).
- Interesting object: the set of distinct color sets.
- Key to compressing the data structure.

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
== Incremental fingerprinting

We need an update function $g$ that takes a partial fingerprint $x$ and adds a color $c$ to the fingerprint. Requirements:

- *Commutative*: $g(g(x, c_1), c_2) = g(g(x, c_2), c_1)$.
- *Atomically updateable*: $x <- g(x, c)$ is an atomic CPU operation.
- *Collision-resistant*: distinct sets map to distinct fingerprints with high probability.

]

#slide[
== Fingerprinting scheme: Zobrist hashing

#v(1.0em)

- *Precomputation*: For each color, pick an $ell$-bit fingerprint uniformly at random. Denote the fingerprint of color $c$ with $f(c)$.
- *Update function*: Given fingerprint $x$ and color $c$ we update with $g(x, c) = x xor f(c)$, where $xor$ is bitwise xor.
- *Fingerprint of a set*: The fingerprint of a _set_ $A = {c_1, c_2, ..., c_m}$ will be $F(A) = f(c_1) xor f(c_2) xor ... xor (c_m)$.

]

#slide[
== Fingerprinting scheme

#v(1.0em)

- *Precomputation*: For each color, pick an $ell$-bit fingerprint uniformly at random. Denote the fingerprint of color $c$ with $f(c)$.
- *Update function*: Given fingerprint $x$ and color $c$ we update with $g(x, c) = x xor f(c)$, where $xor$ is bitwise xor.
- *Fingerprint of a set*: The fingerprint of a _set_ $A = {c_1, c_2, ..., c_m}$ will be $F(A) = f(c_1) xor f(c_2) xor ... xor (c_m)$.
- *Wishlist*: Incremental #emoji.checkmark, Commutative #emoji.checkmark, Atomically updatable #emoji.checkmark, Collision-resistant: ?

]

#slide[
  == Collision analysis 

  #v(1.0em)

  The fingerprint function $F$ is a *universal hash family* over the single-color fingerprint picks $f(c)$. By the union bound:

  #v(0.5em)

  #rect(
    width: 100%,
    inset: 16pt,
    radius: 4pt,
    stroke: accent-color,
    fill: accent-color.lighten(92%),
  )[
*Lemma 2.* _Given a set of distinct sets $A_0, dots, A_(N-1)$, the probability that there exists two sets $A_i != A_j$ such that $F(A_i) = F(A_j)$ is at most $N^2 / 2^(ell+1)$, where $ell$ is the length of a fingerprint._
  ]

  For example, for $ell = 128$ and $N = 10^9$, we have a collision probability of at most $10^18$ / $2^129$ $ approx 1.47 dot 10^(-21) approx$ #underline[don't worry about it].
]

#slide[
  == Okay, but storing a fingerprint for every k-mer is still a lot of memory
]

#slide[
  == Adjacent $k$-mers often share the same color set.
  #v(2em)
  #image("figures/dbg.drawio.pdf", width: 90%)
]

#slide[
  #image("figures/dbg.drawio.pdf", width: 90%)
  - The color set can change only when:
    - The graph branches.
    - An input sequence ends or starts.
]

#slide[
== Key $k$-mers
#v(1em)
  - The color set can change only when:
    - The graph branches.
    - An input sequence ends or starts.
  - If one of the above applies to a $k$-mer, we call it a _key $k$-mer_.
  - The key k-mers are a *color-set covering set* of $k$-mers, but not _minimal_.
]

#slide[
  == Algorithm

  #v(1em)

  We follow a two-step filtering appoach from $k$-mers to key $k$-mers, to _sufficient_ $k$-mers.

  1. Find the key $k$-mers
  2. Build color set fingerprints of the key $k$-mers.
  3. Deduplicate the fingerprints $->$ sufficient $k$-mers.
  
  Finally, we build one color set for each distinct fingerprint, directly into a *compressed form*.
]

#slide[
  == Required data structure support
  #v(1em)

  - *Indexing of rows of the color matrix*: A perfect hash function such that $k$-mers in the dataset map to $[0,m)$.
    - $m >= n$, where $n$ is the number $k$-mers (the color matrix can have unused rows).
    - $k$-mers not in the dataset can map anywhere. 
  - *Identifying key $k$-mers*: de Bruijn graph neighbor lookup to check for branching. 
]

#slide[
  #set align(horizon + center)
  #image("figures/phase_1_2_3_overview.drawio.pdf", width: 110%)
]

#slide[
  == Results
- *Machine*: 32-core Threadripper PRO 3975WX, 504 GiB RAM, 400MB/s hard drive IO.
- *Datasets*: Subsets of AllTheBacteria: 1,2,4...,65536 Salmonella genomes, 1,2,4,...,16384 random genomes. 
- *Implementation details*: 
  - SBWT was used as the perfect hash function on $k$-mers and for the dBg neighbor lookup.
  - Options to build fully in memory, or by writing the final structure to disk in pieces. 
  - Rust #text(fill: orange)[#emoji.crab].
- *Baselines*: Bifrost, GGCAT 2.
]

#slide[
  #set align(horizon + center)
  #image("figures/mem.pdf", width: 100%)
]

#slide[
  #set align(horizon + center)
  #image("figures/time.pdf", width: 100%)
]

#slide[
  #set align(horizon + center)
  #image("figures/speedup.pdf", width: 100%)
]

#slide[
  = Conclusion
  #v(1em)

  Our method provides:

  - Deduplication of color sets even across unitigs.
  - Independent parallel threads.
  - Low RAM.
  - Construction directly into sparse-dense form.

  Future work:

  - Alternative implementations, e.g. based on Sshash. 
  - Better compression in the final form.
]

/*
#slide[
  #set align(horizon + center)
  #image("figures/key_kmers.pdf", width: 80%)
]
*/
