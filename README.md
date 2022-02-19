# How to build

## Install required dependencies

- LaTeX 
  - macOS: Basictex
  - Linux: TexLive
- [Pandoc](https://pandoc.org/)
- [Python 3](https://www.python.org)
- Arial Font

```bash
# LaTeX packages
sudo tlmgr update --self
sudo tlmgr install enumitem sectsty
# Python packages
pip install chevron toml
```
## Generate the resume PDF

```bash
make
```

The resume will be available at `out/cv.pdf`