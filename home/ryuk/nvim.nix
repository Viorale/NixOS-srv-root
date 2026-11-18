# Neovim für ryuk: Programm + alle Werkzeuge kommen aus Nix,
# die Lua-Config (Ordner ./nvim daneben) wird nur verlinkt.
#
#   Nix liefert   → nvim selbst, LSP-Server, Formatter, Linter, fzf, yazi, gcc ...
#   lazy.nvim     → lädt die nvim-Plugins zur Laufzeit nach ~/.local/share/nvim
#
# Warum kein Mason: Mason lädt fertige Binaries aus dem Netz. Die erwarten
# Bibliotheken unter /lib und /usr/lib – die gibt es auf NixOS nicht.
{ pkgs, ... }:
{
  programs.neovim = {
    enable = true;
    defaultEditor = true; # $EDITOR = nvim
    viAlias = true;
    vimAlias = true;

    # Keine Python/Ruby/Node-"Provider" – die Config braucht sie nicht.
    withPython3 = false;
    withRuby = false;
    withNodeJs = false;

    # Home Manager soll KEINE eigene ~/.config/nvim/init.lua schreiben,
    # die kommt aus ./nvim (sonst: "conflicting definitions").
    sideloadInitLua = true;

    # Landen nur im PATH von nvim, nicht global.
    extraPackages = with pkgs; [
      # Bauen: Treesitter-Parser (tree-sitter CLI >= 0.26.1 + C-Compiler),
      # lazy.nvim (git), Downloads von nvim-treesitter (curl, tar)
      tree-sitter
      gcc
      gnumake
      git
      curl
      gnutar
      unzip

      # Suchen & Dateien: fzf-lua, yazi.nvim, Workspace-Picker, Lazygit
      fzf
      ripgrep
      fd
      bat
      yazi
      zoxide
      lazygit

      # Language Server (siehe lua/plugins/lspconfig.lua)
      lua-language-server # Lua (diese Config)
      nixd # Nix (/etc/nixos)
      pyright # Python
      bash-language-server # Shell
      yaml-language-server # YAML (Ansible, Compose, CI)
      vscode-langservers-extracted # JSON (+ HTML/CSS)
      taplo # TOML
      marksman # Markdown (Obsidian)
      dockerfile-language-server # Dockerfile/Containerfile

      # Formatter (conform.nvim) und Linter (nvim-lint)
      stylua
      nixfmt
      ruff
      shfmt
      shellcheck
      yamllint
      markdownlint-cli
      prettier
      hadolint
    ];
  };

  # Die Lua-Config. `recursive = true` verlinkt jede Datei einzeln,
  # ~/.config/nvim selbst bleibt ein normaler Ordner.
  # WICHTIG bei Flakes: neue Dateien erst `git add`, sonst sieht Nix sie nicht.
  xdg.configFile."nvim" = {
    source = ./nvim;
    recursive = true;
  };

  # catppuccin/nix würde sonst ein eigenes Catppuccin-Colorscheme in nvim
  # laden und mit den base46-Themes (neon commit / neon vommit) kämpfen.
  catppuccin.nvim.enable = false;
}
