{ lib, fetchhg, which, ... }:
rec {
  name = "njs";
  src = fetchhg {
    url = "https://hg.nginx.org/njs";
    rev = "0.8.4";
    sha256 = "sha256-SooPFx4WNEezPD+W/wmMLY+FdkGRoojLNUFbhn3Riyg=";
    name = "nginx-njs";
  };

  # njs module sources have to be writable during nginx build, so we copy them
  # to a temporary directory and change the module path in the configureFlags
  preConfigure = ''
    NJS_SOURCE_DIR=$(readlink -m "$TMPDIR/${src}")
    mkdir -p "$(dirname "$NJS_SOURCE_DIR")"
    cp --recursive "${src}" "$NJS_SOURCE_DIR"
    chmod -R u+rwX,go+rX "$NJS_SOURCE_DIR"
    export configureFlags="''${configureFlags/"${src}"/"$NJS_SOURCE_DIR/nginx"}"
    unset NJS_SOURCE_DIR
  '';

  inputs = [ which ];

  meta = with lib; {
    description = "Subset of the JavaScript language that allows extending nginx functionality";
    homepage = "https://nginx.org/en/docs/njs/";
    license = with licenses; [ bsd2 ];
    maintainers = with maintainers; [ ];
  };
}
