{ config, pkgs, ... }:

{
  nix = {
    buildMachines = [{
      hostName = "karen-chan";
      system = "aarch64-linux";
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
}
