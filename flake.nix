{
  description = "srv-root – NixOS-VM mit Niri";

  inputs = {
    # Paketquelle: stabiler Release-Zweig 26.05
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
  

  #Home Manger wird installiert 
  home-manager = {
    url = "github:nix-community/home-manager/release-26.05";
    inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: {
    # "srv-root" ist der Name, den du später mit #srv-root ansprichst
    nixosConfigurations.srv-root = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };   # macht inputs in allen Modulen verfügbar
      modules = [
        ./hosts/srv-root
        home-manager.nixosModules.home-manager
      ];
    };
  };
}
