{ config, lib, pkgs, options, ... }:
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
      daemonSettings = {
        DEFAULT = {
          dbpurgeage = "99y";
        };
      };
      jails.sshd.settings = {
        action = "endlessh";
        enabled = true;
        mode = "aggressive";
      };
    };

    environment.etc."fail2ban/action.d/endlessh.conf".source = let
      dport = toString cfg.sshdPort;
      to-port = toString cfg.endlesshPort;
    in pkgs.writeText "endlessh.conf" ''
      [INCLUDES]
      before = iptables.conf

      [Definition]
      actionstart = <iptables> -t nat -N f2b-<name>
                    <iptables> -t nat -A f2b-<name> -j <returntype>
                    <iptables> -t nat -I PREROUTING -p tcp --dport ${dport} -j f2b-<name>

      actionstop = <iptables> -t nat -D PREROUTING -p tcp --dport ${dport} -j f2b-<name>
                   <actionflush>
                   <iptables> -t nat -X f2b-<name>

      actioncheck = <iptables> -t nat -n -L PREROUTING | grep -q 'f2b-<name>[ \t]'

      actionban = <iptables> -t nat -I f2b-<name> 1 -p tcp -s <ip> -j REDIRECT --dport ${dport} --to-port ${to-port}

      actionunban = <iptables> -t nat -D f2b-<name> -p tcp -s <ip> -j REDIRECT --dport ${dport} --to-port ${to-port}

      actionflush = <iptables> -t nat -F f2b-<name>

      [Init]
      blocktype = blackhole
    '';
  };
}
