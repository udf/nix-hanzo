{ lib, pkgs, ... }:
let
  zshrc = (import ./zsh/zshrc.nix) { inherit lib pkgs; };
in
{
  users.defaultUserShell = pkgs.zsh;

  programs.zsh = {
    enable = true;
    setOptions = [];
    promptInit = "";
    enableLsColors = false;
    shellAliases = {};
    interactiveShellInit = zshrc;
  };
}
