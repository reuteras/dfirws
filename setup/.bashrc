#!/bin/bash
PS1="\[\033]0;$TITLEPREFIX:$PWD\007\] \[\033[33m\]\w\[\033[36m\](__git_ps1)\[\033[0m\]$ "

export PS1

if [[ -e /c/venv/default/Scripts/activate ]]; then
    # shellcheck disable=SC1091
    . /c/venv/default/Scripts/activate
fi

if [[ -e /etc/profile.d/bash_completion.sh ]]; then
    # shellcheck disable=SC1091
    . /etc/profile.d/bash_completion.sh
fi

export PATH="$PATH:/c/venv/Scripts"