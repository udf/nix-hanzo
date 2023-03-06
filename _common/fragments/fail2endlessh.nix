{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.custom.fail2endlessh;
in
{
  options.custom.fail2endlessh = {
    enable = mkEnableOption "Enable fail2ban with endlessh jail";
    sshdPort = mkOption {
      description = "sshd port";
      type = types.port;
      default = 69;
    };
    endlesshPort = mkOption {
      description = "endlessh port";
      type = types.port;
      default = 22;
    };
  };

  config = mkIf cfg.enable {
    services.openssh = {
      ports = [ cfg.sshdPort ];
    };

    services.endlessh = {
      enable = true;
      port = cfg.endlesshPort;
      extraOptions = ["-d 360000"];
      openFirewall = true;
    };

    services.fail2ban = {
      enable = true;
      bantime-increment.enable = true;
      jails.sshd = ''
        action = endlessh
        enabled = true
        mode = aggressive
        port = ${concatMapStringsSep "," (p: toString p) config.services.openssh.ports}
      '';
    };

    environment.etc."fail2ban/action.d/endlessh.conf".source = pkgs.writeText "endless.conf" ''
      [INCLUDES]

      before = iptables-common.conf

      [Definition]
      actionban = <iptables> -t nat -A PREROUTING -p tcp -s <ip> --dport ${toString cfg.sshdPort} -j REDIRECT --to-port ${toString cfg.endlesshPort}
      actionunban = <iptables> -t nat -D PREROUTING -p tcp -s <ip> --dport ${toString cfg.sshdPort} -j REDIRECT --to-port ${toString cfg.endlesshPort}
      actioncheck =
      actionstart =
      actionstop =

      [Init]
      blocktype = blackhole
    '';
  };
}
