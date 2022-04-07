sourceDir: { lib, ... }:
with builtins;
with lib;
let
  listFiles = dir: map (f: dir + "/${f}") (
    attrNames (filterAttrs (k: v: v == "regular") (readDir dir))
  );
in
{
  imports = (
    (listFiles ./_common/fragments)
    ++ (listFiles (sourceDir + "/fragments"))
  );
}
