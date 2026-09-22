# Host entry point for NixBook (Asahi Linux on Apple Silicon). Keep this
# file thin: host identity and device-specific bits only. Shared NixOS
# settings live in ../../../modules/nixos/*.nix, wired up by `mkNixos` in
# ../../../flake.nix.
{ hostname, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  networking.hostName = hostname;
  nixpkgs.config.allowUnfree = true;

  # Per-device Apple firmware, extracted from this Mac -- not something to
  # commit directly (see hosts/nixos/nixbook/firmware/README, once the
  # jrvgr/nixbook-firmware submodule is wired up).
  hardware.asahi.peripheralFirmwareDirectory = ./firmware;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. See `man configuration.nix` or
  # https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion
  system.stateVersion = "26.11";
}
