#!/usr/bin/env bash
# 通用 Shell 函数.

# 创建目录并立即进入.
# 用法: mkcd <目录名>
mkcd() {
    if [[ -z "${1-}" ]]; then
        echo "用法: mkcd <目录名>" >&2
        return 1
    fi
    mkdir -p "$1" && cd "$1"
}
