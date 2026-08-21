{
  hostname,
  user,
  pkgs,
  ...
}: {
  nixpkgs.config.allowUnfree = true;
  system.stateVersion = 6;
  system.primaryUser = user;
  networking.hostName = hostname;

  users.users.${user} = {
    shell = pkgs.fish;
    name = user;
    home = "/Users/${user}";
  };

  programs.fish.enable = true;
  programs.zsh.enable = true;

  security.pam.services.sudo_local.touchIdAuth = true;
}
