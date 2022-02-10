{ lib, stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname = "airsonic-advanced";
  version = "11.0.0-SNAPSHOT.20220209222511";

  src = fetchurl {
    url = "https://github.com/airsonic-advanced/airsonic-advanced/releases/download/${version}/airsonic.war";
    sha256 = "0abxj8hagcr3lrzf2d78bw7659w3r9dn0ryqxhk6phimf3rxy9hy";
  };

  buildCommand = ''
    mkdir -p "$out/webapps"
    cp "$src" "$out/webapps/airsonic.war"
  '';

  doCheck = false;
}
