# Resume

Altair's resume

![Thumbnail](https://github.com/Altair-Bueno/resume/releases/download/latest/thumbnail.png)

# Building

## Required software

- Python3.11
- [Tectonic](https://github.com/tectonic-typesetting/tectonic)
- GNU Make
- Arial Font

> Note: Arial might be already installed on the system

## Building the resume

This project uses GNU MakeFile to simplify the building process of the resume.
The quickest way to build the resume from scratch is to run `make all`. This
will install the required dependencies and build the PDF

## MakeFile command list

```bash
# Install dependencies
make deps
# Build the resume
make resume
# Generate the resume thumbnail (requires poppler-utils)
make thumbnail
# Install dependencies and build
make all
# Cleanup
make clean
```

# License

All software is licensed under the MIT license ([license](LICENSE)), except for
the [LaTeX template](templates/README.md#license). All the data belongs to
Altair Bueno
