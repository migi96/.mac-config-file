#!/usr/bin/env bash
# Focus the Nth agent (1-based) by Herdr's agent-list order. Bound to the keys
# that used to switch kitty tabs:  ctrl+a=1  ctrl+alt+shift+z=2  ctrl+s=3  ctrl+q=4
# (see the [[keys.command]] entries in ~/.config/herdr/config.toml).
set -u

HERDR=/opt/homebrew/bin/herdr
PY=/usr/bin/python3
N="${1:-1}"

target=$("$HERDR" agent list 2>/dev/null | "$PY" -c '
import sys, json
try:
    agents = json.load(sys.stdin)["result"]["agents"]
except Exception:
    agents = []
i = int(sys.argv[1]) - 1
print(agents[i]["terminal_id"] if 0 <= i < len(agents) else "")
' "$N")

[ -n "$target" ] && "$HERDR" agent focus "$target"
