{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    git
    wget
    tree
    file
    htop
    tmux
    python39
    lm_sensors
    ncdu
  ];
}
