#!/usr/bin/env bash
# Label each herdr agent with the basename of the directory it was started in,
# so the agent panel shows e.g. "sheraa" / "ent-hr" instead of the generic
# detected label ("claude").
#
#   • Idempotent: only labels agents that have NO name yet, so it never clobbers
#     a name you set yourself with `herdr agent rename`. Safe to run repeatedly
#     (used both as a one-shot and from the background poller).
#   • Reversible: clear a label back to the detected one with
#         herdr agent rename <terminal_id> --clear
#
# Uses the terminal_id as the rename target and the agent's `cwd` field (the
# directory the agent runs in) from `herdr agent list`.

set -euo pipefail
command -v herdr >/dev/null 2>&1 || exit 0

herdr agent list 2>/dev/null | python3 -c '
import sys, json, os, subprocess
try:
    agents = json.load(sys.stdin)["result"]["agents"]
except Exception:
    sys.exit(0)
for a in agents:
    tid = a.get("terminal_id")
    cwd = (a.get("cwd") or "").rstrip("/")
    if not tid or not cwd:
        continue
    if a.get("name"):            # already labeled (manual or by us) -> leave it
        continue
    label = os.path.basename(cwd) or cwd
    subprocess.run(["herdr", "agent", "rename", tid, label],
                   stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
'
