{ config, lib, pkgs, ... }:
let 
  mountPoint = "/var/cache/nginx-tmpfs";
in 
{
  fileSystems."${mountPoint}" = {
    device = "tmpfs";
    fsType = "tmpfs";
    options = [
      "rw"
      "nodev"
      "nosuid"
      "size=8G"
      "huge=always"
      "mode=700"
      "uid=${toString config.users.users.nginx.uid}"
      "gid=${toString config.users.groups.nginx.gid}"
    ];
  };

  systemd.services.nginx.serviceConfig.ReadWritePaths = [ mountPoint ];

  services.nginx = {
    commonHttpConfig = ''
      proxy_cache_path ${mountPoint}/cache keys_zone=ramcache:100m max_size=7500m; 
      proxy_temp_path ${mountPoint}/temp;
    '';
  };
}
