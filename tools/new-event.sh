#!/bin/sh
# Start a new event menu.
#   tools/new-event.sh 20261225_Christmas                          # from shared/template.tex
#   tools/new-event.sh 20261225_Christmas 20261121_Friendsgiving   # copy an earlier event's .tex files
set -e
root="$(cd "$(dirname "$0")/.." && pwd)"
name="$1"
from="$2"
[ -n "$name" ] || { echo "usage: $0 <YYYYMMDD_Name> [<existing event to copy>]" >&2; exit 2; }
case "$name" in
  *[!A-Za-z0-9._-]*) echo "new-event: use letters, digits, '-', '_' or '.' only (no spaces): '$name'" >&2; exit 1 ;;
esac
dest="$root/events/$name"
[ ! -e "$dest" ] || { echo "new-event: events/$name already exists" >&2; exit 1; }
if [ -n "$from" ]; then
  # copy every .tex of the earlier event (menu, cheatsheet, ...)
  [ -d "$root/events/$from" ] || { echo "new-event: events/$from not found" >&2; exit 1; }
  mkdir -p "$dest"
  cp "$root/events/$from"/*.tex "$dest"/
  echo "new-event: created events/$name/ ($(cd "$dest" && ls *.tex | tr '\n' ' ')) from events/$from"
else
  src="$root/shared/template.tex"
  mkdir -p "$dest"
  cp "$src" "$dest/menu.tex"
  echo "new-event: created events/$name/menu.tex (from shared/template.tex)"
fi
