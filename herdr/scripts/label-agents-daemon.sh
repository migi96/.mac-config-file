#!/bin/bash
# Long-lived poller for launchd (KeepAlive). Keeps herdr agent labels in sync
# with the directory each agent runs in, by re-running label-agents-by-dir.sh
# every few seconds. New agents pick up their directory name automatically.
#
# Why a loop instead of launchd StartInterval: launchd throttles job respawns to
# a ~10s minimum, so a one-shot on a 4s StartInterval would be clamped. A single
# long-lived process that sleeps internally polls as fast as we like.
#
# label-agents-by-dir.sh is a no-op when herdr isn't running, so this idles
# cheaply while herdr is closed.
here="$(cd "$(dirname "$0")" && pwd)"
while :; do
    "$here/label-agents-by-dir.sh" 2>/dev/null || true
    sleep 4
done
