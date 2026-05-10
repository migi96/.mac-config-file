# gh-dash — Complete Shortcuts & Keybindings Reference

> **gh-dash** is a terminal UI dashboard for GitHub, providing a unified view
> of your pull requests, issues, and notifications across all repositories.
> It replaces the GitHub web UI for daily triage and review workflows.
>
> Config: `~/.config/gh-dash/config.yml`
> Version: gh v2.87.3 + gh-dash extension
> Author: Dolev Hadar (@dlvhdr)

---

## Table of Contents

1. [How to Launch](#1-how-to-launch)
2. [Views & Sections](#2-views--sections)
3. [Global / Universal Keybindings](#3-global--universal-keybindings)
4. [Navigation](#4-navigation)
5. [Preview Pane](#5-preview-pane)
6. [Search](#6-search)
7. [PR-Specific Keybindings](#7-pr-specific-keybindings)
8. [PR Actions — Custom Commands](#8-pr-actions--custom-commands)
9. [Issue-Specific Keybindings](#9-issue-specific-keybindings)
10. [Issue Actions — Custom Commands](#10-issue-actions--custom-commands)
11. [Notification Keybindings](#11-notification-keybindings)
12. [Companion Tool Integration](#12-companion-tool-integration)
13. [Template Variables](#13-template-variables)
14. [Theme Configuration](#14-theme-configuration)
15. [Layout Configuration](#15-layout-configuration)
16. [Diff Pager Configuration](#16-diff-pager-configuration)
17. [Tips & Workflows](#17-tips--workflows)

---

## 1. How to Launch

```bash
# Use global config (~/.config/gh-dash/config.yml)
gh dash

# Use local repo config (.gh-dash.yml in repo root)
cd ~/code/my-project && gh dash

# Use a specific config file
gh dash --config /path/to/config.yml
```

---

## 2. Views & Sections

gh-dash has three main views, switched with `Tab`/`Shift+Tab`:

| View            | Description                                        | Sections in Our Config        |
| --------------- | -------------------------------------------------- | ----------------------------- |
| **PRs**         | Pull requests across all repos                     | My PRs, Review Requested, Involved, Recently Merged |
| **Issues**      | Issues across all repos                            | My Issues, Assigned, Mentioned |
| **Notifications** | GitHub notifications                             | Unread, Participating, Review, All Read |

Within each view, sections are navigated with `h`/`l` (left/right).
Items within a section are navigated with `j`/`k` (up/down).

---

## 3. Global / Universal Keybindings

These work in every view and every context.

| Key          | Action           | Why It Matters                                              |
| ------------ | ---------------- | ----------------------------------------------------------- |
| `?`          | Toggle help      | Shows all available keybindings for the current context     |
| `q`          | Quit             | Exit gh-dash cleanly                                        |
| `r`          | Refresh section  | Re-fetch data for the current section from GitHub API       |
| `R`          | Refresh all      | Re-fetch all sections — use after bulk operations           |
| `Enter`      | Open             | Open the preview pane for the selected item                 |
| `b`          | Open in browser  | Open the selected item in your default web browser          |
| `Tab`        | Next view        | Switch from PRs -> Issues -> Notifications                  |
| `Shift+Tab`  | Previous view    | Switch backwards through views                              |

### Why These Matter

- **`?` (help)**: The single most important key. When in doubt, press `?` to
  see every available action for your current context. This is context-aware —
  PR view shows PR actions, issue view shows issue actions.

- **`r`/`R` (refresh)**: gh-dash caches data locally. After merging a PR or
  closing an issue, press `R` to see the updated state. Our config also
  auto-refreshes every 30 minutes.

- **`b` (browser)**: Sometimes you need the full GitHub web UI (for complex
  discussions, image attachments, etc.). This opens the exact item you're
  looking at — no URL copying needed.

---

## 4. Navigation

| Key       | Action            | Why It Matters                                           |
| --------- | ----------------- | -------------------------------------------------------- |
| `j`       | Move down         | Vim-style navigation through items in the current section |
| `k`       | Move up           | Vim-style navigation upward                               |
| `g`       | Go to first item  | Jump to the top of the list                               |
| `G`       | Go to last item   | Jump to the bottom of the list                            |
| `Ctrl+d`  | Page down         | Scroll down a full page for long lists                    |
| `Ctrl+u`  | Page up           | Scroll up a full page                                     |
| `h`       | Previous section  | Move to the section tab on the left                       |
| `l`       | Next section      | Move to the section tab on the right                      |
| `/`       | Search            | Filter items in the current section by text               |

### Why These Matter

The navigation model mirrors Vim: `j`/`k` for line movement, `g`/`G` for
jumping to extremes, `Ctrl+d`/`Ctrl+u` for page scrolling. This means you
can navigate your entire GitHub dashboard without ever reaching for the mouse.

`h`/`l` between sections is critical — it lets you quickly jump between
"My PRs" and "Review Requested" without switching views. Combined with `/`
search, you can find any item in seconds.

---

## 5. Preview Pane

The preview pane (right side, 55% width in our config) shows details of the
selected PR, issue, or notification.

| Setting              | Our Value | Description                              |
| -------------------- | --------- | ---------------------------------------- |
| `defaults.preview.open` | `true`  | Preview pane starts open                 |
| `defaults.preview.width` | `55`   | Takes 55% of the terminal width          |

The preview shows:
- **PRs**: Title, description, labels, reviewers, CI status, diff stats
- **Issues**: Title, description, labels, assignees, comments
- **Notifications**: The notification reason and linked item preview

---

## 6. Search

| Key       | Action            | Why It Matters                                           |
| --------- | ----------------- | -------------------------------------------------------- |
| `/`       | Open search       | Start typing to filter items in the current section      |
| `Esc`     | Cancel search     | Close search without applying                            |
| `Enter`   | Apply search      | Apply the filter and navigate results                    |

### Why This Matters

When you have 20+ open PRs across many repos, search lets you instantly
narrow down to the one you need. Type a repo name, PR title fragment, or
author name to filter the list in real-time.

---

## 7. PR-Specific Keybindings

These work when you're in the PR view with a PR selected.

### Built-in Actions

| Key   | Action           | Why It Matters                                              |
| ----- | ---------------- | ----------------------------------------------------------- |
| `d`   | View diff        | Opens the PR diff using the configured pager (delta)        |
| `c`   | Checkout branch  | Checks out the PR branch locally for testing/review         |
| `o`   | Reopen PR        | Reopen a closed PR                                          |
| `x`   | Close PR         | Close the PR without merging                                |
| `W`   | Ready for review | Mark a draft PR as ready for review                         |
| `M`   | Merge PR         | Merge the PR (uses repo's default merge method)             |
| `w`   | Watch CI checks  | Stream CI check status updates in real-time                 |

### Why These Matter

- **`d` (diff)**: The core of code review. Opens the full PR diff in delta
  with Kanagawa-styled syntax highlighting, side-by-side view, and line
  numbers. This is how you read the actual code changes.

- **`c` (checkout)**: When you need to test a PR locally — run tests, try
  the feature, inspect the code in your editor. One keypress instead of
  copying a branch name and running `git checkout`.

- **`M` (merge)**: The final action in a PR's lifecycle. Capital `M` is
  intentional — it's a destructive action that should require deliberate
  intent (shift key).

- **`w` (watch checks)**: Instead of refreshing the GitHub page, this
  streams CI status in your terminal. You see checks pass/fail in real-time.

---

## 8. PR Actions — Custom Commands

These are custom keybindings that run shell commands with template variables.

| Key   | Action                       | Command                                              |
| ----- | ---------------------------- | ---------------------------------------------------- |
| `v`   | View PR in terminal          | `gh pr view {{.PrNumber}} --repo {{.RepoName}}`     |
| `V`   | Interactive PR review        | `gh pr review {{.PrNumber}} --repo {{.RepoName}}`   |
| `A`   | Approve PR                   | `gh pr review ... --approve --body 'LGTM'`          |
| `X`   | Request changes              | `gh pr review ... --request-changes`                 |
| `C`   | Comment on PR                | `gh pr comment ... --editor`                         |
| `y`   | Copy PR URL                  | Copies URL to macOS clipboard via `pbcopy`           |
| `Y`   | Copy branch name             | Copies head branch name to clipboard                 |
| `e`   | Open diff in Neovim          | Fetches branch, opens DiffviewOpen in nvim           |
| `L`   | Open in lazygit              | Opens lazygit in the repo directory                  |
| `T`   | ENHANCE — view CI checks     | Opens gh-enhance TUI with Kanagawa theme             |
| `D`   | diffnav — view diff w/ tree  | Pipes PR diff into diffnav file tree viewer          |

### Why These Matter

- **`v` (view)**: Shows the full PR description, metadata, and comments
  rendered as markdown in your terminal. Faster than opening a browser.

- **`V` (review)**: Starts an interactive review session where you can
  approve, request changes, or leave a review comment — all from the terminal.

- **`A` (approve)**: One-key approval for straightforward PRs. Sends an
  approval with a standard "LGTM" message.

- **`y`/`Y` (copy)**: Essential for sharing. `y` copies the PR URL for
  Slack/Teams messages. `Y` copies the branch name for `git checkout`.

- **`e` (neovim diffview)**: The most powerful review action. Opens the PR
  diff in Neovim's DiffviewOpen plugin, giving you full editor capabilities
  to navigate, annotate, and understand the code changes.

- **`L` (lazygit)**: Opens the repo in lazygit for full git operations —
  interactive rebase, cherry-pick, stash management, etc.

- **`T` (ENHANCE)**: Opens the PR's CI/CD checks in the ENHANCE TUI with
  the Kanagawa theme. See job status, step details, and logs.

- **`D` (diffnav)**: Opens the PR diff in diffnav's file-tree view.
  Complements `d` (delta) — diffnav adds GitHub-style file navigation.

---

## 9. Issue-Specific Keybindings

### Built-in Actions

| Key   | Action           | Why It Matters                                              |
| ----- | ---------------- | ----------------------------------------------------------- |
| `a`   | Assign to self   | Take ownership of an issue                                  |
| `A`   | Unassign         | Remove yourself from an issue                               |
| `c`   | Comment          | Add a comment to the issue                                  |
| `x`   | Close issue      | Close the issue as completed                                |
| `o`   | Reopen issue     | Reopen a closed issue                                       |

### Why These Matter

- **`a` (assign)**: During triage, quickly claim issues you'll work on.
  No need to open GitHub — one keypress and it's yours.

- **`c` (comment)**: Opens your `$EDITOR` to compose a comment. Write
  markdown with your full editor capabilities, then save to post.

---

## 10. Issue Actions — Custom Commands

| Key   | Action                    | Command                                                |
| ----- | ------------------------- | ------------------------------------------------------ |
| `v`   | View issue in terminal    | `gh issue view {{.IssueNumber}} --repo {{.RepoName}}` |
| `y`   | Copy issue URL            | Copies URL to clipboard via `pbcopy`                   |
| `B`   | Create branch from issue  | `gh issue develop {{.IssueNumber}} ... --checkout`     |

### Why These Matter

- **`B` (branch from issue)**: Creates a properly named branch from the
  issue and checks it out. This follows the "issue -> branch -> PR" workflow
  that GitHub tracks — the issue will automatically link to the PR.

---

## 11. Notification Keybindings

| Key   | Action              | Why It Matters                                           |
| ----- | ------------------- | -------------------------------------------------------- |
| `m`   | Mark as read        | Clear a single notification                              |
| `M`   | Mark all as read    | Inbox zero — clear all notifications in the section      |
| `u`   | Unmark              | Mark a read notification as unread again                 |

### Why These Matter

Notification triage is one of the most time-consuming parts of using GitHub.
These keybindings let you process your notification inbox at terminal speed:
scan the list, mark irrelevant ones as read (`m`), and focus on what needs
your attention.

---

## 12. Companion Tool Integration

### ENHANCE (CI/CD Check Viewer)

Integrated via the `T` keybinding on PRs:
```yaml
- key: "T"
  command: "ENHANCE_THEME=kanagawa gh enhance -R {{.RepoName}} {{.PrNumber}}"
```
Opens a dedicated TUI showing all CI/CD workflow runs, job statuses, and
step-by-step logs for the selected PR.

### diffnav (File Tree Diff Viewer)

Integrated via the `D` keybinding on PRs:
```yaml
- key: "D"
  command: "gh pr diff {{.PrNumber}} --repo {{.RepoName}} | diffnav"
```
Opens the PR diff with a GitHub-style file tree sidebar for navigation.

### lazygit

Integrated via the `L` keybinding on PRs:
```yaml
- key: "L"
  command: "cd {{.RepoPath}} && lazygit"
```
Opens the full lazygit TUI in the PR's repo directory.

### Neovim + DiffviewOpen

Integrated via the `e` keybinding on PRs:
```yaml
- key: "e"
  command: >
    cd {{.RepoPath}} &&
    git fetch origin {{.HeadRefName}} &&
    nvim -c 'DiffviewOpen {{.BaseRefName}}...origin/{{.HeadRefName}}'
```
Opens the PR diff in Neovim's Diffview plugin for editor-level review.

---

## 13. Template Variables

Custom keybindings can use these template variables:

| Variable           | Description                              | Available In   |
| ------------------ | ---------------------------------------- | -------------- |
| `{{.RepoName}}`    | `owner/repo` format                      | PRs, Issues    |
| `{{.RepoPath}}`    | Local filesystem path (from repoPaths)   | PRs, Issues    |
| `{{.PrNumber}}`    | Pull request number                      | PRs only       |
| `{{.HeadRefName}}` | Source branch name                       | PRs only       |
| `{{.BaseRefName}}` | Target branch name                       | PRs only       |
| `{{.Author}}`      | PR/issue author username                 | PRs, Issues    |
| `{{.IssueNumber}}` | Issue number                             | Issues only    |

### repoPaths Setup

For `{{.RepoPath}}` to work, you need to map repos in your config:
```yaml
repoPaths:
  migbyte-0/my-project: ~/code/my-project
  org/repo: ~/code/org/repo
```

---

## 14. Theme Configuration

Our config uses the Kanagawa Wave color palette:

```yaml
theme:
  ui:
    sectionsShowCount: true    # Show item count next to section names
    table:
      showSeparator: true      # Show separator lines between rows
      compact: false           # Use comfortable row spacing

  colors:
    text:
      primary: "#DCD7BA"       # fujiWhite — main text
      secondary: "#C8C093"     # oldWhite — secondary info
      inverted: "#1F1F28"      # sumiInk1 — text on highlighted bg
      faint: "#54546D"         # sumiInk4 — muted/disabled text
      warning: "#FF5D62"       # peachRed — errors, closed items
      success: "#98BB6C"       # springGreen — merged, passing checks

    background:
      selected: "#2D4F67"      # waveBlue2 — highlighted row

    border:
      primary: "#54546D"       # sumiInk4 — main borders
      secondary: "#727169"     # fujiGray — active/focused borders
      faint: "#16161D"         # sumiInk0 — subtle separators
```

---

## 15. Layout Configuration

Column widths are configured per section and in defaults:

| Column         | Width | Description                                      |
| -------------- | ----- | ------------------------------------------------ |
| `repo`         | 18    | Repository name                                  |
| `author`       | 12    | PR/issue author                                  |
| `assignees`    | hidden | Assignees (hidden by default in PRs)             |
| `base`         | 15    | Target branch for PRs                            |
| `lines`        | 12    | Lines added/removed (+/-)                        |
| `reviewStatus` | 5     | Review approval status                           |
| `updatedAt`    | 10    | Time since last update                           |

---

## 16. Diff Pager Configuration

Our config uses delta with Kanagawa-styled colors:

```yaml
pager:
  diff: "delta --side-by-side --line-numbers --syntax-theme=Dracula ..."
```

This gives you:
- Side-by-side view for easy comparison
- Line numbers for referencing specific lines
- Kanagawa-colored additions (green) and deletions (red)
- Syntax highlighting via Dracula (closest to Kanagawa in delta)

---

## 17. Tips & Workflows

### Daily PR Triage
1. `gh dash` — open the dashboard
2. Start in "My PRs" — check CI status, merge what's ready (`M`)
3. `l` to "Review Requested" — review PRs assigned to you
4. `d` to read the diff, `A` to approve, or `V` for detailed review
5. `Tab` to Issues view — triage new issues (`a` to assign)
6. `Tab` to Notifications — clear noise with `m`/`M`

### Full PR Review Workflow
1. Select a PR, press `d` for a quick delta diff scan
2. `D` for diffnav's file tree view on complex PRs
3. `T` to check CI/CD status via ENHANCE
4. `c` to checkout and test locally
5. `e` to open in Neovim DiffviewOpen for deep review
6. `A` to approve or `V` for interactive review
7. `M` to merge when ready

### Quick Reference Card

```
UNIVERSAL           PR ACTIONS          ISSUE ACTIONS
?  help             d  diff (delta)     a  assign
q  quit             D  diff (diffnav)   A  unassign
r  refresh          c  checkout         c  comment
R  refresh all      M  merge            x  close
b  browser          x  close            o  reopen
/  search           W  ready            v  view
Enter  open         w  watch checks     y  copy URL
Tab    next view    T  ENHANCE (CI)     B  branch from issue

NAVIGATION          v  view in terminal NOTIFICATIONS
j  down             V  review           m  mark read
k  up               A  approve          M  mark all read
g  top              X  request changes  u  unmark
G  bottom           C  comment
h  prev section     y  copy URL
l  next section     Y  copy branch
Ctrl+d  page down   e  neovim diff
Ctrl+u  page up     L  lazygit
```

---

*Generated for the Kanagawa terminal setup. gh-dash via gh v2.87.3.*
