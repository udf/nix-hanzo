{ pkgs, callPackage, stdenv }:

let
  sdImageDrv = (callPackage "${pkgs.path}/nixos/modules/installer/sd-card/sd-image-aarch64.nix" { });
in
stdenv.mkDerivation {
  name = "sd-image-firmware";
  buildCommand = ''
    mkdir firmware
    ${sdImageDrv.sdImage.populateFirmwareCommands}
    mkdir -p $out
    mv firmware $out/firmware
  '';
}
