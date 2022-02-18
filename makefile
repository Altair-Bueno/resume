PANDOC_TEMPLATE=resume-pandoc/templates/jb2-modern.latex
PANDOC_DEPENDENT_FILES=$(PANDOC_TEMPLATE) out out/cv.md out/metadata.yaml
PANDOC_ARGUMENTS=--pdf-engine=xelatex --from=markdown+rebase_relative_paths --template=$(PANDOC_TEMPLATE) --metadata-file=out/metadata.yaml

out/cv.pdf: $(PANDOC_DEPENDENT_FILES)
	pandoc $(PANDOC_ARGUMENTS) --output=$@ out/cv.md

out/cv.md: scripts/template.py data/template.toml src/cv.md.mustache out
	python3 $(patsubst out,$@,$^)

out/metadata.yaml: scripts/metadata.py data/template.toml out
	python3 $(patsubst out,$@,$^)

out:
	mkdir $@

clean:
	rm -fr out || true