{ pkgs, ... }:

{
  # --- Boot ---
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # --- Nix selbst ---
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  # --- Zeit & Sprache ---
  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "de_DE.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  # --- Tastatur ---
  services.xserver.xkb = { layout = "de"; variant = ""; };
  console.keyMap = "de";

  # --- Drucken ---
  services.printing.enable = true;

  # --- User ---
  users.users.ryuk = {
    isNormalUser = true;
    description = "ryuk";
    extraGroups = [ "networkmanager" "wheel" ];
  };

  # --- Programme ---
  programs.firefox.enable = true;
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  environment.systemPackages = with pkgs; [
    (vim-full.customize {
      name = "vim";
      vimrcConfig.customRC = ''
        set mouse=
        syntax on
        set tabstop=2
        set shiftwidth=2
        set softtabstop=2
        set expandtab
        colorscheme catppuccin
      '';
    })
    wget
    git
  ];

  # --- SSH ---
  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "yes";
  };
}
