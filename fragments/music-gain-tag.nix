{ config, lib, pkgs, ... }:
let
  unstable = import <nixpkgs-unstable> {};
in
{
  systemd = {
    timers.music-gain-tag = {
      wantedBy = [ "timers.target" ];
      partOf = [ "music-gain-tag.service" ];
      timerConfig = {
        OnCalendar = "daily";
        Persistent = true;
      };
    };
    services.music-gain-tag = {
      path = [
        unstable.r128gain
      ];
      serviceConfig = {
        Type = "oneshot";
        User = "music-gain-tagger";
        WorkingDirectory = "${config.utils.storageDirs.dirs.music.path}";
        Nice = 10;
      };

      script = "r128gain --opus-output-gain -r -s .";
    };
  };
  
  users.extraUsers.music-gain-tagger = {
    description = "Tags music with replaygain";
    isSystemUser = true;
    group = "music-gain-tagger";
  };
  users.groups.music-gain-tagger = {};

  utils.storageDirs.dirs.music.users = [ "music-gain-tagger" ];
}