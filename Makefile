OUT_DIR           = out
DATA_DIR          = data
TEMPLATE_DIR      = templates
SCRIPT_DIR        = scripts

TARGET            = $(OUT_DIR)/resume.pdf
TEMPLATE_FILE     = $(TEMPLATE_DIR)/resume.hbs
DATA_FILE         = $(DATA_DIR)/resume.yml
THUMBNAIL_FILE    = .github/resources/thumbnail.png

PYTHON            = python3.11
VENV_DIR          = .venv
THUMBNAIL_SCRIPT  = $(SCRIPT_DIR)/thumbnail.py

DENO              = deno
HBS_SCRIPT        = $(SCRIPT_DIR)/hbs.ts

THUMBNAIL_CC      = $(VENV_DIR)/bin/python $(THUMBNAIL_SCRIPT)
THUMBNAIL_CCFLAGS =

HBS_CC            = $(DENO) run -q -A $(HBS_SCRIPT)
HBS_CCFLAGS       = --hbs.noEscape --hbs.strict

LATEX_CC          = tectonic
LATEX_CCFLAGS     =

FORMATTER_CC      = $(VENV_DIR)/bin/black
FORMATTER_CCFLAGS = $(SCRIPT_DIR)

# Available targets
resume: $(OUT_DIR)/resume.pdf 
thumbnail: $(THUMBNAIL_FILE) $(THUMBNAIL_SCRIPT)
deps: deps/python
clean: clean/out
all: deps build thumbnail

# deps
deps/python: $(VENV_DIR) requirements.txt
	$(VENV_DIR)/bin/pip-sync requirements.txt

# build
$(THUMBNAIL_FILE): $(TARGET)
	$(THUMBNAIL_CC) $(THUMBNAIL_CCFLAGS) $(TARGET) $@

$(OUT_DIR)/%.pdf: $(OUT_DIR)/%.tex
	$(LATEX_CC) $(LATEX_CCFLAGS) --outdir=$(OUT_DIR) --color=always $<

$(OUT_DIR)/%.tex: $(DATA_DIR)/%.yml $(TEMPLATE_FILE) $(OUT_DIR)
	$(HBS_CC) $(HBS_CCFLAGS) -d $< $(TEMPLATE_FILE) -o $@

$(OUT_DIR):
	mkdir $@

# Python deps
%.txt: %.in $(VENV_DIR)
	$(VENV_DIR)/bin/pip-compile $<

$(VENV_DIR): 
	$(PYTHON) -m venv $@
	$(VENV_DIR)/bin/pip install pip-tools

# clean
clean/out:
	rm -fr $(OUT_DIR) $(OUT_DIR)

clean/venv: 
	rm -fr $(VENV_DIR)

.PHONY: resume thumbnail deps clean all deps/python clean/out clean/venv
.PRECIOUS: $(OUT_DIR)/%.json $(OUT_DIR)/%.tex
