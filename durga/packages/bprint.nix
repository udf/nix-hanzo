{ lib, buildPythonPackage, fetchFromGitHub, setuptools }:

buildPythonPackage rec {
  pname = "beauty-print";
  version = "0.6.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "udf";
    repo = "bprint";
    rev = "4e36f0687bbea1ca3cd5430c8f461792300e3086";
    sha256 = "0hjlh53lzslv3c6nzd087s9ylvaja0k48ij391j9c7a95s785zvj";
  };

  build-system = [ setuptools ];

  doCheck = false;
}
