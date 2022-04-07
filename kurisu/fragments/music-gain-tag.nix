{ config, lib, pkgs, ... }:
let
  unstable = import <nixpkgs-unstable> { };
  makeScript = import ../../helpers/make-script.nix { inherit lib pkgs; };
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
        (pkgs.python3.withPackages (ps: [
          (ps.toPythonModule pkgs.r128gain)
          ps.mutagen
        ]))
      ];
      serviceConfig = {
        Type = "oneshot";
        User = "music-gain-tagger";
        WorkingDirectory = "${config.utils.storageDirs.dirs.music.path}";
        Nice = 10;
        IOSchedulingClass = "idle";
        IOSchedulingPriority = 7;
        ExecStart = makeScript ../scripts/rg.py;
      };
    };
  };

  users.extraUsers.music-gain-tagger = {
    description = "Tags music with replaygain";
    isSystemUser = true;
    group = "music-gain-tagger";
  };
  users.groups.music-gain-tagger = { };

  utils.storageDirs.dirs.music.users = [ "music-gain-tagger" ];
}
