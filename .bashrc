#
# ~/.bashrc
#

## if not running interactively, don't do anything
[[ $- != *i* ]] && return

## don't put duplicate lines or lines starting with space in the history.
HISTCONTROL=ignoreboth

## history size
HISTSIZE=10000
HISTFILESIZE=20000

## alias
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias sudo='sudo -E'
alias gs='git status'
alias ga='git add'
alias gc='git commit'

## prompt
PS1='\[\e[0;34m\][\[\e[0m\]\u\[\e[0;34m\]@\[\e[0m\]\h\[\e[0;34m\]: \[\e[0;1;31m\]\W\[\e[0;34m\]]\[\e[0m\]$ \[\e[0m\]'
