{ lib, buildPythonPackage, fetchFromGitHub, callPackage, aiohttp, systemd }:

buildPythonPackage rec {
  pname = "watcher-bot";
  version = "unstable-2024-05-11";

  src = fetchFromGitHub {
    owner = "udf";
    repo = "the-watcher";
    rev = "71de380777b23189bfd8e94d6613d4a3bba684eb";
    sha256 = "sha256-r8EpgOPsmP+XAvndQf/12XyZ9x7dYhl6/y0O3hFsFSA=";
    fetchSubmodules = true;
  };

  propagatedBuildInputs = [
    (callPackage ./telethon.nix { })
    aiohttp
    systemd
  ];

  doCheck = false;
}
