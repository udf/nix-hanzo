{ ... }:
{
  services.endlessh = {
    enable = true;
    port = 22;
    extraOptions = ["-d 3600000"];
    openFirewall = true;
  };
}