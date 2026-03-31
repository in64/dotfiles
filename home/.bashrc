#!/usr/bin/env bash
# 由交互式 Bash Shell 加载.

# 非交互式 Shell 直接退出.
case $- in
    *i*) ;;
      *) return;;
esac

# 定义仓库根目录.
export DOTFILES_DIR
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"/.. && pwd)"

# 加载模块化脚本.
source "${DOTFILES_DIR}/lib/exports.sh"
source "${DOTFILES_DIR}/lib/path.sh"
source "${DOTFILES_DIR}/lib/aliases.sh"
source "${DOTFILES_DIR}/lib/functions.sh"

# 历史记录设置
export HISTCONTROL=ignoreboth:erasedups
export HISTSIZE=30000
export HISTFILESIZE=20000
export HISTTIMEFORMAT="%F %T "
shopt -s histappend
PROMPT_COMMAND="history -a; ${PROMPT_COMMAND:-}"

# 如果 starship 已安装, 则初始化.
if command -v starship &> /dev/null; then
  eval "$(starship init bash)"
fi

# 如果 zoxide 已安装, 则初始化.
if command -v zoxide &> /dev/null; then
  eval "$(zoxide init bash)"
fi

# 如果 fzf 已安装, 则初始化.
if command -v fzf &> /dev/null; then
  eval "$(fzf --bash)"
fi
