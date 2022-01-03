{ lib, buildPythonPackage, fetchFromGitHub, callPackage, aiohttp, systemd }:

buildPythonPackage rec {
  pname = "watcher-bot";
  version = "unstable-2022-01-03";

  src = fetchFromGitHub {
    owner = "udf";
    repo = "the-watcher";
    rev = "af693e8a59d8f9b0297cfaa986db9768c3add9a2";
    sha256 = "023dijgc4wr9g8c4ihcnqrxy64v0anbkr302yqfb1bbj3jlswbaq";
    fetchSubmodules = true;
  };

  propagatedBuildInputs = [
    (callPackage ./telethon.nix {})
    aiohttp
    systemd
  ];

  doCheck = false;
}
