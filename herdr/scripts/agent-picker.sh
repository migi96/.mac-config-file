#!/usr/bin/env bash
# fzf agent picker: list every agent (Claude session) by name + directory, fuzzy-
# select one, and focus it. Bound to `prefix+f` via [[keys.command]] (type =
# "pane") in ~/.config/herdr/config.toml, so it runs in a throwaway pane that
# herdr closes when the script exits. The focused agent is marked with ●.
set -u
HERDR=/opt/homebrew/bin/herdr
FZF=/opt/homebrew/bin/fzf
PY=/usr/bin/python3
TAB=$'\t'

# Rows: "<●/  ><name padded>  <cwd>" <TAB> "<terminal_id>"  (terminal_id hidden).
rows="$("$HERDR" agent list 2>/dev/null | "$PY" -c '
import sys, json, os
try:
    agents = json.load(sys.stdin)["result"]["agents"]
except Exception:
    sys.exit(0)
home = os.path.expanduser("~")
for a in agents:
    tid = a.get("terminal_id")
    if not tid:
        continue
    name = a.get("name") or a.get("agent") or "agent"
    cwd = a.get("cwd") or ""
    if cwd.startswith(home):
        cwd = "~" + cwd[len(home):]
    star = "● " if a.get("focused") else "  "
    print(f"{star}{name:<18} {cwd}\t{tid}")
')"

[ -n "$rows" ] || exit 0

sel="$(printf '%s\n' "$rows" | "$FZF" \
    --delimiter="$TAB" \
    --with-nth=1 \
    --nth=1 \
    --reverse \
    --prompt 'agent ❯ ' \
    --header 'Enter: focus agent · Esc: cancel' \
    2>/dev/null)"
[ -n "$sel" ] || exit 0

# The hidden 2nd (tab-separated) field is the terminal_id.
term_id="$(printf '%s\n' "$sel" | awk -F "$TAB" '{print $2}')"
[ -n "$term_id" ] && "$HERDR" agent focus "$term_id"
exit 0
