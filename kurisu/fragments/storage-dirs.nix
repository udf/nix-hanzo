{ ... }:
{
  imports = [
    ../modules/storage-dirs.nix
  ];

  utils.storageDirs = {
    storagePath = "/booty";
    adminUsers = [ "sam" ];
    dirs = {
      backups = { path = "/backups"; };
      downloads = { };
    };
  };
}