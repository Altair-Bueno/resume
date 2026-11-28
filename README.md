# Resume

Altair's resume

![Thumbnail](https://github.com/Altair-Bueno/resume/releases/latest/download/thumbnail.png)

The resume is written in [Typst](https://typst.app). The data lives in
[`data/resume.yml`](data/resume.yml), typed by
[`docs/resume.schema.json`](docs/resume.schema.json), and the template lives in
[`src`](src). The data defines several variants, each tailored to a role. Every
release ships `resume.pdf` (the `full` variant), `resume-<variant>.pdf` for the
rest, and `thumbnail.png`.

# Requirements

[mise](https://mise.jdx.dev) (e.g. `brew install mise`). It installs every other
tool at the version pinned in [`mise.toml`](mise.toml), and sets the environment
Typst needs.

```bash
mise trust && mise install
mise generate git-pre-commit --write  # Run the checks before each commit
```

# Build

```bash
mise run validate        # Check the data against the schema
mise run build           # out/resume.pdf and out/thumbnail.png
mise run build embedded  # out/resume-embedded.pdf
mise run watch           # Live preview while editing
```

# Test

```bash
mise run test           # Template tests, against tests/fixtures/resume.yml
mise run reading-order  # Check that extracted text keeps its reading order
mise run fmt            # Check formatting
mise x -- tt update     # Accept an intended layout change
```

# License

The software is MIT licensed ([LICENSE](LICENSE)). The layout derives from
Rezume (see [`src/lib/components.typ`](src/lib/components.typ)), Source Sans 3
is under the [SIL Open Font License 1.1](src/fonts/LICENSE.txt), and the data
under [`data`](data) belongs to Altair Bueno.
