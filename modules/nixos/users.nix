# User accounts and system-wide packages.
#
# Per-user packages and dotfiles are managed by home-manager instead
# (see ../../home/jacco/default.nix) — this list is for things that make
# sense system-wide regardless of who's logged in.
{ config, lib, pkgs, ... }:

{
  users.users.jacco = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable 'sudo' for the user.
  };

  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    gnome-tweaks
    claude-code
  ];
}
