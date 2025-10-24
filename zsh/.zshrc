# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="random"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(zsh-autosuggestions  z)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"


alias gcm="git commit -m"

# hxg MATLAB
# export PATH=/home/hanxiao/Matlab/bin:$PATH

# dotnet tools 
export PATH=/home/hanxiao/.dotnet/tools:$PATH

# hxg python venv ---> HXGPython
# active
alias spy="source /home/hanxiao/Python/HXGPyhton/bin/activate"
# deactive



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

ulimit -c unlimited


# zsh-autosuggestions config
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#ff00ff,bg=yan,bold,underline"
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_COMPLETION_TRIGGER='`'
# export FZF_DEFAULT_COMMAND='fdfind --type file --follow --hidden --exclude .git --exclude .venv --exclude .cache --color=always'
# export FZF_DEFAULT_COMMAND='fd --type f --strip-cwd-prefix --hidden --follow --exclude .git'
export FZF_DEFAULT_COMMAND='fdfind --type f --follow --strip-cwd-prefix --color=always'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_OPTS="--ansi"

# https://github.com/Waylon-cn/docker_images_sync
# docker images sync by aliyun & github actions 
export PATH=$PATH:/home/hanxiao/Bin/docker_images_sync/cmd

# nodejs
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# claude code env
# export ANTHROPIC_AUTH_TOKEN=sk-a71512ef7df84ba69bfbbd484005083f
# export ANTHROPIC_BASE_URL=https://api.deepseek.com/anthropic
# export ANTHROPIC_SMALL_FAST_MODEL=deepseek-chat
# export ANTHROPIC_MODEL=deepseek-chat
export API_TIMEOUT_MS=600000
export ANTHROPIC_BASE_URL=https://open.bigmodel.cn/api/anthropic
export ANTHROPIC_AUTH_TOKEN=4afd2855388e45a5aad6dccf378d48d2.VR3Xl0npeRXx9sKo
export ANTHROPIC_MODEL=glm-4.5v
