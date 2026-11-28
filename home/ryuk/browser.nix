{ inputs, ... }:

{
  imports = [ inputs.zen-browser.homeModules.beta ];

  programs.zen-browser = {
    enable = true;
    setAsDefaultBrowser = true;

    profiles.default = {
      id = 0;
      isDefault = true;

      # Nebula aus dem Nix-Store laden

      userChrome = ''@import "${inputs.zen-nebula}/userChrome.css";'';
      userContent = ''@import "${inputs.zen-nebula}/userContent.css";'';

      settings = {
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "browser.tabs.allow_transparent_browser" = true;
        "zen.widget.linux.transparency" = true; # ⚠️ ABFRAGE 2
      };
    };
  };
}
