{ lib , buildPythonPackage , fetchFromGitHub , openssl , rsa , pyaes , pythonOlder , setuptools , pytest-asyncio , pytestCheckHook }:

buildPythonPackage rec {
  pname = "telethon";
  version = "1.33.1";
  format = "pyproject";
  disabled = pythonOlder "3.5";

  src = fetchFromGitHub {
    owner = "LonamiWebs";
    repo = "Telethon";
    rev = "refs/tags/v${version}";
    hash = "sha256:1b125xhppwjz3rd5xarmwciwcxznjl08f93m226331kwa1ywca1z";
  };

  patchPhase = ''
    substituteInPlace telethon/crypto/libssl.py --replace \
      "ctypes.util.find_library('ssl')" "'${lib.getLib openssl}/lib/libssl.so'"
  '';

  nativeBuildInputs = [
    setuptools
  ];

  propagatedBuildInputs = [
    rsa
    pyaes
  ];

  # this is fine
  # nativeCheckInputs = [
  #   pytest-asyncio
  #   pytestCheckHook
  # ];

  # pytestFlagsArray = [
  #   "tests/telethon"
  # ];

  meta = with lib; {
    homepage = "https://github.com/LonamiWebs/Telethon";
    description = "Full-featured Telegram client library for Python 3";
    license = licenses.mit;
    maintainers = with maintainers; [ nyanloutre ];
  };
}
