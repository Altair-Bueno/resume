# Resume

Altair's resume

![Thumbnail](https://github.com/Altair-Bueno/resume/releases/latest/download/thumbnail.png)

# Building

[`.github/workflows/ci.yml`](.github/workflows/ci.yml) is the single source of
truth for how the resume is built. Each stage runs in the image that owns its
toolchain, so the only thing you need locally is an OCI runtime.

## Required software

- Docker, Podman, or any other OCI runtime

## Building the resume

The three commands below are the same ones CI runs, in the same images.

```bash
mkdir -p out

# 1. Render the LaTeX source from data/resume.yml
docker run --rm -v "$PWD:/w" -w /w denoland/deno:latest \
  deno run -q --allow-read=. --allow-write=. --no-prompt \
    scripts/hbs.ts --hbs.strict \
    -d data/resume.yml templates/rezume.hbs -o out/resume.tex

# 2. Compile the PDF
docker run --rm -v "$PWD:/w" -w /w texlive/texlive:latest \
  lualatex -interaction=nonstopmode -halt-on-error \
    -output-directory=out out/resume.tex

# 3. Render the thumbnail
docker run --rm -v "$PWD:/w" -w /w minidocks/poppler:latest \
  pdftoppm -png -singlefile out/resume.pdf out/thumbnail

# Cleanup
rm -rf out
```

Use LuaTeX, not XeTeX, and keep the `sourcesanspro` `type1` option.

No TeX engine emits space glyphs — there are none in the PDF at all. Word gaps
are `TJ` offsets, and text extractors tell them apart from letter kerns by
magnitude. `type1` is what makes that work: TeX kerns only a handful of letter
pairs, so word gaps stand out as distinctly larger. Without it XeTeX positions
every glyph through HarfBuzz and the two blur together, at which point `pypdf`
returns the whole document as one run-together string. XeTeX also maps
f-ligature glyphs to U+FB01/U+FB02, leaving words like `InfluxDB` and
`CERTIFICATIONS` unsearchable.

# License

All software is licensed under the MIT license ([license](LICENSE)), except for
the templates. Please refer to each template header on the
[`templates`](templates) directory All data under [`data`](data/) belongs to
Altair Bueno
