{ config, lib, pkgs, ... }:
{
  services.diun-container = {
    enable = true;
    socketPath = "/var/run/docker.sock";
  };
}