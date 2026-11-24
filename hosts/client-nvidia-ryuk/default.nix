{ pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../common.nix
    ../../modules/nvidia.nix
    ../../modules/gaming.nix
  ];

  networking.hostName = "client-nvidia-ryuk"; # wird in Phase 1b zu "srv-root"

  # Gaming
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  hardware.nvidia.prime = {
    sync.enable = true;

    #nix shell nixpkgs#pciutils -c lspci | grep ' VGA '
    # dedicated
    nvidiaBusId = "PCI:7:0:0";
  };

  # hardware.opengl has beed changed to hardware.graphics
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.modesetting.enable = true;

  # Version der Erstinstallation – NIE ändern
  system.stateVersion = "26.05";
}
