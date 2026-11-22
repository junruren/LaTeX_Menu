#!/bin/sh
# Usage: tools/impose.sh build/menu.pdf  [build/menu-print.pdf]
# Produces duplex-ready US Letter booklets, then fold the stack in half:
#   menu-print.pdf           print double-sided, flip on SHORT edge
#   menu-print-longedge.pdf  print double-sided, flip on LONG edge
#                            (back sides pre-rotated 180 degrees)
set -e
in="$1"
out="${2:-${in%.pdf}-print.pdf}"
[ -f "$in" ] || { echo "impose: '$in' not found" >&2; exit 1; }
here="$(cd "$(dirname "$0")" && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
abs_in="$(cd "$(dirname "$in")" && pwd)/$(basename "$in")"
( cd "$tmp" && pdflatex -interaction=batchmode -jobname=impose \
    "\def\menufile{$abs_in}\input{$here/impose.tex}" >/dev/null ) \
  || { echo "impose: pdflatex failed, see $tmp/impose.log" >&2; trap - EXIT; exit 1; }
mv "$tmp/impose.pdf" "$out"
echo "impose: wrote $out"

long="${out%.pdf}-longedge.pdf"
abs_out="$(cd "$(dirname "$out")" && pwd)/$(basename "$out")"
( cd "$tmp" && pdflatex -interaction=batchmode -jobname=longedge \
    "\def\printfile{$abs_out}\input{$here/impose-longedge.tex}" >/dev/null ) \
  || { echo "impose: pdflatex failed, see $tmp/longedge.log" >&2; trap - EXIT; exit 1; }
mv "$tmp/longedge.pdf" "$long"
echo "impose: wrote $long"
