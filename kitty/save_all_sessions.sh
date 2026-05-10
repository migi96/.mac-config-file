#!/usr/bin/env zsh
# Save ALL current kitty sessions (all OS windows, tabs, panes) to a timestamped directory.
# Captures: layout, working directories, foreground commands, and scrollback history.

export PATH="/opt/homebrew/bin:$PATH"

session_dir="$HOME/.config/kitty/sessions"
timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
save_dir="$session_dir/all_${timestamp}"
mkdir -p "$save_dir"

# 1. Save the full kitty state as JSON
kitty @ ls > "$save_dir/session.json" 2>/dev/null

if [[ ! -s "$save_dir/session.json" ]]; then
    echo "Error: Failed to get kitty session data"
    rm -rf "$save_dir"
    sleep 1
    exit 1
fi

# 2. Save scrollback for every pane
python3 - "$save_dir" <<'PYEOF'
import json, os, subprocess, sys

save_dir = sys.argv[1]
with open(os.path.join(save_dir, "session.json")) as f:
    data = json.load(f)

count = 0
for os_win in data:
    for tab in os_win.get("tabs", []):
        for win in tab.get("windows", []):
            wid = win.get("id")
            if wid is None:
                continue
            r = subprocess.run(
                ["kitty", "@", "get-text", "--match", f"id:{wid}", "--extent", "all"],
                capture_output=True, text=True
            )
            if r.stdout.strip():
                with open(os.path.join(save_dir, f"scrollback_{wid}.txt"), "w") as f:
                    f.write(r.stdout)
                count += 1

print(f"Saved {count} pane(s) to: {os.path.basename(save_dir)}")
PYEOF

sleep 1
