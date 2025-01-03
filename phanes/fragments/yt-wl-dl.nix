{ config, lib, pkgs, ... }:
let
  externalMount = "/external";
  downloadDir = "${externalMount}/downloads/yt";
  downloadList = "${downloadDir}/wl.txt";
  pythonWithGoogleNonsense = pkgs.python3.withPackages (ps: with ps; [
    google-api-python-client
    google-auth-oauthlib
    google-auth-httplib2
  ]);
in
{
  imports = [
    ./external-ssd.nix
  ];

  systemd = {
    timers.yt-wl-dl = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "*:0/10";
        Persistent = true;
        Unit = "yt-wl-dl.service";
      };
    };
    services.yt-wl-dl = {
      after = [ "network.target" ];
      path = [
        "/home/yt-wl-dl/.local"
        pkgs.ffmpeg
      ];
      upholds = [ "external.mount" ];
      unitConfig = {
        RequiresMountsFor = "/external";
      };
      serviceConfig = {
        Type = "oneshot";
        User = "yt-wl-dl";
        WorkingDirectory = downloadDir;
        UMask = "0000";
        Nice = 19;
        ExecStartPre = lib.escapeShellArgs [
          "${pythonWithGoogleNonsense}/bin/python"
          "${../scripts/yt-wl-fetch.py}"
          "--out-path"
          "${downloadList}"
          "--client-secret-path"
          "/home/yt-wl-dl/wl-fetch/client_secret.json"
          "--client-credentials-path"
          "/home/yt-wl-dl/wl-fetch/creds.bin"
        ];
        ExecStartPost = lib.escapeShellArgs [
          "${pkgs.python3}/bin/python"
          "${../scripts/yt-wl-clean.py}"
          "--download-dir"
          "${downloadDir}"
          "--trash-dir"
          "${externalMount}/downloads/.stversions/yt"
        ];
      };

      script = ''
        ${pkgs.python3.pkgs.pip}/bin/pip install --break-system-packages --user --force-reinstall https://github.com/yt-dlp/yt-dlp/archive/master.tar.gz

        DL_DIR="${downloadDir}"
        DL_LIST="${downloadList}"
        TEMP_DIR=${externalMount}/tmp/yt-wl
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
              -- $line || true
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
