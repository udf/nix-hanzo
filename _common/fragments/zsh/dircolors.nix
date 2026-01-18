{ lib, pkgs, ... }:
pkgs.stdenv.mkDerivation {
  nativeBuildInputs = with pkgs; [ coreutils ];
  name = "dircolors-sh";
  dontUnpack = true;
  buildPhase = ''
    dircolors -p > .dircolors
    substituteInPlace .dircolors --replace-fail "OTHER_WRITABLE 34;42" "OTHER_WRITABLE 30;42"
    dircolors -b .dircolors > dircolors-sh
  '';
  installPhase = ''
    mkdir -p $out
    cp .dircolors $out/
    cp dircolors-sh $out/
  '';
}