#import "select.typ": check, select
#import "components.typ": *

#let render-section(key, data) = {
  let lang = data.locale
  let entries = data.at(key, default: ())
  if entries.len() == 0 { return }

  let spoken = data
    .at("languages", default: ())
    .map(language => [#language.name (#language.level)])
    .join(", ")
  // Shown together, languages become the last row of the skills table.
  let merged = "skills" in data.order and "languages" in data.order

  if key == "skills" {
    let rows = entries.map(group => (group.name, group.items.join(", ")))
    if merged and spoken != none { rows.push((t("languages"), spoken)) }
    section(t("skills"), labelled-rows(rows))
  } else if key == "languages" {
    if not merged or data.at("skills", default: ()).len() == 0 {
      section(t("languages"), par(spoken))
    }
  } else if key == "experience" {
    section(t("experience"), for position in entries {
      entry(
        strong(position.title),
        details: (
          link(position.organization.url, position.organization.name),
          position.at("location", default: none),
          period(position, lang),
        ),
        bullets: position.at("highlights", default: ()),
      )
    })
  } else if key == "education" {
    section(t("education"), for degree in entries {
      entry(
        strong[#degree.degree #t("degree-of") #degree.field],
        details: (
          link(degree.institution.url, degree.institution.name),
          degree.at("grade", default: none),
          period(degree, lang),
        ),
      )
    })
  } else if key == "certifications" {
    section(t("certifications"), for certification in entries {
      entry(
        (
          link(certification.url, strong(certification.name)),
          text(fill: muted, certification.issuer),
          text(fill: muted, month(certification.date, lang)),
        ).join(separator),
      )
    })
  } else if key == "projects" {
    section(t("projects"), for project in entries {
      entry(
        (
          link(project.url, strong(project.name)),
          link(project.url, text(fill: muted, display-url(project.url))),
        ).join(separator),
        details: (project.keywords.join(", "),),
        bullets: (project.summary,) + project.at("highlights", default: ()),
      )
    })
  } else if key == "publications" {
    let to-hayagriva(p) = (
      type: p.type,
      title: p.title,
      author: p.authors,
      date: p.year,
      parent: (type: "periodical", title: p.journal),
      ..if "doi" in p { (serial-number: (doi: p.doi)) },
    )
    section(t("publications"), bibliography(
      bytes(yaml.encode(entries.map(p => (p.id, to-hayagriva(p))).to-dict())),
      title: none,
      full: true,
      style: "apa",
    ))
  }
}

/// Renders the resume for one variant of the data.
#let resume(data, variant: "full") = {
  let errors = check(data)
  if errors.len() > 0 { panic(errors.join("\n")) }
  let data = select(data, variant)

  set document(
    title: data.title,
    author: data.person.name,
    keywords: data.person.headline,
    date: none,
  )
  set page(paper: "a4", margin: (x: 1.5cm, y: 1.3cm))
  set text(font: "Source Sans 3", size: 9.5pt, lang: data.locale)
  set par(leading: 0.5em, spacing: 0.8em)
  set list(
    marker: text(fill: accent, sym.bullet),
    indent: 0.3em,
    spacing: 0.5em,
  )
  show "'": sym.quote.r.single

  header(data.person)
  for key in data.order { render-section(key, data) }

  if data.variant.pages != none {
    context {
      let pages = counter(page).final().first()
      assert(
        pages <= data.variant.pages,
        message: "variant `"
          + data.variant.name
          + "` takes "
          + str(pages)
          + " pages, more than its limit of "
          + str(data.variant.pages),
      )
    }
  }
}
