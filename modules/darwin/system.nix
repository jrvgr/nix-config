{...}: {
  imports = [
    ./defaults/global-domain.nix
    ./defaults/universal-access.nix
    ./defaults/desktop-services.nix
    ./defaults/adlib.nix
    ./defaults/calendar.nix
    ./defaults/dock.nix
    ./defaults/screencapture.nix
    ./defaults/finder.nix
    ./defaults/control-center.nix
    ./defaults/trackpad.nix
    ./defaults/menu-extra-clock.nix
    ./defaults/hitoolbox.nix
  ];

  system = {
    keyboard = {
      enableKeyMapping = true;
      nonUS.remapTilde = true;
    };
    startup.chime = false;
  };
}
