{ ... }:
{
  imports = [
    <nixpkgs/nixos/modules/virtualisation/google-compute-image.nix>

    # core
    ./fragments/system-packages.nix
    ./fragments/users.nix

    # services
    ./modules/watcher-bot.nix

    # programs
    ./fragments/nvim.nix
    ./fragments/zsh.nix
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
