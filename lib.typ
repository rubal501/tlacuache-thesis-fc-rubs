
#let bib = state("bib", none)

#let currentH(level: 1)={
  let elems = query(selector(heading.where(level: level)).after(here()))
  if elems.len() != 0 and elems.first().location().page() == here().page() {
    return elems.first().body
  } else {
    elems = query(selector(heading.where(level: level)).before(here()))
    if elems.len() != 0 {
      return elems.last().body
    }
  }
  return ""
}

#let thesis(
  titulo: [Titulo],
  grado: [Licenciatura],
  autor: [Autor],
  asesor: (
    nombre: "Nombre",
    genero: "fem"
  ),
  lugar: [Ciudad de México, México],
  agno: [#datetime.today().year()],
  bibliography: [],
  body,
)={
  // configuración páginas y contadores
  set document(title: titulo)

  let asesor-texto = if asesor.at("genero", default: "fem") == "fem" {
    "DIRECTORA DE TESIS"
  } else if asesor.at("genero", default: "fem") == "masc" {
    "DIRECTOR DE TESIS"
  } else {
    "DIRECTORX DE TESIS"
  }

  set page("us-letter", margin: (top: 4cm, bottom: 2cm), header: context{
    if here().page() == 1 {
      return
    }
    if calc.rem(here().page(), 2) == 0 [
      #align(left, text(currentH(), size: 18pt))
      #line(length: 100%, start: (0%, -7%))
    ] else [
      #align(right, currentH(level: 2))
      #line(length: 100%)
    ]
  })
  set text(font: "New Computer Modern", lang: "es")
  set heading(numbering: "1.1.")

  set math.equation(
    numbering: num =>
    "(" + (counter(heading.where(level: 1)).get() + (num,)).map(str).join(".") + ")",
  )

  set par(first-line-indent: 1em)

  set block(spacing: 1.5em)
  // Portada
  set align(center)
  set par(justify: false)
  let ancho-escudo=90pt
  grid(
    columns: (ancho-escudo, 1fr),
    rows: (auto, 1fr, auto),
    column-gutter: 1.5em,
    row-gutter: 1.2em,

    // Fila 1: escudo UNAM + universidad
    image("escudos/UNAM_crest_black.svg", width: 100%),
    align(horizon)[
      #text(1.5em, smallcaps[Universidad Nacional Autónoma \ de México])
      // doble linea: un bloque vacío con borde superior grueso e inferior fino
      #block(width: 100%, height: 0.9em, stroke: (top: 2.5pt, bottom: 1pt))
    ],

    // Fila 2: triple linea vertical + cuerpo
    stack(
      dir: ltr,
      spacing: 10pt,
      ..(1pt, 2.5pt, 1pt).map(w => block(height: 100%, stroke: (left: w))),
    ),
    block(height: 100%)[
      #text(1.3em, smallcaps[Facultad de Ciencias])
      #v(1fr)
      #text(1.2em, upper(titulo))
      #v(1fr)
      #text(3em, tracking: 0.6em)[TESIS]
      #v(1em)
      QUE PARA OBTENER EL GRADO DE:
      #v(0.4em)
      #upper(grado)
      #v(1fr)
      #text(tracking: 0.5em)[PRESENTA:]
      #v(0.4em)
      #upper(autor)
    ],

    // Fila 3: escudo FC + tutor y fecha
    image("escudos/FC_crest_black.svg", width: 100%),
    align(horizon)[
      #upper(asesor-texto) \
      #asesor.nombre
      #v(1em)
      #lugar, #agno
    ],
  )

  pagebreak()

  // Table of contents.
  outline(depth: 3)
  set page(numbering: "1")
  counter(page).update(1)

  let line-spacing = 0.65em * 1.5
  set par(justify: true, leading: line-spacing)
  show heading.where(level: 1): it => [
    #pagebreak(to: "even")
    #set align(right)
    #v(40%)
    #set text(font: "Inria Serif", size: 40pt)
    #it.body
    #line(length: 100%, start: (0%, 0%), stroke: gray)
    #pagebreak(weak: true)
  ]

  set align(left)

  body

  if not bibliography == [] {
    [#bibliography <bib>]
  }
}

#let chapter(bibliography: [], body) = {
  set math.equation(
    numbering: num =>
    "(" + (counter(heading.where(level: 1)).get() + (num,)).map(str).join(".") + ")",
  )

  body

  context(if query(<bib>).len() != 1 and bibliography == [] {
    pagebreak()
    bibliography
  })
}

#let section(bibliography: [], body) = {
  set math.equation(
    numbering: num =>
    "(" + (counter(heading.where(level: 1)).get() + (num,)).map(str).join(".") + ")",
  )

  body

  context(if query(<bib>).len() != 1 and bibliography == [] {
    pagebreak()
    bibliography
  })
}
