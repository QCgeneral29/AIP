#
# ~/.bashrc
#

# For Japanese Input Manager
GTK_IM_MODULE=fcitx
QT_IM_MODULE=fcitx
XMODIFIERS=@im=fcitx
GLFW_IM_MODULE=ibus

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto -I' # Ignore binary files
PS1='[\u@\h \W]\$ '
