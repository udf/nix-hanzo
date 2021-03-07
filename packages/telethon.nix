{ lib, buildPythonPackage, fetchPypi, async_generator, rsa, pyaes, openssl, pythonOlder }:

buildPythonPackage rec {
  pname = "telethon";
  version = "1.18.2";

  src = fetchPypi {
    inherit version;
    pname = "Telethon";
    sha256 = "1yyf60fvd3sjn0klwxkybmqyfp21dfcj47sgwk14bxwjfrrzz5a6";
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
