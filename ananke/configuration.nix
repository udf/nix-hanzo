{ config, pkgs, lib, ... }:

let
  private = (import ../_common/constants/private.nix).ananke;
  sdImageFirmware = (pkgs.callPackage ./packages/sd-image-firmware.nix {});
in
{
  imports = [
    <nixos-hardware/raspberry-pi/4>
    (import ../_autoload.nix ./.)
  ];

  custom.rpi-remote-build-durga.enable = true;
  custom.rpi-swapfile = {
    enable = true;
    disableSwappiness = false;
  };
  zramSwap.enable = true;
  zramSwap.memoryPercent = 200;

  # Assuming this is installed on top of the disk image.
  fileSystems = {
    "/boot/firmware" = {
      device = "/dev/disk/by-label/FIRMWARE";
      fsType = "vfat";
    };
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [ "noatime" ];
    };
  };
  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;
  # Mainline doesn't work yet
  boot.kernelPackages = pkgs.linuxPackages_rpi4;

  system.activationScripts = {
    updateFirmware = ''
      if [ "$(cat /boot/firmware/src.path 2>/dev/null || true)" != "${sdImageFirmware}" ]; then
        echo Updating firmware from ${sdImageFirmware}
        ${pkgs.rsync}/bin/rsync -rv "${sdImageFirmware}/firmware/" /boot/firmware/ && \
        echo -n "${sdImageFirmware}" > /boot/firmware/src.path
      fi
    '';
  };

  # ttyAMA0 is the serial console broken out to the GPIO
  boot.kernelParams = [
    "8250.nr_uarts=1" # may be required only when using u-boot
    "console=ttyAMA0,115200"
    "console=tty1"
    "cgroup_enable=memory"
  ];

  boot.kernel.sysctl = {
    "net.ipv6.conf.eth0.accept_ra" = 0;
    "vm.watermark_boost_factor" = 0;
    "vm.watermark_scale_factor" = 125;
    "vm.page-cluster" = 0;
    "vm.swappiness" = 150;
  };

  powerManagement.cpuFreqGovernor = "ondemand";

  # Required for the Wireless firmware
  hardware = {
    enableRedistributableFirmware = true;
    raspberry-pi."4".apply-overlays-dtmerge.enable = true;
    deviceTree = {
      enable = true;
      filter = "*rpi-4-*.dtb";
    };
  };
  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "23.11";

  time.timeZone = "Africa/Harare";

  networking = {
    hostName = "ananke";
    defaultGateway = "192.168.0.1";
    nameservers = [ "1.1.1.1" ];
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
    firewall.allowedTCPPorts = [ 3493 ];
    dhcpcd.enable = false;
  };

  services.openssh = {
    enable = true;
    extraConfig = ''
      AuthenticationMethods publickey

      Match Address 192.168.0.0/16
        AuthenticationMethods publickey password
    '';
  };

  environment.systemPackages = with pkgs; [
    sshfs
    wol
    libraspberrypi
    raspberrypi-eeprom
  ];

}
