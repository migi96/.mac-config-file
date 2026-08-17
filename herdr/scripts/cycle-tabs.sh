#!/usr/bin/env bash
# Cycle focus across ALL tabs in ALL workspaces (spaces), forward or backward.
#   cycle-tabs.sh next   -> prefix+tab
#   cycle-tabs.sh prev   -> prefix+shift+tab
# Wired via [[keys.command]] (type = "shell") in ~/.config/herdr/config.toml.
#
# Because focusing a tab that lives in another space also switches to that space,
# this is a single flat "next thing / previous thing" across the whole session.
# Agents ride along automatically: each agent lives in a tab, so cycling every
# tab visits every agent's tab too.
set -u
HERDR=/opt/homebrew/bin/herdr
PY=/usr/bin/python3
DIR="${1:-next}"   # "next" or "prev"

"$PY" - "$HERDR" "$DIR" <<'PYEOF'
import sys, json, subprocess

herdr, direction = sys.argv[1], sys.argv[2]

def call(*args):
    try:
        out = subprocess.run([herdr, *args], capture_output=True,
                             text=True, timeout=5).stdout
        return json.loads(out)["result"]
    except Exception:
        return None

wl = call("workspace", "list")
if not wl:
    sys.exit(0)
workspaces = sorted(wl.get("workspaces", []), key=lambda w: w.get("number", 0))

# Flat, stable list of (workspace_id, tab_id): spaces in `number` order, tabs in
# `number` order within each space.
order = []
for w in workspaces:
    wid = w.get("workspace_id")
    if not wid:
        continue
    tl = call("tab", "list", "--workspace", wid)
    if not tl:
        continue
    for t in sorted(tl.get("tabs", []), key=lambda t: t.get("number", 0)):
        tid = t.get("tab_id")
        if tid:
            order.append((wid, tid))

if len(order) < 2:
    sys.exit(0)

# The globally-focused tab is the focused workspace's active tab. (Do NOT use
# `pane current` / $HERDR_TAB_ID here — those name the pane this command was
# invoked from, not the tab the user is actually looking at.)
cur_tab = None
for w in workspaces:
    if w.get("focused"):
        cur_tab = w.get("active_tab_id")
        break
if cur_tab is None:
    cur_tab = order[0][1]

try:
    i = next(k for k, (_, tid) in enumerate(order) if tid == cur_tab)
except StopIteration:
    i = 0

step = -1 if direction in ("prev", "previous", "back") else 1
tgt_ws, tgt_tab = order[(i + step) % len(order)]
# Focus the target's workspace first so crossing a space boundary is reliable,
# then the tab within it.
subprocess.run([herdr, "workspace", "focus", tgt_ws],
               stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
subprocess.run([herdr, "tab", "focus", tgt_tab],
               stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
PYEOF
