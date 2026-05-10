#!/usr/bin/env zsh
# kitty_last_output.sh — Capture last command output and open in nvim
# Works with: kitty (via remote control) and tmux (as fallback)
# Usage: kitty-cmds

set -uo pipefail

local output=""
local source_label=""

# --- Strategy 1: kitty @ get-text (best, needs shell_integration) ---
if [[ -n "${KITTY_WINDOW_ID:-}" ]]; then
  # Try last_cmd_output first (requires shell_integration marks)
  output=$(kitty @ get-text --self --extent last_cmd_output 2>/dev/null)

  if [[ -n "$output" ]]; then
    source_label="kitty (last_cmd_output)"
  else
    # Fallback: last_non_empty_output
    output=$(kitty @ get-text --self --extent last_non_empty_output 2>/dev/null)
    [[ -n "$output" ]] && source_label="kitty (last_non_empty_output)"
  fi
fi

# --- Strategy 2: tmux capture-pane (fallback) ---
if [[ -z "$output" && -n "${TMUX:-}" ]]; then
  # Capture the full scrollback of the current pane
  output=$(tmux capture-pane -p -S - -E - 2>/dev/null)
  [[ -n "$output" ]] && source_label="tmux (capture-pane)"
fi

# --- Strategy 3: kitty scrollback as last resort ---
if [[ -z "$output" && -n "${KITTY_WINDOW_ID:-}" ]]; then
  output=$(kitty @ get-text --self --extent screen 2>/dev/null)
  [[ -n "$output" ]] && source_label="kitty (screen)"
fi

# --- Bail if nothing captured ---
if [[ -z "$output" ]]; then
  print -u2 "Error: Could not capture any terminal output."
  print -u2 "Make sure you are running inside kitty or tmux."
  return 1 2>/dev/null || exit 1
fi

# --- Write to temp file and open in nvim ---
local tmpfile=$(mktemp /tmp/last-cmd-output.XXXXXX)
trap 'rm -f "$tmpfile"' EXIT INT TERM

print -r -- "$output" > "$tmpfile"

nvim -R \
  -c "setlocal buftype=nofile nomodifiable noswapfile" \
  -c "setlocal number cursorline" \
  -c "nnoremap <buffer> q :q<CR>" \
  -c "norm G" \
  "$tmpfile"
