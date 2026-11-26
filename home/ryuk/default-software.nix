{ pkgs, inputs, ... }:

{

  imports = [ inputs.spicetify-nix.homeModules.default ];

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
}

#  programs.obsidian = {
#    enable = true;
#
#    vaults.notes.target = "Dokumente/Obsidian";
#
#    defaultSettings = {
#      communityPlugins = with pkgs.obsidianPlugins; [
#        dataview
#        obsidian-git
#        obsidian-importer
#        vim-yank-highlight
#      ];
#
#      themes = with pkgs.obsidianThemes; [
#        catppuccin
#   ];
#  };
#};
