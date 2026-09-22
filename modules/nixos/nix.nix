# Nix daemon settings: flakes, and the nix-community binary cache.
{ config, lib, pkgs, ... }:

{
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];

    # Fixed: previously pointed at "https://cachix.org" (the web frontend),
    # which isn't a binary cache, so it never actually served anything.
    substituters = [ "https://nix-community.cachix.org" ];
    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  # crates.io (fronted by Cloudflare) hard-blocks any HTTP User-Agent
  # containing "curl/" on this network, which is exactly what nixpkgs'
  # fetchurl builder sends by default — breaking every Rust package that
  # vendors crates from source (e.g. nix-software-center on aarch64, which
  # has no prebuilt cache). fetchurl's builder.sh appends $NIX_CURL_FLAGS
  # after its own --user-agent flag, and curl honors the last one given,
  # so this overrides it without needing a proxy or touching nixpkgs itself.
  systemd.services.nix-daemon.environment.NIX_CURL_FLAGS = "-A cargo/1.75.0";
}
