{ config, lib, pkgs, ... }:
let
  pythonPkg = pkgs.python3.withPackages (ps: with ps; [ gpiozero rpi-gpio ]);
  gpioScript = pkgs.writeScript "gpio-pwr-btn.py" ''
    #!${pythonPkg}/bin/python
    import time
    from gpiozero import DigitalOutputDevice

    laptop_pwr_btn = DigitalOutputDevice('BOARD11')

    laptop_pwr_btn.on()
    time.sleep(0.5)
    laptop_pwr_btn.off()
  '';
  checkIP = "192.168.0.5";
in
{
  systemd.services.press-phanes-pwr = {
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = "yes";
    };
    path = [ pkgs.iputils ];

    script = ''
      if ping -W 1 -c 1 ${checkIP} >/dev/null ; then
        echo "<4>${checkIP} responded to ping: not pressing power button."
        exit
      fi
      echo "<4>Pressing power button..."
      GPIOZERO_PIN_FACTORY=native ${gpioScript}
      sleep 30
      if ! ping -W 1 -c 1 ${checkIP} >/dev/null ; then
        echo "<3>${checkIP} not responding to ping after power on! Manual intervention required."
        exit 1
      fi
    '';
  };
}
