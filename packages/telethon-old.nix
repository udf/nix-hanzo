{ lib, buildPythonPackage, fetchFromGitHub, fetchurl, openssl, rsa, pyaes, pythonOlder }:

let
  # 134
  layerSchema = fetchurl {
    url = "https://raw.githubusercontent.com/telegramdesktop/tdesktop/f839c7f2bb3ad627be437ed067ca5d3bafc9457e/Telegram/Resources/tl/api.tl";
    sha256 = "0xc1i0n42ch3zzbmrii55ba84pma4rrcy12im1fa6763ifmixknw";
  };
in
buildPythonPackage rec {
  pname = "telethon";
  version = "1.24.0";

  src = fetchFromGitHub {
    owner = "LonamiWebs";
    repo = "Telethon";
    rev = "v1.24.0";
    sha256 = "12rvmb5hxadp5cc6dcxh4nlf7m8zg8f73d5saikcxjnmf38v7l0v";
  };

  patchPhase = ''
    cp ${layerSchema} telethon_generator/data/api.tl
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
