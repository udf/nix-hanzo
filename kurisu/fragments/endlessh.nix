{ ... }:
{
  imports = [
    ../modules/endlessh.nix
  ];

  services.endlessh = {
    enable = true;
    port = 22;
    messageDelay = 3600;
    openFirewall = true;
  };
}