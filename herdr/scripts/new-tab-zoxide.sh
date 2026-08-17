#!/usr/bin/env bash
# New-tab picker: zoxide + fzf. Bound to `prefix+c` via a [[keys.command]] entry
# (type = "pane") in ~/.config/herdr/config.toml, so it runs interactively in a
# throwaway pane that herdr closes when this script exits.
#
# You are shown your zoxide directories (frecency-ordered). Type to fuzzy-find.
# What you press / type decides what the new tab does:
#
#   <dir>            Enter   -> open a shell tab in <dir>, named after <dir>
#   <dir> -c         Enter   -> open <dir> and launch `claude`
#   <dir> -con       Enter   -> open <dir> and launch `claude --resume`
#                              (pick from previous claude sessions in <dir>)
#
# The leading `cd ` / `z ` you'd normally type is optional and stripped if present
# (so `cd wisp -c` works too). `-c` / `-con` are TRAILING flags; while one is in
# the query the list shows "no match" (expected) — the directory is resolved from
# the rest of the query through `zoxide query` (same match `z <words>` would give).
#
# Implementation: pick here, then `herdr tab create --cwd <dir> --label <name>`
# starts the new tab's shell already IN <dir>, and (for claude modes) `pane run`
# launches claude in it.
set -u

HERDR=/opt/homebrew/bin/herdr
FZF=/opt/homebrew/bin/fzf
ZOXIDE=/opt/homebrew/bin/zoxide
PY=/usr/bin/python3
CLAUDE="$(command -v claude 2>/dev/null || echo claude)"

# ---- 1) fzf over the zoxide database ---------------------------------------
dirs="$("$ZOXIDE" query --list 2>/dev/null)"
[ -n "$dirs" ] || exit 0

out="$(printf '%s\n' "$dirs" | "$FZF" \
    --print-query \
    --reverse \
    --prompt 'cd ❯ ' \
    --header $'Enter: open in dir · append  -c  → claude · append  -con  → claude --resume  · Esc: cancel' \
    --preview 'ls -1p {} 2>/dev/null | head -60' \
    --preview-window 'right,45%,border-left' \
    2>/dev/null)"
rc=$?

# Esc / Ctrl-C -> cancel, leave no tab behind.
[ "$rc" -eq 130 ] && exit 0

# fzf with --print-query prints the query on line 1, the selection (if any) on
# line 2. On a non-matching query (a flag is armed) there is no line 2.
query="$(printf '%s\n' "$out" | sed -n '1p')"
choice="$(printf '%s\n' "$out" | sed -n '2p')"

# ---- 2) parse the trailing flag + strip an optional leading cd/z ------------
# trim leading/trailing whitespace
query="${query#"${query%%[![:space:]]*}"}"
query="${query%"${query##*[![:space:]]}"}"

read -r -a words <<< "$query"
mode=plain
if [ "${#words[@]}" -gt 0 ]; then
    last="${words[$(( ${#words[@]} - 1 ))]}"
    case "$last" in
        -con|--con|-r|--resume|-cr|-cn)
            mode=resume; unset 'words[$(( ${#words[@]} - 1 ))]' ;;
        -c|--claude|--code|-cc)
            mode=claude; unset 'words[$(( ${#words[@]} - 1 ))]' ;;
    esac
fi
# drop a leading `cd` / `z` / `zi` if the user typed one
if [ "${#words[@]}" -gt 0 ]; then
    case "${words[0]}" in
        cd|z|zi)
            if [ "${#words[@]}" -gt 1 ]; then words=("${words[@]:1}"); else words=(); fi
            ;;
    esac
fi
# (bash 3.2 + set -u errors on ${words[*]} when the array is empty -> guard it)
qpath=""
[ "${#words[@]}" -gt 0 ] && qpath="${words[*]}"

# ---- 3) resolve the target directory ---------------------------------------
dir=""
if [ -n "$choice" ] && [ -d "$choice" ]; then
    dir="$choice"                                   # a highlighted row was chosen
elif [ -n "$qpath" ]; then
    dir="$("$ZOXIDE" query -- $qpath 2>/dev/null)"  # resolve via zoxide (like `z`)
fi
[ -n "$dir" ] && [ -d "$dir" ] || exit 0            # nothing to open -> cancel

label="$(basename "$dir")"

# ---- 4) create the tab already in that dir, named after it -----------------
pane_id="$("$HERDR" tab create --cwd "$dir" --label "$label" --focus 2>/dev/null | "$PY" -c '
import sys, json
try:
    r = json.load(sys.stdin)["result"]
except Exception:
    sys.exit(0)
for path in (("root_pane","pane_id"), ("pane","pane_id"), ("pane","id")):
    node = r
    for k in path:
        node = node.get(k) if isinstance(node, dict) else None
        if node is None:
            break
    if node:
        print(node); break
')"

# ---- 5) launch claude in the new tab for the -c / -con modes ---------------
[ -n "$pane_id" ] || exit 0
case "$mode" in
    claude) "$HERDR" pane run "$pane_id" "$CLAUDE" ;;
    resume) "$HERDR" pane run "$pane_id" "$CLAUDE --resume" ;;
esac
exit 0
