{...}: {
  # App itself is installed via homebrew (see modules/darwin/homebrew/default.nix)
  # since it's a signed macOS app nixpkgs can't build. The config is fully
  # nix-managed here; only fn-key-apps.json (shared with karabiner.nix) is a
  # real writable file, edited live from the menu bar as well as by hand.
  home.file.".hammerspoon".source = ./hammerspoon;

  launchd.agents.hammerspoon = {
    enable = true;
    config = {
      ProgramArguments = ["/Applications/Hammerspoon.app/Contents/MacOS/Hammerspoon"];
      RunAtLoad = true;
      KeepAlive = false;
      ProcessType = "Interactive";
    };
  };
}
