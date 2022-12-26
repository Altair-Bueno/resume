OUT_DIR           = out
DATA_DIR          = data
TEMPLATE_DIR      = templates
SCRIPT_DIR        = scripts

TARGET            = $(OUT_DIR)/resume.pdf
TEMPLATE_FILE     = $(TEMPLATE_DIR)/resume.mustache
DATA_FILE         = $(DATA_DIR)/resume.yml
SCHEME_FILE       = $(DATA_DIR)/scheme.json
THUMBNAIL_FILE    = .github/resources/thumbnail.png

PYTHON            = python3.11
VENV_DIR          = .venv
PREPARSER_SCRIPT  = $(SCRIPT_DIR)/preparser.py
SCHEME_SCRIPT     = $(SCRIPT_DIR)/scheme.py
THUMBNAIL_SCRIPT  = $(SCRIPT_DIR)/thumbnail.py

PREPARSER_CC      = $(VENV_DIR)/bin/python $(PREPARSER_SCRIPT)
PREPARSER_CCFLAGS =

THUMBNAIL_CC      = $(VENV_DIR)/bin/python $(THUMBNAIL_SCRIPT)
THUMBNAIL_CCFLAGS =

SCHEME_CC         = $(VENV_DIR)/bin/python $(SCHEME_SCRIPT)
SCHEME_CCFLAGS    =

SCHEME_CC         = $(VENV_DIR)/bin/python $(THUMBNAIL_SCRIPT)
SCHEME_CCFLAGS    =

MUSTACHE_CC       = $(VENV_DIR)/bin/chevron
MUSTACHE_CCFLAGS  = -l "<<" -r ">>" -w -p $(TEMPLATE_DIR)

LATEX_CC          = xelatex
LATEX_CCFLAGS     =

FORMATTER_CC      = $(VENV_DIR)/bin/black
FORMATTER_CCFLAGS = $(SCRIPT_DIR)

LATEX_DEPS        = enumitem \
                    sectsty

# Available targets
resume: $(TARGET) $(PREPARSER_SCRIPT)
scheme: $(SCHEME_FILE) $(SCHEME_SCRIPT)
thumbnail: $(THUMBNAIL_FILE) $(THUMBNAIL_SCRIPT)
deps: deps/python deps/latex
clean: clean/out
all: deps build thumbnail
fmt:
	 $(FORMATTER_CC) $(FORMATTER_CCFLAGS)

# deps
deps/python: $(VENV_DIR) requirements.txt
	$(VENV_DIR)/bin/pip-sync requirements.txt

deps/latex:
	sudo tlmgr update --self
	sudo tlmgr install $(LATEX_DEPS)

# build
$(THUMBNAIL_FILE): $(TARGET)
	$(THUMBNAIL_CC) $(THUMBNAIL_CCFLAGS) $(TARGET) $@

$(OUT_DIR)/%.pdf: $(OUT_DIR)/%.tex
	$(LATEX_CC) $(LATEX_CCFLAGS) -output-directory=$(OUT_DIR) $<

$(OUT_DIR)/%.tex: $(OUT_DIR)/%.json $(TEMPLATE_FILE)
	$(MUSTACHE_CC) $(MUSTACHE_CCFLAGS) -d $^ > $@

$(OUT_DIR)/%.json: $(DATA_FILE) $(OUT_DIR)
	$(PREPARSER_CC) $(PREPARSER_CCFLAGS) $< $@

$(OUT_DIR):
	mkdir $@

# Python deps
%.txt: %.in $(VENV_DIR)
	$(VENV_DIR)/bin/pip-compile $<

$(VENV_DIR): 
	$(PYTHON) -m venv $@
	$(VENV_DIR)/bin/pip install pip-tools

# scheme
$(SCHEME_FILE): $(SCRIPT_DIR)/*
	$(SCHEME_CC) $(SCHEME_CCFLAGS) > $@

# clean
clean/out:
	rm -fr $(OUT_DIR) $(OUT_DIR)

clean/venv: 
	rm -fr $(VENV_DIR)

.PHONY: build deps clean all fmt deps/python deps/latex clean/out clean/venv scheme
.PRECIOUS: $(OUT_DIR)/%.json $(OUT_DIR)/%.tex