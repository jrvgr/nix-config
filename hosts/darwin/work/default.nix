{
  pkgs,
  system,
  ...
}: {
  nixpkgs.hostPlatform = system;

  environment.systemPackages = with pkgs; [
    pnpm
    bat
    ripgrep
    github-copilot-cli
    delta
    bitwarden-cli
    bob-nvim
    tree-sitter
    spotify
    github-cli
    loopwm
    taskwarrior2
    python314Packages.bugwarrior
    opencode
    firefox
  ];
}
