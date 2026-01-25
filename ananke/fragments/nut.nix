{
  config,
  lib,
  pkgs,
  ...
}:
let
  private = (import ../../_common/constants/private.nix).ananke;
  states = [
    "ONLINE"
    "ONBATT"
    "LOWBATT"
    "FSD"
    "COMMOK"
    "COMMBAD"
    "SHUTDOWN"
    "REPLBATT"
    "NOCOMM"
    "NOPARENT"
  ];
in
{
  systemd.services.clear-upsd-pids = {
    wantedBy = [
      "upsd.service"
      "upsmon.service"
    ];
    before = [
      "upsd.service"
      "upsmon.service"
    ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = "yes";
    };

    script = ''
      rm -f -v /var/lib/nut/*.pid
    '';
  };

  environment.etc."nut/sam.passwd".source = pkgs.writeText "sam.passwd" "${private.upsd.pw}";

  users.groups.nutmon = {
    gid = 69;
  };

  power.ups = {
    enable = true;
    mode = "netserver";

    ups.mecer-vesta-3k = {
      driver = "nutdrv_qx";
      port = "auto";
      directives = [
        "default.battery.voltage.low = 46.0"
        "default.battery.voltage.high = 56.0"
      ];
      # vendorid = "0665";
      # productid = "5161";
      # product = "USB to Serial";
      # vendor = "INNO TECH";
    };

    upsd.listen = [
      {
        address = "127.0.0.1";
        port = 3493;
      }
      {
        address = "192.168.0.3";
        port = 3493;
      }
    ];

    users.sam = {
      passwordFile = "/etc/nut/sam.passwd";
      instcmds = [ "ALL" ];
      actions = [ "SET" ];
    };

    upsmon = {
      monitor."mecer-vesta-3k@localhost" = {
        user = "sam";
        passwordFile = "/etc/nut/sam.passwd";
      };
      settings = {
        MINSUPPLIES = 1;
        NOTIFYCMD = "/etc/nut/notify.sh";
        POLLFREQ = 1;
        POLLFREQALERT = 1;
        NOTIFYMSG = map (status: [
          status
          "\"%s\""
        ]) states;
        NOTIFYFLAG = map (status: [
          status
          "EXEC"
        ]) states;
      };
    };
  };

  environment.etc."nut/notify.sh".source = pkgs.writeScript "notify.sh" ''
    #!${pkgs.bash}/bin/bash
    echo $NOTIFYTYPE on $1 | ${pkgs.systemd}/bin/systemd-cat -p warning -t upsmon-notify
    if [ "$NOTIFYTYPE" == "ONBATT" ]; then
      sleep 5
      ${pkgs.nut}/bin/upscmd -u sam -p '${private.upsd.pw}' $1 beeper.toggle
    fi
  '';
}
