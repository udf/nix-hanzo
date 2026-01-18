{ lib, pkgs, ... }:
with lib;
let
  dirColorsConf = import ./dircolors.nix { inherit lib pkgs; };
in
''
${builtins.readFile ./zshrc}

# dircolors (from ${dirColorsConf})
${builtins.readFile "${dirColorsConf}/dircolors-sh"}

# right prompt
export RPROMPT='$(${lib.getExe pkgs.gitprompt-rs} zsh)'

# syntax highlighting plugin
source "${pkgs.zsh-fast-syntax-highlighting}/share/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh"

# fzf + custom commands
export FZF_DEFAULT_OPTS="--color=dark"
function fzf() { ${pkgs.fzf}/bin/fzf "$@" }
source "${pkgs.fzf}/share/fzf/key-bindings.zsh"
source "${pkgs.fzf}/share/fzf/completion.zsh"

${builtins.readFile ./fzf-widgets.zsh}
''