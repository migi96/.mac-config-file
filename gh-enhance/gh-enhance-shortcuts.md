# gh-enhance — Complete Shortcuts & Keybindings Reference

> **gh-enhance** (ENHANCE) is a blazingly fast terminal UI for GitHub Actions.
> It provides a rich, interactive view of CI/CD workflow runs, jobs, and steps
> for any pull request — replacing the GitHub Actions web UI for monitoring
> build and test pipelines.
>
> Theme: Kanagawa (via `ENHANCE_THEME=kanagawa`)
> Author: Dolev Hadar (@dlvhdr)

---

## Table of Contents

1. [How to Launch](#1-how-to-launch)
2. [Interface Layout](#2-interface-layout)
3. [Navigation Keybindings](#3-navigation-keybindings)
4. [Search Keybindings](#4-search-keybindings)
5. [Action Keybindings](#5-action-keybindings)
6. [Theming](#6-theming)
7. [CLI Flags & Options](#7-cli-flags--options)
8. [gh-dash Integration](#8-gh-dash-integration)
9. [tmux Integration](#9-tmux-integration)
10. [Tips & Workflows](#10-tips--workflows)

---

## 1. How to Launch

```bash
# By PR URL — works from anywhere
gh enhance https://github.com/owner/repo/pull/123

# By PR number — must be inside a clone of the repo
gh enhance 123

# With a specific repo (from anywhere)
gh enhance -R owner/repo 123

# With Kanagawa theme
ENHANCE_THEME=kanagawa gh enhance 123

# Flat view (no grouping by workflow)
gh enhance --flat 123

# Debug mode (writes to debug.log)
gh enhance --debug 123
```

### Shell Alias (add to ~/.zshrc)

```bash
# Quick alias with Kanagawa theme baked in
alias ghe='ENHANCE_THEME=kanagawa gh enhance'

# Usage: ghe 123 or ghe https://github.com/owner/repo/pull/123
```

---

## 2. Interface Layout

ENHANCE displays a multi-pane interface:

```
┌─────────────────────────────────────────────────────────┐
│  ENHANCE — PR #123: "Add user authentication"           │  <- Header
├──────────────────────┬──────────────────────────────────┤
│  Workflows / Jobs    │  Steps / Logs                    │
│                      │                                  │
│  > CI Pipeline       │  1. Checkout code        ✓ 2s   │
│    > Build (linux)   │  2. Setup Node.js        ✓ 5s   │
│      > test          │  3. Install deps         ✓ 12s  │
│      > lint          │  4. Run tests            ✗ 45s  │
│      > deploy        │  5. Upload artifacts     - skip  │
│    > Build (macos)   │                                  │
│                      │                                  │
├──────────────────────┴──────────────────────────────────┤
│  ? help  o browser  R refresh  ctrl+r rerun             │  <- Footer
└─────────────────────────────────────────────────────────┘
```

- **Left pane**: Workflow runs grouped by workflow, with jobs nested inside.
  In flat mode (`--flat` or toggle with `m`), jobs are shown as a flat list.
- **Right pane**: Steps within the selected job, with status icons and duration.

---

## 3. Navigation Keybindings

| Key    | Action              | Why It Matters                                            |
| ------ | ------------------- | --------------------------------------------------------- |
| `j`    | Next row            | Move down through workflows/jobs/steps                    |
| `k`    | Previous row        | Move up through the list                                  |
| `↓`    | Next row            | Arrow key alternative to `j`                              |
| `↑`    | Previous row        | Arrow key alternative to `k`                              |
| `l`    | Next pane           | Move focus from jobs pane to steps/logs pane               |
| `h`    | Previous pane       | Move focus back to the jobs pane                           |
| `→`    | Move right          | Arrow key alternative to `l`                               |
| `←`    | Move left           | Arrow key alternative to `h`                               |
| `g`    | Go to top           | Jump to the first item in the current pane                 |
| `G`    | Go to bottom        | Jump to the last item in the current pane                  |
| `?`    | Toggle help         | Show/hide the keybindings help overlay                     |

### Why These Matter

- **`j`/`k` (vertical navigation)**: The primary way to browse through your
  CI pipeline. In grouped mode, `j`/`k` moves through workflows, then into
  jobs within each workflow. This hierarchical navigation mirrors how GitHub
  Actions organizes workflows.

- **`h`/`l` (pane switching)**: ENHANCE has two panes — the job list (left)
  and the step detail (right). `l` moves focus to the steps pane so you can
  see the individual steps of a job. `h` moves back. This is essential for
  debugging: find the failing job with `j`/`k`, then `l` to see which step
  failed.

- **`g`/`G` (jump)**: When a PR has many workflow runs (e.g., CI on multiple
  OS targets, linting, security scans), `g` and `G` let you quickly jump to
  the first or last workflow without scrolling through everything.

- **`?` (help)**: Context-sensitive help. Always available when you forget a
  keybinding. Shows all actions available in the current pane.

---

## 4. Search Keybindings

| Key      | Action            | Why It Matters                                          |
| -------- | ----------------- | ------------------------------------------------------- |
| `/`      | Open search       | Start filtering items in the current pane               |
| `Esc`    | Cancel search     | Close search without applying the filter                |
| `Enter`  | Apply search      | Apply the search filter and navigate to matches         |
| `Ctrl+n` | Next match        | Jump to the next search result                          |
| `Ctrl+p` | Previous match    | Jump to the previous search result                      |

### Why These Matter

- **`/` (search)**: When a PR triggers 10+ workflow runs across different
  environments, searching by name (e.g., "lint", "test", "deploy") lets you
  find the specific job you care about instantly.

- **`Ctrl+n`/`Ctrl+p` (match navigation)**: After searching, these let you
  jump between matches without clearing the filter. Essential when multiple
  jobs match your search (e.g., "test" matching "test-unit", "test-e2e",
  "test-integration").

---

## 5. Action Keybindings

| Key      | Action               | Why It Matters                                         |
| -------- | -------------------- | ------------------------------------------------------ |
| `m`      | Toggle flat/grouped  | Switch between hierarchical and flat job views          |
| `o`      | Open in browser      | Open the selected job/step in the GitHub web UI         |
| `O`      | Open PR              | Open the PR itself in the browser                       |
| `R`      | Refresh all          | Re-fetch all workflow data from GitHub API              |
| `Ctrl+r` | Rerun                | Re-trigger the selected workflow run                    |

### Why These Matter

- **`m` (toggle mode)**: Grouped mode shows workflows with nested jobs —
  good for understanding the pipeline structure. Flat mode shows all jobs as
  a single list — faster for scanning when you just need to find the failing
  job. Toggle based on your current need.

- **`o` (open in browser)**: Some CI failures need the full GitHub web UI to
  debug — especially when you need to see log output, download artifacts, or
  read full error messages that are truncated in the TUI.

- **`O` (open PR)**: Quick escape hatch to the PR page. Useful when you
  realize you need to see the PR discussion or leave a review comment.

- **`R` (refresh)**: CI is a moving target — jobs start, succeed, fail, and
  get re-triggered. `R` fetches the latest state so you see real-time status
  without restarting ENHANCE.

- **`Ctrl+r` (rerun)**: The most powerful action. When a job fails due to a
  flaky test or transient error, you can re-trigger it directly from your
  terminal without opening GitHub. This saves significant time when dealing
  with intermittent CI failures.

---

## 6. Theming

ENHANCE supports all themes from [bubbletint](https://lrstanley.github.io/bubbletint/).

### Setting the Theme

```bash
# One-time use
ENHANCE_THEME=kanagawa gh enhance 123

# Permanent via shell alias (in ~/.zshrc)
alias ghe='ENHANCE_THEME=kanagawa gh enhance'

# Or export globally
export ENHANCE_THEME=kanagawa
```

### Available Themes Close to Kanagawa

| Theme ID          | Description                                          |
| ----------------- | ---------------------------------------------------- |
| `kanagawa`        | Kanagawa color palette (our default)                 |
| `kanagawabones`   | Kanagawa-inspired with bone tones                    |
| `tokyonight`      | Tokyo Night — similar dark Japanese aesthetic         |
| `tokyonight_storm`| Tokyo Night Storm variant                            |
| `dracula`         | Dracula — popular dark theme                         |
| `catppuccin_mocha`| Catppuccin Mocha — warm dark palette                 |
| `rose_pine`       | Rose Pine — dark with muted colors                   |
| `gruvbox_dark`    | Gruvbox Dark — earthy tones                          |

---

## 7. CLI Flags & Options

| Flag             | Short | Description                                            |
| ---------------- | ----- | ------------------------------------------------------ |
| `--repo`         | `-R`  | Select a specific repo (`[HOST/]OWNER/REPO`)           |
| `--flat`         |       | Present checks as a flat list instead of grouped       |
| `--debug`        |       | Write debug output to `debug.log`                      |
| `--help`         | `-h`  | Show help information                                  |
| `--version`      | `-v`  | Show version information                               |

### Examples

```bash
# View checks for PR #42 in a specific repo
gh enhance -R dlvhdr/gh-dash 42

# View in flat mode (no workflow grouping)
gh enhance --flat 123

# Debug a rendering issue
gh enhance --debug 123
# then inspect: cat debug.log
```

---

## 8. gh-dash Integration

ENHANCE is integrated into our gh-dash config via the `T` keybinding:

```yaml
# In ~/.config/gh-dash/config.yml
keybindings:
  prs:
    - key: "T"
      command: "ENHANCE_THEME=kanagawa gh enhance -R {{.RepoName}} {{.PrNumber}}"
```

### Workflow
1. In gh-dash, select a PR
2. Press `T` to open ENHANCE for that PR's CI checks
3. Navigate jobs with `j`/`k`, view steps with `l`
4. `Ctrl+r` to rerun a failed job
5. `q` to return to gh-dash

---

## 9. tmux Integration

### Launch in a New tmux Window
```yaml
# In gh-dash config
keybindings:
  prs:
    - key: "T"
      command: >-
        tmux new-window '
          ENHANCE_THEME=kanagawa gh enhance -R {{.RepoName}} {{.PrNumber}}
        '
```

### Launch in a tmux Split
```bash
# Horizontal split
tmux split-window -h 'ENHANCE_THEME=kanagawa gh enhance 123'

# Vertical split
tmux split-window -v 'ENHANCE_THEME=kanagawa gh enhance 123'
```

---

## 10. Tips & Workflows

### Debugging a Failed CI Job
1. `gh enhance 123` (or `T` from gh-dash)
2. `j`/`k` to find the failing workflow (marked with `X` or red)
3. `l` to move into the steps pane
4. `j`/`k` to find the failing step
5. Read the step output / error message
6. `o` to open in browser if you need full log output
7. Fix the code, push, then `Ctrl+r` to rerun

### Monitoring a Deploy Pipeline
1. `gh enhance <deploy-pr-number>`
2. Watch the steps progress through build -> test -> deploy
3. `R` to refresh and see the latest status
4. `o` on the deploy step to see the full deploy log in browser

### Quick Status Check
1. From gh-dash, press `w` to watch checks inline
2. Or press `T` for the full ENHANCE TUI
3. `m` to toggle between grouped/flat view based on preference

### Quick Reference Card

```
NAVIGATION          SEARCH              ACTIONS
j/↓    next row     /      search       m      toggle flat/grouped
k/↑    prev row     Esc    cancel       o      open in browser
l/→    next pane    Enter  apply        O      open PR
h/←    prev pane    Ctrl+n next match   R      refresh all
g      go to top    Ctrl+p prev match   Ctrl+r rerun job
G      go to bottom
?      toggle help

LAUNCH
gh enhance <PR#>                     # by number (in repo)
gh enhance <URL>                     # by PR URL
gh enhance -R owner/repo <PR#>       # specific repo
ENHANCE_THEME=kanagawa gh enhance    # with theme
```

---

*Generated for the Kanagawa terminal setup. gh-enhance companion to gh-dash.*
