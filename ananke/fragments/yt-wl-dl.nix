{ config, lib, pkgs, ... }:
let
  homeHostname = (import ../../_common/constants/private.nix).homeHostname;
  downloadDir = "/sync/downloads/yt";
  downloadList = "${downloadDir}/wl.txt";
in
{
  systemd = {
    timers.yt-wl-dl = {
      wantedBy = [ "timers.target" ];
      partOf = [ "yt-wl-dl.service" ];
      timerConfig = {
        OnCalendar = "*:10/30";
        Persistent = true;
      };
    };
    paths.yt-wl-dl = {
      wantedBy = [ "default.target" ];
      pathConfig = {
        PathModified = downloadList;
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
        ${pkgs.python311.pkgs.pip}/bin/pip install --break-system-packages --user --force-reinstall https://github.com/yt-dlp/yt-dlp/archive/master.tar.gz

        DL_DIR="${downloadDir}"
        DL_LIST="${downloadList}"
        TEMP_DIR=/sync/tmp/yt-wl
        mkdir -p "$TEMP_DIR"

        do_download() {
          local MAXRES="$2"
          local DL_ARCHIVE="$DL_DIR/''${1}_dl.txt"

          mkdir -p "$DL_DIR/$1"
          cd "$DL_DIR/$1"
          while read line; do
            if [[ "$(df -k --output=avail . | tail -n1)" -lt ${toString (7 * 1024 * 1024)} ]]; then
              >&2 echo "<3>Not enough free disk space!"
              exit 1
            fi

            yt-dlp --no-progress --add-metadata \
              --extractor-args "youtube:player_client=default,ios" \
              -P "temp:$TEMP_DIR" -f "bv*[height<=$MAXRES]+ba/b[height<=$MAXRES]" \
              --download-archive "$DL_ARCHIVE" \
              --sponsorblock-mark default --sponsorblock-api https://sponsorblock.hankmccord.dev \
              --live-from-start \
              -a "$DL_LIST" || true
          done < <(yt-dlp --download-archive "$DL_ARCHIVE" --flat-playlist -a "$DL_LIST" --print id)
        }

        do_download wl 1440
        do_download wl_720 720
        rm -fr "$TEMP_DIR"
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