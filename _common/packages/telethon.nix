{ lib, buildPythonPackage, fetchFromGitHub, fetchurl, openssl, rsa, pyaes, pythonOlder, setuptools }:

buildPythonPackage rec {
  pname = "telethon";
  version = "1.24.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "udf";
    repo = "Telethon";
    rev = "v1.24-lts";
    sha256 = "1454v9qsh421ssj6jic3rgvb5a9priwlpgqfqvvrbqh8spibliil";
  };

  build-system = [ setuptools ];

  patchPhase = ''
    substituteInPlace telethon/crypto/libssl.py --replace \
      "ctypes.util.find_library('ssl')" "'${openssl.out}/lib/libssl.so'"
  '';

  propagatedBuildInputs = [
    rsa
    pyaes
  ];

  # No tests available
  doCheck = false;

  disabled = pythonOlder "3.5";

  meta = with lib; {
    homepage = "https://github.com/LonamiWebs/Telethon";
    description = "Full-featured Telegram client library for Python 3";
    license = licenses.mit;
    maintainers = with maintainers; [ nyanloutre ];
  };
}
