{ lib, buildPythonPackage, fetchFromGitHub, callPackage, aiohttp, systemd }:

buildPythonPackage {
  pname = "watcher-bot";
  version = "unstable-2025-05-25";

  src = fetchFromGitHub {
    owner = "udf";
    repo = "the-watcher";
    rev = "d861fad684af0c3b8435a49cac973bb00989c9e5";
    sha256 = "sha256-Pjo6QuEzdtk05Uw4q6ekpmJLSmZgUQEg4qvtqeoOYpY=";
    fetchSubmodules = true;
  };

  propagatedBuildInputs = [
    (callPackage ./telethon.nix { })
    aiohttp
    systemd
  ];

  doCheck = false;
}
