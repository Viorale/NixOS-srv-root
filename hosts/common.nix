{ inputs, ... }:

{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    inputs.niri.nixosModules.niri
    inputs.noctalia.nixosModules.default

    ../modules/core.nix
    ../modules/audio.nix
    ../modules/network.nix
    ../modules/desktop.nix
    ../modules/fonts.nix
    ../modules/greeter.nix

  ];

  nixpkgs.config.allowUnfree = true;

  home-manager = {
    useGlobalPkgs = true; # gleiche pkgs wie das System (inkl. allowUnfree)
    useUserPackages = true; # Pakete landen in /etc/profiles/per-user/ryuk
    backupFileExtension = "hm-backup"; # vorhandene Dateien umbenennen statt abbrechen
    extraSpecialArgs = { inherit inputs; };
    users.ryuk = import ../home/ryuk;
  };

  # Version der Erstinstallation – NIE ändern
  system.stateVersion = "26.05";
}
