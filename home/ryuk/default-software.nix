{ pkgs, ... }:

{
  home.packages = with pkgs; [
    obsidian
  ];

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
}
