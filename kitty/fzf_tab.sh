#!/usr/bin/env zsh
# fzf switcher for open kitty tabs
export PATH="/opt/homebrew/bin:$PATH"
tab=$(kitty @ ls 2>/dev/null \
  | python3 -c "
import sys, json
data = json.load(sys.stdin)
for os_win in data:
    for tab in os_win['tabs']:
        active = '*' if tab['is_focused'] else ' '
        print(f\"{active} {tab['id']:>3}  {tab['title']}\")
" | fzf --ansi --prompt="  tab > " --reverse --no-info)

[ -z "$tab" ] && exit 0
tab_id=$(echo "$tab" | awk '{print $2}')
kitty @ focus-tab --match "id:$tab_id"
