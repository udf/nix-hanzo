{ config, lib, pkgs, options, ... }:
with lib;
let
  cfg = config.custom.fail2ban-persistent;
in
{
  options.custom.fail2ban-persistent = {
    enable = mkEnableOption "Enable fail2ban persistent jail";
    exceptPorts = mkOption {
      description = "Ports to allow";
      type = types.listOf types.port;
      default = [ ];
    };
  };

  config = mkIf cfg.enable {
    services.fail2ban =
      let
        ignorePorts = concatMapStringsSep "," (p: toString p) cfg.exceptPorts;
      in
      {
        jails.persistent = ''
          action = ${ if cfg.exceptPorts == [] then
                        "iptables-allports"
                      else
                        "iptables-allports-except[ports=\"${ignorePorts}\"]"
                    }
                   persist
          enabled = true
          bantime = -1
          filter = empty
        '';
      };

    environment.etc."fail2ban/filter.d/empty.conf".source = pkgs.writeText "empty.conf" ''
      [Definition]
      failregex=
      ignoreregex=
      journalmatch=_SYSTEMD_UNIT=junktoavoidmatching.asdfasdf
    '';

    environment.etc."fail2ban/action.d/persist.conf".source = let
      file = "/var/lib/fail2ban/persist-<name>.txt";
    in
      pkgs.writeText "persist.conf" ''
        [Definition]
        actionstart = touch ${file}
                      while read ip; do fail2ban-client set <name> banip $ip & done < ${file}

        actionban = grep -q <ip> ${file} || echo <ip> >> ${file}
      '';

    environment.etc."fail2ban/action.d/iptables-allports-except.conf".source =
      pkgs.writeText "iptables-allports-except.conf" ''
        [INCLUDES]
        before = iptables.conf

        [Definition]
        actionstart = <iptables> -N f2b-<name>
                      <iptables> -A f2b-<name> -j <returntype>
                      <iptables> -I <chain> -p <protocol> -m multiport ! --dports <ports> -j f2b-<name>

        actionstop = <iptables> -D <chain> -p <protocol> -m multiport ! --dports <ports> -j f2b-<name>
                     <actionflush>
                     <iptables> -X f2b-<name>

        actioncheck = <iptables> -n -L <chain> | grep -q 'f2b-<name>[ \t]'

        actionban = <iptables> -I f2b-<name> 1 -s <ip> -j DROP

        actionunban = <iptables> -D f2b-<name> -s <ip> -j DROP

        [Init]
        blocktype = blackhole
      '';
  };
}
