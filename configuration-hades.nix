{ config, lib, pkgs, ... }:

let
  private = import ./constants/private.nix;
in
{
  imports = [
    # core
    ./fragments/system-packages.nix
    ./fragments/users.nix
    ./fragments/nix-options.nix
    ./fragments/rpi-swapfile.nix
    ./fragments/remote-build-desktop-aarch64.nix

    # services
    ./modules/watcher-bot.nix

    # programs
    ./fragments/nvim.nix
    ./fragments/zsh.nix
  ];

  boot = {
    loader = {
      raspberryPi = {
        enable = true;
        version = 3;
        uboot.enable = true;
      };
      grub.enable = false;
    };
    kernelPackages = pkgs.linuxPackages;
    # kernelParams = ["cma=32M"];
  };

  hardware.enableRedistributableFirmware = true;
  nixpkgs.config.allowUnfree = true;

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [ "noatime" ];
    };
  };

  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";

  networking = {
    hostName = "hades";
    defaultGateway = "192.168.1.1";
    nameservers = [ "1.1.1.1" "8.8.8.8" ];
    interfaces.br0.ipv4.addresses = [{
      address = "192.168.1.2";
      prefixLength = 24;
    }];
  };

  time.timeZone = "Africa/Harare";

  environment.systemPackages = with pkgs; [ ];

  services.openssh.enable = true;

  systemd.services.ap-watcher = {
    after = [ "network.target" ];
    serviceConfig = {
      Type = "simple";
      User = "root";
      Restart = "always";
    };
    path = [
      pkgs.iputils
    ];

    script = ''
      sleep 60
      while true; do
        if ping -W 1 -c 1 192.168.0.8 >/dev/null ; then
          systemctl stop hostapd
        else
          systemctl start hostapd
        fi
        sleep 5
      done
    '';
  };

  systemd.services.hostapd = {
    requires = [ "ap-watcher.service" ];
    serviceConfig.ExecStartPost = "systemctl restart network-setup.service";
  };

  services.hostapd = {
    enable = true;
    interface = "wlan0";
    hwMode = "g";
    ssid = "Hades";
    wpaPassphrase = private.hadesPassphrase;
    noScan = true;
    channel = 7;
    extraConfig = ''
      ht_capab=[HT40-][SHORT-GI-20][SHORT-GI-40][TX-STBC][DELAYED-BA][DSSS_CCK-40][LSIG-TXOP-PROT]
    '';
  };

  services.haveged.enable = true;
  networking.bridges.br0.interfaces = [ "eth0" "wlan0" ];
}
