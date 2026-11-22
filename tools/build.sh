#!/bin/sh
# Build one menu:   tools/build.sh [--no-print] events/<event>/menu.tex
#   -> events/<event>/build/menu.pdf        one panel per page (screen / proofing)
#   -> events/<event>/build/menu-print.pdf  imposed on US Letter for duplex printing
# The shared class and icons in shared/ are put on TeX's search path, so a
# menu can live in any folder.
set -e
print=1
if [ "$1" = "--no-print" ]; then print=0; shift; fi
[ $# -eq 1 ] || { echo "usage: $0 [--no-print] path/to/menu.tex" >&2; exit 2; }
[ -f "$1" ] || { echo "build: '$1' not found" >&2; exit 1; }

root="$(cd "$(dirname "$0")/.." && pwd)"
dir="$(cd "$(dirname "$1")" && pwd)"
name="$(basename "$1" .tex)"

# "." first so a class copied into an event folder overrides the shared one;
# the trailing ":" keeps TeX's default search path.
TEXINPUTS=".:$root/shared:${TEXINPUTS:-}"
export TEXINPUTS

cd "$dir"
latexmk -xelatex -synctex=1 -interaction=nonstopmode -file-line-error \
        -outdir=build "$name.tex"
# Only half-letter menus (class cocktailmenu) get the folded-booklet version;
# full-page documents such as the bartender cheatsheet are printed as-is.
if [ "$print" = 1 ] && grep -q '{cocktailmenu}' "$name.tex"; then
  sh "$root/tools/impose.sh" "build/$name.pdf"
fi
