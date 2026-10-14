#!/bin/sh
# Copy mode, after a V selection (y or Esc): put the cursor back on the column V
# started from, on the row it is on now. tmux parks it at the start or end of the
# line during a V selection. The row is read from copy mode's own screen (-M):
# the pane may have moved on since copy mode froze it.
#
# usage: copy-col.sh <pane_id> <column> <copy_cursor_x> <copy_cursor_y> <scroll_position>
pane=$1 want=$2 cx=$3 cy=$4 scroll=$5
[ -n "$want" ] && [ -n "$cx" ] || exit 0

row=$((cy - scroll))
len=$(tmux capture-pane -p -M -t "$pane" -S "$row" -E "$row" | tr -d '\n' | LC_ALL=en_US.UTF-8 wc -m)
len=$((len))

# Clamp to the row like vim does; cursor-right past the end would wrap to the next line.
target=$want
[ "$target" -ge "$len" ] && target=$((len > 0 ? len - 1 : 0))

if [ "$target" -gt "$cx" ]; then
  tmux send-keys -t "$pane" -X -N $((target - cx)) cursor-right
elif [ "$target" -lt "$cx" ]; then
  tmux send-keys -t "$pane" -X -N $((cx - target)) cursor-left
fi
