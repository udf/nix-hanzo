{ config, lib, pkgs, ... }:
let
  externalMount = "/external";
  downloadDir = "${externalMount}/downloads/yt";
  downloadList = "${downloadDir}/wl.txt";
  cookiesCredential = "yt-cookies";
  cookiesSocket = "/var/run/yt-store-cookies.socket";
in
{
  imports = [
    ./external-ssd.nix
  ];

  systemd = {
    # Use a socket for storing the cookies in system credentials so that it is write-only from the user
    # (the only way to read the cookies is for systemd to pass it to the unit)
    sockets.yt-store-cookies = {
      wantedBy = [ "multi-user.target" ];
      listenStreams = [ cookiesSocket ];
      socketConfig = {
        SocketUser = "yt-wl-dl";
        SocketGroup = "root";
        SocketMode = "0600";
        Accept = "yes";
      };
    };
    services."yt-store-cookies@" = {
      description = "Stores incoming data in '${cookiesCredential}' systemd crediential (%i)";
      serviceConfig = {
        ExecStart = "systemd-creds encrypt - /etc/credstore.encrypted/${cookiesCredential}";
        Type = "oneshot";
        StandardInput = "socket";
        StandardOutput = "socket";
      };
    };
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
        ExecStartPost = lib.escapeShellArgs [
          "${pkgs.python3}/bin/python"
          "${../scripts/yt-wl-clean.py}"
          "--download-dir"
          "${downloadDir}"
          "--trash-dir"
          "${externalMount}/downloads/.stversions/yt"
        ];
        LoadCredentialEncrypted = cookiesCredential;
        PrivateTmp = "yes";
      };

      script = ''
        ${pkgs.python3.pkgs.pip}/bin/pip install --break-system-packages --user --force-reinstall https://github.com/yt-dlp/yt-dlp/archive/master.tar.gz

        # copy cookies to (private) temp because we need them to be writable
        COOKIES_FILE=/tmp/cookies.txt
        cat < $CREDENTIALS_DIRECTORY/${cookiesCredential} > $COOKIES_FILE
        new_wl="$(yt-dlp --cookies $COOKIES_FILE --flat-playlist --print id 'https://www.youtube.com/playlist?list=WL')"
        ${pkgs.netcat}/bin/nc -UN ${cookiesSocket} < $COOKIES_FILE
        if [ "$(<wl.txt md5sum)" = "$(md5sum <<< "$new_wl")" ]; then
          echo "no new video IDs"
          exit
        fi
        echo -n "$new_wl" > wl.txt
        echo grabbed $(wc -l < wl.txt) video IDs

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
    isNormalUser = true;
    group = "syncthing";
    openssh.authorizedKeys.keys = config.users.users.sam.openssh.authorizedKeys.keys;
  };
}
