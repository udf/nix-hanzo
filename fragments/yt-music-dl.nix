{ config, lib, pkgs, ... }:
let
  playlists = {
    "wubwubwub" = "https://www.youtube.com/playlist?list=PLjgVd_07uAd95EmLlzcafgYjwIqHnIDUg";
    "cool stuff" = "https://www.youtube.com/playlist?list=PLjgVd_07uAd9LSrikWrxkUKQs9NmVKx69";
    "weeb shit" = "https://www.youtube.com/playlist?list=PLjgVd_07uAd-JL2Wz1Zr9q7aVKG8pBdZA";
  };
  getDownloadCmd = playlist: url: ''
    yt-dlp -o '${playlist}/%(title)s-%(id)s.%(ext)s' --download-archive '${playlist}.txt' \
    --no-progress --no-post-overwrites -ciwx -f bestaudio \
    --add-metadata --replace-in-metadata 'album' '.' "" --parse-metadata 'title:%(track)s' --parse-metadata 'uploader:%(artist)s' '${url}' || true
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
      after = [ "network.target" ];
      before = [ "music-gain-tag.service" ];
      path = [
        "/home/yt-music-dl/.local"
        pkgs.ffmpeg
      ];
      serviceConfig = {
        Type = "oneshot";
        User = "yt-music-dl";
        WorkingDirectory = "${config.utils.storageDirs.dirs.music.path}/favourites";
      };

      script = ''
        ${pkgs.python38.pkgs.pip}/bin/pip install --user -U yt-dlp
        ${builtins.concatStringsSep "\n" (lib.mapAttrsToList getDownloadCmd playlists)}
      '';
    };
  };

  users.extraUsers.yt-music-dl = {
    description = "YT playlist downloader";
    home = "/home/yt-music-dl";
    createHome = true;
    isSystemUser = true;
    group = "yt-music-dl";
  };
  users.groups.yt-music-dl = { };

  utils.storageDirs.dirs.music.users = [ "yt-music-dl" ];
}
