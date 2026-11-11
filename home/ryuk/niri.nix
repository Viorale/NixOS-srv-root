{ pkgs, ... }:

{
  # Übergangs-Launcher, bis Noctalia (Phase 4) einen eigenen mitbringt
  home.packages = [ pkgs.fuzzel ];

  programs.niri.settings = {
    # --- Eingabe ---
    input.keyboard.xkb.layout = "de";

    # --- Verhalten ---
    prefer-no-csd = true;                  # Apps ohne eigene Titelleisten
    environment.NIXOS_OZONE_WL = "1";      # Electron-Apps nativ unter Wayland

    # --- Tastenkürzel (Mod = Super-/Windows-Taste) ---
    binds = {
      # Programme
      "Mod+Return".action.spawn = [ "kitty" ];
      "Mod+D".action.spawn = [ "fuzzel" ];

      # Fenster
      "Mod+Q".action.close-window = { };
      "Mod+F".action.maximize-column = { };
      "Mod+Shift+F".action.fullscreen-window = { };
      "Mod+R".action.switch-preset-column-width = { };

      # Fokus wechseln
      "Mod+Left".action.focus-column-left = { };
      "Mod+Right".action.focus-column-right = { };
      "Mod+Up".action.focus-window-up = { };
      "Mod+Down".action.focus-window-down = { };

      # Spalten verschieben
      "Mod+Shift+Left".action.move-column-left = { };
      "Mod+Shift+Right".action.move-column-right = { };

      # Workspaces
      "Mod+1".action.focus-workspace = 1;
      "Mod+2".action.focus-workspace = 2;
      "Mod+3".action.focus-workspace = 3;
      "Mod+4".action.focus-workspace = 4;
      "Mod+Shift+1".action.move-column-to-workspace = 1;
      "Mod+Shift+2".action.move-column-to-workspace = 2;
      "Mod+Shift+3".action.move-column-to-workspace = 3;
      "Mod+Shift+4".action.move-column-to-workspace = 4;

      # Übersicht und Hilfe
      "Mod+O".action.toggle-overview = { };
      "Mod+Shift+H".action.show-hotkey-overlay = { };   # H wie Hilfe

      # Niri beenden (mit Rückfrage)
      "Mod+Shift+E".action.quit = { };
    };
  };
}
