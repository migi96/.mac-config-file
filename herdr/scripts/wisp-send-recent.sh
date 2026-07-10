#!/usr/bin/env bash
# prefix+n in Herdr: stage recent downloads + screenshots, then ask wisp (my
# WhatsApp TUI) to open its media picker on them. wisp watches for the trigger
# file and sends the pick to its currently-open chat via its native send path
# (the same one the `A` key uses) — no cross-pane key injection.
set -u

HERDR=/opt/homebrew/bin/herdr
PY=/usr/bin/python3
TRIGGER="$HOME/.cache/wisp/attach-recent"

# ── the "wisp" tab (created by prefix+t) — focus it so you land on the picker ─
wisp_tab=$("$HERDR" tab list 2>/dev/null | "$PY" -c '
import sys, json
try: tabs = json.load(sys.stdin)["result"]["tabs"]
except Exception: sys.exit(0)
print(next((t["tab_id"] for t in tabs if t.get("label") == "wisp"), ""))
')
[ -n "$wisp_tab" ] || exit 0        # wisp not open (launch it with prefix+t)

# ── stage recent downloads + screenshots into a temp dir (newest first) ──────
DOWNLOADS="$HOME/Downloads"
SHOTS=$(defaults read com.apple.screencapture location 2>/dev/null)
SHOTS=${SHOTS:-$HOME/Desktop}
SHOTS=${SHOTS/#\~/$HOME}

STAGE=$(mktemp -d "${TMPDIR:-/tmp}/wisp-recent.XXXXXX")
{
    [ -d "$DOWNLOADS" ] && find "$DOWNLOADS" -maxdepth 1 -type f \
        ! -name '.*' ! -name '*.crdownload' ! -name '*.part' ! -name '*.download' \
        -exec stat -f '%m %N' {} +
    if [ -d "$SHOTS" ] && [ "$SHOTS" != "$DOWNLOADS" ]; then
        find "$SHOTS" -maxdepth 1 -type f ! -name '.*' -exec stat -f '%m %N' {} +
    fi
} 2>/dev/null | sort -rn | head -n 30 | {
    i=0
    while IFS=' ' read -r _mtime path; do
        [ -e "$path" ] || continue
        printf -v idx '%02d' "$i"
        ln -s "$path" "$STAGE/${idx}__$(basename "$path")" 2>/dev/null && i=$((i + 1))
    done
}

if [ -z "$(ls -A "$STAGE" 2>/dev/null)" ]; then
    rmdir "$STAGE" 2>/dev/null
    exit 0
fi

# ── hand the folder to wisp and jump to it ──────────────────────────────────
mkdir -p "$(dirname "$TRIGGER")"
printf '%s\n' "$STAGE" > "$TRIGGER"
"$HERDR" tab focus "$wisp_tab" >/dev/null 2>&1
