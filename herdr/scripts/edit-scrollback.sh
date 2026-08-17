#!/usr/bin/env bash
# prefix+e: open the CURRENT pane's scrollback in nvim, IN COLOR (ANSI preserved)
# and scrollable to the very top. Replaces herdr's built-in edit_scrollback, which
# was monochrome and viewport-only. Bound via [[keys.command]] (type = "shell").
#
# Capture uses --source recent (the whole retained scrollback, not just what's on
# screen) + --format ansi (keep the colors). The viewer opens in its own tab and
# returns you to the source tab on quit (q / Esc).
#
# LIMITATION: a full-screen app that owns the alternate screen (claude, wisp, nvim)
# has NO terminal scrollback above the visible screen — the app redraws its own
# screen and never emits history to the terminal. For those panes only the current
# viewport can be captured (that's a terminal-level fact, not a capture setting).
# Normal shell panes get their full scrollback.
set -u
HERDR=/opt/homebrew/bin/herdr
NVIM=/opt/homebrew/bin/nvim
PY=/usr/bin/python3
VIEW=/Users/migbyte/.config/herdr/scripts/scrollback-view.lua

# fresh capture file; sweep old ones so /tmp doesn't accumulate
rm -f /tmp/herdr-scrollback-*.ans 2>/dev/null
TMP="/tmp/herdr-scrollback-$$.ans"

# Resolve the focused pane + its tab/workspace from authoritative state (NOT
# $HERDR_PANE_ID / `pane current`, which name the invoking context). python prints
# "<pane_id>\t<tab_id>\t<workspace_id>".
line="$("$PY" - "$HERDR" <<'PYEOF'
import sys, json, subprocess
HERDR = sys.argv[1]
def call(*a):
    try:
        return json.loads(subprocess.run([HERDR, *a], capture_output=True,
                                          text=True, timeout=5).stdout)
    except Exception:
        return None
wl = call("workspace", "list") or {}
wss = (wl.get("result") or {}).get("workspaces", [])
ws = next((w for w in wss if w.get("focused")), None) or (wss[0] if wss else None)
if not ws:
    print("\t\t"); raise SystemExit(0)
wid = ws.get("workspace_id") or ""
tid = ws.get("active_tab_id") or ""
pane = ""
pl = call("pane", "list") or {}
panes = (pl.get("result") or {}).get("panes", [])
in_tab = [p for p in panes if p.get("tab_id") == tid]
pick = next((p for p in in_tab if p.get("focused")), in_tab[0] if in_tab else None)
if pick:
    pane = pick.get("pane_id", "")
print(f"{pane}\t{tid}\t{wid}")
PYEOF
)"
IFS=$'\t' read -r pane_id tab_id ws_id <<< "$line"
[ -n "${pane_id:-}" ] || exit 0

# Capture scrollback with color. Fall back to the visible screen if recent is empty.
"$HERDR" pane read "$pane_id" --source recent --lines 100000 --format ansi > "$TMP" 2>/dev/null
[ -s "$TMP" ] || "$HERDR" pane read "$pane_id" --source visible --lines 100000 --format ansi > "$TMP" 2>/dev/null
[ -s "$TMP" ] || exit 0

# Open the viewer in its own focused tab; it returns to $tab_id on quit.
create=( tab create --label scrollback --focus )
[ -n "${ws_id:-}" ] && create+=( --workspace "$ws_id" )
np="$("$HERDR" "${create[@]}" 2>/dev/null | "$PY" -c '
import sys, json
try:
    r = json.load(sys.stdin)["result"]
except Exception:
    raise SystemExit(0)
for path in (("root_pane","pane_id"), ("pane","pane_id"), ("pane","id")):
    n = r
    for k in path:
        n = n.get(k) if isinstance(n, dict) else None
        if n is None: break
    if n:
        print(n); break
')"
[ -n "$np" ] || exit 0

"$HERDR" pane run "$np" "exec env HERDR_SB_FILE=$TMP HERDR_SB_RETURN_TAB=$tab_id $NVIM -u NONE -c 'luafile $VIEW'"
exit 0
