{
  description = "NixOS-VM mit Niri";

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

    noctalia = {
      url = "github:noctalia-dev/noctalia/v5.5.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    catppuccin = {
      url = "github:catppuccin/nix/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    obsidian-isinglass = {
      url = "github:ameyxd/obsidian-isinglass";
      flake = false;
    };

    zen-nebula = {
      url = "github:JustAdumbPrsn/Zen-Nebula";
      flake = false;
    };

    spicetify-nix.url = "github:Gerg-L/spicetify-nix";

  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      niri,
      noctalia,
      catppuccin,
      ...
    }@inputs:
    let
      mkHost =
        name:
        nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [ ./hosts/${name} ];
        };
    in
    {
      nixosConfigurations = {
        client-vmware-ryuk = mkHost "client-vmware-ryuk";
        client-nvidia-ryuk = mkHost "client-nvidia-ryuk";
      };
    };

}
