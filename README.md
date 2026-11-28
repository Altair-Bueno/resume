# Resume

Altair's resume

![Thumbnail](https://github.com/Altair-Bueno/resume/releases/latest/download/thumbnail.png)

The resume is written in [Typst](https://typst.app). The data lives in
[`data/resume.yml`](data/resume.yml), typed by
[`docs/resume.schema.json`](docs/resume.schema.json), and the template lives in
[`src`](src). The data defines several variants, each tailored to a role. Every
release ships `resume-<variant>.pdf` for each of them, plus `thumbnail.png`.

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
mise run build           # out/resume-full.pdf
mise run build embedded  # out/resume-embedded.pdf
mise run thumbnail       # out/thumbnail.png, from full (or pass a variant)
mise run watch           # Live preview while editing
```

# Test

```bash
mise run test           # Template tests, against tests/fixtures/resume.yml
mise run reading-order  # Check that extracted text keeps its reading order
mise run fmt            # Check formatting
mise x -- tt update     # Accept an intended layout change
```

# Release

Releases are manual. Run the CI workflow on `master` from the Actions tab, or:

```bash
gh workflow run ci.yml --ref master
```

# License

The software is MIT licensed ([LICENSE](LICENSE)). The layout derives from
Rezume (see [`src/lib/components.typ`](src/lib/components.typ)), Source Sans 3
is under the [SIL Open Font License 1.1](src/fonts/LICENSE.txt), and the data
under [`data`](data) belongs to Altair Bueno.
