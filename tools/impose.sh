#!/bin/sh
# Usage: tools/impose.sh build/menu.pdf  [build/menu-print.pdf]
# Produces a duplex-ready US Letter booklet. Print double-sided,
# "flip on short edge", then fold the stack in half.
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
