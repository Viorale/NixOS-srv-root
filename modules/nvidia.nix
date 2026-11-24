{ config, lib, pkgs, ... }:

{
  boot.kernelPackages = lib.mkForce pkgs.linuxPackages;
  
  # Grafik-Grundlage (OpenGL/Vulkan); 32 Bit braucht Steam/Proton (Spiele-Kompatibilitätsschicht)
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Lädt den NVIDIA-Treiber – heißt "xserver", gilt aber auch für Wayland
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;      # Pflicht für Wayland (setzt nvidia-drm.modeset=1)
    open = true;                    # offene Kernel-Module – RTX 40 (Ada) unterstützt das
    nvidiaSettings = true;          # GUI-Tool nvidia-settings
    powerManagement.enable = false; # nur einschalten, wenn Standby Probleme macht
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # Niri-VRAM-Fix (Treiber-Profil nur für den Prozess "niri")
  environment.etc."nvidia/nvidia-application-profiles-rc.d/50-limit-free-buffer-pool-in-wayland-compositors.json".text =
    builtins.toJSON {
      rules = [{
        pattern = { feature = "procname"; matches = "niri"; };
        profile = "Limit Free Buffer Pool On Wayland Compositors";
      }];
      profiles = [{
        name = "Limit Free Buffer Pool On Wayland Compositors";
        settings = [{ key = "GLVidHeapReuseRatio"; value = 0; }];
      }];
    };
}
