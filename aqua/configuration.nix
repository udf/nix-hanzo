{ ... }:
{
  imports = [
    <nixpkgs/nixos/modules/virtualisation/google-compute-image.nix>
    (import ../_autoload.nix ./.)
  ];

  services.openssh = {
    enable = true;
    ports = [ 69 ];
    openFirewall = true;
  };

  swapDevices = [{ device = "/swapfile"; size = 2048; }];
  boot.kernel.sysctl = {
    "vm.swappiness" = 0;
  };

  system.autoUpgrade = {
    enable = true;
    allowReboot = true;
  };
}
