{...}: {
  system.defaults.iCal = {
    CalendarSidebarShown = true;
    "TimeZone support enabled" = true;
  };

  system.defaults.CustomUserPreferences."com.apple.ical" = {
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
}
