#!/usr/bin/env bash
# Run the gdUnit4 test suite headless. Usage: tools/run_tests.sh [extra gdUnit4 args]
set -euo pipefail
REPO="$(cd "$(dirname "$0")/.." && pwd)"
export GODOT_BIN="${GODOT_BIN:-/Applications/Godot.app/Contents/MacOS/Godot}"
cd "$REPO/game"
"$GODOT_BIN" --headless --path . --import > /dev/null 2>&1
# Our tests do not depend on UI input events, so gdUnit4's headless guard is not needed.
./addons/gdUnit4/runtest.sh --headless --ignoreHeadlessMode -a res://tests "$@"
