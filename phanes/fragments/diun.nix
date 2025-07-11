{ config, lib, pkgs, ... }:
{
  services.diun-container = {
    enable = true;
    socketPath = "/run/podman/podman.sock";
  };
}