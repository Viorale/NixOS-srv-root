{
  description = "srv-root – NixOS-VM mit Niri";

  inputs = {
    # Paketquelle: stabiler Release-Zweig 26.05
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
  

  #Home Manger wird installiert 
  #Home Manager = schreibt Configs. Die Programme dazu kommen aus deiner nixpkgs.
  home-manager = {
    url = "github:nix-community/home-manager/release-26.05";
    inputs.nixpkgs.follows = "nixpkgs";
    };

  # Niri-Paket + NixOS-/Home-Manager-Module.
  # Bewusst KEIN nixpkgs.follows – sonst passt der Binär-Cache nicht mehr.

  # Niri-flake = liefert ein fertig gebautes Programm (niri), das nicht aus deiner nixpkgs kommt, sondern vom Entwickler mit seiner gebaut wurde.
  niri.url = "github:epireyn/niri-flake";
  };

  outputs = { self, nixpkgs, home-manager, niri, ... }@inputs: {
    # "srv-root" ist der Name, den du später mit #srv-root ansprichst
    nixosConfigurations.srv-root = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };   # macht inputs in allen Modulen verfügbar
      modules = [
        ./hosts/srv-root
        home-manager.nixosModules.home-manager
        niri.nixosModules.niri
      ];
    };
  };
}
