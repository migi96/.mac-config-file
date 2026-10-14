#!/bin/sh
# prefix + v — copy mode in Neovim, laid exactly over the pane.
# Snapshots the pane (history + screen, colors kept, wrapped lines joined) and
# opens it with scripts/vimcopy.lua in a borderless popup the size of the pane,
# with the cursor and scroll position the pane had.
#
# usage (from tmux.conf): vimcopy.sh <pane_id> <client_name>
pane=$1
client=$2
here=$(cd "$(dirname "$0")" && pwd)

set -- $(tmux display -p -t "$pane" \
  '#{pane_width} #{pane_height} #{history_size} #{?#{==:#{pane_mode},copy-mode},1 #{scroll_position} #{copy_cursor_x} #{copy_cursor_y},0 0 #{cursor_x} #{cursor_y}}')
width=$1 height=$2 hist=$3 in_copy=$4 scroll=$5 cx=$6 cy=$7

# -M: in copy mode, read the frozen screen copy mode is showing — the pane may
# have printed more since, and copy mode's coordinates refer to the frozen copy.
dir=$(mktemp -d "${TMPDIR:-/tmp}/tmux-vimcopy.XXXXXX") || exit 1
tmux capture-pane -p -M -J -e -S - -E - -t "$pane" >"$dir/content" || { rm -rf "$dir"; exit 1; }
if [ "$in_copy" = 1 ]; then
  hist=$(($(tmux capture-pane -p -M -S - -E - -t "$pane" | wc -l) - height))
fi
top=$((hist - scroll))

tmux display-popup -c "$client" -t "$pane" -B -E \
  -x '#{popup_pane_left}' -y '#{popup_pane_top}' -w "$width" -h "$height" \
  -d '#{pane_current_path}' \
  -e VIMCOPY_FILE="$dir/content" -e VIMCOPY_WIDTH="$width" \
  -e VIMCOPY_TOP="$top" -e VIMCOPY_CURSOR="$((top + cy)),$cx" \
  "nvim -n -i NONE --noplugin -u '$here/vimcopy.lua'; rm -rf '$dir'"
