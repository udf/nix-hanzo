{ lib, buildPythonPackage, fetchPypi }:

buildPythonPackage rec {
  pname = "basest";
  version = "0.7.3";

  src = fetchPypi {
    inherit version;
    pname = "basest";
    sha256 = "1a8kyayyi4wbfvj0k6fj3bhzkn5gka1y7crzjkhxs1lkyp7qnijp";
  };

  # No tests available
  doCheck = false;
}
