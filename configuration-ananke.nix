{ pkgs, ... }:

{
  imports = [
    # core
    ./fragments/users.nix

    # programs
    ./fragments/nvim.nix
    ./fragments/zsh.nix
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

  nix = {
    autoOptimiseStore = true;
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
    # Free up to 1GiB whenever there is less than 100MiB left.
    extraOptions = ''
      min-free = ${toString (100 * 1024 * 1024)}
      max-free = ${toString (1024 * 1024 * 1024)}
    '';
  };

  time.timeZone = "Africa/Harare";

  networking = {
    hostName = "ananke";
    defaultGateway = "192.168.0.1";
    nameservers = [ "1.1.1.1" "8.8.8.8" ];
    interfaces.eth0.ipv4.addresses = [{
      address = "192.168.0.3";
      prefixLength = 24;
    }];
    firewall.allowedTCPPorts = [ 8443 3493 ];
  };

  services.openssh.enable = true;

  environment.systemPackages = with pkgs; [
    git
    wget
    tree
    file
    htop
    sshfs
    tmux
    lm_sensors
  ];

  services.unifi = {
    enable = true;
    openPorts = true;
    unifiPackage = pkgs.unifiStable;
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
  systemd.services.upsmon.enable = false;
  environment.etc."nut/upsd.conf".source = pkgs.writeText "upsd.conf" ''
    LISTEN 127.0.0.1 3493
    LISTEN 192.168.0.3 3493
  '';
  environment.etc."nut/upsd.users".source = ../ups/upsd.users;
  environment.etc."nut/upsmon.conf".source = ../ups/upsmon.conf;
}
