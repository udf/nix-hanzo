{ config, lib, pkgs, ... }:
let
  pythonPkg = pkgs.python311;
  libraryPkgs = [ pkgs.gcc-unwrapped ];
in
{
  systemd = {
    timers.szuru-ocrbot = {
      wantedBy = [ "timers.target" ];
      partOf = [ "szuru-ocrbot.service" ];
      timerConfig = {
        OnCalendar = "*-*-* *:*:00";
        AccuracySec = "1s";
      };
    };
    services.szuru-ocrbot = {
      description = "Szuru OCRbot";
      after = [ "network.target" "szuru.service" ];
      wantedBy = [ "multi-user.target" ];
      environment = {
        LD_LIBRARY_PATH = lib.makeLibraryPath libraryPkgs;
      };

      serviceConfig = {
        User = "szocrbot";
        Group = "szocrbot";
        Type = "oneshot";
        WorkingDirectory = "/home/szocrbot/szuru-ocrbot/";
      };
      script = ''
        # allow pip to install wheels
        unset SOURCE_DATE_EPOCH
        # ensure that we rebuild the venv when the python package changes
        VENV_DIR=".venv-${builtins.baseNameOf (builtins.toString pythonPkg)}"
        for other_venv in .venv-*; do
          if [ "$other_venv" != "$VENV_DIR" ]; then
            echo Removing unused venv: "$other_venv"
            rm -fr "$other_venv"
          fi
        done
        if [ ! -d "$VENV_DIR" ]; then
          echo "Creating new venv environment in path: '$VENV_DIR'"
          ${pythonPkg}/bin/python -m venv "$VENV_DIR"
          source "$VENV_DIR/bin/activate"
          pip install -r requirements.txt
        else
          source "$VENV_DIR/bin/activate"
        fi
        python ocrbot.py
      '';
    };
  };

  users.extraUsers.szocrbot = {
    description = "Szuru OCRbot user";
    home = "/home/szocrbot";
    isNormalUser = true;
    group = "szocrbot";
  };
  users.groups.szocrbot = { };
}
