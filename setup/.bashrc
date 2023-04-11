# shellcheck shell=bash
if [[ -e /c/venv/default/Scripts/activate ]]; then
    # shellcheck disable=SC1091
    . /c/venv/default/Scripts/activate
fi

if [[ -e /etc/profile.d/bash_completion.sh ]]; then
    # shellcheck disable=SC1091
    . /etc/profile.d/bash_completion.sh
fi

if [[ ! -e ~/.gitconfig ]]; then
    for dir in /c/git/*; do
        basename=$(basename "$dir")
        git config --global --add safe.directory "C:/git/$basename";
    done
fi

export PATH="$PATH:/c/venv/Scripts"
export PS1="\[\033]0;$TITLEPREFIX:$PWD\007\] \[\033[33m\]\w\[\033[36m\]\`__git_ps1\`\[\033[0m\]$ "
