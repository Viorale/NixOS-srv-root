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
        # userChrome.css/userContent.css überhaupt erlauben
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        # Von Nebula empfohlen (Transparenz/Blur)
        "browser.tabs.allow_transparent_browser" = true;
        "zen.widget.linux.transparency" = true; # ⚠️ ABFRAGE 2
      };
    };
  };
}
