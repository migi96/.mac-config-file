#!/usr/bin/env zsh
# fzf picker to restore a saved kitty session into the current instance.
# Lists all saved session directories in ~/.config/kitty/sessions/,
# shows a preview with session info, and restores the selected one.

export PATH="/opt/homebrew/bin:$PATH"

session_dir="$HOME/.config/kitty/sessions"
script_dir="$(dirname "$0")"
mkdir -p "$session_dir"

# Build a list of saved session directories with summary info
entries=$(python3 - "$session_dir" <<'PYEOF'
import json, os, sys

session_dir = sys.argv[1]
entries = []
for name in sorted(os.listdir(session_dir), reverse=True):
    d = os.path.join(session_dir, name)
    sfile = os.path.join(d, "session.json")
    if not os.path.isdir(d) or not os.path.isfile(sfile):
        continue
    try:
        with open(sfile) as f:
            data = json.load(f)
        # Count tabs and panes
        tabs = 0
        panes = 0
        tab_names = []
        for os_win in data:
            for tab in os_win.get("tabs", []):
                tabs += 1
                tab_names.append(tab.get("title", "?"))
                panes += len(tab.get("windows", []))
        summary = f"{tabs} tab(s), {panes} pane(s)"
        preview = " | ".join(tab_names[:5])
        if len(tab_names) > 5:
            preview += " ..."
        print(f"{name}  [{summary}]  {preview}")
    except Exception:
        print(f"{name}  [error reading session]")
PYEOF
)

if [[ -z "$entries" ]]; then
    echo "No saved sessions found in $session_dir"
    echo "Use ctrl+alt+w to save all sessions first."
    sleep 2
    exit 0
fi

selection=$(echo "$entries" \
  | fzf --prompt="  restore session > " --reverse --no-info \
         --preview-window=hidden)

[ -z "$selection" ] && exit 0

# Extract the directory name (first field before the double-space)
dir_name=$(echo "$selection" | awk '{print $1}')

"$script_dir/restore_session.sh" "$session_dir/$dir_name"
