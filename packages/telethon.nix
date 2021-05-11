{ lib, buildPythonPackage, fetchPypi, async_generator, rsa, pyaes, openssl, pythonOlder }:

buildPythonPackage rec {
  pname = "telethon";
  version = "1.21.1";

  src = fetchPypi {
    inherit version;
    pname = "Telethon";
    sha256 = "1whf7v969dsmf9ry0l0s7n3a46751jxbzmr75abxzba5yxz86g4r";
  };

  patchPhase = ''
    substituteInPlace telethon/crypto/libssl.py --replace \
      "ctypes.util.find_library('ssl')" "'${openssl.out}/lib/libssl.so'"
  '';

  propagatedBuildInputs = [
    async_generator
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
