{ config, lib, pkgs, ... }:
let 
  cachePath = "/var/cache/nginx/proxy";
in 
{
  systemd.services.nginx.serviceConfig.ReadWritePaths = [ cachePath ];

  services.nginx = {
    commonHttpConfig = ''
      proxy_cache_path ${cachePath} levels=1:2 keys_zone=diskcache:100m max_size=10000m inactive=36500d; 
    '';
  };
}
