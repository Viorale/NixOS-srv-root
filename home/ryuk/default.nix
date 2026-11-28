{ ... }:

# Durch reichen der packete
{
  imports = [
    ./terminal.nix
    ./niri.nix
    ./cli.nix
    ./yazi.nix
    ./nvim.nix
    ../noctalia.nix
    ./theme.nix
    ./browser.nix
    ./default-software.nix
  ];

  #User wird für nix konfiguriert
  home.username = "ryuk";
  home.homeDirectory = "/home/ryuk";

  # wie system.stateVersion: einmal setzen, nie ändern
  home.stateVersion = "26.05";
}
