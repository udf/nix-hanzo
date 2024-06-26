# CTRL-R - Reload history before running regular fzf CTRL-r
reload-fzf-history-widget() {
  fc -RI
  zle fzf-history-widget
}
zle     -N            reload-fzf-history-widget
bindkey -M emacs '^R' reload-fzf-history-widget
bindkey -M vicmd '^R' reload-fzf-history-widget
bindkey -M viins '^R' reload-fzf-history-widget