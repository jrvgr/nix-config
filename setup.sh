#!/usr/bin/env bash
# Bootstrap a fresh macOS machine onto this nix-darwin config.
#
# 1. Installs Nix via the Determinate Systems installer (if not already present).
# 2. Clones this repo (with its submodules) if it isn't already checked out.
# 3. Uses `gum` (run ephemerally from nixpkgs, nothing installed permanently)
#    to interactively pick which darwinConfiguration to activate.
# 4. Builds and switches to that configuration.
set -euo pipefail

REPO_URL="git@github.com:jrvgr/nix-config.git"
REPO_DIR="${NIX_CONFIG_DIR:-$HOME/.config/nix}"

if ! command -v nix >/dev/null 2>&1; then
  echo "Installing Nix (Determinate Nix installer)..."
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
  # shellcheck disable=SC1091
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi

if [ ! -d "$REPO_DIR/.git" ]; then
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

echo "Activating '$config'..."
sudo nix run nix-darwin -- switch --flake "$REPO_DIR#$config"
