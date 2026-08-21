{
  pkgs,
  user,
  ...
}: {
  imports = [
    ./karabiner.nix
    ./lazygit.nix
  ];

  home.stateVersion = "23.05";

  programs.home-manager.enable = true;

  home.packages = with pkgs; [macshot raycast];

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  programs.direnv = {
    enable = true;
    enableFishIntegration = true;
    silent = true;
    nix-direnv.enable = true;
  };

  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
    options = [
      "--cmd z"
    ];
  };

  xdg.configFile."fish/completions/nix.fish".source = "${pkgs.nix}/share/fish/vendor_completions.d/nix.fish";

  programs.zsh = {
    loginExtra = ''
      export PATH="$PATH:/Users/${user}/.dotnet/tools"
    '';
  };

  programs.fish = {
    enable = true;
    shellAliases = {
      rebuild = "sudo -i darwin-rebuild switch --flake $XDG_CONFIG_HOME/nix";
      edit = "nvim ~/.config/nix/flake.nix";
      "e" = "nvim";
      nvimback = "nvim -u ~/.config/nvim.back/init.lua";
    };
    shellInit = ''
      if test -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish
        source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish
      end
    '';
    interactiveShellInit = ''
      set fish_greeting
      set -gx PNPM_HOME /Users/${user}/Library/pnpm
      set -gx SSH_AUTH_SOCK "/Users/${user}/Library/Containers/com.bitwarden.desktop/Data/.bitwarden-ssh-agent.sock"
      set -gx XDG_CONFIG_HOME "$HOME/.config"
      set -gx DIRENV_LOG_FORMAT ""
      set -gx PATH "/run/current-system/sw/bin" $PATH
      set -gx PATH "$HOME/.tmux/plugins/tmuxifier/bin" $PATH
      set -gx PATH "$HOME/Library/pnpm" $PATH
      export PATH="$PATH:/Users/${user}/.dotnet/tools"
      export PATH="/Users/${user}/.local/share/bob/nvim-bin:$PATH"
    '';
  };
}
