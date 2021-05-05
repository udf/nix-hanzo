{ config, lib, pkgs, ... }:
let
  playlists = {
    "wubwubwub" = "https://www.youtube.com/playlist?list=PLjgVd_07uAd95EmLlzcafgYjwIqHnIDUg";
    "cool stuff" = "https://www.youtube.com/playlist?list=PLjgVd_07uAd9LSrikWrxkUKQs9NmVKx69";
    "weeb shit" = "https://www.youtube.com/playlist?list=PLjgVd_07uAd-JL2Wz1Zr9q7aVKG8pBdZA";
  };
  getDownloadCmd = playlist: url: ''
    youtube-dl -o '${playlist}/%(title)s-%(id)s.%(ext)s' --download-archive '${playlist}.txt' --no-progress --no-post-overwrites -ciwx --add-metadata '${url}'
  '';
in
{
  systemd = {
    timers.yt-music-dl = {
      wantedBy = [ "timers.target" ];
      partOf = [ "yt-music-dl.service" ];
      timerConfig = {
        OnCalendar = "daily";
        Persistent = true;
      };
    };
    services.yt-music-dl = {
      after = ["network.target"];
      before = ["music-gain-tag.service"];
      path = [
        "/home/yt-music-dl/.local"
        pkgs.ffmpeg
      ];
      environment = {
        HOME = "/home/yt-music-dl";
      };
      serviceConfig = {
        Type = "oneshot";
        User = "yt-music-dl";
        WorkingDirectory = "${config.utils.storageDirs.storagePath}/music/favourites";
      };

      script = ''
        ${pkgs.python38.pkgs.pip}/bin/pip install --user -U youtube-dl
        ${builtins.concatStringsSep "\n" (lib.mapAttrsToList getDownloadCmd playlists)}
      '';
    };
  };

  users.extraUsers.yt-music-dl = {
    description = "YT playlist downloader";
    createHome = true;
    isSystemUser = true;
  };

  utils.storageDirs.dirs.music.users = [ "yt-music-dl" ];
}