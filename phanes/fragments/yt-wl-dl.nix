{ config, lib, pkgs, ... }:
let
  externalMount = "/external";
  downloadDir = "${externalMount}/downloads/yt";
  downloadList = "${downloadDir}/wl.txt";
  cleanupScript = pkgs.writeScript "yt-wl-clean.py" ''
    #!${pkgs.python3}/bin/python
    import re
    import os
    import shutil
    from pathlib import Path

    download_dir = Path('${downloadDir}')
    os.chdir(download_dir)
    trash_dir = Path('${externalMount}/downloads/.stversions/yt')
    vid_dirs = [
      download_dir / 'wl',
      download_dir / 'wl_720'
    ]

    expected_ids = set()
    with open('wl.txt') as f:
      for line in f:
        expected_ids.add(line.strip())

    for dir_name in vid_dirs:
      for path in Path(dir_name).glob('*.*'):
        vidID = re.search(r' \[([\dA-Za-z_-]{11})\]\.', path.name)
        if not vidID:
          continue
        vidID = vidID[1]
        if vidID not in expected_ids:
          print(f'Trashing {str(path)!r}')
          new_path = trash_dir / path.relative_to(download_dir)
          new_path.parent.mkdir(parents=True, exist_ok=True)
          shutil.move(path, new_path)
  '';
in
{
  imports = [
    ./external-ssd.nix
  ];

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
      requires = [ "external.mount" ];
      path = [
        "/home/yt-wl-dl/.local"
        pkgs.ffmpeg
      ];
      serviceConfig = {
        Type = "oneshot";
        User = "yt-wl-dl";
        WorkingDirectory = "/home/yt-wl-dl";
        UMask = "0000";
        Nice = 19;
        ExecStartPost = cleanupScript;
      };

      script = ''
        ${pkgs.python311.pkgs.pip}/bin/pip install --break-system-packages --user --force-reinstall https://github.com/yt-dlp/yt-dlp/archive/master.tar.gz

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
              $line || true
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