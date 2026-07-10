#!/usr/bin/env bash
# Jump to the Herdr tab running wisp (my WhatsApp TUI), creating it and
# launching wisp automatically if it doesn't exist yet.
#
# Bound to `prefix+t` via a [[keys.command]] entry in ~/.config/herdr/config.toml.
# The wisp tab is identified by its label ("wisp"), which this script sets when
# it creates the tab — so repeat presses just focus the same tab.
set -u

HERDR=/opt/homebrew/bin/herdr
PY=/usr/bin/python3
WISP=/Users/migbyte/Projects/wisp/target/release/wisp
LABEL=wisp

# 1) Already have a tab labeled "wisp"? Focus it and stop.
tab_id="$("$HERDR" tab list 2>/dev/null | "$PY" -c '
import sys, json
try:
    tabs = json.load(sys.stdin)["result"]["tabs"]
except Exception:
    sys.exit(0)
for t in tabs:
    if t.get("label") == "wisp":
        print(t.get("tab_id", ""))
        break
')"

if [ -n "$tab_id" ]; then
    "$HERDR" tab focus "$tab_id"
    exit 0
fi

# 2) Otherwise create a focused tab labeled "wisp" and launch wisp in its pane.
pane_id="$("$HERDR" tab create --label "$LABEL" --focus 2>/dev/null | "$PY" -c '
import sys, json
try:
    print(json.load(sys.stdin)["result"]["root_pane"]["pane_id"])
except Exception:
    pass
')"

if [ -n "$pane_id" ]; then
    "$HERDR" pane run "$pane_id" "$WISP"
fi
