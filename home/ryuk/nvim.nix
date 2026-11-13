{ ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;   # setzt EDITOR=nvim für ryuk
  };
  # Das Catppuccin-Theme kommt in Phase 5 automatisch dazu.
}
