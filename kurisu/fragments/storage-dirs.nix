{ ... }:
{
  imports = [
    ../modules/storage-dirs.nix
  ];

  utils.storageDirs = {
    storagePath = "/booty";
    adminUsers = [ "sam" ];
    dirs = {
      music = { path = "/cum/music"; genACL = false; };
      backups = { path = "/backups"; };
      downloads = { };
    };
  };
}