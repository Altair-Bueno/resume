// Layout loosely derived from Rezume, a resume template for developers
// Author: Nanu Panchamurthy
// Based off of: https://www.overleaf.com/latex/templates/rezume/kfrvqywfkwjs
// License: MIT

#import "@preview/datify:1.3.0": custom-date-format
#import "@preview/linguify:0.5.0": linguify

#let database = toml("lang.toml")
#let t(key) = linguify(key, from: database)

#let accent = rgb("#1d4f91")
#let muted = luma(35%)

/// "2024-10" as "Oct 2024", in the document's language.
#let month(value, lang) = {
  let (year, month) = value.split("-").map(int)
  custom-date-format(
    datetime(year: year, month: month, day: 1),
    pattern: "MMM yyyy",
    lang: lang,
  )
}

#let period(entry, lang) = {
  month(entry.start, lang)
  [ – ]
  if "end" in entry { month(entry.end, lang) } else { t("present") }
}

/// A URL as printed: no scheme, no trailing slash.
#let display-url(url) = (
  url
    .replace(regex("^https?://(www\.)?"), "")
    .trim(
      "/",
      at: end,
    )
)

#let header(person) = {
  let address = person.address
  let place = (address.city, address.region, address.country).dedup().join(", ")
  let links = (
    (person.at("website", default: none),)
      + person.at("profiles", default: ()).map(p => p.url)
  ).filter(url => url != none)
  let contacts = (
    (place,)
      + links.map(url => link(url, display-url(url)))
      + (
        link("mailto:" + person.email, person.email),
        link("tel:" + person.phone.replace(" ", ""), person.phone),
      )
  )

  block(below: 1.2em, {
    block(below: 0.8em, text(size: 22pt, weight: "bold", person.name))
    block(below: 0.7em, text(size: 13pt, fill: accent, person.headline))
    set text(size: 9pt, fill: muted)
    contacts.map(box).join(h(0.6em) + sym.dot.c + h(0.6em))
  })
  par(person.summary)
}

#let section(title, body) = {
  block(above: 1.15em, below: 0.65em, sticky: true, {
    text(size: 11pt, weight: "bold", fill: accent, smallcaps(title))
    v(0.3em, weak: true)
    line(length: 100%, stroke: 0.5pt + accent.lighten(50%))
  })
  body
}

#let separator = h(0.5em) + sym.dot.c + h(0.5em)

/// A bold title line, then a muted line of details. Everything is flush
/// left: right-aligned text makes extractors such as poppler detach it from
/// the entry it belongs to.
#let entry(title, details: (), bullets: ()) = block(
  above: 0.75em,
  below: 0.75em,
  breakable: true,
  {
    block(below: 0.45em, sticky: true, {
      title
      let details = details.filter(x => x != none)
      if details.len() > 0 {
        linebreak()
        text(size: 9pt, fill: muted, details.join(separator))
      }
    })
    if bullets.len() > 0 {
      list(..bullets)
    }
  },
)

#let labelled-rows(rows) = grid(
  columns: (auto, 1fr),
  column-gutter: 0.6em,
  row-gutter: 0.55em,
  align: (right, left),
  ..rows.map(((label, value)) => (strong[#label:], value)).flatten(),
)
