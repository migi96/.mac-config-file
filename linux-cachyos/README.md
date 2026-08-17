# linux-cachyos — Hyprland config ported from my macOS setup

Copy-paste desktop config for **CachyOS + Hyprland**. Window-management
shortcuts are ported **1:1 from AeroSpace**, so the muscle memory carries over.

```
linux-cachyos/
├── install.sh            # copies everything into ~/.config (backs up existing)
├── hypr/hyprland.conf    # ← the WM, AeroSpace keybinds ported (cmd → SUPER)
├── waybar/               # status bar (replaces macOS sketchybar)
├── herdr/config.toml     # terminal multiplexer (Linux paths)
├── ghostty/config        # primary terminal
└── kitty/kitty.conf      # fallback terminal
```

## Install

```bash
# from inside the repo:
cd linux-cachyos

./install.sh --packages     # 1. install Hyprland + tools via paru (CachyOS)
./install.sh                # 2. copy the desktop configs into ~/.config
./install.sh --crossplat    # 3. (optional) also copy nvim/yazi/tmux/starship/atuin/wisp
```

Existing `~/.config/<dir>` is backed up to `<dir>.bak-YYYYMMDD` before copying.
Then: `chsh -s /usr/bin/zsh`, install fonts (below), log out, pick **Hyprland**.

---

## Window-management keys (AeroSpace → Hyprland)

The `⌘` key on a Mac keyboard registers as **SUPER** on Linux — same physical keys.

| Action | macOS (AeroSpace) | Linux (Hyprland) |
|---|---|---|
| Focus left/down/up/right | `⌘ h/j/k/l` | `SUPER h/j/k/l` |
| Move window left/down/up/right | `⌘⇧ h/j/k/l` | `SUPER SHIFT h/j/k/l` |
| Resize shrink / grow | `⌘⇧ - / =` | `SUPER SHIFT - / =` |
| Fullscreen | `⌘⇧ a` | `SUPER SHIFT a` |
| Flip split (tiles h/v) | `⌘ /` | `SUPER /` |
| Group/stack (≈ accordion) | `⌘ ,` | `SUPER ,` |
| **Workspace 1–9** | `⌘⌥⇧ s d f g b u w y a` | `SUPER ALT SHIFT s d f g b u w y a` |
| **Move window → ws 1–9** | `⌘⌃⌥⇧ s d f g b u w y a` | `SUPER CTRL ALT SHIFT s d f g b u w y a` |
| Workspace back-and-forth | `⌘ 5` / `⌘ b` | `SUPER 5` / `SUPER b` |
| Join windows (service mode) | `⌘⇧ h/j/k/l` | `SUPER CTRL h/j/k/l` |
| Float/tile toggle | service `o` | `SUPER CTRL o` |

Workspace letter map (unchanged): **s→1 d→2 f→3 g→4 b→5 u→6 w→7 y→8 a→9**

### Desktop keys macOS gave you for free (Hyprland needs them explicitly)

| Action | Key |
|---|---|
| Open terminal | `SUPER Return` |
| App launcher (≈ ⌘-Space Spotlight) | `SUPER Space` |
| Close window (≈ ⌘-Q) | `SUPER Q` |
| File manager (yazi) | `SUPER E` |
| Toggle floating | `SUPER SHIFT Space` |
| Resize mode (then h/j/k/l, Esc) | `SUPER R` |
| Lock screen | `SUPER P` |
| Region screenshot → clipboard | `Print` |
| Volume / brightness / media | hardware keys |

---

## Fonts

Two fonts are required (same as macOS). On Linux they go in `~/.local/share/fonts/`:

1. **ProFont IIx Nerd Font** — main terminal font.
2. **Kawkab Mono (patched)** — Arabic rendering in wisp. Your macOS build script
   (`kitty/fonts/build-tajawal-wisp.py`) writes the patched `.otf` to
   `~/Library/Fonts` on the Mac — copy those two patched files
   (`KawkabMono-{Regular,Bold}.otf`) to `~/.local/share/fonts/` on Linux, or
   re-run the script with a Linux output path.

```bash
cp *.otf *.ttf ~/.local/share/fonts/ && fc-cache -f
fc-list | grep -i kawkab      # verify it registered
```

---

## herdr + wisp

- **herdr** (terminal multiplexer): `config.toml` here has all built-in
  keybindings (prefix `ctrl+n`, tmux-style) working unchanged. The macOS
  `[[keys.command]]` custom scripts (`prefix+t` → wisp, `prefix+c` → zoxide
  picker, etc.) are **commented out** because they call mac tools (`pbcopy`,
  `screencapture`, `osascript`, `launchd`). Port the scripts and uncomment when
  ready — the swaps are: `pbcopy→wl-copy`, `screencapture→grim`, drop
  `osascript`/`launchd`.
- **wisp** (WhatsApp TUI): cross-platform Rust, needs Rust ≥ 1.96. Build it,
  don't copy config. Its Arabic rendering depends on the patched Kawkab Mono +
  the `font-codepoint-map` in `ghostty/config` (both already set here).

---

## What was left behind (macOS-only, no Linux equivalent)

`aerospace` (→ hypr), `sketchybar` (→ waybar), `karabiner`, `raycast`, `iterm2`,
`SmartSetMasterErgo (Mac)`. Keyboard remapping like Karabiner → use **keyd** or
Hyprland's `input.kb_options`.

## Things to set after first login

- `hyprctl monitors` → put your real monitor name (DP-1/HDMI-A-1) in
  `hypr/hyprland.conf` for the LG UltraGear line + the workspace-pinning block.
- If on an **NVIDIA** GPU, uncomment the NVIDIA `env` block in `hyprland.conf`.
- Arabic input toggle: uncomment the `kb_layout = us,ara` lines in `input {}`.
