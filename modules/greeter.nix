{ config, lib, pkgs, ... }:

{
  # Schaltet auch services.greetd an und startet ReGreet in cage (Kiosk-Compositor:
  # zeigt genau ein Fenster bildschirmfüllend).
  programs.regreet = {
    enable = true;

    # Der Greeter läuft als User "greeter", nicht als ryuk.
    # Home-Manager-Settings von ryuk sieht er nicht – darum hier noch einmal.
    theme = {
      name = "Colloid-Dark-Catppuccin";
      package = pkgs.colloid-gtk-theme.override {
        colorVariants = [ "dark" ];
        tweaks = [ "catppuccin" ];
      };
    };
    iconTheme = {
      name = "Colloid-Catppuccin-Dark";
      package = pkgs.colloid-icon-theme.override {
        schemeVariants = [ "catppuccin" ];
      };
    };
    cursorTheme = {
      name = "catppuccin-mocha-dark-cursors";
      package = pkgs.catppuccin-cursors.mochaDark;
    };
    font = {
      name = "CaskaydiaCove Nerd Font";
      size = 14;
      package = pkgs.nerd-fonts.caskaydia-cove;
    };

    settings = {
      GTK.application_prefer_dark_theme = true;
      appearance.greeting_msg = "srv-root";
    };
  };

  # greetd startet den Greeter mit LEERER Umgebung: ohne Layout-Angabe
  # tippst du dein Passwort mit US-Tastatur (z und y vertauscht!).
  # Gleicher Befehl wie der Standard des regreet-Moduls, nur mit XKB_DEFAULT_LAYOUT davor.
  services.greetd.settings.default_session.command =
  "${pkgs.dbus}/bin/dbus-run-session ${pkgs.coreutils}/bin/env XKB_DEFAULT_LAYOUT=de GSK_RENDERER=cairo WLR_NO_HARDWARE_CURSORS=1 XCURSOR_THEME=catppuccin-mocha-dark-cursors XCURSOR_SIZE=24 XCURSOR_PATH=/run/current-system/sw/share/icons "
    + "${lib.getExe pkgs.cage} ${lib.escapeShellArgs config.programs.regreet.cageArgs} -- "
    + "${lib.getExe config.programs.regreet.package}";

  # Schlüsselbund beim Login entsperren – bisher hat GDM das erledigt
  security.pam.services.greetd.enableGnomeKeyring = true;
}
