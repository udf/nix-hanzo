{ lib, buildPythonPackage, fetchFromGitHub, callPackage, aiohttp, systemd }:

buildPythonPackage rec {
  pname = "watcher-bot";
  version = "unstable-2025-03-10";

  src = fetchFromGitHub {
    owner = "udf";
    repo = "the-watcher";
    rev = "aba1eccf223cd765fa4c91ac6503a06b6a752401";
    sha256 = "sha256-e400yHpYbGqHbihzoXmdughzlenNttff48RKECDvX/c=";
    fetchSubmodules = true;
  };

  propagatedBuildInputs = [
    (callPackage ./telethon.nix { })
    aiohttp
    systemd
  ];

  doCheck = false;
}
