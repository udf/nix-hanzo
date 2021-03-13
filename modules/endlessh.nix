{config, lib, pkgs, ...}:
with lib;
let
  cfg = config.services.endlessh;
in
{
  options.services.endlessh = {
    enable = mkEnableOption "Enable Endlessh service";
    port = mkOption {
      type = types.port;
      default = 22;
      description = "Listening port";
    };
    messageDelay = mkOption {
      type = types.ints.positive;
      default = 10;
      description = "Delay between messages (in seconds)";
    };

    openFirewall = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Whether to automatically open the specified port in the firewall.
      '';
    };
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = if cfg.openFirewall then [ cfg.port ] else [];

    systemd.services.endlessh = {
     description = "SSH tarpit";
     after = ["network.target"];
     wantedBy = ["multi-user.target"];

     serviceConfig = {
       Type = "simple";
       ExecStart = "${pkgs.endlessh}/bin/endlessh -v -p ${toString cfg.port} -d ${toString (cfg.messageDelay * 1000)}";
       Restart = "always";
       RestartSec = 3;
       DynamicUser = true;
       AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
     };
    };
  };
}