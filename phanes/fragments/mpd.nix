{ config, lib, pkgs, ... }:
with lib;
let
  mpdPassword = (import ../../_common/constants/private.nix).phanes.mpdPassword;
  port = 6600;
in
{
  systemd.services.mpd = {
    serviceConfig.TimeoutStartSec = "infinity";
    unitConfig.RequiresMountsFor = "/backup/music";
  };

  services.mpd = {
    enable = true;
    musicDirectory = "/backup/music/music";
    extraConfig = ''
      # Files and directories 
      playlist_directory "/backup/music/music/playlists"
      max_playlist_length "262144"

      # General music daemon option
      restore_paused "yes"

      auto_update	"yes"

      port "${toString port}"
      max_output_buffer_size "262144"
      connection_timeout "3600"

      # Symbolic link behavior
      follow_inside_symlinks "yes"

      # Permissions
      password "${mpdPassword}@read,add,control,admin"
      default_permissions ""

      audio_output {
        type  "null"
        name  "Null output"
      }

      # Normalization automatic volume adjustments
      replaygain "track"
      filesystem_charset "UTF-8"
    '';
    network.listenAddress = "any";
  };

  networking.firewall = {
    allowedTCPPorts = [ port ];
  };
}
