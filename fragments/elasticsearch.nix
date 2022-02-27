{ config, lib, pkgs, ... }:
let
  unstable = import <nixpkgs-unstable> { config.allowUnfree = true; };
in
{
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "elasticsearch"
  ];

  services.elasticsearch = {
    enable = true;
    package = pkgs.elasticsearch7;
    single_node = true;
    extraConf = ''
      xpack.security.enabled: true
      xpack.security.authc:
        anonymous:
          roles: anonymous
          authz_exception: true 
    '';
    extraJavaOptions = ["-Xmx2048m"];
  };

  # Add role so the postStart script can check if es is up without creds
  systemd.services.elasticsearch.preStart =
    let
      rolesYml = pkgs.writeText "roles.yml" ''
        anonymous:
          cluster: [ 'monitor' ]
      '';
    in
    ''
      cp ${rolesYml} ${config.services.elasticsearch.dataDir}/config/roles.yml
    '';
}
