# Asahi hardware support, kernel, and bootloader.
{ config, lib, pkgs, ... }:

{
  hardware.asahi.enable = true;

  boot.extraModprobeConfig = ''
    options hid_apple swap_fn_leftctrl=1
  '';

  boot.kernelParams = [
    "appledrm.show_notch=1"
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;
}
