{ lib, buildPythonPackage, fetchPypi, async_generator, rsa, pyaes, openssl, pythonOlder }:

buildPythonPackage rec {
  pname = "telethon";
  version = "1.23.0";

  src = fetchPypi {
    inherit version;
    pname = "Telethon";
    sha256 = "04y31rp4x439pvjl2vrcgahcqx3mmd5vmvpkcynlm5by8k752xds";
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
