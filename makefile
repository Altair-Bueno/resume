PANDOC_TEMPLATE=templates/jb2-modern.latex
PANDOC_ARGUMENTS=--pdf-engine=xelatex \
--from=markdown+rebase_relative_paths \
--template=$(PANDOC_TEMPLATE) \
--metadata-file=out/metadata.json

# Available targets
build: out/cv.pdf

clean:
	rm -fr out

# Aditional formulas

out/cv.pdf: out out/cv.tex
	cd out; xelatex cv.tex -output-directory=../out

out/cv.tex: scripts/template.py out/template.toml templates/jb2-modern.tex out
	python3 $(patsubst out,$@,$^)

out/template.toml: scripts/preparser.py data/template.toml
	python3 $^ $@

out:
	mkdir $@
