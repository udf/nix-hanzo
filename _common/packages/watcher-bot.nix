{ lib, buildPythonPackage, fetchFromGitHub, callPackage, aiohttp, systemd }:

buildPythonPackage rec {
  pname = "watcher-bot";
  version = "unstable-2024-05-11";

  src = fetchFromGitHub {
    owner = "udf";
    repo = "the-watcher";
    rev = "3312b94924c0be8ac44e0f33560a24db1510bb7f";
    sha256 = "sha256-uWok8NFTbgSiX3+083k+kAF08xzfx8q9QxE6lcJUHYA=";
    fetchSubmodules = true;
  };

  propagatedBuildInputs = [
    (callPackage ./telethon.nix { })
    aiohttp
    systemd
  ];

  doCheck = false;
}
