# Home Manager configuration for the NixBook (NixOS/Asahi) host.
#
# Add further program modules here as you adopt them, e.g.:
#   programs.git = {
#     enable = true;
#     userName = "...";
#     userEmail = "...";
#   };
{ config, pkgs, inputs, ... }:

{
  home.username = "jacco";
  home.homeDirectory = "/home/jacco";

  # Per-user CLI tools (system-wide tools live in modules/nixos/users.nix).
  home.packages = with pkgs; with gnomeExtensions; [
    bitwarden-desktop
    blur-my-shell
    wack-sonoma-lockscreen
    rounded-corners
    just-perfection
    hide-universal-access
    transparent-top-bar-tweaks
    fuzzy-app-search
    bring-out-submenu-of-power-offlogout-button
  ];

  dconf.settings."org/gnome/shell" = {
    enabled-extensions = [
      "blur-my-shell@aunetx"
      "wack-lockscreen-clock@rinzler69-wastaken.github.com"
      "Rounded_Corners@lennart-k"
      "just-perfection-desktop@just-perfection"
      "hide-universal-access@akiirui.github.io"
      "transparent-top-bar-tweaks@hectorandac.github.io"
      "gnome-fuzzy-app-search@gnome-shell-extensions.Czarlie.gitlab.com"
      "BringOutSubmenuOfPowerOffLogoutButton@pratap.fastmail.fm"
    ];
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.fish = {
    enable = true;

    # `nix flake update` bumps every input together, including `apple-silicon`
    # (the Asahi kernel source) -- which almost always forces a full local
    # kernel rebuild since there's no binary cache for it. These update
    # inputs one at a time instead, so a kernel rebuild only happens when you
    # deliberately ask for one.
    shellAbbrs = {
      nix-update-safe = "nix flake lock /etc/nixos --update-input home-manager --update-input nixos-aarch64-widevine";
      nix-update-nixpkgs = "nix flake lock /etc/nixos --update-input nixpkgs";
      nix-update-kernel = "nix flake lock /etc/nixos --update-input apple-silicon";
      # Pins apple-silicon to whatever rev the third-party cache last built
      # and imports that prebuilt closure -- see modules/nixos/asahi-kernel-cache.nix.
      nix-update-kernel-cached = "update-asahi-kernel-cache";
    };
  };

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
    options = [
      "--cmd z"
    ];
  };

  programs.ghostty.enable = true;

  # jacco's login shell stays bash (see users.users.jacco), but every
  # interactive bash immediately execs into fish. This keeps scripts and
  # anything hardcoding "bash" working while fish is what you actually type in.
  programs.bash = {
    enable = true;
    initExtra = ''
      if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
      then
        shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
        exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
      fi
    '';
  };

  programs.firefox = {
    enable = true;
  };


  # Widevine (DRM) support for Firefox, via the nixos-aarch64-widevine overlay
  # (flake.nix). Moved here from system-level environment.variables since
  # Firefox itself now lives in home-manager.
  home.sessionVariables = {
    MOZ_GMP_PATH = "${pkgs.widevine-cdm-lacros}/gmp-widevinecdm/system-installed";
  };

  # Keep in lockstep with system.stateVersion in hosts/nixos/nixbook/default.nix;
  # do not bump either without reading the release notes for both.
  home.stateVersion = "26.11";
}
