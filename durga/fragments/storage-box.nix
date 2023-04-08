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
    "Compression=no"
  ];
in
{
  environment.systemPackages = with pkgs; [
    sshfs
  ];

  users.groups = {
    cl_qbit.members = [ "sam" ];
    cl_music.members = [ "sam" ];
    cl_backups.members = [ "sam" ];
    cl_allro.members = [ "sam" ];
  };

  fileSystems."/cum/qbit" = {
    device = "${host}:qbit";
    fsType = "fuse.sshfs";
    options = sshfsOptions ++ [
      "uid=sam"
      "gid=cl_qbit"
      "max_conns=2"
    ];
  };

  fileSystems."/cum/music" = {
    device = "${host}:music";
    fsType = "fuse.sshfs";
    options = sshfsOptions ++ [
      "uid=nicotine"
      "gid=cl_music"
      "max_conns=2"
    ];
  };

  fileSystems."/cum/soulseek-downloads" = {
    device = "${host}:soulseek-downloads";
    fsType = "fuse.sshfs";
    options = sshfsOptions ++ [
      "uid=nicotine"
      "gid=cl_music"
    ];
  };

  fileSystems."/cum/backups" = {
    device = "${host}:backups";
    fsType = "fuse.sshfs";
    options = sshfsOptions ++ [
      "uid=sam"
      "gid=cl_backups"
    ];
  };

  fileSystems."/cum/all_ro" = {
    device = "${host}:/home";
    fsType = "fuse.sshfs";
    options = sshfsOptions ++ [
      "uid=nginx"
      "gid=cl_allro"
      "ro"
    ];
  };
}
