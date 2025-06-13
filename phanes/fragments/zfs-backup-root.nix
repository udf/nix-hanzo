{ config, lib, pkgs, ... }:
let
  srcDataset = "zpool";
  targetDataset = "backup/${config.networking.hostName}_bk";
  syncoidServiceOpts = {
    startAt = lib.mkForce [ ];
    after = [ "sanoid.service" ];
    wantedBy = [ "sanoid.service" ];
    serviceConfig.Type = "oneshot";
  };
  sanoidAllSnapsOff = {
    frequently = 0;
    hourly = 0;
    daily = 0;
    weekly = 0;
    monthly = 0;
    yearly = 0;
  };
in
{
  boot.zfs.requestEncryptionCredentials = [ targetDataset ];

  services.sanoid = {
    enable = true;
    interval = "*-*-* 03,11,19:00:00";

    datasets."${targetDataset}/root" = sanoidAllSnapsOff // {
      hourly = 90;
      autoprune = true;
      autosnap = false;
    };
    datasets."${srcDataset}/root" = sanoidAllSnapsOff // {
      hourly = 3;
      autoprune = true;
      autosnap = true;
    };

    extraArgs = [ "--verbose" ];
  };

  systemd.services.sanoid.serviceConfig.Type = "oneshot";
  systemd.services."syncoid-${srcDataset}-nix" = syncoidServiceOpts;
  systemd.services."syncoid-${srcDataset}-root" = syncoidServiceOpts // {
    after = syncoidServiceOpts.after ++ [ "syncoid-${srcDataset}-nix.service" ];
  };

  services.syncoid = {
    enable = true;
    interval = "daily";
    localTargetAllow = [
      "change-key"
      "compression"
      "create"
      "mount"
      "mountpoint"
      "receive"
      "rollback"
      "destroy"
    ];
    commands."${srcDataset}-root" = {
      source = "${srcDataset}/root";
      target = "${targetDataset}/root";
      extraArgs = [ "--no-sync-snap" "--create-bookmark" ];
    };
    commands."${srcDataset}-nix" = {
      source = "${srcDataset}/nix";
      target = "${targetDataset}/nix";
      extraArgs = [ "--delete-target-snapshots" ];
    };
  };
}
