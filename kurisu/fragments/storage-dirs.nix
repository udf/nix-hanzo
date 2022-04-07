{ ... }:
{
  imports = [
    ../modules/storage-dirs.nix
  ];

  utils.storageDirs = {
    storagePath = "/booty";
    adminUsers = [ "sam" ];
    dirs = {
      music = { path = "/backups/music"; };
      backups = { path = "/backups"; };
      downloads = { };
    };
  };
}