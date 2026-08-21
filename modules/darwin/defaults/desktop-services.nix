{...}: {
  system.defaults.CustomUserPreferences."com.apple.desktopservices" = {
    # Disable creating .DS_Store files in network an USB volumes
    DSDontWriteNetworkStores = true;
    DSDontWriteUSBStores = true;
  };
}
