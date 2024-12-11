{pkgs, ...}: {
  #  programs.browserpass.enable = true;
  programs.firefox = {
    enable = false;
    nativeMessagingHosts = [pkgs.plasma5Packages.plasma-browser-integration];
    profiles.alan = {
      #      bookmarks = { };
      #      # extensions = with pkgs.inputs.firefox-addons; [
      #      #   ublock-origin
      #      #   browserpass
      #      # ];
      settings = {
        #        "browser.disableResetPrompt" = true;
        "browser.download.panel.shown" = true;
        "browser.download.useDownloadDir" = false;
        "browser.newtabpage.enabled" = false;
        #        "browser.shell.checkDefaultBrowser" = false;
        #        "browser.shell.defaultBrowserCheckCount" = 1;
        "browser.startup.homepage" = "about:blank";
        "middlemouse.paste" = false;
        #        "dom.security.https_only_mode" = true;
        #        "identity.fxaccounts.enabled" = false;
        #        "privacy.trackingprotection.enabled" = true;
        #        "signon.rememberSignons" = false;
      };
    };
  };

  home = {
    packages = with pkgs; [firefox];

    # persistence = {
    #   # Not persisting is safer
    #   # "/persist/home/alan".directories = [ ".mozilla/firefox" ];
    # };
  };

  xdg.mimeApps.defaultApplications = {
    "text/html" = ["firefox.desktop"];
    "text/xml" = ["firefox.desktop"];
    "x-scheme-handler/http" = ["firefox.desktop"];
    "x-scheme-handler/https" = ["firefox.desktop"];
  };
}
