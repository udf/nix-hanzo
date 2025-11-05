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
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKxBxAt/K3h+W4wyxLbTsW0awTIzJy2rpsQgDKxBHNe5 iOS"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEbHvYANduDUO7939VJu12KFxMEM5fCRx/4PG/W5UwIa sam@mashiro"
      ];
      uid = 1000;
      packages = [
        pkgs.python3
        pkgs.python3Packages.pip
      ];
    };
  };
}
