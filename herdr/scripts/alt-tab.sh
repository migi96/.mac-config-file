#!/usr/bin/env bash
# Ctrl-^ (vim "alternate file", for tabs): jump to the tab you were on before the
# current one, and toggle back on the next press. Reads the last-two-focused-tabs
# history kept by alt-tab-tracker.sh (launchd daemon). Bound via [[keys.command]]
# (type = "shell") in ~/.config/herdr/config.toml.
#
# Robust even if the tracker is momentarily down: it uses the live focused tab to
# reconcile (if focus drifted from the recorded "current", the alternate is that
# recorded current), and it re-writes the pair after acting so a bare toggle keeps
# working on its own.
set -u
exec /usr/bin/python3 - <<'PY'
import subprocess, json, os
HERDR = "/opt/homebrew/bin/herdr"
STATE = f"/tmp/herdr-alt-tab-{os.getuid()}.state"

def call(*a):
    try:
        return json.loads(subprocess.run([HERDR, *a], capture_output=True,
                                          text=True, timeout=5).stdout)
    except Exception:
        return None

def focused():
    d = call("workspace", "list") or {}
    wss = (d.get("result") or {}).get("workspaces", [])
    w = next((x for x in wss if x.get("focused")), None)
    return (w or {}).get("active_tab_id")

actual = focused()

try:
    lines = open(STATE).read().splitlines()
except Exception:
    lines = []
SC = lines[0] if len(lines) > 0 else ""   # recorded current
SP = lines[1] if len(lines) > 1 else ""   # recorded previous (the alternate)

# Pick the alternate: normally the recorded previous; but if the live focus has
# drifted away from the recorded current (a switch the tracker hasn't logged yet),
# the alternate is that recorded current — i.e. where we just were.
if actual and actual == SC:
    target = SP
elif SC and SC != actual:
    target = SC
else:
    target = ""

if not target or target == actual:
    raise SystemExit(0)

# Validate the target still exists (survives herdr restarts / stale ids) and learn
# its workspace in the same call.
g = call("tab", "get", target) or {}
tab = (g.get("result") or {}).get("tab")
if not tab:
    raise SystemExit(0)

ws = tab.get("workspace_id")
if ws:
    call("workspace", "focus", ws)     # make cross-space jumps reliable
call("tab", "focus", target)

# Record the new pair so a plain back-and-forth keeps working even without the
# tracker running.
try:
    tmp = STATE + f".{os.getpid()}.tmp"
    with open(tmp, "w") as f:
        f.write(f"{target}\n{actual or ''}\n")
    os.replace(tmp, STATE)
except Exception:
    pass
PY
