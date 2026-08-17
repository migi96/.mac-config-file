#!/usr/bin/env bash
# prefix+y: open a new tab in the CURRENT dir, start tmux in it, and auto-run
# `flutter-watch` inside that tmux session. Bound via a [[keys.command]]
# (type = "shell") entry in ~/.config/herdr/config.toml.
#
# Why tmux: `flutter-watch` is a zsh function (~/.zshrc) that drives tmux itself —
# it send-keys `flutter run … --pid-file=/tmp/tf1.pid` into its pane, splits a
# small pane below, and runs a `nodemon` watcher there that hot-reloads (kill
# -USR1) on every .dart save. It only works from INSIDE a tmux session, so we
# launch tmux first, then feed it `flutter-watch`.
#
# "Current dir" is resolved from server state (focused workspace -> its active
# tab -> that tab's pane foreground_cwd), NOT from $HERDR_TAB_ID / `pane current`
# (those name the pane THIS command was spawned from, not the one you're viewing).
set -u
HERDR=/opt/homebrew/bin/herdr
TMUX_BIN=/opt/homebrew/bin/tmux
PY=/usr/bin/python3
SOCK="/tmp/tmux-$(id -u)/default"   # one explicit socket so both sides share a server
WATCH_CMD="flutter-watch"           # command sent into the tmux session (bare, no args)

# 1) resolve current dir + create the tab. python prints "<pane_id>\t<cwd>\t<label>".
line="$("$PY" - "$HERDR" <<'PYEOF'
import sys, json, subprocess, os
herdr = sys.argv[1]
def call(*a):
    try:
        return json.loads(subprocess.run([herdr, *a], capture_output=True,
                                          text=True, timeout=5).stdout)["result"]
    except Exception:
        return None

wl = call("workspace", "list") or {}
wss = wl.get("workspaces", [])
ws = next((w for w in wss if w.get("focused")), None) or (wss[0] if wss else None)
ws_id = ws.get("workspace_id") if ws else None
tab_id = ws.get("active_tab_id") if ws else None

cwd = None
pl = call("pane", "list") or {}
in_tab = [p for p in pl.get("panes", []) if p.get("tab_id") == tab_id]
pick = next((p for p in in_tab if p.get("focused")), in_tab[0] if in_tab else None)
if pick:
    cwd = pick.get("foreground_cwd") or pick.get("cwd")
if not cwd or not os.path.isdir(cwd):
    cwd = os.path.expanduser("~")
label = os.path.basename(cwd.rstrip("/")) or "tab"

args = ["tab", "create", "--cwd", cwd, "--label", label, "--focus"]
if ws_id:
    args += ["--workspace", ws_id]
res = call(*args) or {}
pane = ""
for path in (("root_pane", "pane_id"), ("pane", "pane_id"), ("pane", "id")):
    n = res
    for k in path:
        n = n.get(k) if isinstance(n, dict) else None
        if n is None:
            break
    if n:
        pane = n
        break
print(f"{pane}\t{cwd}\t{label}")
PYEOF
)"

IFS=$'\t' read -r pane_id cwd label <<< "$line"
[ -n "${pane_id:-}" ] || exit 0

# 2) unique tmux session name for this tab (sanitized: letters/digits/underscore)
suffix="$(printf '%s' "${label}_${pane_id}" | tr -c 'A-Za-z0-9' '_')"
sess="flw_${suffix}"

# 3) run tmux in the new pane (explicit socket + start dir); exec so the pane IS
#    the tmux client and closes cleanly when tmux exits.
"$HERDR" pane run "$pane_id" "exec $TMUX_BIN -S $SOCK new-session -A -s $sess -c '$cwd'"

# 4) wait for the session to come up, give zsh a beat to reach its prompt, then
#    send flutter-watch. Polling avoids racing the pane's shell startup.
for _ in $(seq 1 60); do
    "$TMUX_BIN" -S "$SOCK" has-session -t "$sess" 2>/dev/null && break
    sleep 0.1
done
sleep 0.5
"$TMUX_BIN" -S "$SOCK" send-keys -t "$sess" "$WATCH_CMD" Enter 2>/dev/null
exit 0
