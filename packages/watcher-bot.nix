{ lib, buildPythonPackage, fetchFromGitHub, callPackage, aiohttp }:

buildPythonPackage rec {
  pname = "watcher-bot";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "udf";
    repo = "the-watcher";
    rev = "760faa03bfcd2bd45ab1de93ec43f675683fde60";
    sha256 = "0j33wzqm3jrg9qdjqc41q6wn9hlr1ag2ha196nrzhzy60vnilm00";
  };

  propagatedBuildInputs = [
    (callPackage ./telethon.nix {})
    aiohttp
  ];

  doCheck = false;
}
