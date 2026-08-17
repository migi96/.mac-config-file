#!/usr/bin/env bash
# Open a new tab in the CURRENT directory, no prompt. Bound to `prefix+o` via a
# [[keys.command]] (type = "shell") entry in ~/.config/herdr/config.toml.
#
# "Current directory" = the working dir of the pane you're looking at. We resolve
# it from authoritative server state (focused workspace -> its active tab -> that
# tab's pane -> foreground_cwd), NOT from $HERDR_TAB_ID / `pane current`, which
# name the pane this command was spawned from rather than the one you're viewing.
# The new tab is auto-named after that dir's basename (still zero prompts).
set -u
HERDR=/opt/homebrew/bin/herdr
PY=/usr/bin/python3

"$PY" - "$HERDR" <<'PYEOF'
import sys, json, subprocess, os

herdr = sys.argv[1]

def call(*args):
    try:
        out = subprocess.run([herdr, *args], capture_output=True,
                             text=True, timeout=5).stdout
        return json.loads(out)["result"]
    except Exception:
        return None

# 1) focused workspace + its active tab
wl = call("workspace", "list") or {}
ws = None
for w in wl.get("workspaces", []):
    if w.get("focused"):
        ws = w
        break
if ws is None:
    wss = wl.get("workspaces", [])
    ws = wss[0] if wss else None

ws_id = ws.get("workspace_id") if ws else None
tab_id = ws.get("active_tab_id") if ws else None

# 2) the pane of that active tab -> its foreground cwd
cwd = None
pl = call("pane", "list") or {}
panes = pl.get("panes") or []
in_tab = [p for p in panes if p.get("tab_id") == tab_id]
pick = next((p for p in in_tab if p.get("focused")), in_tab[0] if in_tab else None)
if pick:
    cwd = pick.get("foreground_cwd") or pick.get("cwd")
if not cwd or not os.path.isdir(cwd):
    cwd = os.path.expanduser("~")

label = os.path.basename(cwd.rstrip("/")) or cwd

# 3) create the tab in that workspace + dir, focused, no prompt
args = ["tab", "create", "--cwd", cwd, "--label", label, "--focus"]
if ws_id:
    args += ["--workspace", ws_id]
subprocess.run([herdr, *args], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
PYEOF
