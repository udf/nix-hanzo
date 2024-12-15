{ config, pkgs, lib, ... }:with lib;
let
  cfg = config.custom.remote-build-desktop;
in
{
  options.custom.remote-build-desktop = {
    enable = mkEnableOption "Enable using karen-chan as a remote x86 builder";
  };

  config = mkIf cfg.enable {
    nix = {
      buildMachines = [{
        hostName = "karen-chan";
        system = "x86_64-linux";
        maxJobs = 12;
        speedFactor = 10;
        supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
        mandatoryFeatures = [ ];
      }];
      distributedBuilds = true;
      extraOptions = ''
        builders-use-substitutes = true
      '';
    };
  };
}
