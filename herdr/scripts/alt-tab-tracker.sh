#!/bin/bash
# Long-lived focus-history tracker for herdr's Ctrl-^ alternate-tab (alt-tab.sh).
# Records the last two DISTINCT focused tabs in a small state file so Ctrl-^ can
# jump to the previous one, vim-style, no matter HOW you switched (prefix+a, a
# click, alt+1..9, the cycle-tabs key, …).
#
# Runs under launchd (RunAtLoad + KeepAlive) — see
# ~/Library/LaunchAgents/com.migbyte.herdr-alt-tab.plist. A single long-lived
# python process keeps it cheap: one ~4ms herdr call per poll, and it idles
# cheaply (does nothing) whenever herdr isn't running.
exec /usr/bin/python3 - <<'PY'
import subprocess, json, time, os
HERDR = "/opt/homebrew/bin/herdr"
STATE = f"/tmp/herdr-alt-tab-{os.getuid()}.state"
INTERVAL = 0.3   # seconds between focus polls

def focused():
    try:
        out = subprocess.run([HERDR, "workspace", "list"], capture_output=True,
                             text=True, timeout=3).stdout
        wss = json.loads(out)["result"]["workspaces"]
        w = next((x for x in wss if x.get("focused")), None)
        return (w or {}).get("active_tab_id")
    except Exception:
        return None

def recorded_current():
    try:
        with open(STATE) as f:
            return f.read().splitlines()[0]
    except Exception:
        return ""

def write(cur, prev):
    tmp = STATE + f".{os.getpid()}.tmp"
    with open(tmp, "w") as f:
        f.write(f"{cur}\n{prev}\n")
    os.replace(tmp, STATE)

while True:
    f = focused()
    if f:
        cur = recorded_current()
        if f != cur:                 # focus changed -> rotate: new current, old -> previous
            write(f, cur)
    time.sleep(INTERVAL)
PY
