# ----------------------------------------------------------------------
#  make              build every menu (*.tex in this folder, except
#                    glass-catalog) + its print-ready version
#  make menu         build just menu.tex  ->  build/menu.pdf, build/menu-print.pdf
#  make catalog      build the glass reference sheet
#  make watch        rebuild menu.tex on every save
#  make clean        remove build/
# ----------------------------------------------------------------------
BUILD   := build
DEPS    := cocktailmenu.cls cocktailglasses.sty
MENUS   := $(filter-out glass-catalog,$(basename $(wildcard *.tex)))

.PHONY: all catalog watch clean $(MENUS)

all: $(MENUS)

$(MENUS): %: $(BUILD)/%-print.pdf

catalog: $(BUILD)/glass-catalog.pdf

# (print rule listed first: GNU make 3.81 picks the first matching pattern)
$(BUILD)/%-print.pdf: $(BUILD)/%.pdf tools/impose.tex tools/impose.sh
	@sh tools/impose.sh $< $@

$(BUILD)/%.pdf: %.tex $(DEPS)
	latexmk -xelatex -outdir=$(BUILD) $<

watch:
	latexmk -xelatex -pvc -outdir=$(BUILD) menu.tex

clean:
	rm -rf $(BUILD)
