{ config, lib, pkgs, ... }:
{
  imports = [
    ../modules/uniborg.nix
  ];

  services.uniborg = {
    enable = true;
    users = {
      sam = {
        enable = true;
        extraPythonPackages = [
          "pillow" "ffmpeg-python" "numpy" "aiohttp"
        ];
      };
      cath = {
        enable = true;
        user = "sam";
        subdir = "uniborg_cath";
      };
    };
  };
}