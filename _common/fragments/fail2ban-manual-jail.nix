{ config, lib, pkgs, ... }:
with lib;
{
  services.fail2ban = {
    jails.manual = ''
      action = iptables-allports
      bantime = ${toString (90 * 24 * 60 * 60)}
      enabled = true
      filter = empty
    '';
  };

  environment.etc."fail2ban/filter.d/empty.conf".source = pkgs.writeText "empty.conf" ''
  [Definition]
  failregex=
  ignoreregex=
  '';
}
