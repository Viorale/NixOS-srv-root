{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    spotify
  ];

  programs.gamemode.enable = true;
}
