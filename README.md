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

Use LuaTeX, not XeTeX. Both need the `sourcesanspro` `type1` option to emit real
space glyphs, but XeTeX's `xdvipdfmx` additionally maps f-ligature glyphs to
U+FB01/U+FB02, which leaves words like `InfluxDB` and `CERTIFICATIONS`
unsearchable in the extracted text.

# License

All software is licensed under the MIT license ([license](LICENSE)), except for
the templates. Please refer to each template header on the
[`templates`](templates) directory All data under [`data`](data/) belongs to
Altair Bueno
