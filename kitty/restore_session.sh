#!/usr/bin/env zsh
# Restore a saved kitty session from a session directory into the current instance.
# Usage: restore_session.sh <session_dir>
#
# Expects:
#   <session_dir>/session.json       — kitty @ ls JSON snapshot
#   <session_dir>/scrollback_<id>.txt — per-pane scrollback (optional)

export PATH="/opt/homebrew/bin:$PATH"

session_dir="$1"
if [[ -z "$session_dir" || ! -f "$session_dir/session.json" ]]; then
    echo "Usage: restore_session.sh <session_dir>"
    echo "Error: session.json not found in '$session_dir'"
    exit 1
fi

# Use Python to parse the session JSON and emit restore commands
python3 - "$session_dir" <<'PYEOF'
import json, sys, os, subprocess, time

session_dir = sys.argv[1]
with open(os.path.join(session_dir, "session.json")) as f:
    data = json.load(f)

def kitty(*args):
    """Run a kitty @ remote control command and return stdout."""
    cmd = ["kitty", "@"] + list(args)
    r = subprocess.run(cmd, capture_output=True, text=True)
    return r.stdout.strip()

def kitty_json(*args):
    """Run a kitty @ command and parse JSON output."""
    out = kitty(*args)
    if out:
        try:
            return json.loads(out)
        except json.JSONDecodeError:
            return None
    return None

def get_fg_command(window):
    """Extract the foreground command running in a pane, if it's not just a shell."""
    shells = {"zsh", "bash", "fish", "sh", "dash", "tcsh", "csh", "nu", "elvish"}
    for proc in window.get("foreground_processes", []):
        cmdline = proc.get("cmdline", [])
        if not cmdline:
            continue
        binary = os.path.basename(cmdline[0])
        if binary not in shells:
            return cmdline
    return None

def restore_scrollback(match_arg, window_id):
    """Restore scrollback content from a saved file."""
    scrollback_file = os.path.join(session_dir, f"scrollback_{window_id}.txt")
    if os.path.isfile(scrollback_file):
        with open(scrollback_file) as f:
            content = f.read()
        if content.strip():
            # Send the scrollback text so it appears in the pane's history
            kitty("send-text", "--match", match_arg, content)

# Process each OS window in the saved session
for os_win in data:
    tabs = os_win.get("tabs", [])
    for tab_idx, tab in enumerate(tabs):
        tab_title = tab.get("title", "")
        layout = tab.get("layout", "stack")
        windows = tab.get("windows", [])
        if not windows:
            continue

        # --- First window in this tab: create the tab ---
        first_win = windows[0]
        cwd = first_win.get("cwd", os.path.expanduser("~"))
        fg_cmd = get_fg_command(first_win)

        # Launch a new tab with the first pane
        launch_args = ["launch", "--type=tab", "--cwd=" + cwd]
        if tab_title:
            launch_args += ["--tab-title", tab_title]

        if fg_cmd:
            launch_args += fg_cmd
        else:
            launch_args += ["zsh"]

        new_win_id = kitty(*launch_args)

        # Small delay to let the tab initialize
        time.sleep(0.15)

        # Try to restore scrollback for the first pane
        if new_win_id:
            try:
                nwid = int(new_win_id)
                restore_scrollback(f"id:{nwid}", first_win.get("id", 0))
            except ValueError:
                pass

        # --- Remaining windows (panes) in this tab via splits ---
        for win in windows[1:]:
            win_cwd = win.get("cwd", os.path.expanduser("~"))
            win_fg_cmd = get_fg_command(win)

            split_args = ["launch", "--type=window", "--cwd=" + win_cwd]
            if win_fg_cmd:
                split_args += win_fg_cmd
            else:
                split_args += ["zsh"]

            split_win_id = kitty(*split_args)
            time.sleep(0.1)

            if split_win_id:
                try:
                    swid = int(split_win_id)
                    restore_scrollback(f"id:{swid}", win.get("id", 0))
                except ValueError:
                    pass

print(f"Restored session from: {os.path.basename(session_dir)}")
PYEOF
