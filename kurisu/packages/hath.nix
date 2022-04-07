{ lib, pkgs, stdenv, fetchzip }:

stdenv.mkDerivation rec {
  pname = "hath";
  version = "1.6.1";

  src = fetchzip {
    url = "https://repo.e-hentai.org/hath/HentaiAtHome_${version}.zip";
    sha256 = "0vc1clb529997zpkswm95ahm6h4m0aj9zbwyw6g4ll77kip79bvb";
    stripRoot = false;
  };

  doCheck = false;

  installPhase = ''
    mkdir -p $out/bin
    cp HentaiAtHome.jar $out/bin/
  '';
}
