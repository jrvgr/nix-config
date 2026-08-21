{pkgs, ...}: {
  environment.systemPackages = [pkgs.ghostty-bin];
  system.defaults.CustomUserPreferences."com.mitchellh.ghostty".ApplePressAndHoldEnabled = 0;
}
