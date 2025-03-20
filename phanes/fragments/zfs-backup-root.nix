{ config, lib, pkgs, ... }:
let
  srcDataset = "zpool";
  targetDataset = "backup/${config.networking.hostName}_bk";
  syncoidServiceOpts = {
    startAt = lib.mkForce [ ];
    after = [ "sanoid.service" ];
    wantedBy = [ "sanoid.service" ];
  };
  sanoidAllSnapsOff = {
    frequently = 0;
    hourly = 0;
    daily = 30;
    weekly = 0;
    monthly = 0;
    yearly = 0;
  };
in
{
  services.sanoid = {
    enable = true;
    interval = "*-*-* 03,11,19:00:00";
    extraArgs = [
      "--verbose"
      "--monitor-capacity"
      "--monitor-health"
    ];

    datasets."${targetDataset}/root" = sanoidAllSnapsOff // {
      daily = 30;
      autoprune = true;
      autosnap = false;
    };
    datasets."${srcDataset}/root" = sanoidAllSnapsOff // {
      daily = 1;
      autoprune = true;
      autosnap = true;
    };
  };

  systemd.services."syncoid-${srcDataset}-nix" = syncoidServiceOpts;
  systemd.services."syncoid-${srcDataset}-root" = syncoidServiceOpts // {
    after = [ "syncoid-${srcDataset}-nix.service" ];
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
