{
  pkgs,
  system,
  ...
}: {
  nixpkgs.hostPlatform = system;

  environment.systemPackages = with pkgs; [
    pnpm
    lazygit
    bat
    ripgrep
    github-copilot-cli
    delta
    bitwarden-cli
    bob-nvim
    vscode
    tree-sitter
    ghostty-bin
    raycast
    spotify
    github-cli
    loopwm
    taskwarrior2
    python314Packages.bugwarrior
    opencode
    firefox
  ];
}
