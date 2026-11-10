{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/core.nix
    ../../modules/audio.nix
    ../../modules/network.nix
    ../../modules/gnome.nix   # Übergang: fliegt in Phase 6 raus
    ../../modules/vmware.nix
  ];

  networking.hostName = "srv-root";   # wird in Phase 1b zu "srv-root"

  # Version der Erstinstallation – NIE ändern
  system.stateVersion = "26.05";
}
