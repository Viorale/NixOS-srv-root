{
  description = "srv-root – NixOS-VM mit Niri";

  inputs = {
    # Paketquelle: stabiler Release-Zweig 26.05
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    # "srv-root" ist der Name, den du später mit #srv-root ansprichst
    nixosConfigurations.srv-root = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };   # macht inputs in allen Modulen verfügbar
      modules = [
        ./hosts/srv-root
      ];
    };
  };
}
