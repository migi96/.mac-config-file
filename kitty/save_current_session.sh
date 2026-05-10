#!/usr/bin/env zsh
# Save only the CURRENTLY FOCUSED tab (all its panes) to a timestamped directory.
# Captures: layout, working directories, foreground commands, and scrollback history.

export PATH="/opt/homebrew/bin:$PATH"

session_dir="$HOME/.config/kitty/sessions"

# Get full kitty state, then extract only the focused tab
python3 - "$session_dir" <<'PYEOF'
import json, os, subprocess, sys, re
from datetime import datetime

session_dir = sys.argv[1]

# Get kitty state
r = subprocess.run(["kitty", "@", "ls"], capture_output=True, text=True)
if not r.stdout.strip():
    print("Error: Failed to get kitty session data")
    sys.exit(1)

data = json.loads(r.stdout)

# Find the focused tab
focused_tab = None
for os_win in data:
    if not os_win.get("is_focused", False):
        continue
    for tab in os_win.get("tabs", []):
        if tab.get("is_focused", False):
            focused_tab = tab
            break
    if focused_tab:
        break

if not focused_tab:
    print("Error: No focused tab found")
    sys.exit(1)

# Build a sanitized name from the tab title
title = focused_tab.get("title", "untitled")
safe_title = re.sub(r'[^a-zA-Z0-9._-]', '_', title)[:40]
timestamp = datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
save_dir = os.path.join(session_dir, f"tab_{safe_title}_{timestamp}")
os.makedirs(save_dir, exist_ok=True)

# Wrap the focused tab in the same structure kitty @ ls uses (os_window > tabs)
# so restore_session.sh can read it uniformly
session_data = [{
    "tabs": [focused_tab],
    "is_focused": True
}]

with open(os.path.join(save_dir, "session.json"), "w") as f:
    json.dump(session_data, f, indent=2)

# Save scrollback for each pane in this tab
count = 0
for win in focused_tab.get("windows", []):
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

print(f"Saved tab '{title}' ({count} pane(s)) to: {os.path.basename(save_dir)}")
PYEOF

sleep 1
