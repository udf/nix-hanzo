{ config, lib, pkgs, ... }:
let
  host = "u317530@u317530.your-storagebox.de";
  sshfsOptions = [
    "port=23"
    "x-systemd.automount"
    "x-systemd.requires=network-online.target"
    "noauto"
    "x-systemd.mount-timeout=5s"
    "_netdev"
    "user"
    "idmap=user"
    "transform_symlinks"
    "identityfile=/root/.ssh/id_rsa"
    "allow_other"
    "default_permissions"
    "umask=0007"
  ];
in
{
  environment.systemPackages = with pkgs; [
    sshfs
  ];

  fileSystems."/cum/music" = {
    device = "${host}:music";
    fsType = "fuse.sshfs";
    options = sshfsOptions ++ [
      "gid=${toString config.users.groups.st_music.gid}"
    ];
  };
  fileSystems."/cum/music_ro" = {
    device = "${host}:music";
    fsType = "fuse.sshfs";
    options = sshfsOptions ++ [
      "uid=nginx"
      "ro"
    ];
  };
}
