# Resume

Altair's resume

![Thumbnail](https://github.com/Altair-Bueno/resume/releases/download/latest/thumbnail.png)

# Building

## Required software

- [Deno](https://deno.land)
- [Tectonic](https://github.com/tectonic-typesetting/tectonic)
- GNU Make

## Building the resume

This project uses GNU MakeFile to simplify the building process of the resume.
The quickest way to build the resume from scratch is to run `make all`. This
will install the required dependencies and build the PDF

## MakeFile command list

```bash
# Build the resume
make resume
# Generate the resume thumbnail (requires poppler-utils)
make thumbnail
# Cleanup
make clean
```

# License

All software is licensed under the MIT license ([license](LICENSE)), except for
the templates. Please refer to each template header on the
[`templates`](templates) directory All data under [`data`](data/) belongs to
Altair Bueno
