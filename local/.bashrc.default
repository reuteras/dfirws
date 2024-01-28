# shellcheck shell=bash
if [[ -e /etc/profile.d/bash_completion.sh ]]; then
    # shellcheck disable=SC1091
    . /etc/profile.d/bash_completion.sh
fi

export PATH="$PATH:/c/venv/Scripts"
export PS1="\[\033]0;$TITLEPREFIX:$PWD\007\] \[\033[33m\]\w\[\033[36m\]\`__git_ps1\`\[\033[0m\]$ "
export HISTFILESIZE=99999
export HISTSIZE=99999
set bell-style none
set echo-control-characters off
