{ pkgs, inputs, ... }:

{

  imports = [ inputs.spicetify-nix.homeManagerModules.default ];

  home.packages = with pkgs; [
    obsidian
  ];

  programs.spicetify =
    let
      spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
    in
    {
      enable = true;
      theme = spicePkgs.themes.catppuccin;
      colorScheme = "mocha";
    };

  programs.obsidian = {
    enable = true;

    vaults = {
      nixos.target = "Dokumente/Obsidian/NixOS/NixOS";
      cybersec.target = "Dokumente/Obsidian/CyberSec";
    };
    defaultSettings.themes = [ inputs.obsidian-obsidianite ];
  };
}
