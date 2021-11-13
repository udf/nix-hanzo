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
    package = unstable.elasticsearch7;
    extraConf = ''
      discovery.type: single-node
      xpack.security.enabled: true
      reindex.remote.whitelist: "localhost:9999"
    '';
  };
}