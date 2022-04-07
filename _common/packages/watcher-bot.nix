{ lib, buildPythonPackage, fetchFromGitHub, callPackage, aiohttp, systemd }:

buildPythonPackage rec {
  pname = "watcher-bot";
  version = "unstable-2022-03-24";

  src = fetchFromGitHub {
    owner = "udf";
    repo = "the-watcher";
    rev = "36af520c9a10dd5f35e9a1bd7ddca729aaf474b8";
    sha256 = "06vjlgbbmh59j2f6yj1x8868l0nnzg9z6ms5nkz10sjd1ryadma2";
    fetchSubmodules = true;
  };

  propagatedBuildInputs = [
    (callPackage ./telethon.nix { })
    aiohttp
    systemd
  ];

  doCheck = false;
}
