# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

let
  mkMappedBind = { fromUser, toUser, fromGroup, toGroup, toPath }: {
    device = toPath;
    fsType = "fuse.bindfs";
    options = [
      "map=${fromUser}/${toUser}:@${fromGroup}/@${toGroup}"
      "force-user=${toUser}"
      "force-group=${toGroup}"
    ];
    noCheck = true;
  };
  mkSuwayomiSyncthingBind = toPath: (mkMappedBind {
    fromUser = "suwayomi";
    toUser = "syncthing";
    fromGroup = "suwayomi";
    toGroup = "suwayomi";
    toPath = toPath;
  });
in
{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "virtio_pci" "virtio_scsi" "usbhid" ];
  boot.initrd.kernelModules = [ "nvme" ];
  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
    device = "nodev";
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/098aab8a-579b-4376-b268-fba317eab5d1";
    fsType = "btrfs";
    options = [ "compress-force=zstd:15" "space_cache=v2" ];
  };
  fileSystems."/sync" = {
    device = "/dev/disk/by-uuid/098aab8a-579b-4376-b268-fba317eab5d1";
    fsType = "btrfs";
    options = [ "noatime" "space_cache=v2" "subvol=sync" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/D57C-6430";
    fsType = "vfat";
  };

  system.fsPackages = [ pkgs.bindfs ];
  fileSystems."/sync/downloads/suwayomi/local" = mkSuwayomiSyncthingBind "/var/lib/docker/volumes/suwayomi/_data/local";
  fileSystems."/sync/downloads/suwayomi/downloads" = mkSuwayomiSyncthingBind "/var/lib/docker/volumes/suwayomi/_data/downloads";
  fileSystems."/sync/downloads/suwayomi/backups" = mkSuwayomiSyncthingBind "/var/lib/docker/volumes/suwayomi/_data/backups";

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
}
