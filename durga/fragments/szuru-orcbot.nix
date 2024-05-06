{ config, lib, pkgs, ... }:
let
  pythonPkg = pkgs.python311;
  libraryPkgs = [ pkgs.gcc-unwrapped ];
  venvDir = ".venv";
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
      requires = [ "szuru.service" ];
      wantedBy = [ "multi-user.target" ];
      path = [ pythonPkg ];
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
        if [ ! -d "${venvDir}" ]; then
          echo "Creating new venv environment in path: '${venvDir}'"
          ${pythonPkg}/bin/python -m venv "${venvDir}"
          source "${venvDir}/bin/activate"
          pip install -r requirements.txt
        else
          source "${venvDir}/bin/activate"
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
