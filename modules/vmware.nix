{ ... }:

{
  # open-vm-tools: Auflösung, Zeit-Sync, Shared Folders
  virtualisation.vmware.guest.enable = true;

  # Mesa (OpenGL/Vulkan) – nutzt den vmwgfx-Treiber der VM
  # (niri-flake schaltet das später auch ein; explizit = Doku)
  hardware.graphics.enable = true;
}
