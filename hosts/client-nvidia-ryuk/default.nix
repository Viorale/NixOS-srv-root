{ inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../common.nix
    ../../modules/nvidia.nix
  ];

  networking.hostName = "client-nvidia-ryuk"; # wird in Phase 1b zu "srv-root"

  # Version der Erstinstallation – NIE ändern
  system.stateVersion = "26.05";
}
