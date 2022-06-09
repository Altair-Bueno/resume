# PANDOC_TEMPLATE=templates/jb2-modern.latex
# PANDOC_ARGUMENTS=--pdf-engine=xelatex \
# --from=markdown+rebase_relative_paths \
# --template=$(PANDOC_TEMPLATE) \
# --metadata-file=out/metadata.json

# Available targets
build: out/resume.pdf

deps: poetry_deps latex_deps

clean: out_clean
	
all: deps build

# deps
poetry_deps:
	poetry install

latex_deps: latex.deps
	sudo tlmgr update --self
	sudo tlmgr install `cat $^ | xargs`

# build
out/resume.pdf: out out/resume.tex
	cd out; xelatex resume.tex -output-directory=../out

out/resume.tex: scripts/template.py out/template.toml templates/jb2-modern.tex out
	poetry run python $(patsubst out,$@,$^)

out/template.toml: scripts/preparser.py data/template.toml
	poetry run python $^ $@

out:
	mkdir $@

# clean
out_clean:
	rm -fr out
