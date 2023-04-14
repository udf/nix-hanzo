{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    git
    wget
    tree
    file
    htop
    iotop
    btop
    tmux
    python310
    python310Packages.pip
    lm_sensors
    ncdu
    pv
    lsof
    aria
  ];
}
