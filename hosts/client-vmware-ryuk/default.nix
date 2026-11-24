:q{ inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../common.nix
<<<<<<< HEAD
    ../../modules/nvidia.nix
=======
    ../../modules/vmware.nix
    ../../modules/sunshine.nix
>>>>>>> d88b16e56fbb6d19e6f5fbe40ae1d909ee4b54e2
  ];

  networking.hostName = "client-nvidia-ryuk"; # wird in Phase 1b zu "srv-root"

  # Version der Erstinstallation – NIE ändern
  system.stateVersion = "26.05";
}
