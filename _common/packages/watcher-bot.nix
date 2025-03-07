{ lib, buildPythonPackage, fetchFromGitHub, callPackage, aiohttp, systemd }:

buildPythonPackage rec {
  pname = "watcher-bot";
  version = "unstable-2024-05-11";

  src = fetchFromGitHub {
    owner = "udf";
    repo = "the-watcher";
    rev = "fd5a79852507c794d05169fb31dc5362674bdc81";
    sha256 = "sha256-CWD0JCCy6LC9yrOrhJ19YrD321zFJpmRlnUg8MWfLZ8=";
    fetchSubmodules = true;
  };

  propagatedBuildInputs = [
    (callPackage ./telethon.nix { })
    aiohttp
    systemd
  ];

  doCheck = false;
}
