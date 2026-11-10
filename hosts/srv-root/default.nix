{ inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/core.nix
    ../../modules/audio.nix
    ../../modules/network.nix
    ../../modules/gnome.nix   # Übergang: fliegt in Phase 6 raus
    ../../modules/vmware.nix
  ];

  home-manager = {
    useGlobalPkgs = true;               # gleiche pkgs wie das System (inkl. allowUnfree)
    useUserPackages = true;             # Pakete landen in /etc/profiles/per-user/ryuk
    backupFileExtension = "hm-backup";  # vorhandene Dateien umbenennen statt abbrechen
    extraSpecialArgs = { inherit inputs; };
    users.ryuk = import ../../home/ryuk;
  };

  networking.hostName = "srv-root";   # wird in Phase 1b zu "srv-root"

  # Version der Erstinstallation – NIE ändern
  system.stateVersion = "26.05";
}
