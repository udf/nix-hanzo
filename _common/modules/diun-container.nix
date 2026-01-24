{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.services.diun-container;
in
{
  options.services.diun-container = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Whether or not to enable the diun container";
    };
    socketPath = mkOption {
      type = types.str;
      default = "/var/run/docker.sock";
      description = "Path to the docker/podman socket";
    };
    configPath = mkOption {
      type = types.str;
      default = "/etc/diun/diun.yml";
      description = "Path to the diun config file";
    };
  };

  config = mkIf cfg.enable {
    systemd.services."${config.virtualisation.oci-containers.backend}-diun".serviceConfig = {
      StateDirectory = "diun";
      ConfigurationDirectory = "diun";
      ConfigurationDirectoryMode = "0700";
    };

    virtualisation.oci-containers.containers.diun = {
      # MARK: pinned version
      image = "crazymax/diun:4.31";
      volumes = [
        "/var/lib/diun:/data"
        "${cfg.socketPath}:/var/run/docker.sock"
        "${../constants/diun.yml}:/diun.yml:ro"
      ];
      environment = {
        TZ = "Africa/Johannesburg";
        LOG_LEVEL = "debug";
      };
      environmentFiles = [ "/etc/diun/diun.env" ];
      extraOptions = [
        "--hostname=${config.networking.hostName}"
      ];
    };
  };
}
