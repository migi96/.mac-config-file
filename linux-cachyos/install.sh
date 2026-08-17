#!/usr/bin/env bash
# ============================================================================
# install.sh — drop these configs into ~/.config on CachyOS (Hyprland).
#
# Usage:
#   ./install.sh              # copy the Linux desktop configs into ~/.config
#   ./install.sh --crossplat  # ALSO copy the cross-platform configs (nvim, yazi,
#                             #   tmux, starship, atuin, wisp) from the repo root
#   ./install.sh --packages   # print/run the paru package install first
#
# Existing target dirs are backed up to <dir>.bak-YYYYMMDD before overwriting.
# ============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"   # .../linux-cachyos
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"                    # the config repo root
DEST="$HOME/.config"

# NOTE: timestamped backup suffix (no seconds — one backup per day is plenty)
STAMP="$(date +%Y%m%d)"

LINUX_DIRS=(hypr waybar herdr ghostty kitty)
CROSSPLAT_DIRS=(nvim yazi tmux starship atuin wisp)

PACKAGES=(
  # --- Hyprland desktop core ---
  hyprland waybar wofi mako hyprpolkitagent hyprlock hyprpaper xdg-desktop-portal-hyprland
  # --- utilities the hyprland.conf binds call ---
  grim slurp wl-clipboard cliphist brightnessctl playerctl
  wireplumber pavucontrol network-manager-applet
  # --- terminals / shell / tools you already use ---
  ghostty kitty zsh atuin starship zoxide fzf yazi tmux neovim
  # --- fonts ---
  ttf-nerd-fonts-symbols noto-fonts noto-fonts-emoji
)

backup_and_copy() {
  local src="$1" name="$2"
  [[ -d "$src" ]] || { echo "  skip $name (not found in repo)"; return; }
  if [[ -e "$DEST/$name" ]]; then
    mv "$DEST/$name" "$DEST/$name.bak-$STAMP"
    echo "  backed up existing ~/.config/$name -> $name.bak-$STAMP"
  fi
  cp -R "$src" "$DEST/$name"
  echo "  installed ~/.config/$name"
}

install_packages() {
  echo ">> Installing packages with paru (CachyOS ships it):"
  printf '   %s\n' "${PACKAGES[@]}"
  if command -v paru >/dev/null 2>&1; then
    paru -S --needed "${PACKAGES[@]}"
  else
    echo "!! paru not found. Install with: sudo pacman -S --needed base-devel git && \\"
    echo "   git clone https://aur.archlinux.org/paru.git && cd paru && makepkg -si"
    echo "   (or just: sudo pacman -S --needed ${PACKAGES[*]}  — AUR-only pkgs will fail)"
  fi
}

main() {
  local do_cross=0 do_pkgs=0
  for a in "$@"; do
    case "$a" in
      --crossplat) do_cross=1 ;;
      --packages)  do_pkgs=1 ;;
      *) echo "unknown arg: $a"; exit 1 ;;
    esac
  done

  [[ $do_pkgs == 1 ]] && install_packages

  mkdir -p "$DEST"
  echo ">> Installing Linux desktop configs into $DEST"
  for d in "${LINUX_DIRS[@]}"; do
    backup_and_copy "$SCRIPT_DIR/$d" "$d"
  done

  if [[ $do_cross == 1 ]]; then
    echo ">> Copying cross-platform configs from repo root"
    for d in "${CROSSPLAT_DIRS[@]}"; do
      backup_and_copy "$REPO_ROOT/$d" "$d"
    done
  fi

  cat <<'EOF'

Done. Next steps:
  1. Set zsh as your login shell:   chsh -s /usr/bin/zsh
  2. Install fonts (see README): ProFont IIx Nerd Font + the patched Kawkab Mono
     into ~/.local/share/fonts, then `fc-cache -f`.
  3. Log out and pick "Hyprland" at your login screen (or `Hyprland` from a TTY).
  4. Verify monitors:  hyprctl monitors   (then set the DP-*/HDMI-* name in
     hypr/hyprland.conf for your LG UltraGear + workspace pinning).
EOF
}
main "$@"
