{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    git
    wget
    tree
    file
    htop
    iotop-c
    btop
    tmux
    lm_sensors
    ncdu
    pv
    lsof
    aria
    zip
    atool
    unzip
    pipx
    expect
  ];
}
