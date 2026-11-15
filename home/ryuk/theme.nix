{ inputs, ... }:

{
  imports = [ inputs.catppuccin.homeModules.catppuccin ];

  catppuccin = {
    enable = true;      # themet jedes unterstützte Programm, das in HM aktiv ist:
                        # kitty, neovim, yazi, bat, fzf
    flavor = "mocha";
    accent = "mauve";

    # catppuccin würde sonst Papirus-Icons setzen und Colloid überschreiben
    gtk.icon.enable = false;
  };
}
