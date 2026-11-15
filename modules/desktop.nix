{ pkgs, ... }:

{
  #Niri wird installiert
  programs.niri.enable = true;
  
  # X11-Apps: Niri startet xwayland-satellite selbst, sobald es im PATH liegt
  environment.systemPackages = [pkgs.xwayland-satellite ];

  # Übergang für Datei-Dialog
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  xdg.portal.config.niri."org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];

  services.gnome.gnome-keyring.enable = true;
  systemd.user.services.niri-flake-polkit.enable = false;

  #Energie-Widgets.
  programs.noctalia = {
    enable = true;
    recommendedServices.enable = true;
  };

}
