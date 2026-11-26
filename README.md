# Resume

Altair's resume

![Thumbnail](https://github.com/Altair-Bueno/resume/releases/latest/download/thumbnail.png)

# Variants

[`data/resume.yml`](data/resume.yml) holds every entry once, and
[`data/resume.schema.json`](data/resume.schema.json) types it. Editors with the
YAML language server (VS Code's YAML extension, Zed, Neovim) pick the schema up
from the first line of the data file, for completion and inline errors.

Each profile under `variants` decides what it shows:

- `tags`: show tagged items carrying any of these tags. Untagged items appear in
  every variant. Omit `tags` to show everything, as `full` does.
- `hide`: leave out specific items by `id`.
- `headline` and `summary`: replace the person's defaults.

Sections, skill items and highlights can all carry `id` and `tags`:

```yaml
variants:
  full: {}
  embedded:
    tags: [embedded]
    hide: [cost-paper]
    summary: Optional summary for this variant only
experience:
  - title: Some position
    highlights:
      - Shown in every variant
      - text: Shown in embedded and full
        tags: [embedded]
      - id: cost-paper
        text: Shown everywhere except embedded
```

The schema checks structure. The template checks references: an unknown tag, a
duplicate id or a hidden id that doesn't exist fails the build.

# Building

[`.github/workflows/ci.yml`](.github/workflows/ci.yml) is the single source of
truth for how the resume is built. Each release ships `resume.pdf` (the `full`
variant), `thumbnail.png`, and `resume-<variant>.pdf` for every other variant.

## Required software

- [Typst](https://typst.app) (e.g. `brew install typst`), or any OCI runtime
  with the `ghcr.io/typst/typst` image
- [check-jsonschema](https://github.com/python-jsonschema/check-jsonschema)
  (e.g. `brew install check-jsonschema`) to validate the data

Fonts are vendored in [`fonts`](fonts) so builds don't depend on what is
installed on the machine.

## Building the resume

```bash
export TYPST_ROOT=. TYPST_FONT_PATHS=fonts TYPST_IGNORE_SYSTEM_FONTS=true

# Validate the data
check-jsonschema --schemafile data/resume.schema.json data/resume.yml

# Full resume
typst compile templates/resume.typ out/resume.pdf

# A specific variant
typst compile --input variant=embedded templates/resume.typ out/resume-embedded.pdf

# Thumbnail
typst compile --pages 1 --ppi 150 templates/resume.typ out/thumbnail.png

# Live preview while editing
typst watch templates/resume.typ out/resume.pdf
```

# License

All software is licensed under the MIT license ([license](LICENSE)), except for
the templates and fonts. Please refer to each template header on the
[`templates`](templates) directory, and to
[`fonts/LICENSE.txt`](fonts/LICENSE.txt) (SIL Open Font License 1.1) for Source
Sans 3. All data under [`data`](data/) belongs to Altair Bueno
