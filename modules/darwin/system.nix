{...}: {
  system = {
    defaults = {
      screencapture = {
        target = "clipboard";
      };
      CustomUserPreferences = {
        NSGlobalDomain = {
          AppleAquaColorVariant = 1;
          AppleAccentColor = 0;
          AppleIconAppearanceCustomTintColor = "0.475000 0.836670 1.000000 1.000000";
          AppleIconAppearanceTintColor = "Other";
          AppleActionOnDoubleClick = "fill";
          NSGlassDiffusionSetting = 0;
          AppleInterfaceStyle = null;
          AppleShowScrollBars = "WhenScrolling";
          AppleMiniaturizeOnDoubleClick = false;
        };
        "com.apple.universalaccess" = {
          showToolbarButtonShapes = 1;
          showWindowTitlebarIcons = 1;
          differentiateWithoutColor = 1;
        };
        "com.apple.desktopservices" = {
          # Disable creating .DS_Store files in network an USB volumes
          DSDontWriteNetworkStores = true;
          DSDontWriteUSBStores = true;
        };
        "com.apple.AdLib".allowApplePersonalizedAdvertising = false;
        "com.apple.ical" = {
          privacyPaneHasBeenAcknowledgedVersion = 5;
          "scroll by weeks in week view" = 1;
          "n days of week" = 7;
          "first day of week" = 0;
          "first minute of work hours" = 480;
          "last minute of work hours" = 1020;
          "Show Week Numbers" = 1;
          SuggestionsShowEventsFoundInMail = false;
          "Show time in Month View" = true;
          "WarnBeforeSendingInvitations" = true;
          "OpenEventsInWindowType" = true;
          "CalDefaultCalendar" = "UseLastSelectedAsDefaultCalendar";
        };
        "com.apple.dock" = {
          mineffect = "genie";
          show-process-indicators = true;
          show-recents = true;
          autohide-delay = 0.0;
          expose-group-apps = false;
          show-recent-count = 1;
        };
        "com.mitchellh.ghostty" = {
          ApplePressAndHoldEnabled = 0;
        };
        "com.microsoft.visual-studio" = {
          ApplePressAndHoldEnabled = 0;
        };
        "com.raycast.macos" = {
          # Hotkey/shortcut config (incl. Hyper Key) lives in Raycast v2's
          # encrypted local store (~/Library/Application Support/com.raycast.macos/raycast-enc.sqlite),
          # not in defaults, so it can't be managed here.
          raycastPreferredWindowMode = "default";
          raycastWindowPresentationMode = 2;
          raycastShouldFollowSystemAppearance = true;
          navigationCommandStyleIdentifierKey = "vim";
          popToRootTimeout = 30;
          raycastUI_preferredTextSize = "medium";
          faviconProvider = "legacy";
          showGettingStartedLink = false;
        };
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
