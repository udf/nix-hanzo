{ lib, buildPythonPackage, fetchFromGitHub, callPackage, aiohttp, systemd }:

buildPythonPackage rec {
  pname = "watcher-bot";
  version = "unstable-2022-01-01";

  src = fetchFromGitHub {
    owner = "udf";
    repo = "the-watcher";
    rev = "bae8dcf5f13477a36abf89f80d33e206cad60ce8";
    sha256 = "1x403w3hh5gxrplk8dygvlwh9bdawnzqiykqh5mshwrq632kp89m";
    fetchSubmodules = true;
  };

  propagatedBuildInputs = [
    (callPackage ./telethon.nix {})
    aiohttp
    systemd
  ];

  doCheck = false;
}
