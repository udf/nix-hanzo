{ lib, pkgs }:
with lib;
with builtins;
(path:
  let
    shellEscape = s: (replaceChars [ "\\" ] [ "\\\\" ] s);
    scriptName = replaceChars [ "\\" "@" ] [ "-" "_" ] (shellEscape (baseNameOf path));
    out = pkgs.writeTextFile {
      name = "script-${scriptName}";
      executable = true;
      destination = "/bin/${scriptName}";
      text = readFile path;
    };
  in
  "${out}/bin/${scriptName}"
)
