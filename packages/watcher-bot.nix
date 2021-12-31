{ lib, buildPythonPackage, fetchFromGitHub, callPackage, aiohttp, systemd }:

buildPythonPackage rec {
  pname = "watcher-bot";
  version = "unstable-2021-12-31";

  src = fetchFromGitHub {
    owner = "udf";
    repo = "the-watcher";
    rev = "9dfc4eb4cfeebb7078a5447063a67fa49026465e";
    sha256 = "1q9hlik9nrnfcikaw83k9gh8ya6nzyb0wrs81xkaz7wrkqk6vkr1";
    fetchSubmodules = true;
  };

  propagatedBuildInputs = [
    (callPackage ./telethon.nix {})
    aiohttp
    systemd
  ];

  doCheck = false;
}
