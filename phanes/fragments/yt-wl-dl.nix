{ config, lib, pkgs, ... }:
let
  externalMount = "/external";
  downloadDir = "${externalMount}/downloads/yt";
  fetchStateDirectoryName = "yt-wl-fetch";
  downloadList = "/var/lib/${fetchStateDirectoryName}/wl.txt";
  cookiesCredential = "yt-cookies";
  cookiesSocket = "/var/run/yt-wl/yt-store-cookies.socket";
  pythonPkg = pkgs.python3;
  venvSetupCode = import ../../_common/helpers/gen-venv-setup.nix { inherit pythonPkg; };
in
{
  imports = [
    ./external-dl-hdd.nix
  ];

  systemd = {
    # Use a socket for storing the cookies in system credentials so that it is write-only for a normal user
    # (the only way to read the cookies is for systemd to pass it to the unit)
    sockets.yt-store-cookies = {
      wantedBy = [ "multi-user.target" ];
      listenStreams = [ cookiesSocket ];
      socketConfig = {
        SocketUser = "sam";
        SocketGroup = "root";
        # warning: world writable! (but the parent directory is 0700)
        SocketMode = "0606";
        Accept = "yes";
      };
    };
    services."yt-store-cookies@" = {
      description = "Store incoming data in '${cookiesCredential}' systemd crediential (%i)";
      serviceConfig = {
        ExecStart = "systemd-creds encrypt - /etc/credstore.encrypted/${cookiesCredential}";
        Type = "oneshot";
        StandardInput = "socket";
        StandardOutput = "socket";
      };
    };

    # fetcher runs as a dynamic user (to avoid leaking cookies), every 10 minutes
    timers.yt-wl-fetch = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "*:0/10";
        Persistent = true;
        Unit = "yt-wl-fetch.service";
      };
    };
    services.yt-wl-fetch = {
      after = [ "network.target" "yt-wl-dl.service" ];
      upholds = [ "external.mount" ];
      unitConfig = {
        RequiresMountsFor = "/external";
      };
      serviceConfig = {
        Type = "oneshot";
        DynamicUser = "yes";
        UMask = "0000";
        Nice = 19;
        BindPaths = "${cookiesSocket}:/tmp/yt-store-cookies.socket";
        LoadCredentialEncrypted = cookiesCredential;
        PrivateTmp = "yes";
        StateDirectory = fetchStateDirectoryName;
        StateDirectoryMode = "744";
      };

      script = ''
        cd "$STATE_DIRECTORY"
        ${venvSetupCode}
        pip --cache-dir="$STATE_DIRECTORY/.cache" install --force-reinstall https://github.com/yt-dlp/yt-dlp/archive/master.tar.gz

        DL_LIST="${downloadList}"

        # copy cookies to (private) temp because we need them to be writable
        COOKIES_FILE=/tmp/cookies.txt
        cat < $CREDENTIALS_DIRECTORY/${cookiesCredential} > $COOKIES_FILE
        new_wl="$(yt-dlp --cookies $COOKIES_FILE --flat-playlist --print id 'https://www.youtube.com/playlist?list=WL')"
        ${pkgs.netcat}/bin/nc -UN /tmp/yt-store-cookies.socket < $COOKIES_FILE
        if [ "$(<"$DL_LIST" md5sum)" = "$(echo -n "$new_wl" | md5sum)" ]; then
          echo "no new video IDs"
          exit
        fi
        echo -n "$new_wl" > "$DL_LIST"
        echo grabbed $(grep ^ "$DL_LIST" | wc -l) video IDs
      '';
    };

    # downloader runs as yt-wl-dl, if the list (from the fetcher's private state) was changed
    paths.yt-wl-dl = {
      wantedBy = [ "default.target" ];
      pathConfig = {
        PathModified = downloadList;
      };
    };
    services.yt-wl-dl = {
      after = [ "network.target" ];
      path = [
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
        BindReadOnlyPaths = "${downloadList}:/tmp/wl.txt";
        ExecStartPost = lib.escapeShellArgs [
          "${pkgs.python3}/bin/python"
          "${../scripts/yt-wl-clean.py}"
          "--download-dir"
          "${downloadDir}"
          "--trash-dir"
          "${externalMount}/downloads/.stversions/yt"
        ];
        PrivateTmp = "yes";
        StateDirectory = "yt-wl-dl";
        StateDirectoryMode = "744";
      };

      script = ''
        DL_DIR="${downloadDir}"
        DL_LIST="/tmp/wl.txt"
        TEMP_DIR=${externalMount}/tmp/yt-wl

        cd $STATE_DIRECTORY
        ${venvSetupCode}
        pip install --force-reinstall https://github.com/yt-dlp/yt-dlp/archive/master.tar.gz

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
              --write-subs --embed-subs --compat-options no-keep-subs --sub-lang "en.*" \
              --live-from-start \
              -- $line || true
          done < <(yt-dlp --download-archive "$DL_ARCHIVE" --flat-playlist -a "$DL_LIST" --print id)
        }

        do_download wl 1440
        do_download wl_720 720
        cat < "$DL_LIST" > "$DL_DIR/wl.txt"
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
    openssh.authorizedKeys.keys = config.users.users.sam.openssh.authorizedKeys.keys;
  };
}
