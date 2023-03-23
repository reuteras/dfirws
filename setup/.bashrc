export PS1="\[\033]0;$TITLEPREFIX:$PWD\007\] \[\033[33m\]\w\[\033[36m\]`__git_ps1`\[\033[0m\]$ "

if [[ -e /c/venv/Scripts/activate ]]; then
    . /c/venv/Scripts/activate
fi

if [[ -e /etc/profile.d/bash_completion.sh ]]; then
    . /etc/profile.d/bash_completion.sh
fi

export PATH="$PATH:/c/venv/Scripts"