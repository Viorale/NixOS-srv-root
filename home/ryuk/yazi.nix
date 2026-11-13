{ ... }:

{
  programs.yazi = {
    enable = true;
    enableBashIntegration = true;  # Shell-Funktion: yazi öffnen, beim Beenden in den Ordner wechseln
    shellWrapperName = "y";        # Name dieser Funktion
  };
}
