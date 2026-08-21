{...}: {
  system.defaults.dock = {
    enable-spring-load-actions-on-all-items = true;
    minimize-to-application = true;
    mouse-over-hilite-stack = true;
    mru-spaces = false;
    showhidden = true;
    wvous-tl-corner = 2;
    showDesktopGestureEnabled = false;
    magnification = true;
    largesize = 55;
    tilesize = 42;
  };

  system.defaults.CustomUserPreferences."com.apple.dock" = {
    mineffect = "genie";
    show-process-indicators = true;
    show-recents = true;
    autohide-delay = 0.0;
    expose-group-apps = false;
    show-recent-count = 1;
  };
}
