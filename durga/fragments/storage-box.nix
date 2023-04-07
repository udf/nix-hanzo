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

  users.groups = {
    cl_qbit.members = [ "sam" ];
  };

  fileSystems."/cum/qbit" = {
    device = "${host}:qbit";
    fsType = "fuse.sshfs";
    options = sshfsOptions ++ [
      "uid=sam"
      "gid=cl_qbit"
      "max_conns=4"
    ];
  };
}