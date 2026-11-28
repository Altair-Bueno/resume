#import "/lib/select.typ": check, select

#let data = yaml("/tests/fixtures/resume.yml")
#let texts(entry) = entry.highlights

// The fixture is consistent.
#assert.eq(check(data), ())

// `full` shows everything and reduces text items to strings.
#let full = select(data, "full")
#assert.eq(full.experience.len(), 2)
#assert.eq(texts(full.experience.first()), (
  "Shared highlight",
  "Alpha highlight",
  "Beta highlight",
  "Hidden in alpha",
))
#assert.eq(full.skills.first().items, (
  "Rust (tokio, no_std)",
  "Alpha-only skill",
))
#assert.eq(full.person.headline, "Software Engineer")
#assert.eq(full.variant, (name: "full", pages: none))

// Tags keep untagged items and items sharing a tag; `hide` drops ids.
#let alpha = select(data, "alpha")
#assert.eq(alpha.experience.map(p => p.title), ("Position One",))
#assert.eq(texts(alpha.experience.first()), (
  "Shared highlight",
  "Alpha highlight",
))
#assert.eq(alpha.skills.map(g => g.name), ("Systems",))
#assert.eq(alpha.person.headline, "Alpha Engineer")
#assert.eq(alpha.person.summary, data.person.summary)
#assert.eq(alpha.variant, (name: "alpha", pages: 1))

#let beta = select(data, "beta")
#assert.eq(beta.experience.map(p => p.title), ("Position One", "Position Two"))
#assert.eq(texts(beta.experience.first()), (
  "Shared highlight",
  "Beta highlight",
  "Hidden in alpha",
))
#assert.eq(beta.skills.first().items, ("Rust (tokio, no_std)",))

// `sections` picks and orders sections.
#assert.eq(select(data, "reordered").order, ("education", "experience"))
#assert.eq(full.order.first(), "skills")

// Cross-reference problems are reported, not ignored.
#let broken = data
#broken.experience.first().highlights.push((id: "shared-hidden", text: "Twin"))
#broken.experience.first().highlights.push((text: "Typo", tags: ("alpah",)))
#broken.variants.alpha.hide.push("missing")
#assert.eq(check(broken), (
  "duplicate id `shared-hidden`",
  "tag `alpah` is not used by any variant",
  "variant `alpha` hides unknown id `missing`",
))
