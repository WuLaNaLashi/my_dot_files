# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi
# hxg for git branch
parse_git_branch() {
     git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\] \[\033[01;34m\]\w\[\033[01;34m\]$(parse_git_branch)\[\033[00m\] $ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h \w\$(parse_git_branch)\ $ '
fi
#if [ "$color_prompt" = yes ]; then
#    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
#else
#    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
#fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

#hxg .NET
export PATH=$PATH:$HOME/.dotnet:$HOME/.dotnet/tools

# bash parameter completion for the dotnet CLI

function _dotnet_bash_complete()
{
  local cur="${COMP_WORDS[COMP_CWORD]}" IFS=$'\n'
  local candidates

  read -d '' -ra candidates < <(dotnet complete --position "${COMP_POINT}" "${COMP_LINE}" 2>/dev/null)

  read -d '' -ra COMPREPLY < <(compgen -W "${candidates[*]:-}" -- "$cur")
}

complete -f -F _dotnet_bash_complete dotnet


# hxg QT
export PATH=/home/hanxiao/QT/5.9.2/gcc_64/bin:$PATH

# hxg alias

alias gcm='git commit -m'

# hxg for python v_
# export PATH=/home/hanxiao/.local/bin:$PATH
# source /home/hanxiao/V_Python/py_v/bin/activate

# hxg build for arm
# codesync for sync code from git source to arm_src
# b for build only
# bc for synccode & build
# alias codesync='bash ~/Bash_dir/sync_code.sh'
# alias b='cd ~/wspace/aiforcetech_arm_n/src/Decision/decision_controller && bash ~/Bash_dir/build_for_arm.sh'
# alias cb='codesync && b'
# alias p='source ~/Bash_dir/move_exe.sh'
# alias cdc="source ~/Bash_dir/change_directory.sh"
# alias armcmake="cmake -DCMAKE_TOOLCHAIN_FILE=/home/hanxiao/wspace/aiforcetech_arm_n/arm-toolchain.cmake"
# alias logcalc='python3 ~/Bash_dir/log_calc.py'
# alias routeplot='python3 ~/Bash_dir/route_plot.py'
# alias routegif='python3 ~/Bash_dir/route_gif.py'
# alias routesplit='python3 ~/Bash_dir/route_split.py'
# alias armb="bash ~/Bash_dir/build_for_arm.sh" 
# alias runmonitor="~/Bin/msg_monitor"

alias logplot='python3 ~/Bash_dir/log_plot.py'
alias logsplit='python3 ~/Bash_dir/log_split.py'
alias zo="~/Zotero_linux-x86_64/zotero"
alias groot="~/Bin/Groot2/bin/groot2"
alias cp-debain="bash ~/Bash_dir/debain_cp_arm.sh"
alias checkupdate="spy && python ~/Bash_dir/remote_file_checker.py"
alias mc_logger="spy && python /home/hanxiao/Bash_dir/mc_log_analyzer.py"
alias remote_deloy="bash ~/Bash_dir/remote_sync_deploy.sh"
alias make_config_backup="bash /home/hanxiao/Bash_dir/make_remote_config_backup.sh"
alias c="clear"


# hxg MATLAB
export PATH=/home/hanxiao/Matlab/bin:$PATH


ulimit -c unlimited

export PATH=/home/hanxiao/wspace/valgrind/bin:$PATH

# ~/.bashrc

alias runmonitorwq="bash ~/Bash_dir/runmonitor.sh"
alias runmonitor="bash ~/Bash_dir/runmonitor.sh"

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
. "$HOME/.cargo/env"
