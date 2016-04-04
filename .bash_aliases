shopt -s expand_aliases

# ls alias for color-mode
alias ll='ls -l'
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    #alias grep='grep --color=auto'
    #alias fgrep='fgrep --color=auto'
    #alias egrep='egrep --color=auto'
fi

# up 'n' folders
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

# refresh shell
alias reload='source ~/.bashrc'

# Qt
alias qtexport64='export PATH=/opt/Qt/5.3/gcc_64/bin:$PATH'
alias qtexport32='export PATH=/opt/Qt/5.3/gcc/bin:$PATH'
alias qmake64='/home/opt/Qt/5.5/gcc_64/bin/qmake -spec linux-g++-64'
alias qmake32='/opt/Qt/5.3/gcc/bin/qmake -spec linux-g++-32'

# Python
alias pip='python3 -m pip'

# Git
alias git='LANG=en_GB git'
alias g='git st -sb'
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# SVN
alias svnadd="svn st | grep ? | tr -s ' ' | sed 's/^..//g' | sed 's/ /\\\\ /g' | xargs svn add"

# TMUX
if [ -f /usr/share/bash-completion/tmuxcompletion.bash ]; then
        source /usr/share/bash-completion/tmuxcompletion.bash
fi

# SSH
alias addtrialogkey='ssh-add ~/.ssh/id_rsa_trialog'

# History
alias phgrep='cat ~/.persistent_history|grep --color'
alias hgrep='history|grep --color'
HISTCONTROL=ignoreboth
shopt -s histappend
HISTSIZE=5000
HISTFILESIZE=10000

# Qompoter
alias syncqomp=/media/data/qompoter/sync.sh


