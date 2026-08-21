{...}: {
  imports = [
    ./defaults/global-domain.nix
    ./defaults/universal-access.nix
    ./defaults/desktop-services.nix
    ./defaults/adlib.nix
    ./defaults/calendar.nix
    ./defaults/apple-dock.nix
  ];

  system = {
    defaults = {
      screencapture = {
        target = "clipboard";
      };
      NSGlobalDomain = {
        AppleKeyboardUIMode = 2;
        AppleInterfaceStyleSwitchesAutomatically = true;
        AppleShowAllFiles = true;
        InitialKeyRepeat = 15;
        KeyRepeat = 2;
        NSDocumentSaveNewDocumentsToCloud = false;
        NSTableViewDefaultSizeMode = 2;
      };
      controlcenter = {
        FocusModes = true;
        Sound = true;
        NowPlaying = false;
      };
      dock = {
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
      finder = {
        AppleShowAllFiles = true;
        NewWindowTarget = "Home";
        AppleShowAllExtensions = true;
        FXDefaultSearchScope = "SCcf";
        FXPreferredViewStyle = "icnv";
        FXRemoveOldTrashItems = true;
        ShowMountedServersOnDesktop = true;
        ShowPathbar = true;
        ShowStatusBar = true;
        _FXShowPosixPathInTitle = true;
        _FXSortFoldersFirst = true;
      };
      iCal = {
        CalendarSidebarShown = true;
        "TimeZone support enabled" = true;
      };
      menuExtraClock = {
        Show24Hour = true;
        ShowSeconds = true;
      };
      trackpad = {
        Clicking = true;
        Dragging = true;
        SecondClickThreshold = 2;
        TrackpadPinch = true;
        TrackpadThreeFingerTapGesture = 0;
        TrackpadTwoFingerFromRightEdgeSwipeGesture = 3;
      };
      hitoolbox.AppleFnUsageType = "Do Nothing";
    };
    keyboard = {
      enableKeyMapping = true;
      nonUS.remapTilde = true;
    };
    startup.chime = false;
  };
}
