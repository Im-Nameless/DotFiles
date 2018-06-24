#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
PS1='[\u@\h \W]\$ '

export GOPATH=/home/noname/go:/home/noname/Projects/Go

neofetch --w3m Pictures/Backgrounds/animearchlogo.png
