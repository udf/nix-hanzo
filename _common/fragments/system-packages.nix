{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    git
    wget
    tree
    file
    htop
    iotop
    bpytop
    tmux
    python39
    python39Packages.pip
    lm_sensors
    ncdu
    pv
    lsof
    aria
  ];
}
