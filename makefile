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

out/cv.pdf: $(PANDOC_TEMPLATE) out out/cv.md out/metadata.json
	pandoc $(PANDOC_ARGUMENTS) --output=$@ out/cv.md

out/cv.md: scripts/template.py data/template.toml src/cv.md.mustache out
	python3 $(patsubst out,$@,$^)

out/metadata.json: scripts/metadata.py data/template.toml out
	python3 $(patsubst out,$@,$^)

out:
	mkdir $@
