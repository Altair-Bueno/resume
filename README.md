# How to build

## Install required dependencies

- LaTeX 
  - macOS: Basictex
  - Linux: TexLive
- Make
- [Python 3](https://www.python.org)
- Arial Font

On the terminal run:

```bash
# LaTeX packages
sudo tlmgr update --self
sudo tlmgr install enumitem sectsty
# Python packages
pip install chevron toml python-dateutil
```
## Generate the resume PDF

On the terminal run:

```bash
make
```

The resume will be available at `out/cv.pdf`

# License

All software is licensed under the MIT license ([see](LICENSE)), except for the
LaTeX template. For more information read the [license](templates/README.md#license)