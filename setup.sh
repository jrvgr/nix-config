#!/usr/bin/env bash
# Bootstrap a fresh macOS machine onto this nix-darwin config.
#
# 1. Installs Nix via the Determinate Systems installer (if not already present).
# 2. Clones this repo (with its submodules) if it isn't already checked out.
# 3. Uses `gum` (run ephemerally from nixpkgs, nothing installed permanently)
#    to interactively pick which darwinConfiguration to activate.
# 4. Builds and switches to that configuration.
#
# Usage: ./setup.sh [--dry-run|-n]
#   --dry-run   Don't install Nix, clone, or switch — just show what would
#               happen. Still runs the picker and builds the chosen
#               configuration (no switch) so you can verify it evaluates.
set -euo pipefail

DRY_RUN=false
for arg in "$@"; do
  case "$arg" in
    --dry-run | -n) DRY_RUN=true ;;
    -h | --help)
      tail -n +2 "$0" | grep '^#' | cut -c3-
      exit 0
      ;;
    *)
      echo "Unknown option: $arg" >&2
      exit 1
      ;;
  esac
done

REPO_URL="git@github.com:jrvgr/nix-config.git"
REPO_DIR="${NIX_CONFIG_DIR:-$HOME/.config/nix}"

if ! command -v nix >/dev/null 2>&1; then
  if $DRY_RUN; then
    echo "[dry-run] would install Nix via the Determinate Systems installer"
    echo "[dry-run] nix isn't installed, so there's nothing more to simulate — stopping here."
    exit 0
  fi
  echo "Installing Nix (Determinate Nix installer)..."
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
  # shellcheck disable=SC1091
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi

if [ ! -d "$REPO_DIR/.git" ]; then
  if $DRY_RUN; then
    echo "[dry-run] would run: git clone --recurse-submodules $REPO_URL $REPO_DIR"
    echo "[dry-run] repo isn't checked out yet, so there's nothing more to simulate — stopping here."
    exit 0
  fi
  echo "Cloning $REPO_URL to $REPO_DIR..."
  git clone --recurse-submodules "$REPO_URL" "$REPO_DIR"
fi

mapfile -t hosts < <(
  nix eval "$REPO_DIR#darwinConfigurations" --apply builtins.attrNames --json |
    nix run nixpkgs#jq -- -r '.[]'
)

config=$(
  nix run nixpkgs#gum -- choose \
    --header "Which nix-darwin configuration do you want to activate?" \
    "${hosts[@]}"
)

if $DRY_RUN; then
  echo "Building '$config' (no switch)..."
  nix build "$REPO_DIR#darwinConfigurations.$config.system" --no-link
  echo "[dry-run] build succeeded. would run: sudo nix run nix-darwin -- switch --flake $REPO_DIR#$config"
  exit 0
fi

echo "Activating '$config'..."
sudo nix run nix-darwin -- switch --flake "$REPO_DIR#$config"
