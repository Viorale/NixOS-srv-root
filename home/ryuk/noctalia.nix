{ inputs, ... }:

{
  imports = [ inputs.noctalia.homeModules.default ];

  programs.noctalia = {
    enable = true;
    # Kein systemd.enable: Niri startet Noctalia (siehe niri.nix).
    # Beides zusammen = zwei Bars.

    # Wird zu ~/.config/noctalia/config.toml und beim Bauen
    # mit "noctalia config validate" geprüft – wie die Niri-Config.
    settings = {
      theme = {
        mode = "dark";
        source = "builtin";
        builtin = "Catppuccin";
      };
      shell.polkit_agent = false;   # wird in 4.3 auf true gesetzt
    };
  };
}
