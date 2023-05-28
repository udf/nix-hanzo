{ pkgs, ... }:
{
  users.users = {
    sam = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIzlWx6yy2nWV8fYcIm9Laap8/KxAlLJd943TIrcldSY archdesktop"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB/M7Ba3GQSuRFjMTInCAv/mZIvlc4KxyrJZkklL0yhv phone"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHcNGC8Qg4+lVODt4cdbDtjbrVe44GGBae5sVoCZ1irJ sam@alice"
      ];
      uid = 1000;
      packages = [ pkgs.python311 pkgs.python311Packages.pip ];
    };
  };
}
