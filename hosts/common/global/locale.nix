{ lib, ... }: {
  i18n = {
    defaultLocale = lib.mkDefault "en_GB.UTF-8";
    extraLocaleSettings = {
      LC_TIME = lib.mkDefault "en_GB.UTF-8";
    };
    supportedLocales = lib.mkDefault [
      "en_GB.UTF-8/UTF-8"
      "en_IE.UTF-8/UTF-8"
      "en_US.UTF-8/UTF-8"
      "bg_BG.UTF-8/UTF-8"
    ];
  };
  time.timeZone = lib.mkDefault "Europe/London";
}
