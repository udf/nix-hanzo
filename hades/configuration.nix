{ config, lib, pkgs, ... }:
{
  imports = [
    (import ../_autoload.nix ./.)
  ];

  custom.rpi-remote-build-desktop.enable = true;
  custom.rpi-swapfile.enable = true;

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
    blacklistedKernelModules = [ "i2c_bcm2835" ];
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
    interfaces.eth0.ipv4.addresses = [{
      address = "192.168.1.2";
      prefixLength = 24;
    }];
    interfaces.wlan0.ipv4.addresses = [{
      address = "10.0.0.1";
      prefixLength = 24;
    }];
    dhcpcd.enable = false;
  };

  time.timeZone = "Africa/Harare";

  services.openssh.enable = true;
  services.haveged.enable = true;
}
