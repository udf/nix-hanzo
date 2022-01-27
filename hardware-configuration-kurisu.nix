# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [ "ehci_pci" "ahci" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/fd1206f1-f275-4035-b74b-26e79a50193f";
    fsType = "ext4";
  };

  fileSystems."/booty" = {
    device = "booty";
    fsType = "zfs";
  };

  fileSystems."/backups" = {
    device = "backups";
    fsType = "zfs";
  };

  fileSystems."/backups/snapshots" = {
    device = "backups/snapshots";
    fsType = "zfs";
  };

  boot.kernel.sysctl = {
    "vm.swappiness" = 0;
  };

  powerManagement.cpuFreqGovernor = lib.mkDefault "performance";
}