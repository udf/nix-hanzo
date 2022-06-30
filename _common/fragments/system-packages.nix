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
    lm_sensors
    ncdu
    pv
    lsof
  ];
}
