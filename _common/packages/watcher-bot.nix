{ lib, buildPythonPackage, fetchFromGitHub, callPackage, setuptools, aiohttp, systemd-python, telethon }:

buildPythonPackage {
  pname = "watcher-bot";
  version = "unstable-2025-05-25";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "udf";
    repo = "the-watcher";
    rev = "d861fad684af0c3b8435a49cac973bb00989c9e5";
    sha256 = "sha256-Pjo6QuEzdtk05Uw4q6ekpmJLSmZgUQEg4qvtqeoOYpY=";
    fetchSubmodules = true;
  };

  build-system = [ setuptools ];

  propagatedBuildInputs = [
    telethon
    aiohttp
    systemd-python
  ];

  doCheck = false;
}
