#!/usr/bin/env bash
# prefix+n in Herdr (GLOBAL): stage the most recent downloads + screenshots and
# open `yazi` on them in a new tab — a quick "recent files" browser. Not tied to
# wisp; just browse / open / operate on recent files from anywhere.
#
# (Sending a recent file to a WhatsApp chat is now the `f` key *inside wisp*,
# which stages + opens its own picker natively.)
set -u

HERDR=/opt/homebrew/bin/herdr
PY=/usr/bin/python3

DOWNLOADS="$HOME/Downloads"
SHOTS=$(defaults read com.apple.screencapture location 2>/dev/null)
SHOTS=${SHOTS:-$HOME/Desktop}
SHOTS=${SHOTS/#\~/$HOME}

# Fresh stage dir; clear previous ones so /tmp doesn't accumulate symlink dirs.
rm -rf "${TMPDIR:-/tmp}"/herdr-recent.* 2>/dev/null
STAGE=$(mktemp -d "${TMPDIR:-/tmp}/herdr-recent.XXXXXX")

# Symlink the newest files from Downloads AND the screenshot dir. Take the newest
# N from EACH source independently (rather than one merged "newest 40"), so a busy
# folder — e.g. many recent screenshots — can't crowd the other source out (that
# bug left the browser showing screenshots only). The two lists are then combined
# and ordered newest-first for display.
PER_SOURCE=20
{
    [ -d "$DOWNLOADS" ] && find "$DOWNLOADS" -maxdepth 1 -type f \
        ! -name '.*' ! -name '*.crdownload' ! -name '*.part' ! -name '*.download' \
        -exec stat -f '%m %N' {} + 2>/dev/null | sort -rn | head -n "$PER_SOURCE"
    if [ -d "$SHOTS" ] && [ "$SHOTS" != "$DOWNLOADS" ]; then
        find "$SHOTS" -maxdepth 1 -type f ! -name '.*' \
            -exec stat -f '%m %N' {} + 2>/dev/null | sort -rn | head -n "$PER_SOURCE"
    fi
} | sort -rn | {
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

# Open yazi on the staged folder in a new focused tab (STAGE is a mktemp path,
# so no spaces — safe to pass unquoted through `pane run`).
pane_id="$("$HERDR" tab create --label recent --focus 2>/dev/null | "$PY" -c '
import sys, json
try:
    print(json.load(sys.stdin)["result"]["root_pane"]["pane_id"])
except Exception:
    pass
')"

[ -n "$pane_id" ] || exit 0
"$HERDR" pane run "$pane_id" "yazi $STAGE"
