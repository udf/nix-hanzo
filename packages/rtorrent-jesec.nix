{ lib, pkgs, stdenv, fetchurl, fetchFromGitHub, cmake
, ncurses, curl, gtest
, zlib, openssl, libxml2, xmlrpc_c, nlohmann_json
}:

stdenv.mkDerivation rec {
  pname = "rtorrent";
  version = "0.9.8-r10";

  src = fetchFromGitHub {
    owner = "jesec";
    repo = pname;
    rev = "v${version}";
    sha256 = "1qx9zwd9a050h7vmfa4lnfl2ad7y1vihcrxwxh0fb7fsnbb5dvhr";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    (pkgs.callPackage ./libtorrent-jesec.nix {})
    ncurses curl zlib openssl gtest
    xmlrpc_c libxml2 nlohmann_json
  ];
}
