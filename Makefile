# ----------------------------------------------------------------------
#  make                       build every event menu
#  make E=20261121_Friendsgiving
#                             build one event
#  make new E=20261225_Christmas [FROM=20261121_Friendsgiving]
#                             start a new event from the template
#                             (or from a copy of an earlier event)
#  make catalog               glass reference -> shared/build/glass-catalog.pdf
#  make clean                 remove all build folders
#
#  Each event folder gets build/menu.pdf (screen) and
#  build/menu-print.pdf (print duplex, flip on short edge, fold).
# ----------------------------------------------------------------------
MENUS := $(if $(E),$(wildcard events/$(E)/*.tex),$(wildcard events/*/*.tex))

.PHONY: all new catalog clean

all:
	@test -n "$(MENUS)" || { echo "No menus found in events/$(or $(E),*)/"; exit 1; }
	@for f in $(MENUS); do sh tools/build.sh "$$f" || exit 1; done

new:
	@test -n "$(E)" || { echo "usage: make new E=YYYYMMDD_Name [FROM=existing_event]"; exit 1; }
	@sh tools/new-event.sh "$(E)" $(FROM)

catalog:
	@sh tools/build.sh --no-print shared/glass-catalog.tex

clean:
	rm -rf events/*/build shared/build
