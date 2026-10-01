#!/usr/bin/env bash
# Export .aseprite sources to sprite sheets + JSON inside the Godot content pack.
#
#   tools/export_aseprite.sh art-source/aseprite/characters/luffy.aseprite [more files...]
#   tools/export_aseprite.sh --all
#
# art-source/aseprite/<group>/<id>[_<form>].aseprite
#   -> game/content/$PACK/<group>/<id>/sprites/<id>[_<form>].png + .json
# Frames are never trimmed: character pivots depend on the full frame size.
set -euo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"
PACK="${PACK:-onepiece}"
ASEPRITE="${ASEPRITE:-$(command -v aseprite || echo /Applications/Aseprite.app/Contents/MacOS/aseprite)}"

if [[ ! -x "$ASEPRITE" ]]; then
  echo "Aseprite CLI not found. Install Aseprite or set ASEPRITE=/path/to/aseprite" >&2
  exit 1
fi

export_one() {
  local source="$1"
  local relative="${source#"$REPO"/}"
  relative="${relative#art-source/aseprite/}"
  local group="${relative%%/*}"
  local name
  name="$(basename "$source" .aseprite)"
  local owner="${name%%_*}"
  local out_dir="$REPO/game/content/$PACK/$group/$owner/sprites"
  mkdir -p "$out_dir"
  "$ASEPRITE" -b "$source" \
    --sheet "$out_dir/$name.png" \
    --data "$out_dir/$name.json" \
    --format json-array --list-tags --sheet-type packed
  echo "exported $relative -> ${out_dir#"$REPO"/}/$name.png"
}

if [[ "${1:-}" == "--all" ]]; then
  find "$REPO/art-source/aseprite" -name '*.aseprite' -print0 | while IFS= read -r -d '' file; do
    export_one "$file"
  done
else
  [[ $# -gt 0 ]] || { sed -n '2,8p' "$0"; exit 1; }
  for file in "$@"; do
    export_one "$(cd "$(dirname "$file")" && pwd)/$(basename "$file")"
  done
fi
