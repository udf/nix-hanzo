# jesec's fork of libtorrent, no clue why it exists
{ lib, stdenv, fetchFromGitHub, cmake
, cppunit, openssl, libsigcxx, zlib
}:

stdenv.mkDerivation rec {
  pname = "libtorrent";
  version = "0.13.8";

  src = fetchFromGitHub {
    owner = "jesec";
    repo = pname;
    rev = "2a75735cf0854cfe7c5232b98526144f25c8f6f8";
    sha256 = "052mkiwb4qbndgr3sjrk9v1dxvn016ay74yw0v8c4jwrfdqymxdl";
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [ cppunit openssl libsigcxx zlib ];
}
