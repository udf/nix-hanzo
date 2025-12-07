{ config, lib, pkgs, ... }:
let
  pythonPkg = pkgs.python311;
  venvSetupCode = import ../../_common/helpers/gen-venv-setup.nix { inherit pythonPkg; inherit pkgs; };
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
        ${venvSetupCode}
        if [ "$IS_NEW_VENV" = true ]; then
          pip install -r requirements.txt
        fi
        python ocrbot.py
      '';
    };
  };

  users.extraUsers.szocrbot = {
    description = "Szuru OCRbot user";
    home = "/home/szocrbot";
    isSystemUser = true;
    group = "szocrbot";
  };
  users.groups.szocrbot = { };
}
