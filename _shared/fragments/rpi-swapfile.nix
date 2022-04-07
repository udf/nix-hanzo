{ pkgs, ... }:
{
  swapDevices = [{ device = "/swapfile"; size = 1024; }];
  boot.kernel.sysctl = {
    "vm.swappiness" = 0;
  };
}
