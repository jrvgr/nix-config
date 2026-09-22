# NixOS module wiring for the tools defined in ../asahi-kernel-cache-pkgs.nix
# -- see that file for what they do and their trust caveats. Split out so
# the same derivations are also reachable as flake `packages` outputs
# (flake.nix) without needing a full `nixos-rebuild switch` first.
{ pkgs, ... }:

let
  tools = import ../asahi-kernel-cache-pkgs.nix { inherit pkgs; };
in
{
  environment.systemPackages = [ tools.importAsahiKernelCache tools.updateAsahiKernelCache ];
}
