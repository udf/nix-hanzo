{ config, lib, pkgs, ... }:
{
  # coolercontrol is garbage and needs to be accessed locally
  # ssh -L localhost:11988:localhost:11988 phanes
  programs.coolercontrol.enable = true;
  boot = {
    kernelModules = [ "thinkpad_acpi" ];
    extraModprobeConfig = ''
      options thinkpad_acpi fan_control=1
    '';
  };
}
