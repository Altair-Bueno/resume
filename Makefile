OUT_DIR           = out
DATA_DIR          = data
TEMPLATE_DIR      = templates
SCRIPT_DIR        = scripts

TARGET            = $(OUT_DIR)/resume.pdf
TEMPLATE_FILE     = $(TEMPLATE_DIR)/rezume.hbs
DATA_FILE         = $(DATA_DIR)/resume.yml
THUMBNAIL_FILE    = $(OUT_DIR)/thumbnail.png

DENO              = deno
HBS_SCRIPT        = $(SCRIPT_DIR)/hbs.ts

THUMBNAIL_CC      = pdftoppm
THUMBNAIL_CCFLAGS = -png -singlefile

HBS_CC            = $(DENO) run \
                    -q \
                    --allow-read=. \
					--allow-write=. \
					--no-prompt \
					$(HBS_SCRIPT)
HBS_CCFLAGS       = --hbs.strict

LATEX_CC          = tectonic
LATEX_CCFLAGS     =

# Available targets
resume: $(OUT_DIR)/resume.pdf 
thumbnail: $(THUMBNAIL_FILE) $(THUMBNAIL_SCRIPT)
clean: clean/out

# build
# pdftoppm -png -singlefile out/resume.pdf 
$(THUMBNAIL_FILE): $(TARGET)
	$(THUMBNAIL_CC) $(THUMBNAIL_CCFLAGS) $< $(basename $@) 

$(OUT_DIR)/%.pdf: $(OUT_DIR)/%.tex
	$(LATEX_CC) $(LATEX_CCFLAGS) --outdir=$(OUT_DIR) --color=always $<

$(OUT_DIR)/%.tex: $(DATA_DIR)/%.yml $(TEMPLATE_FILE) $(OUT_DIR)
	$(HBS_CC) $(HBS_CCFLAGS) -d $< $(TEMPLATE_FILE) -o $@

$(OUT_DIR):
	mkdir $@

# clean
clean/out:
	rm -fr $(OUT_DIR) $(OUT_DIR)

.PHONY: resume thumbnail clean all clean/out
.PRECIOUS: $(OUT_DIR)/%.json $(OUT_DIR)/%.tex
