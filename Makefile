OUT_DIR          = out
DATA_DIR         = data
TEMPLATE_DIR     = templates

TARGET           = $(OUT_DIR)/resume.pdf
TEMPLATE_FILE    = $(TEMPLATE_DIR)/jb2-modern.tex
PREPARSER_SCRIPT = scripts/preparser.py

MUSTACHE_CC      = poetry run chevron
MUSTACHE_ARGS    = -l "<<" -r ">>" -w

LATEX_DEPS       = enumitem \
                   sectsty

# Available targets
build: $(TARGET)
deps: poetry_deps latex_deps
clean: out_clean
all: deps build

# deps
poetry_deps:
	poetry install

latex_deps:
	sudo tlmgr update --self
	sudo tlmgr install $(LATEX_DEPS)

# build
$(OUT_DIR)/%.pdf: $(OUT_DIR)/%.tex $(OUT_DIR)
	xelatex -output-directory=$(OUT_DIR) $<

$(OUT_DIR)/%.tex: $(OUT_DIR)/%.json $(TEMPLATE_FILE)
	$(MUSTACHE_CC) $(MUSTACHE_ARGS) -d $^ > $@

$(OUT_DIR)/%.json: $(OUT_DIR) $(PREPARSER_SCRIPT) $(DATA_DIR)/%.toml
	poetry run python $(wordlist 2, 3, $^) $@

$(OUT_DIR):
	mkdir $@

# clean
out_clean:
	rm -fr $(OUT_DIR) $(OUT_DIR)

.PHONY: build deps clean all poetry_deps latex_deps out_clean
.PRECIOUS: $(OUT_DIR)/%.json $(OUT_DIR)/%.tex