{ lib, buildPythonPackage, fetchFromGitHub, callPackage, aiohttp, systemd }:

buildPythonPackage rec {
  pname = "watcher-bot";
  version = "unstable-2022-01-17";

  src = fetchFromGitHub {
    owner = "udf";
    repo = "the-watcher";
    rev = "c03354bc0b737ed353a11e97d465e4dc4f4c7478";
    sha256 = "0fm5ihb0l0yx9kasbbs0zf8xxlblxjbar1yjry8ix0qmmndmiasc";
    fetchSubmodules = true;
  };

  propagatedBuildInputs = [
    (callPackage ./telethon.nix { })
    aiohttp
    systemd
  ];

  doCheck = false;
}
