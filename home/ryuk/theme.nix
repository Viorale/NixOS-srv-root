{ inputs, pkgs, ... }:

{
  imports = [ inputs.catppuccin.homeModules.catppuccin ];

  catppuccin = {
    enable = true;
    # themet jedes unterstützte Programm, das in HM aktiv ist:
    # kitty, neovim, yazi, bat, fzf
    flavor = "mocha";
    accent = "mauve";

    # catppuccin würde sonst Papirus-Icons setzen und Colloid überschreiben
    gtk.icon.enable = false;
  };

  catppuccin.cursors = {
    enable = true;
    accent = "dark"; # ergibt: catppuccin-mocha-dark-cursors
  };

  catppuccin.kitty.enable = false; # kitty-Farben kommen jetzt von Noctalia
  gtk = {
    #  enable = true;

    # theme = {
    #    name = "Colloid-Dark-Catppuccin";
    #    package = pkgs.colloid-gtk-theme.override {
    #      colorVariants = [ "dark" ];
    #      tweaks = [ "catppuccin" ];
    #    };
    iconTheme = {
      name = "Colloid-Catppuccin-Dark";
      package = pkgs.colloid-icon-theme.override {
        schemeVariants = [ "catppuccin" ];
      };
    };

    font = {
      name = "CaskaydiaCove Nerd Font";
      size = 11;
    };
  };

  home.pointerCursor = {
    size = 24;
    gtk.enable = true; # Cursor auch in GTK-Apps
  };

  # GTK4-/libadwaita-Apps und Portale lesen nur diese Einstellung
  dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";
}
