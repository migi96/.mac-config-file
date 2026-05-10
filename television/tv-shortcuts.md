# Television (tv) - Complete Shortcuts & Keybindings Reference

> Version: 0.15.4 | Config: `~/.config/television/config.toml`
> Theme: Kanagawa | Shell: Zsh

---

## Table of Contents

1. [Core Navigation](#1-core-navigation)
2. [Selection & Confirmation](#2-selection--confirmation)
3. [Preview Panel Controls](#3-preview-panel-controls)
4. [UI Toggles](#4-ui-toggles)
5. [Data Operations](#5-data-operations)
6. [Input Field Editing](#6-input-field-editing)
7. [History Navigation](#7-history-navigation)
8. [Shell Integration (Zsh)](#8-shell-integration-zsh)
9. [Channel Triggers Map](#9-channel-triggers-map)
10. [Remote Control (Channel Switcher)](#10-remote-control-channel-switcher)
11. [Source & Preview Cycling](#11-source--preview-cycling)
12. [Action Picker & Custom Actions](#12-action-picker--custom-actions)
13. [Multi-Selection Workflow](#13-multi-selection-workflow)
14. [Expect Keys (Script Mode)](#14-expect-keys-script-mode)
15. [CLI Flags Quick Reference](#15-cli-flags-quick-reference)
16. [Entry Selection Strategies](#16-entry-selection-strategies)
17. [Watch Mode](#17-watch-mode)
18. [Inline Mode](#18-inline-mode)
19. [Layout & Scaling](#19-layout--scaling)
20. [Borders & Padding](#20-borders--padding)
21. [Search Patterns](#21-search-patterns)
22. [Environment Variables](#22-environment-variables)
23. [Performance Tips](#23-performance-tips)
24. [All Available Channels](#24-all-available-channels)
25. [Custom Channel Anatomy](#25-custom-channel-anatomy)
26. [Complete Action Reference](#26-complete-action-reference)
27. [Key Syntax Reference](#27-key-syntax-reference)

---

## 1. Core Navigation

Navigate through the results list.

| Key | Action | Description |
|-----|--------|-------------|
| `Down` | `select_next_entry` | Move to next result |
| `Up` | `select_prev_entry` | Move to previous result |
| `Ctrl+J` | `select_next_entry` | Move down (Vim-style) |
| `Ctrl+K` | `select_prev_entry` | Move up (Vim-style) |
| `Ctrl+N` | `select_next_entry` | Move down (Emacs-style) |
| `Ctrl+P` | `select_prev_entry` | Move up (Emacs-style) |
| `Esc` | `quit` | Exit television |
| `Ctrl+C` | `quit` | Exit television |

---

## 2. Selection & Confirmation

Select entries and confirm your choice.

| Key | Action | Description |
|-----|--------|-------------|
| `Enter` | `confirm_selection` | Confirm and output the selected entry |
| `Tab` | `toggle_selection_down` | Toggle multi-select on current entry, move down |
| `Shift+Tab` | `toggle_selection_up` | Toggle multi-select on current entry, move up |

### Multi-Select Workflow
1. Navigate to an entry
2. Press `Tab` to mark it (entry gets highlighted)
3. Navigate to more entries, press `Tab` on each
4. Press `Enter` to confirm all selected entries
5. Output: one line per selected entry

---

## 3. Preview Panel Controls

Scroll and cycle through preview content.

| Key | Action | Description |
|-----|--------|-------------|
| `PageDown` | `scroll_preview_half_page_down` | Scroll preview down half page |
| `PageUp` | `scroll_preview_half_page_up` | Scroll preview up half page |
| `Ctrl+D` | `scroll_preview_half_page_down` | Scroll preview down (Vim-style) |
| `Ctrl+B` | `scroll_preview_half_page_up` | Scroll preview up (Vim-style) |
| `Ctrl+F` | `cycle_previews` | Cycle through preview commands |
| `Ctrl+O` | `toggle_preview` | Show/hide the preview panel |

### Preview Cycling

When a channel defines multiple preview commands:

```toml
[preview]
command = ["bat -n --color=always '{}'", "cat '{}'", "head -50 '{}'"]
```

Press `Ctrl+F` to cycle: syntax-highlighted -> raw -> first 50 lines.

---

## 4. UI Toggles

Toggle visibility of various UI components.

| Key | Action | Description |
|-----|--------|-------------|
| `Ctrl+T` | `toggle_remote_control` | Open/close the channel switcher panel |
| `Ctrl+O` | `toggle_preview` | Show/hide preview panel |
| `Ctrl+H` | `toggle_help` | Show/hide the help panel |
| `F12` | `toggle_status_bar` | Show/hide the status bar |
| `Ctrl+L` | `toggle_layout` | Switch between landscape/portrait layout |
| `Ctrl+X` | `toggle_action_picker` | Open the action picker for current entry |

---

## 5. Data Operations

Copy, reload, and cycle through data sources.

| Key | Action | Description |
|-----|--------|-------------|
| `Ctrl+Y` | `copy_entry_to_clipboard` | Copy the selected entry text to system clipboard |
| `Ctrl+R` | `reload_source` | Re-run the source command (refresh results) |
| `Ctrl+S` | `cycle_sources` | Cycle through multiple source commands |

### Source Cycling

When a channel defines multiple source commands:

```toml
[source]
command = ["fd -t f", "fd -t f -H", "fd -t f -H -I"]
# 1. Normal files only
# 2. Include hidden files
# 3. Include hidden + gitignored files
```

Press `Ctrl+S` to cycle through these modes.

---

## 6. Input Field Editing

Edit the search query in the input bar.

| Key | Action | Description |
|-----|--------|-------------|
| `Backspace` | `delete_prev_char` | Delete character before cursor |
| `Delete` | `delete_next_char` | Delete character after cursor |
| `Ctrl+W` | `delete_prev_word` | Delete previous word |
| `Ctrl+U` | `delete_line` | Clear the entire input line |
| `Left` | `go_to_prev_char` | Move cursor left one character |
| `Right` | `go_to_next_char` | Move cursor right one character |
| `Home` | `go_to_input_start` | Jump to start of input |
| `End` | `go_to_input_end` | Jump to end of input |
| `Ctrl+A` | `go_to_input_start` | Jump to start (Emacs-style) |
| `Ctrl+E` | `go_to_input_end` | Jump to end (Emacs-style) |

---

## 7. History Navigation

Navigate through previous search queries.

| Key | Action | Description |
|-----|--------|-------------|
| `Ctrl+Up` | `select_prev_history` | Previous search query |
| `Ctrl+Down` | `select_next_history` | Next search query |

History is channel-scoped by default. Set `global_history = true` in config
to share history across all channels.

History size: `history_size = 500` (configurable in config.toml).

---

## 8. Shell Integration (Zsh)

Television hooks into your shell for smart autocompletion and history search.

### Setup

Add to `~/.zshrc`:
```zsh
eval "$(tv init zsh)"
```

Or cache it (recommended for speed):
```zsh
# In ~/.cache/shell/rebuild.sh, add:
tv init zsh > ~/.cache/shell/tv_init.zsh
zcompile ~/.cache/shell/tv_init.zsh

# In ~/.zshrc deferred init:
source ~/.cache/shell/tv_init.zsh
```

### Shell Keybindings

| Key | Function | Description |
|-----|----------|-------------|
| `Ctrl+T` | Smart Autocomplete | Opens tv with context-aware channel based on current command |
| `Ctrl+R` | Command History | Opens tv with your shell history for fuzzy search |

### How Smart Autocomplete Works

1. You start typing a command: `git checkout `
2. Press `Ctrl+T`
3. Television detects "git checkout" matches the `git-branch` channel trigger
4. Opens tv with the `git-branch` channel
5. You fuzzy-find the branch, press Enter
6. The branch name is inserted into your command line

### Context Examples

| You Type... | Then Press `Ctrl+T` | Channel Opened |
|-------------|---------------------|----------------|
| `cd ` | `Ctrl+T` | `dirs` |
| `nvim ` | `Ctrl+T` | `git-repos` |
| `git checkout ` | `Ctrl+T` | `git-branch` |
| `git add ` | `Ctrl+T` | `git-diff` |
| `docker exec ` | `Ctrl+T` | `docker-containers` |
| `ssh ` | `Ctrl+T` | `ssh-hosts` |
| `man ` | `Ctrl+T` | `man-pages` |
| `kill ` | `Ctrl+T` | `procs` |
| `brew info ` | `Ctrl+T` | `brew-packages` |
| (anything else) | `Ctrl+T` | `files` (fallback) |

---

## 9. Channel Triggers Map

Complete mapping of commands to channels (from config):

| Channel | Triggered By |
|---------|-------------|
| `files` | `cat`, `less`, `head`, `tail`, `bat`, `cp`, `mv`, `rm`, `touch`, `chmod`, `chown`, `ln`, `tar`, `zip`, `unzip`, `gzip`, `gunzip`, `xz`, `php`, `php artisan`, `composer` |
| `dirs` | `cd`, `ls`, `rmdir`, `z` |
| `alias` | `alias`, `unalias` |
| `env` | `export`, `unset` |
| `git-diff` | `git add`, `git restore` |
| `git-branch` | `git checkout`, `git branch`, `git merge`, `git rebase`, `git pull`, `git push`, `git switch` |
| `git-log` | `git log`, `git show`, `git revert`, `git cherry-pick` |
| `git-stash` | `git stash` |
| `git-tags` | `git tag` |
| `git-repos` | `nvim`, `nv`, `code`, `hx`, `git clone` |
| `docker-images` | `docker run`, `docker rmi` |
| `docker-containers` | `docker exec`, `docker logs`, `docker stop`, `docker rm` |
| `brew-packages` | `brew uninstall`, `brew info`, `brew upgrade` |
| `ssh-hosts` | `ssh`, `scp`, `rsync` |
| `man-pages` | `man` |
| `tmux-sessions` | `tmux attach`, `tmux switch` |
| `procs` | `kill`, `killall` |

---

## 10. Remote Control (Channel Switcher)

The Remote Control is tv's built-in channel switcher. Think of it as a "TV remote"
that lets you flip between data channels without leaving the UI.

### Usage

1. Press `Ctrl+T` inside tv to open the remote
2. Fuzzy-search for a channel name (e.g., "docker", "git", "brew")
3. Press `Enter` to switch to that channel
4. Press `Ctrl+T` again to go back to the remote

### Direct Channel Launch

```bash
tv files            # File picker
tv text             # Search file contents (ripgrep)
tv git-repos        # Find git repositories
tv git-branch       # Git branches
tv git-log          # Git log
tv git-diff         # Git diff (staged/unstaged)
tv docker-images    # Docker images
tv brew-packages    # Homebrew packages
tv tmux-sessions    # Tmux sessions
tv ssh-hosts        # SSH known hosts
tv man-pages        # Man pages
tv procs            # Running processes
tv env              # Environment variables
tv zsh-history      # Zsh command history
tv zoxide           # Zoxide frecent directories
tv dotfiles         # Dotfiles
tv todo-comments    # TODO/FIXME/HACK in codebase
```

---

## 11. Source & Preview Cycling

### Source Cycling (`Ctrl+S`)

Channels can define multiple source commands. Each press of `Ctrl+S` advances
to the next source variant.

**Example**: The files channel could cycle between:
- Normal files
- Include hidden files
- Include hidden + gitignored files

### Preview Cycling (`Ctrl+F`)

Same concept but for preview commands:
- Syntax-highlighted preview (bat)
- Raw text (cat)
- First N lines (head)

---

## 12. Action Picker & Custom Actions

### Opening the Action Picker

Press `Ctrl+X` to see all available actions for the current channel.

### Defining Custom Actions in Channels

```toml
# In a cable channel TOML file:
[keybindings]
ctrl-e = "actions:edit"
ctrl-v = "actions:view"

[actions.edit]
description = "Open in Neovim"
command = "nvim '{}'"
mode = "execute"    # replaces tv process

[actions.view]
description = "View with bat"
command = "bat '{}'"
mode = "fork"       # runs in subprocess, returns to tv
```

### Action Modes

| Mode | Behavior |
|------|----------|
| `execute` | Replaces the tv process entirely (e.g., opening an editor) |
| `fork` | Runs command as subprocess, returns to tv when done |

---

## 13. Multi-Selection Workflow

### Step-by-Step

1. Launch tv: `tv files`
2. Type to fuzzy-filter results
3. Navigate to first file you want
4. Press `Tab` to select it (highlighted)
5. Navigate to next file
6. Press `Tab` again
7. Repeat for all desired files
8. Press `Enter` to confirm

### Output

Each selected entry is output on its own line:
```
file1.txt
file2.txt
file3.txt
```

### Practical Example: Open Multiple Files

```bash
nvim $(tv files)
# Select multiple files with Tab, press Enter
# Neovim opens with all selected files as buffers
```

### Deselecting

- `Shift+Tab` (backtab): Toggle selection and move UP
- Press `Tab` on an already-selected entry to deselect it

---

## 14. Expect Keys (Script Mode)

For scripting, `--expect` lets you detect *which* key was used to confirm.

### Usage

```bash
output=$(tv files --expect "ctrl-e,ctrl-v,ctrl-o")
key=$(echo "$output" | head -1)
file=$(echo "$output" | tail -1)

case "$key" in
  ctrl-e) nvim "$file" ;;
  ctrl-v) code "$file" ;;
  ctrl-o) open "$file" ;;
  "")     cat "$file" ;;    # Regular Enter
esac
```

### Output Format

When an expect key is pressed:
```
ctrl-e          <-- line 1: the key that was pressed
selected_file   <-- line 2+: the selected entry/entries
```

When regular `Enter` is pressed:
```
                <-- line 1: empty
selected_file   <-- line 2+: the selected entry/entries
```

---

## 15. CLI Flags Quick Reference

### Source Flags

| Flag | Description |
|------|-------------|
| `-s`, `--source-command <CMD>` | Override or set the source command |
| `--ansi` | Parse ANSI color codes from source output |
| `--no-sort` | Preserve original order from source |
| `--source-display <TPL>` | Template for display formatting |
| `--source-output <TPL>` | Template for output formatting |
| `--source-entry-delimiter <CHAR>` | Custom delimiter (e.g., `\0` for null) |

### Preview Flags

| Flag | Description |
|------|-------------|
| `-p`, `--preview-command <CMD>` | Set preview command |
| `--preview-header <TPL>` | Preview header template |
| `--preview-footer <TPL>` | Preview footer template |
| `--preview-offset <TPL>` | Line offset for preview scroll |
| `--preview-size <INT>` | Preview panel size (1-99%) |
| `--preview-border <TYPE>` | Border: none, plain, rounded, thick |
| `--preview-padding <STR>` | Padding: "top=1;left=2;bottom=1;right=2" |
| `--preview-word-wrap` | Enable word wrap in preview |
| `--cache-preview` | Cache preview output per entry |
| `--hide-preview-scrollbar` | Hide the preview scrollbar |

### Visibility Flags

| Flag | Description |
|------|-------------|
| `--no-preview` | Disable preview entirely |
| `--hide-preview` | Hide preview (can toggle later) |
| `--show-preview` | Force show preview |
| `--no-status-bar` | Disable status bar entirely |
| `--hide-status-bar` | Hide status bar (can toggle later) |
| `--no-remote` | Disable remote control entirely |
| `--hide-remote` | Hide remote (can toggle later) |
| `--no-help-panel` | Disable help panel entirely |
| `--show-help-panel` | Force show help panel |

### Input Flags

| Flag | Description |
|------|-------------|
| `-i`, `--input <STR>` | Prefill the search input |
| `--input-header <TPL>` | Input field header |
| `--input-prompt <STR>` | Input prompt string (default: ">") |
| `--input-position <POS>` | top or bottom |
| `--input-border <TYPE>` | Border style |

### Layout Flags

| Flag | Description |
|------|-------------|
| `--layout <TYPE>` | landscape or portrait |
| `--ui-scale <INT>` | UI scale percentage (0-100) |
| `--height <INT>` | Fixed height in lines (non-fullscreen) |
| `--width <INT>` | Fixed width in columns (requires --height or --inline) |
| `--inline` | Inline mode at bottom of terminal |

### Behavior Flags

| Flag | Description |
|------|-------------|
| `--exact` | Substring matching instead of fuzzy |
| `--select-1` | Auto-select if only one result |
| `--take-1` | Auto-select first result after loading |
| `--take-1-fast` | Auto-select first result immediately |
| `--watch <FLOAT>` | Auto-reload source every N seconds |
| `--global-history` | Use global history for this session |

### Config Flags

| Flag | Description |
|------|-------------|
| `--config-file <PATH>` | Use alternate config file |
| `--cable-dir <PATH>` | Use alternate cable/channels directory |
| `-k`, `--keybindings <STR>` | Override keybindings inline |
| `--expect <STR>` | Additional confirm keys (for scripting) |

---

## 16. Entry Selection Strategies

For scripting and automation.

| Strategy | Flag | Behavior |
|----------|------|----------|
| Manual | (none) | User browses and selects |
| Auto-single | `--select-1` | If only 1 result, auto-select it |
| Take first | `--take-1` | Wait for load, take first entry |
| Take first fast | `--take-1-fast` | Take first entry as soon as it appears |

### Examples

```bash
# Auto-select if unique match
tv files --input "unique_filename" --select-1

# Always get first result (scripting)
first_file=$(tv files --take-1)

# Fastest possible (no wait)
tv files --take-1-fast
```

---

## 17. Watch Mode

Auto-reload the source at intervals. Useful for monitoring.

### CLI

```bash
tv --source-command "docker ps" --watch 2.0     # Refresh every 2s
tv procs --watch 5.0                              # Processes every 5s
```

### In Channel Config

```toml
[source]
command = "docker ps --format 'table {{.Names}}\t{{.Status}}'"
watch = 2.0
```

### Use Cases

- Monitor Docker containers
- Watch running processes
- Track file system changes
- Live log tailing

---

## 18. Inline Mode

Run tv embedded in your terminal instead of fullscreen.

```bash
tv --inline                        # Use all available space at bottom
tv --height 15                     # Fixed 15-line height
tv --height 15 --width 80          # Fixed dimensions
tv files --inline --no-status-bar  # Clean inline picker
```

### Use Cases

- Embed in tmux panes without taking over
- Quick file selection without full UI
- Script integration

---

## 19. Layout & Scaling

### Layout Orientation

```bash
tv --layout portrait      # Preview below results
tv --layout landscape     # Preview beside results (default)
```

Toggle at runtime: `Ctrl+L`

### UI Scaling

```bash
tv --ui-scale 80          # Use 80% of terminal, centered
```

In config:
```toml
[ui]
ui_scale = 90
```

---

## 20. Borders & Padding

### CLI

```bash
tv --preview-border thick --results-border none
tv --preview-padding "top=1;left=2;bottom=1;right=2"
tv --input-border rounded
```

### Border Types

| Value | Style |
|-------|-------|
| `none` | No border |
| `plain` | Single-line border |
| `rounded` | Rounded corners (default) |
| `thick` | Double-line border |

---

## 21. Search Patterns

Television uses fuzzy matching by default.

### Fuzzy Matching (Default)

Type any substring or character sequence. Results are ranked by match quality.

```
src main     → matches "src/app/main.rs"
```

### Exact/Substring Matching

```bash
tv files --exact
```

Characters must appear as a contiguous substring. Better performance on
large datasets.

### Tips

- Spaces separate multiple search terms (AND logic)
- The more specific your query, the faster results appear
- Frecency sorting promotes recently/frequently selected entries

---

## 22. Environment Variables

| Variable | Purpose |
|----------|---------|
| `TELEVISION_CONFIG` | Override config directory path |
| `TELEVISION_DATA` | Override data directory path |
| `XDG_CONFIG_HOME` | XDG config base (tv looks in `$XDG_CONFIG_HOME/television/`) |
| `XDG_DATA_HOME` | XDG data base |

---

## 23. Performance Tips

1. **Use `--exact`** for large datasets when fuzzy matching isn't needed
2. **`--take-1-fast`** for fastest scripted selections
3. **`--no-preview`** when preview isn't needed (saves subprocess overhead)
4. **Limit source output**: e.g., `fd --max-results 10000`
5. **Cache shell integration**: Don't `eval "$(tv init zsh)"` every time -- cache it to a file
6. **Set `tick_rate`** higher (e.g., 100) on slow machines for lower CPU usage
7. **Source-level filtering** is always faster than tv-side fuzzy filtering

---

## 24. All Available Channels

Channels installed in `~/.config/television/cable/`:

### Built-in (Native)

| Channel | Command | Description |
|---------|---------|-------------|
| `files` | `tv files` | File picker (fd-based) |
| `text` | `tv text` | Search file contents (ripgrep) |
| `dirs` | `tv dirs` | Directory picker |
| `env` | `tv env` | Environment variables |
| `git-branch` | `tv git-branch` | Git branches |
| `git-diff` | `tv git-diff` | Git diff (changed files) |
| `git-log` | `tv git-log` | Git commit log |
| `git-repos` | `tv git-repos` | Find git repositories |
| `docker-images` | `tv docker-images` | Docker images |
| `bash-history` | `tv bash-history` | Bash command history |

### Community (Cable)

| Channel | Description |
|---------|-------------|
| `alias` | Shell aliases |
| `brew-packages` | Homebrew packages |
| `cargo-commands` | Cargo subcommands |
| `cargo-crates` | Installed Rust crates |
| `channels` | Meta: list all channels |
| `crontab` | Cron jobs |
| `docker-compose` | Docker Compose services |
| `docker-containers` | Docker containers |
| `docker-networks` | Docker networks |
| `docker-volumes` | Docker volumes |
| `dotfiles` | Dotfiles in home |
| `downloads` | Downloads directory |
| `fonts` | Installed fonts |
| `gh-issues` | GitHub issues (via gh) |
| `gh-prs` | GitHub pull requests (via gh) |
| `git-files` | Git tracked files |
| `git-reflog` | Git reflog |
| `git-remotes` | Git remotes |
| `git-stash` | Git stash entries |
| `git-submodules` | Git submodules |
| `git-tags` | Git tags |
| `git-worktrees` | Git worktrees |
| `k8s-contexts` | Kubernetes contexts |
| `k8s-deployments` | Kubernetes deployments |
| `k8s-pods` | Kubernetes pods |
| `k8s-services` | Kubernetes services |
| `make-targets` | Makefile targets |
| `man-pages` | Man pages |
| `mounts` | Mounted filesystems |
| `node-packages` | Node.js packages |
| `npm-packages` | npm packages |
| `npm-scripts` | npm scripts (package.json) |
| `path` | PATH directories |
| `pdf-files` | PDF files |
| `procs` | Running processes |
| `python-venvs` | Python virtual environments |
| `recent-files` | Recently modified files |
| `sesh` | Sesh sessions |
| `ssh-hosts` | SSH known hosts |
| `tmux-sessions` | Tmux sessions |
| `tmux-windows` | Tmux windows |
| `todo-comments` | TODO/FIXME/HACK comments |
| `unicode` | Unicode characters |
| `zoxide` | Zoxide frecent directories |
| `zsh-history` | Zsh command history |

---

## 25. Custom Channel Anatomy

Create custom channels in `~/.config/television/cable/`:

```toml
# ~/.config/television/cable/my-channel.toml

# ── Metadata (required) ───────────────────────────────
[metadata]
name = "my-channel"
description = "What this channel searches"
requirements = ["binary1", "binary2"]   # optional

# ── Source (required) ─────────────────────────────────
[source]
command = "fd -t f -e toml"             # what to search through
# command = ["cmd1", "cmd2"]            # multiple (cycle with Ctrl+S)
# display = "{split:/:-1}"             # format display text
# output = "{}"                        # format output text
# ansi = true                          # parse ANSI colors
# no_sort = true                       # preserve original order
# frecency = false                     # disable frecency ranking
# watch = 5.0                          # auto-reload interval (seconds)

# ── Preview (optional) ────────────────────────────────
[preview]
command = "bat -n --color=always '{}'"
# command = ["bat '{}'", "cat '{}'"]   # multiple (cycle with Ctrl+F)
# env = { BAT_THEME = "ansi" }        # extra environment variables
# offset = "{split:\\::1}"            # scroll to this line

# ── UI Overrides (optional) ──────────────────────────
[ui]
# ui_scale = 80
# layout = "portrait"
# input_bar_position = "bottom"
# input_header = "Search files:"

[ui.preview_panel]
# size = 60
# header = "{}"
# hidden = false

# ── Keybindings (optional) ───────────────────────────
[keybindings]
# shortcut = "f1"                     # F-key shortcut to switch to this
# ctrl-e = "actions:edit"

# ── Actions (optional) ───────────────────────────────
[actions.edit]
description = "Open in editor"
command = "nvim '{}'"
mode = "execute"                       # execute | fork
# separator = "\n"                    # multi-select join character
```

---

## 26. Complete Action Reference

All bindable actions in television:

### Navigation Actions

| Action | Description |
|--------|-------------|
| `select_next_entry` | Move to next entry in results |
| `select_prev_entry` | Move to previous entry in results |
| `select_next_page` | Move down one page of results |
| `select_prev_page` | Move up one page of results |

### Selection Actions

| Action | Description |
|--------|-------------|
| `confirm_selection` | Confirm current selection and exit |
| `toggle_selection_down` | Toggle multi-select, move down |
| `toggle_selection_up` | Toggle multi-select, move up |

### Preview Actions

| Action | Description |
|--------|-------------|
| `scroll_preview_up` | Scroll preview up one line |
| `scroll_preview_down` | Scroll preview down one line |
| `scroll_preview_half_page_up` | Scroll preview up half page |
| `scroll_preview_half_page_down` | Scroll preview down half page |
| `cycle_previews` | Cycle through preview commands |

### Data Actions

| Action | Description |
|--------|-------------|
| `copy_entry_to_clipboard` | Copy entry to system clipboard |
| `reload_source` | Re-run the source command |
| `cycle_sources` | Cycle through source commands |

### UI Toggle Actions

| Action | Description |
|--------|-------------|
| `toggle_remote_control` | Toggle channel switcher |
| `toggle_help` | Toggle help panel |
| `toggle_status_bar` | Toggle status bar |
| `toggle_preview` | Toggle preview panel |
| `toggle_layout` | Switch landscape/portrait |
| `toggle_action_picker` | Open action picker |

### Input Actions

| Action | Description |
|--------|-------------|
| `delete_prev_char` | Delete character before cursor |
| `delete_next_char` | Delete character after cursor |
| `delete_prev_word` | Delete previous word |
| `delete_line` | Clear entire input |
| `go_to_prev_char` | Move cursor left |
| `go_to_next_char` | Move cursor right |
| `go_to_input_start` | Move to start of input |
| `go_to_input_end` | Move to end of input |

### History Actions

| Action | Description |
|--------|-------------|
| `select_prev_history` | Navigate to previous query |
| `select_next_history` | Navigate to next query |

### Application Actions

| Action | Description |
|--------|-------------|
| `quit` | Exit television |

### Custom Actions

| Syntax | Description |
|--------|-------------|
| `actions:<name>` | Trigger a custom action defined in `[actions.<name>]` |

---

## 27. Key Syntax Reference

Valid key names for keybinding configuration:

### Single Characters
`a`-`z`, `0`-`9`, and special characters

### Special Keys

| Key | Name |
|-----|------|
| Enter | `enter` |
| Escape | `esc` |
| Tab | `tab` |
| Shift+Tab | `backtab` |
| Space | `space` |
| Backspace | `backspace` |
| Delete | `delete` |
| Home | `home` |
| End | `end` |
| Page Up | `pageup` |
| Page Down | `pagedown` |
| Arrow Up | `up` |
| Arrow Down | `down` |
| Arrow Left | `left` |
| Arrow Right | `right` |

### Control Keys
`ctrl-a` through `ctrl-z`

### Control + Special
`ctrl-up`, `ctrl-down`, `ctrl-left`, `ctrl-right`

### Function Keys
`f1` through `f12`

### Binding Multiple Keys to One Action

```toml
quit = ["esc", "ctrl-c"]
select_next_entry = ["down", "ctrl-j", "ctrl-n"]
```

### Binding Multiple Actions to One Key

```toml
ctrl-r = ["reload_source", "copy_entry_to_clipboard"]
```

---

## Quick Reference Card

```
╭─────────────────────────────────────────────────────╮
│           TELEVISION QUICK REFERENCE                │
├────────────┬────────────────────────────────────────┤
│ NAVIGATE   │  Up/Down  Ctrl+J/K  Ctrl+N/P          │
│ SELECT     │  Enter (confirm)  Tab (multi-select)   │
│ PREVIEW    │  Ctrl+O (toggle)  PgUp/PgDn (scroll)  │
│ CHANNELS   │  Ctrl+T (remote)  Ctrl+S (cycle src)  │
│ ACTIONS    │  Ctrl+X (picker)  Ctrl+Y (copy)       │
│ LAYOUT     │  Ctrl+L (flip)    Ctrl+H (help)       │
│ RELOAD     │  Ctrl+R (refresh source)               │
│ INPUT      │  Ctrl+W (del word) Ctrl+U (del line)  │
│ QUIT       │  Esc  Ctrl+C                           │
├────────────┴────────────────────────────────────────┤
│ SHELL:  Ctrl+T = smart autocomplete                 │
│         Ctrl+R = history search                     │
╰─────────────────────────────────────────────────────╯
```
