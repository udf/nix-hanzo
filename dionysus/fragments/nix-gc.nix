{ pkgs, lib, ... }:
with lib;
{
  nix.gc.options = mkForce "--delete-older-than 1d";
}