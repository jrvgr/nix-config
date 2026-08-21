{...}: {
  homebrew = {
    prefix = "/opt/homebrew/";
    enable = true;
    masApps = {
      tailscale = 1475387142;
      bitwarden = 1352778147;
    };
    brews = [
      "media-control"
    ];
    casks = [
      "keka"
      "middleclick"
      "helium-browser"
      "notion-calendar"
      "karabiner-elements"
      "hammerspoon"
      "homerow"
      "thebrowsercompany-dia"
      "orbstack"
    ];
  };
}
