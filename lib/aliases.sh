# Shell 别名定义

# --- Git ---
alias g='git'
alias ga='git add'
alias gaa='git add --all'
alias gap='git add -p'
alias gb='git branch'
alias gc='git commit -v'
alias gca='git commit -v -a'
alias gcam='git commit -v -a -m'
alias gcm='git commit -m'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gd='git diff'
alias gds='git diff --staged'
alias glog='git log --graph --pretty=format:"%C(yellow)%h%C(reset) -%C(auto)%d%C(reset) %s %C(green)(%cr) %C(bold blue)<%an>%C(reset)" --all'
alias gp='git push'
alias gpf='git push --force-with-lease'
alias gpl='git pull --rebase'
alias gs='git status'

# --- 文件系统 ---
# 如果 eza 存在则使用, 否则回退到 ls
if command -v eza &>/dev/null; then
  alias ls='eza'
  alias ll='eza -l'
  alias la='eza -la'
else
  alias ls='ls --color=auto'
  alias ll='ls -l'
  alias la='ls -la'
fi

# --- 通用 ---
alias cd='cd -P'
alias vi='vim'
alias tmux='tmux -2'
alias grep='grep --color=auto -I'
alias pkill='pkill -u $USER'
alias pw='pwd'

# 如果 bat 存在则使用, 否则回退到 cat
if command -v bat &>/dev/null; then
  alias cat='bat'
# 在某些系统上, bat 的命令是 batcat
elif command -v batcat &>/dev/null; then
  alias cat='batcat'
fi
