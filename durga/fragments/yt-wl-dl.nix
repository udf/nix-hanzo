{ config, lib, pkgs, ... }:
let
  tempDir = "/home/yt-wl-dl/tmp";
  getDownloadCmd = { maxRes, dir }: ''
    DEST_DIR=/sync/downloads/yt
    cd $DEST_DIR/${dir}
    yt-dlp --no-progress --add-metadata \
      --extractor-args "youtube:player_client=default,ios" \
      -P "temp:${tempDir}" -f 'bv*[height<=${maxRes}]+ba/b[height<=${maxRes}]' \
      --download-archive $DEST_DIR/${dir}_dl.txt \
      --sponsorblock-mark default --sponsorblock-api https://sponsorblock.hankmccord.dev \
      --live-from-start \
      -a $DEST_DIR/wl.txt
  '';
in
{
  systemd = {
    timers.yt-wl-dl = {
      wantedBy = [ "timers.target" ];
      partOf = [ "yt-wl-dl.service" ];
      timerConfig = {
        OnCalendar = "00/1:10";
        Persistent = true;
      };
    };
    services.yt-wl-dl = {
      after = [ "network.target" ];
      path = [
        "/home/yt-wl-dl/.local"
        pkgs.ffmpeg
      ];
      serviceConfig = {
        Type = "oneshot";
        User = "yt-wl-dl";
        WorkingDirectory = "/home/yt-wl-dl";
        UMask = "0000";
      };

      script = ''
        ${pkgs.python311.pkgs.pip}/bin/pip install --break-system-packages --user -U yt-dlp

        rm -fr ${tempDir}
        mkdir -p ${tempDir}
        ${getDownloadCmd { dir = "wl"; maxRes = "1440"; }}
        ${getDownloadCmd { dir = "wl_720"; maxRes = "720"; }}
      '';
    };
  };

  users.extraUsers.yt-wl-dl = {
    description = "YT watch later downloader";
    home = "/home/yt-wl-dl";
    createHome = true;
    isSystemUser = true;
    group = "syncthing";
  };
}