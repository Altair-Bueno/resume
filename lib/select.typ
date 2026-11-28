#let sections = (
  "skills",
  "languages",
  "experience",
  "education",
  "certifications",
  "projects",
  "publications",
)
#let nested = (
  skills: "items",
  experience: "highlights",
  projects: "highlights",
)

#let collect(value, key) = if type(value) == dictionary {
  let own = if key in value {
    let found = value.at(key)
    if type(found) == array { found } else { (found,) }
  } else { () }
  own + value.values().map(v => collect(v, key)).flatten()
} else if type(value) == array {
  value.map(v => collect(v, key)).flatten()
} else { () }

#let content-of(data) = sections.filter(s => s in data).map(s => data.at(s))

/// Cross-reference problems the schema cannot express, as messages.
#let check(data) = {
  let errors = ()
  let ids = collect(content-of(data), "id")
  for id in ids.dedup() {
    if ids.filter(x => x == id).len() > 1 {
      errors.push("duplicate id `" + id + "`")
    }
  }
  let known-tags = collect(data.variants.values(), "tags")
  for tag in collect(content-of(data), "tags").dedup() {
    if tag not in known-tags {
      errors.push("tag `" + tag + "` is not used by any variant")
    }
  }
  for (name, variant) in data.variants {
    for id in variant.at("hide", default: ()) {
      if id not in ids {
        errors.push("variant `" + name + "` hides unknown id `" + id + "`")
      }
    }
  }
  errors
}

#let keep(item, variant) = {
  if type(item) != dictionary { return true }
  if item.at("id", default: none) in variant.at("hide", default: ()) {
    return false
  }
  let tags = item.at("tags", default: ())
  let wanted = variant.at("tags", default: none)
  wanted == none or tags.len() == 0 or tags.any(t => t in wanted)
}

#let plain(item) = if type(item) == dictionary { item.text } else { item }

/// The data as one variant shows it: hidden items removed, text items
/// reduced to strings, person overrides applied and sections ordered.
#let select(data, name) = {
  assert(name in data.variants, message: "unknown variant `" + name + "`")
  let variant = data.variants.at(name)
  let out = (
    title: data.title,
    locale: data.locale,
    variant: (name: name, pages: variant.at("pages", default: none)),
    person: data.person,
    order: variant.at("sections", default: sections),
  )
  for key in ("headline", "summary") {
    if key in variant { out.person.insert(key, variant.at(key)) }
  }
  for key in sections.filter(s => s in data) {
    let entries = data.at(key).filter(item => keep(item, variant))
    if key in nested {
      let field = nested.at(key)
      entries = entries.map(entry => {
        let entry = entry
        if field in entry {
          entry.insert(
            field,
            entry.at(field).filter(item => keep(item, variant)).map(plain),
          )
        }
        entry
      })
    }
    out.insert(key, entries)
  }
  out
}
