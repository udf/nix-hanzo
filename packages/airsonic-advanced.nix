{ lib, stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname = "airsonic-advanced";
  version = "11.0.0-SNAPSHOT.20211209065629";

  src = fetchurl {
    url = "https://github.com/airsonic-advanced/airsonic-advanced/releases/download/${version}/airsonic.war";
    sha256 = "1nfxi114swh1vjw63dl7yw362z6rl61gjz9h8gaw0x041x7z1jgp";
  };

  buildCommand = ''
    mkdir -p "$out/webapps"
    cp "$src" "$out/webapps/airsonic.war"
  '';

  doCheck = false;
}
