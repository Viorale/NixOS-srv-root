{ ... }:
{
  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = false;
    openFirewall = true;
    settings = {
      sunshine_name = "client-hyperv-ryuk";
      capture = "wlr";
      encoder = "software";
      sw_preset = "superfast";
    };
  };
}
