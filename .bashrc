#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias sudo='sudo -E'
alias gs='git status'
alias ga='git add'
alias gc='git commit'

PS1='[\u@\h \W]\$ '
