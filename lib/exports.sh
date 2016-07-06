#!/usr/bin/env bash
# 设置通用环境变量.

# --- 编辑器 ---
# 为命令行工具设置默认编辑器.
export EDITOR='vim'
export VISUAL='vim'

# --- 区域与编码 ---
# 设置标准 UTF-8 区域, 防止乱码.
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# --- 分页器 ---
# 为 'less' 和 'man' 添加颜色.
export LESS_TERMCAP_mb=$'\e[1;31m'
export LESS_TERMCAP_md=$'\e[1;33m'
export LESS_TERMCAP_so=$'\e[01;44;37m'
export LESS_TERMCAP_us=$'\e[01;37m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_ue=$'\e[0m'
export GROFF_NO_SGR=1