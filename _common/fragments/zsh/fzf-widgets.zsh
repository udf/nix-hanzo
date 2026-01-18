# CTRL-Y - Paste the selected directory path(s) into the command line
__fzf_select_dir() {
  setopt localoptions pipefail no_aliases 2> /dev/null
  local item
  FZF_DEFAULT_COMMAND=${FZF_CTRL_T_COMMAND:-} \
  FZF_DEFAULT_OPTS=$(__fzf_defaults "--reverse --walker=dir,follow,hidden --scheme=path" "${FZF_CTRL_T_OPTS-} -m") \
  FZF_DEFAULT_OPTS_FILE='' $(__fzfcmd) "$@" < /dev/tty | while read item; do
    echo -n "${(q)item} "
  done
  local ret=$?
  echo
  return $ret
}

fzf-dir-widget() {
  LBUFFER="${LBUFFER}$(__fzf_select_dir)"
  local ret=$?
  zle reset-prompt
  return $ret
}
zle     -N   fzf-dir-widget
bindkey '^Y' fzf-dir-widget

reload-fzf-history-widget() {
  fc -RI
  zle fzf-history-widget
}
zle     -N            reload-fzf-history-widget
bindkey -M emacs '^R' reload-fzf-history-widget
bindkey -M vicmd '^R' reload-fzf-history-widget
bindkey -M viins '^R' reload-fzf-history-widget