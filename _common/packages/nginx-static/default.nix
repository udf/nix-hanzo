{ lib, pkgs, ... }:
pkgs.stdenv.mkDerivation {
  nativeBuildInputs = with pkgs; [ parallel findutils libwebp coreutils ];
  name = "nginx-static";
  src = ./.;
  dontUnpack = true;
  buildPhase = ''
    function genb64ImgTag() {
      (
        echo -n '<img src="data:image/webp;base64,'
        cwebp -z 8 -q 95 "$1" -o - | base64 -w0
        echo -n '"/>'
      ) > "$2"
    }
    export -f genb64ImgTag
    find $src/error-imgs -type f -iname '*.png' \
      | parallel --jobs $NIX_BUILD_CORES genb64ImgTag '{}' '{/.}.html'

    cp $src/error.html ./
  '';
  installPhase = ''
    mkdir -p $out
    cp *.html $out/
    cp $src/*.ico $out/
  '';
}