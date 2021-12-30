{ lib, buildPythonPackage, fetchFromGitHub, callPackage, aiohttp, systemd }:

buildPythonPackage rec {
  pname = "watcher-bot";
  version = "unstable-2021-12-31";

  src = fetchFromGitHub {
    owner = "udf";
    repo = "the-watcher";
    rev = "21164ac032bd88f9568db7beaac11ab2cbf3472b";
    sha256 = "1mjdf3qavm16fbd72i9rw7xmgy60vclzh50h3041s2k2xyz0p0bk";
    fetchSubmodules = true;
  };

  propagatedBuildInputs = [
    (callPackage ./telethon.nix {})
    aiohttp
    systemd
  ];

  doCheck = false;
}
