{ pkgs, ... }:

let
  private = (import ./constants/private.nix).ananke;
in
{
  imports = [
    # core
    ./fragments/system-packages.nix
    ./fragments/users.nix
    ./fragments/nix-options.nix
    ./fragments/rpi-swapfile.nix

    # services
    ./modules/watcher-bot.nix

    # programs
    ./fragments/nvim.nix
    ./fragments/zsh.nix
    ./fragments/msmtp-gmail.nix
  ];

  # Assuming this is installed on top of the disk image.
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
    };
  };
  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;
  # Mainline doesn't work yet
  boot.kernelPackages = pkgs.linuxPackages_rpi4;

  # ttyAMA0 is the serial console broken out to the GPIO
  boot.kernelParams = [
    "8250.nr_uarts=1" # may be required only when using u-boot
    "console=ttyAMA0,115200"
    "console=tty1"
  ];

  powerManagement.cpuFreqGovernor = "ondemand";

  # Required for the Wireless firmware
  hardware.enableRedistributableFirmware = true;
  nixpkgs.config.allowUnfree = true;

  time.timeZone = "Africa/Harare";

  networking = {
    hostName = "ananke";
    defaultGateway = "192.168.0.1";
    nameservers = [ "1.1.1.1" "8.8.8.8" ];
    interfaces.eth0.ipv4.addresses = [{
      address = "192.168.0.3";
      prefixLength = 24;
    }];
    interfaces.eth0.ipv6.addresses = [{
      address = private.publicIPv6;
      prefixLength = 64;
    }];
    defaultGateway6 = {
      address = "fe80::76ac:b9ff:fe54:4f1";
      interface = "eth0";
    };
    firewall.allowedTCPPorts = [ 8443 3493 ];
  };

  boot.kernel.sysctl = {
    "net.ipv6.conf.eth0.accept_ra" = 0;
  };

  services.openssh.enable = true;

  environment.systemPackages = with pkgs; [
    sshfs
    wol
  ];

  services.unifi = {
    enable = true;
    openFirewall = true;
    unifiPackage = pkgs.unifiStable;
  };
  programs.ssh = {
    pubkeyAcceptedKeyTypes = [ "+ssh-rsa" ];
    hostKeyAlgorithms = [ "+ssh-rsa" ];
  };

  systemd = {
    timers.unifi-rebooter = {
      wantedBy = [ "timers.target" ];
      partOf = [ "unifi-rebooter.service" ];
      timerConfig = {
        OnCalendar = "Mon *-*-* 03:00:00";
        Persistent = true;
      };
    };
    services.unifi-rebooter = {
      after = ["network.target"];
      serviceConfig = {
        Type = "oneshot";
        User = "sam";
        WorkingDirectory = "/home/sam";
      };

      script = ''
        ${pkgs.openssh}/bin/ssh admin@192.168.0.8 reboot
      '';
    };
  };

  power.ups = {
    enable = true;
    mode = "netserver";
    ups.mecer-vesta-3k = {
      driver = "blazer_usb";
      port = "auto";
    };
  };
  systemd.services.upsd.preStart = ''
    PIDFILE=/var/state/ups/upsd.pid
    if [ -f $PIDFILE ]; then
      [[ "$(basename $(readlink /proc/$(cat $PIDFILE)/exe))" == "upsd" ]] || rm $PIDFILE && echo "Deleted invalid PID file"
    fi
  '';
  environment.etc."nut/upsd.conf".source = pkgs.writeText "upsd.conf" ''
    LISTEN 127.0.0.1 3493
    LISTEN 192.168.0.3 3493
  '';
  environment.etc."nut/upsd.users".source = pkgs.writeText "upsd.users" ''
    [${private.upsd.username}]
    password = "${private.upsd.pw}"
    actions = SET
    instcmds = ALL
  '';
  environment.etc."nut/upsmon.conf".source = pkgs.writeText "upsmon.conf" ''
    MONITOR mecer-vesta-3k@localhost 1 ${private.upsd.username} ${private.upsd.pw} master

    MINSUPPLIES 1
    NOTIFYCMD /etc/nut/notify.sh
    POLLFREQ 1
    POLLFREQALERT 1

    NOTIFYMSG ONLINE "%s"
    NOTIFYMSG ONBATT "%s"
    NOTIFYMSG LOWBATT "%s"
    NOTIFYMSG FSD "%s"
    NOTIFYMSG COMMOK "%s"
    NOTIFYMSG COMMBAD "%s"
    NOTIFYMSG SHUTDOWN "%s"
    NOTIFYMSG REPLBATT "%s"
    NOTIFYMSG NOCOMM "%s"
    NOTIFYMSG NOPARENT "%s"

    NOTIFYFLAG ONLINE EXEC
    NOTIFYFLAG ONBATT EXEC
    NOTIFYFLAG LOWBATT EXEC
    NOTIFYFLAG FSD EXEC
    NOTIFYFLAG COMMOK EXEC
    NOTIFYFLAG COMMBAD EXEC
    NOTIFYFLAG SHUTDOWN EXEC
    NOTIFYFLAG REPLBATT EXEC
    NOTIFYFLAG NOCOMM EXEC
  '';
  environment.etc."nut/notify.sh".source = pkgs.writeScript "notify.sh" ''
    #!${pkgs.bash}/bin/bash
    echo $NOTIFYTYPE on $1 | ${pkgs.systemd}/bin/systemd-cat -p warning -t upsmon-notify
    if [ "$NOTIFYTYPE" == "ONBATT" ]; then
      ${pkgs.nut}/bin/upscmd -u ${private.upsd.username} -p '${private.upsd.pw}' $1 beeper.toggle
    fi
  '';
}
