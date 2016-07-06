#!/usr/bin/env bash
# 管理 PATH 环境变量, 避免重复添加.

# 函数: 将路径添加到 PATH 的开头 (如果它不存在).
# 用法: prepend_to_path_if_not_exists "/path/to/add"
prepend_to_path_if_not_exists() {
    if [[ ":$PATH:" != *":$1:"* ]]; then
        export PATH="$1:$PATH"
    fi
}

# 在 macOS 上, 优先使用 Homebrew 的路径.
if [[ "$(uname -s)" == "Darwin" ]] && [[ -d "/opt/homebrew/bin" ]]; then
    prepend_to_path_if_not_exists "/opt/homebrew/bin"
fi

# 添加用户本地的 bin 目录.
prepend_to_path_if_not_exists "$HOME/.local/bin"

# 清理函数, 使其在 sourcing 后不可用.
unset -f prepend_to_path_if_not_exists
