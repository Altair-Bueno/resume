// Rezume, a resume template for developers
// Author: Nanu Panchamurthy
// Based off of: https://www.overleaf.com/latex/templates/rezume/kfrvqywfkwjs
// License: MIT

#let data = yaml(sys.inputs.at("data", default: "/data/resume.yml"))

#metadata(data.variants.keys()) <variants>

#let variant = sys.inputs.at("variant", default: "full")
#let profile = data.variants.at(variant)

#let collect-ids(value) = if type(value) == dictionary {
  let own = if "id" in value { (value.id,) } else { () }
  own + value.values().map(collect-ids).flatten()
} else if type(value) == array {
  value.map(collect-ids).flatten()
} else { () }
#let ids = {
  let content = data
  let _ = content.remove("variants")
  collect-ids(content)
}
#let known-tags = (
  data.variants.values().map(v => v.at("tags", default: ())).flatten()
)
#for id in ids.dedup() {
  assert(
    ids.filter(x => x == id).len() == 1,
    message: "duplicate id `" + id + "`",
  )
}
#for (name, v) in data.variants {
  for id in v.at("hide", default: ()) {
    assert(
      id in ids,
      message: "variant `" + name + "` hides unknown id `" + id + "`",
    )
  }
}

#let keep(item) = {
  if type(item) != dictionary { return true }
  let tags = item.at("tags", default: ())
  for tag in tags {
    assert(
      tag in known-tags,
      message: "tag `" + tag + "` is not used by any variant",
    )
  }
  if item.at("id", default: none) in profile.at("hide", default: ()) {
    return false
  }
  let wanted = profile.at("tags", default: none)
  wanted == none or tags.len() == 0 or tags.any(t => t in wanted)
}
#let section(key) = data.at(key, default: ()).filter(keep)
#let pick(item, key) = item.at(key, default: ()).filter(keep)
#let text-of(item) = if type(item) == dictionary { item.text } else { item }

#let format-month(month) = {
  let (year, month) = month.split("-").map(int)
  datetime(year: year, month: month, day: 1).display(
    "[month repr:short] [year]",
  )
}
#let period(entry) = {
  format-month(entry.start)
  " - "
  if "end" in entry { format-month(entry.end) } else { "Present" }
}

#let accent = rgb("#0000ff")

#set document(title: data.title, author: data.person.name)
#set text(font: "Source Sans 3", size: 10pt, lang: data.locale)
#set page(paper: "a4", margin: 0.5in)
#show "'": "’"
#set par(leading: 0.5em, spacing: 0.6em)
#set list(marker: [•], indent: 0.25in, body-indent: 0.6em, spacing: 0.8em)
#show heading.where(level: 1): it => block(above: 1.6em, below: 0.8em, {
  set text(size: 12pt, weight: "regular", fill: accent)
  smallcaps(it.body)
  v(-0.6em)
  line(length: 100%, stroke: 0.4pt)
})

#let ulink(dest, body) = link(dest, underline(offset: 2pt, body))
#let entries(body) = pad(left: 0.15in, body)
#let items(xs) = {
  set text(size: 9pt)
  pad(right: 0.11in, list(..xs.map(text-of)))
}
#let two-columns(start, end) = grid(
  columns: (1fr, auto),
  align: (left, right),
  column-gutter: 1em,
  start, end,
)

// Contact details
#{
  let person = data.person
  let address = person.address
  two-columns(
    text(size: 25pt, weight: "bold", person.name),
    [#address.city, #address.region, #address.country],
  )
  v(-0.2em)
  let website = if "website" in person {
    (ulink(person.website)[Website],)
  } else { () }
  two-columns(
    (
      website
        + person.at("profiles", default: ()).map(p => ulink(p.url, p.network))
    ).join(" | "),
    [
      #ulink("mailto:" + person.email, person.email) |
      #ulink("tel:" + person.phone.replace(" ", ""), person.phone)
    ],
  )
}

// Summary
= #profile.at("headline", default: data.person.headline)
#text(size: 9pt, profile.at("summary", default: data.person.summary))

// Skills
#let skills = section("skills")
#let languages = section("languages")
#if skills.len() + languages.len() > 0 [
  = Skills
  #entries(grid(
    columns: (0.15fr, auto, 0.81fr),
    column-gutter: (0pt, 0.6em),
    row-gutter: 0.6em,
    align: (right, left, left),
    ..skills
      .map(s => (strong(s.name), [:], pick(s, "items").map(text-of).join(", ")))
      .flatten(),
    ..if languages.len() > 0 {
      (
        strong("Languages"),
        [:],
        languages.map(l => l.name + " (" + l.level + ")").join(", "),
      )
    },
  ))
]

// Experience
#let experience = section("experience")
#if experience.len() > 0 [
  = Experience
  #entries(for position in experience {
    block(above: 1.2em, below: 0.8em, {
      two-columns(strong(position.title), period(position))
      v(-0.3em)
      set text(size: 9pt, style: "italic")
      two-columns(
        link(position.organization.url, position.organization.name),
        position.at("location", default: ""),
      )
    })
    let highlights = pick(position, "highlights")
    if highlights.len() > 0 { items(highlights) }
  })
]

// Education
#let education = section("education")
#if education.len() > 0 [
  = Education
  #entries(for degree in education {
    block(above: 1.2em)[
      #link(degree.institution.url, strong(degree.institution.name)) \
      #text(size: 9pt, style: "italic")[
        #degree.degree of #degree.field#if "grade" in degree [. #degree.grade], #period(degree)
      ]
    ]
  })
]

// Certifications
#let certifications = section("certifications")
#if certifications.len() > 0 [
  = Certifications
  #items(certifications.map(c => ulink(
    c.url,
    c.name + " from " + c.issuer + " - " + format-month(c.date),
  )))
]

// Projects
#let projects = section("projects")
#if projects.len() > 0 [
  = Open Source projects
  #entries(for project in projects {
    block(above: 1.2em, below: 0.8em, grid(
      columns: (1fr, auto, 1fr),
      align: (left, center, right),
      strong(project.name),
      emph(project.keywords.join(", ")),
      ulink(project.url)[Source Code],
    ))
    items((project.summary,) + pick(project, "highlights"))
  })
]

// Publications
#let publications = section("publications")
#if publications.len() > 0 [
  = Publications
  #set text(size: 9pt)
  #let to-hayagriva(p) = (
    type: p.type,
    title: p.title,
    author: p.authors,
    date: p.year,
    parent: (type: "periodical", title: p.journal),
    ..if "doi" in p { (serial-number: (doi: p.doi)) },
  )
  #let library = publications.map(p => (p.id, to-hayagriva(p))).to-dict()
  #bibliography(
    bytes(yaml.encode(library)),
    title: none,
    full: true,
    style: "apa",
  )
]
