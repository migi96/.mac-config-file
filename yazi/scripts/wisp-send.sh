#!/bin/bash
# yazi `w`: stage the files selected in yazi so the running wisp can send them to
# WhatsApp chats, then bring wisp to the front.
#
# Called by yazi as:  wisp-send.sh <file1> <file2> ...   (paths from yazi's %s)
#
# Contract: wisp watches ~/.cache/wisp/send-files (App::check_send_files_trigger)
# for a newline-separated list of file paths, and on finding it opens its chat
# picker on those files. We publish the list atomically (temp + mv) so wisp never
# reads a half-written file, then launch-or-focus the wisp herdr tab.
set -euo pipefail

trigger="$HOME/.cache/wisp/send-files"
mkdir -p "$(dirname "$trigger")"

tmp="$(mktemp "${trigger}.XXXXXX")"
for f in "$@"; do
    [ -e "$f" ] && printf '%s\n' "$f" >> "$tmp"
done

# Nothing selected / nothing valid — do nothing.
if [ ! -s "$tmp" ]; then
    rm -f "$tmp"
    exit 0
fi

# Atomic publish (same dir → same filesystem → atomic rename).
mv -f "$tmp" "$trigger"

# Launch-or-focus the wisp tab so its chat picker comes up.
"$HOME/.config/herdr/scripts/wisp-tab.sh" >/dev/null 2>&1 || true
