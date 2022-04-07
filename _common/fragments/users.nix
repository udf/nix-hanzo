{ ... }:
{
  users.users = {
    sam = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIzlWx6yy2nWV8fYcIm9Laap8/KxAlLJd943TIrcldSY archdesktop"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIISRXQoctePFQfGqILvQHzoIgdeF1SPGxGRQBrfqWgoA phone"
      ];
      uid = 1000;
    };
  };
}
