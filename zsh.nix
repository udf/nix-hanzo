{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    fzf
  ];

  programs.zsh = {
    enable = true;
    histSize = 10000000;
    enableGlobalCompInit = true;
    setOptions = [
      # history
      "appendhistory" "histfindnodups" "histignoredups" "histreduceblanks" "INC_APPEND_HISTORY"
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
        echo -n '%B%F{magenta}[%b%F{red}%(?..%? )%B%F{green}%m %b%F{magenta}%~%B]%# %f%b'
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

      # completion
      zstyle ':completion:*' menu select
      zmodload zsh/complist
      # Include hidden files
      _comp_options+=(globdots)

      # Edit line in editor with alt-e:
      autoload edit-command-line; zle -N edit-command-line
      bindkey '^[e' edit-command-line

      # syntax highlighting plugin
      source "${pkgs.zsh-fast-syntax-highlighting}/share/zsh/site-functions/fast-syntax-highlighting.plugin.zsh"

      # fzf
      source "$(fzf-share)/key-bindings.zsh"
      source "$(fzf-share)/completion.zsh"

      # CTRL-Y - Paste the selected directory path(s) into the command line
      fzf-dir-widget() {
        OLD_CMD="''${FZF_CTRL_T_COMMAND}"
        FZF_CTRL_T_COMMAND="find -L . -mindepth 1 \\( -path '*/\\.*' -o -fstype 'sysfs' -o -fstype 'devfs' -o -fstype 'devtmpfs' -o -fstype 'proc' \\) -prune \
          -o -type d -print 2> /dev/null | cut -b3-"
        LBUFFER="''${LBUFFER}$(__fsel)"
        FZF_CTRL_T_COMMAND="''${OLD_CMD}"
        local ret=$?
        zle reset-prompt
        return $ret
      }
      zle     -N   fzf-dir-widget
      bindkey '^Y' fzf-dir-widget
    '';
  };
}
