{pkgs, ...}: {
  environment.systemPackages = [pkgs.vscode];
  system.defaults.CustomUserPreferences."com.microsoft.VSCode".ApplePressAndHoldEnabled = 0;
}
