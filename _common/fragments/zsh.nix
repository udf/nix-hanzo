{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    fzf
  ];

  users.defaultUserShell = pkgs.zsh;

  programs.zsh = {
    enable = true;
    histSize = 10000000;
    enableGlobalCompInit = true;
    setOptions = [
      # history
      "appendhistory"
      "histfindnodups"
      "histignoredups"
      "histreduceblanks"
      "INC_APPEND_HISTORY"
      # cd on dir name
      "autocd"
      # error on failed glob match
      "nomatch"
      # report background job status immediately
      "notify"
      # prompt
      "promptsubst"
    ];
    promptInit = ''
      function do_prompt() {
        uid=$(id -u)
        fg=green
        [ $uid = 0 ] && fg=red
        echo -n "%F{magenta}%B[%b%F{red}%(?..%? )%B%F{$fg}"
        [ $uid != 1000 ] && echo -n '%n@'
        echo -n "%m %b%F{magenta}%~%B]%# %f%b"
      }
      export PROMPT='$(do_prompt)'
    '';
    interactiveShellInit = ''
      # escape key codes
      bindkey -e
      bindkey "\e[H" beginning-of-line       # HOME
      bindkey "\e[F" end-of-line             # END
      bindkey "\e[3~" delete-char            # DELETE
      bindkey "\e[2~" quoted-insert          # INSERT
      # keypad enter
      bindkey -s "^[OM" "^M"

      export WORDCHARS=
      bindkey "\e[1;5C" emacs-forward-word
      bindkey "\e[1;5D" emacs-backward-word
      bindkey "^H" vi-backward-kill-word

      # make time builtin look like bash
      TIMEFMT=$'\nreal\t%*Es\nuser\t%*Us\nsys\t%*Ss'

      # Issue a BELL when a command is done
      function precmd() {
          echo -ne '\a'
      }

      # completion
      zstyle ':completion:*' menu select
      zmodload zsh/complist
      # Include hidden files
      _comp_options+=(globdots)

      # shift+tab to go backwards in completions
      bindkey -M menuselect '^[[Z' reverse-menu-complete

      # Edit line in editor with alt-e:
      autoload edit-command-line; zle -N edit-command-line
      bindkey '^[e' edit-command-line

      # Add Python package binaries to path
      export PATH="$HOME/.local/bin:$PATH"

      # syntax highlighting plugin
      source "${pkgs.zsh-fast-syntax-highlighting}/share/zsh/site-functions/fast-syntax-highlighting.plugin.zsh"

      # fzf
      if [ -n "''${commands[fzf-share]}" ]; then
        source "$(fzf-share)/key-bindings.zsh"
        source "$(fzf-share)/completion.zsh"
      else
        eval "$(fzf --zsh)"
      fi

      source ${./fzf-dir-widget.zsh}
      source ${./fzf-reload-history-widget.zsh}
    '';
  };
}
