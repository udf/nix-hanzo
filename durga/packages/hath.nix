{ lib, pkgs, stdenv, fetchzip }:

stdenv.mkDerivation rec {
  pname = "hath";
  version = "1.6.2";

  src = fetchzip {
    url = "https://piracy.withsam.org/shared/HentaiAtHome_${version}.zip";
    sha256 = "sha256-0c8ltti19c6QBkcxZThdqHRGN7pDP0YUwwFXcvvmqDM=";
    stripRoot = false;
  };

  doCheck = false;

  installPhase = ''
    mkdir -p $out/bin
    cp HentaiAtHome.jar $out/bin/
  '';
}
