# diffnav — Complete Shortcuts & Keybindings Reference

> **diffnav** is a terminal-based git diff pager built on top of delta, adding a
> GitHub-style file tree sidebar for navigating multi-file diffs. It is the
> visual companion to `git diff`, replacing the default pager with an
> interactive, navigable TUI.
>
> Config: `~/.config/diffnav/config.yml`
> Version: v0.11.0
> Author: Dolev Hadar (@dlvhdr)

---

## Table of Contents

1. [How to Launch](#1-how-to-launch)
2. [Navigation — Moving Through Files](#2-navigation--moving-through-files)
3. [Navigation — Scrolling the Diff](#3-navigation--scrolling-the-diff)
4. [File Tree Controls](#4-file-tree-controls)
5. [Search & Go-To](#5-search--go-to)
6. [View Modes](#6-view-modes)
7. [Actions](#7-actions)
8. [Watch Mode](#8-watch-mode)
9. [CLI Flags](#9-cli-flags)
10. [Icon Styles](#10-icon-styles)
11. [Integration with Other Tools](#11-integration-with-other-tools)
12. [Configuration Reference](#12-configuration-reference)
13. [Delta Integration](#13-delta-integration)
14. [Tips & Workflows](#14-tips--workflows)

---

## 1. How to Launch

diffnav is set as the global git diff pager, so any `git diff` command will
automatically open in diffnav. You can also pipe into it explicitly:

```bash
# Automatic — set via: git config --global pager.diff diffnav
git diff

# Explicit pipe
git diff | diffnav
git diff --cached | diffnav
git diff HEAD~3..HEAD | diffnav

# GitHub PR diffs via gh CLI
gh pr diff 123 | diffnav
gh pr diff https://github.com/owner/repo/pull/123 | diffnav

# Watch mode — auto-refresh
diffnav --watch
diffnav --watch-cmd "git diff --cached" --watch-interval 5s
```

---

## 2. Navigation — Moving Through Files

| Key   | Action              | Why It Matters                                                |
| ----- | ------------------- | ------------------------------------------------------------- |
| `j`   | Next node/file      | Vim-style downward movement through the file tree             |
| `k`   | Previous node/file  | Vim-style upward movement through the file tree               |
| `n`   | Next file           | Jump directly to the next file's diff, skipping tree nodes    |
| `p`   | Previous file       | Jump directly to the previous file's diff                     |
| `N`   | Previous file       | Alias for `p` — same as "next" in reverse                     |

### Why These Matter

When reviewing a PR with 20+ changed files, `j`/`k` let you browse the tree
while `n`/`p` let you jump between files in the diff pane without touching the
tree. This separation means you can focus on reading diffs linearly (`n`/`p`)
or selectively pick files from the tree (`j`/`k` + `Enter`).

---

## 3. Navigation — Scrolling the Diff

| Key      | Action              | Why It Matters                                             |
| -------- | ------------------- | ---------------------------------------------------------- |
| `Ctrl+d` | Scroll diff down    | Page down through the current file's diff content          |
| `Ctrl+u` | Scroll diff up      | Page up through the current file's diff content            |

### Why These Matter

Long diffs can span hundreds of lines. `Ctrl+d`/`Ctrl+u` are the standard
Vim half-page scroll commands — they let you read through a large diff
methodically without losing your place. This is critical for reviewing
implementation details within a single file.

---

## 4. File Tree Controls

| Key   | Action              | Why It Matters                                              |
| ----- | ------------------- | ----------------------------------------------------------- |
| `e`   | Toggle file tree    | Show/hide the sidebar to maximize diff reading space        |
| `Tab` | Switch pane focus   | Move focus between the file tree and the diff pane          |

### Why These Matter

- **`e` (toggle tree)**: When you know which file you want to read, hiding
  the tree gives you the full terminal width for the diff. When you need to
  navigate to a different file, bring it back. This is especially important
  on smaller screens or when using side-by-side mode.

- **`Tab` (switch focus)**: The two-pane layout requires a way to move
  keyboard focus. When the tree is focused, `j`/`k` move through files.
  When the diff is focused, scrolling commands apply to the diff content.

---

## 5. Search & Go-To

| Key   | Action                | Why It Matters                                           |
| ----- | --------------------- | -------------------------------------------------------- |
| `t`   | Search/go-to file     | Fuzzy-find a file by name in large diffs                 |

### Why This Matters

In a PR with 50+ files, scrolling through the tree is tedious. `t` opens a
search panel (width configurable via `ui.searchTreeWidth`) where you can type
part of a filename to jump directly to it. This is the equivalent of GitHub's
file finder in the PR diff view — essential for targeted code review.

---

## 6. View Modes

| Key   | Action                        | Why It Matters                                   |
| ----- | ----------------------------- | ------------------------------------------------ |
| `s`   | Toggle side-by-side/unified   | Switch between split and inline diff views       |
| `i`   | Cycle icon style              | Rotate through icon display modes in the tree    |

### Why These Matter

- **`s` (side-by-side toggle)**: Side-by-side shows old and new code next to
  each other — ideal for refactoring reviews where you need to compare
  structure. Unified view stacks deletions and additions vertically — better
  for reading new code additions linearly. Being able to switch on the fly
  means you pick the right view for each file.

- **`i` (cycle icons)**: Rotates through: `nerd-fonts-status` -> `simple` ->
  `filetype` -> `full` -> `unicode` -> `ascii`. The `filetype` and `full`
  modes show language-specific icons (Go gopher, Python snake, etc.) making
  it easy to visually identify file types at a glance.

---

## 7. Actions

| Key   | Action              | Why It Matters                                              |
| ----- | ------------------- | ----------------------------------------------------------- |
| `y`   | Copy file path      | Yank the selected file's path to the clipboard              |
| `o`   | Open in $EDITOR     | Open the selected file in your configured editor (nvim)     |
| `q`   | Quit                | Exit diffnav and return to the terminal                     |

### Why These Matter

- **`y` (copy path)**: After reviewing a diff, you often need to reference
  the file path — to paste into a PR comment, run a test, or open it
  elsewhere. `y` copies it instantly without mouse selection.

- **`o` (open in editor)**: The most powerful action. When you spot something
  in the diff that needs fixing, press `o` to jump directly into your editor
  at that file. This bridges the gap between reviewing and editing — no need
  to remember the path and open it manually.

- **`q` (quit)**: Clean exit. Returns you to where you were.

---

## 8. Watch Mode

Watch mode makes diffnav auto-refresh on an interval, showing you live
changes as you code. This is useful for monitoring your work-in-progress.

```bash
# Watch unstaged changes (default: git diff, every 2s)
diffnav --watch

# Watch staged changes with custom interval
diffnav --watch-cmd "git diff --cached" --watch-interval 5s

# Watch changes against a specific branch
diffnav --watch-cmd "git diff main..."

# Watch a specific file
diffnav --watch-cmd "git diff -- src/main.go"
```

### Why Watch Mode Matters

Instead of repeatedly running `git diff` to check your progress, watch mode
keeps a live view open. Pair this with a tmux split — editor on one side,
diffnav watch on the other — and you get real-time visual feedback on your
changes as you code.

---

## 9. CLI Flags

| Flag                 | Short | Description                                          |
| -------------------- | ----- | ---------------------------------------------------- |
| `--side-by-side`     | `-s`  | Force side-by-side diff view                         |
| `--unified`          | `-u`  | Force unified (inline) diff view                     |
| `--watch`            | `-w`  | Enable watch mode (auto-refresh)                     |
| `--watch-cmd`        |       | Command to run in watch mode (default: `git diff`)   |
| `--watch-interval`   |       | Refresh interval (default: `2s`)                     |
| `--help`             | `-h`  | Show help                                            |
| `--version`          | `-v`  | Show version                                         |

---

## 10. Icon Styles

Configure via `ui.icons` in `config.yml` or cycle at runtime with `i`:

| Style               | Description                                              | Best For                |
| ------------------- | -------------------------------------------------------- | ----------------------- |
| `nerd-fonts-status`  | Boxed git status icons (M/A/D) colored by change type   | Status-focused review   |
| `nerd-fonts-simple`  | Generic file icon colored by change type                 | Minimal, clean look     |
| `nerd-fonts-filetype`| Language-specific icons colored by change type           | Polyglot projects       |
| `nerd-fonts-full`    | Both status + filetype icons, all colored                | Maximum information     |
| `unicode`            | Unicode symbols (+/x/*)                                  | No Nerd Font installed  |
| `ascii`              | Plain ASCII characters (+/x/*)                           | SSH / minimal terminals |

---

## 11. Integration with Other Tools

### As Global Git Diff Pager
```bash
git config --global pager.diff diffnav
```
Now every `git diff` command opens in diffnav automatically.

### With gh-dash
In `~/.config/gh-dash/config.yml`:
```yaml
keybindings:
  prs:
    - key: "D"
      command: "gh pr diff {{.PrNumber}} --repo {{.RepoName}} | diffnav"
```
Press `D` on any PR in gh-dash to view its diff with the file tree.

### With tmux Watch Mode
```bash
# Open a tmux split with live diff monitoring
tmux split-window -h 'diffnav --watch'
```

### With GitHub CLI
```bash
# View any PR diff
gh pr diff 123 | diffnav

# Compare branches
gh pr diff https://github.com/org/repo/pull/456 | diffnav
```

---

## 12. Configuration Reference

Config file location: `~/.config/diffnav/config.yml`

```yaml
ui:
  hideHeader: false        # Hide the DIFFNAV header bar
  hideFooter: false        # Hide the keybindings footer
  showFileTree: true       # Show file tree on startup
  fileTreeWidth: 30        # Width of the file tree (columns)
  searchTreeWidth: 55      # Width of the search panel
  icons: nerd-fonts-full   # Icon style (see table above)
  colorFileNames: true     # Color filenames by git status
  showDiffStats: true      # Show +/- line counts per file
  sideBySide: true         # Side-by-side view (false = unified)
```

---

## 13. Delta Integration

diffnav uses `delta` under the hood for syntax-highlighted diff rendering.
Delta reads its configuration from `~/.gitconfig` or `~/.config/delta/config`.

Key delta options that affect diffnav rendering:

| Delta Option              | Effect in diffnav                                   |
| ------------------------- | --------------------------------------------------- |
| `syntax-theme`            | Code syntax highlighting theme                      |
| `minus-style`             | Style for removed lines                             |
| `plus-style`              | Style for added lines                               |
| `line-numbers`            | Show line numbers in diffs                          |
| `side-by-side`            | Default to side-by-side (overridden by diffnav)     |
| `navigate`                | Enable n/N to jump between files (handled by diffnav) |

To get Kanagawa-style diffs, add to `~/.gitconfig`:
```ini
[delta]
    syntax-theme = Dracula
    minus-style = syntax #43242B
    plus-style = syntax #2B3328
    minus-emph-style = syntax #FF5D62
    plus-emph-style = syntax #98BB6C
    line-numbers = true
    line-numbers-minus-style = #E46876
    line-numbers-plus-style = #98BB6C
    line-numbers-zero-style = #54546D
```

---

## 14. Tips & Workflows

### Code Review Workflow
1. `gh pr diff 123 | diffnav` — open the PR diff
2. `t` to search for the most important file
3. `s` to pick the right view mode (side-by-side for refactors)
4. `Ctrl+d`/`Ctrl+u` to read through the diff
5. `o` to jump into your editor if something needs fixing
6. `n`/`p` to move to the next/previous file
7. `y` to copy the path for a PR comment
8. `q` when done

### Live Development Feedback
1. Split tmux: `tmux split-window -h 'diffnav --watch'`
2. Edit code in the other pane
3. diffnav auto-refreshes every 2s showing your changes
4. `s` to toggle view mode as needed

### Quick Keybinding Summary

```
j/k        — navigate file tree
n/p/N      — jump between files
Ctrl+d/u   — scroll diff
e          — toggle file tree
t          — search files
s          — toggle side-by-side/unified
i          — cycle icon style
y          — copy file path
o          — open in $EDITOR
Tab        — switch pane focus
q          — quit
```

---

*Generated for the Kanagawa terminal setup. diffnav v0.11.0.*
