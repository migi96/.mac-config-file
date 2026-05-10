#!/usr/bin/env zsh
# Restore the most recently saved FULL session (all_* directories).
# Finds the latest all_* directory in sessions/ and restores it into the current kitty instance.

export PATH="/opt/homebrew/bin:$PATH"

session_dir="$HOME/.config/kitty/sessions"
script_dir="$(dirname "$0")"

# Find the latest all_* directory (sorted by name = sorted by timestamp)
latest=$(ls -d "$session_dir"/all_* 2>/dev/null | sort | tail -1)

if [[ -z "$latest" || ! -f "$latest/session.json" ]]; then
    echo "No saved sessions found in $session_dir"
    echo "Use save_all_sessions.sh first to create a snapshot."
    sleep 2
    exit 1
fi

echo "Restoring from: $(basename "$latest")"
"$script_dir/restore_session.sh" "$latest"
sleep 1
