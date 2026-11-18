{ ... }:

{
  programs.kitty = {
    enable = true;
    # "Mono"-Variante: Icons sind genau eine Zelle breit
    font = {
      name = "CaskaydiaCove Nerd Font Mono";
      size = 12;
    };
  };
  programs.kitty.settings = {
    background_opacity = "0.7";   # Wert zwischen 0 und 1, als String
    background_blur = 1;        # kitty bittet den Compositor um Blur
  };

}
