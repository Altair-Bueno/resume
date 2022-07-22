OUT_DIR           = out
DATA_DIR          = data
TEMPLATE_DIR      = templates
SCRIPT_DIR        = scripts

TARGET            = $(OUT_DIR)/resume.pdf
TEMPLATE_FILE     = $(TEMPLATE_DIR)/resume.mustache
DATA_FILE         = $(DATA_DIR)/resume.yml
SCHEME_FILE       = $(DATA_DIR)/scheme.json

POETRY_EXEC       = poetry
PREPARSER_SCRIPT  = $(SCRIPT_DIR)/preparser.py
SCHEME_SCRIPT     = $(SCRIPT_DIR)/scheme.py

PREPARSER_CC      = $(POETRY_EXEC) run python $(PREPARSER_SCRIPT)
PREPARSER_CCFLAGS =

SCHEME_CC         = $(POETRY_EXEC) run python $(SCHEME_SCRIPT)
SCHEME_CCFLAGS    =

MUSTACHE_CC       = $(POETRY_EXEC) run chevron
MUSTACHE_CCFLAGS  = -l "<<" -r ">>" -w -p $(TEMPLATE_DIR)

LATEX_CC          = xelatex
LATEX_CCFLAGS     =

FORMATTER_CC      = $(POETRY_EXEC) run black
FORMATTER_CCFLAGS = $(SCRIPT_DIR)

LATEX_DEPS        = enumitem \
                    sectsty

# Available targets
build: $(TARGET) $(PREPARSER_SCRIPT)
scheme: $(SCHEME_FILE) $(SCHEME_SCRIPT)
deps: deps/poetry deps/latex
clean: clean/out
all: deps build
fmt:
	 $(FORMATTER_CC) $(FORMATTER_CCFLAGS)

# deps
deps/poetry:
	$(POETRY_EXEC) install

deps/latex:
	sudo tlmgr update --self
	sudo tlmgr install $(LATEX_DEPS)

# build
$(OUT_DIR)/%.pdf: $(OUT_DIR)/%.tex
	$(LATEX_CC) $(LATEX_CCFLAGS) -output-directory=$(OUT_DIR) $<

$(OUT_DIR)/%.tex: $(OUT_DIR)/%.json $(TEMPLATE_FILE)
	$(MUSTACHE_CC) $(MUSTACHE_CCFLAGS) -d $^ > $@

$(OUT_DIR)/%.json: $(DATA_FILE) $(OUT_DIR)
	$(PREPARSER_CC) $(PREPARSER_CCFLAGS) $< $@

$(OUT_DIR):
	mkdir $@

# scheme
$(SCHEME_FILE): $(SCRIPT_DIR)/*
	$(SCHEME_CC) $(SCHEME_CCFLAGS) > $@

# clean
clean/out:
	rm -fr $(OUT_DIR) $(OUT_DIR)

.PHONY: build deps clean all fmt deps/poetry deps/latex clean/out scheme
.PRECIOUS: $(OUT_DIR)/%.json $(OUT_DIR)/%.tex