# Keys for machines using this one as a remote builder
{ ... }:
{
  nix.settings.trusted-users = [ "@wheel" ];

  users.users.sam.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAFSIAxGtpP93dBLKAZ80nd+D1AX4iDjwW0L1IhhkfOo sam@ananke"
  ];
}
