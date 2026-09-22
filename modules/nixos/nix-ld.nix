# nix-ld: run unpatched, dynamically-linked binaries built for generic Linux
# (e.g. downloaded release tarballs) without manually patchelf-ing each one.
{ config, lib, pkgs, ... }:

{
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    nss
    nspr
    expat
    alsa-lib
  ];
}
