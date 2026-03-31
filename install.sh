#!/usr/bin/env bash

set -euo pipefail

# 获取脚本所在目录
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
HOME=${HOME:=$(eval echo ~)}
PREFIX_PROXY=""

# 通用辅助函数
# 日志函数
info() { printf " [34m➜  %s[0m\n" "$*"; }
warn() { printf " [33m➜  %s[0m\n" "$*"; }
error() { printf " [31m✖  %s[0m\n" "$*" >&2; exit 1; }

# 检查是否在中国大陆,并设置全局代理前缀
is_china=$(curl -fsSL -m 5 https://ip.seiya.dev/country 2>/dev/null | grep -Eq '^(CN)$' && echo 1 || echo 0)

if [[ "$is_china" -eq 1 ]]; then
    info "📍 检测到在中国, 将为部分网络请求启用代理和镜像."
    PREFIX_PROXY="https://spu.seiya.dev/"
    # 为 Homebrew 设置镜像,加速软件包下载
    export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.ustc.edu.cn/homebrew-bottles"
fi

# 根据工具名和系统架构, 获取对应的架构关键字
get_arch_name() {
    local tool=${1:-default}
    local arch=$(uname -m)
    if [[ "$arch" == "aarch64" ]]; then
        case "$tool" in
            fzf|rage) echo "arm64" ;;
            *)        echo "aarch64" ;;
        esac
    elif [[ "$arch" == "x86_64" ]]; then
        case "$tool" in
            fzf|fastfetch) echo "amd64" ;;
            *)             echo "x86_64" ;;
        esac
    fi
}

# 从 GitHub Release 下载并安装二进制文件.
# 用法: install_from_github <命令名> <GitHub仓库> <资源关键词> [tar解压参数...]
install_from_github() {
    local cmd="$1"
    local repo="$2"
    local keyword="$3"
    shift 3
    local tar_args=($@)

    if command -v "$cmd" &>/dev/null; then
        info "✅ $cmd 已安装, 跳过."
        return
    fi

    info "🚀 正在安装 $cmd..."
    local url
    url=$(curl -fsL "${PREFIX_PROXY}https://api.github.com/repos/${repo}/releases/latest" | \
        jq -r ".assets[] | select(.name | test(\"${keyword}\")) | .browser_download_url" | \
        head -n 1)

    if [[ -z "$url" ]]; then
        error "无法为 ${repo} 找到匹配 \"${keyword}\" 的资源."
        return
    fi

    curl -fsL "${PREFIX_PROXY}${url}" | tar -xzf - -C "$HOME/.local/bin/" "${tar_args[@]}"
    info "✅ $cmd 安装成功."
}


# 主安装流程
info "📁 Dotfiles 仓库位于: $DOTFILES_DIR"
info "🚀 开始安装 dotfiles..."

# 1. 根据操作系统, 运行特定的安装脚本
case "$(uname -s)" in
    Darwin)
        # --- macOS 安装逻辑 ---
        info "🍎 检测到 macOS, 运行特定于 macOS 的安装脚本..."

        # 如果未安装 Homebrew, 则自动安装
        if ! command -v brew &>/dev/null; then
            info "🍺 未找到 Homebrew, 正在安装..."
            /bin/bash -c "$(curl -fsSL ${PREFIX_PROXY}https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        else
            info "🍺 Homebrew 已安装, 跳过安装."
        fi

        info "📦 正在通过 Brewfile 安装/更新软件包..."
        brew bundle --file=- <<-EOF
# 核心工具
brew "git"
brew "delta"
brew "rage"
brew "vim"
brew "coreutils"
brew "tmux"
brew "tig"

# 推荐工具
brew "bat"     # 带语法高亮的 cat
brew "eza"     # ls 的现代替代品
brew "fzf"     # 命令行模糊搜索
brew "ripgrep" # 高性能 grep
brew "zoxide"  # 更智能的 cd
brew "universal-ctags" # ctags
brew "fastfetch"
EOF
        ;;

    Linux)
        # --- Linux 安装逻辑 ---
        info "🐀 检测到 Linux, 运行特定于 Linux 的安装脚本..."
        mkdir -p "$HOME/.local/bin"

        # 检测包管理器
        if command -v apt-get &>/dev/null; then
            info "📦 使用 apt 作为包管理器 (Debian/Ubuntu)."

            APT_PACKAGES=("build-essential" "curl" "file" "git" "jq" "vim" "tmux" "tig" "ripgrep" "zoxide" "universal-ctags")

            sudo apt-get update -y
            info "🔧 正在安装依赖: ${APT_PACKAGES[*]}"
            sudo apt-get install -y --no-install-recommends "${APT_PACKAGES[@]}"
        else
            error "不支持的 Linux 包管理器, 请手动安装软件包."
        fi

        # 使用新函数安装二进制工具
        info "☁️ 正在从 GitHub Releases 下载并安装最新的二进制文件..."
        install_from_github "rage" "str4d/rage" "v[0-9.]*-$(get_arch_name rage)-linux.tar.gz$" --strip-components=1 --wildcards "*/rage" "*/rage-keygen"
        install_from_github "delta" "dandavison/delta" "$(get_arch_name)-unknown-linux-gnu.tar.gz$" --strip-components=1 --wildcards '*/delta'
        install_from_github "eza" "eza-community/eza" "eza.*$(get_arch_name)-unknown-linux-gnu.tar.gz$" "./eza"
        install_from_github "zoxide" "ajeetdsouza/zoxide" "$(get_arch_name)-unknown-linux-musl.tar.gz$" "zoxide"
        install_from_github "bat" "sharkdp/bat" "$(get_arch_name)-unknown-linux-musl.tar.gz$" --strip-components=1 --wildcards "*/bat"
        install_from_github "fzf" "junegunn/fzf" "linux_$(get_arch_name fzf).tar.gz$" "fzf"
        install_from_github "fastfetch" "fastfetch-cli/fastfetch" "fastfetch-linux-$(get_arch_name fastfetch).tar.gz$" --strip-components=3 "fastfetch-linux-$(get_arch_name fastfetch)/usr/bin/fastfetch"

        info "✅ Linux 特定软件包安装完成."
        ;;

    *)
        error "不支持的操作系统: $(uname -s)"
        ;;
esac

# 2. 创建配置文件链接
info "🔗 正在创建配置文件的链接..."

# 特殊处理: 向 ~/.bashrc 追加 source 命令
DOTFILES_BASHRC="${DOTFILES_DIR}/home/.bashrc"
SYSTEM_BASHRC="${HOME}/.bashrc"
SOURCE_CMD="source '${DOTFILES_BASHRC}'"

touch "${SYSTEM_BASHRC}"

if ! grep -qF "${SOURCE_CMD}" "${SYSTEM_BASHRC}"; then
    info "✒️ 正在向 ${SYSTEM_BASHRC} 添加 dotfiles loader..."
    printf "\n# 加载自定义 dotfiles\n%s\n" "${SOURCE_CMD}" >> "${SYSTEM_BASHRC}"
else
    info "✅ Dotfiles loader 已存在于 ${SYSTEM_BASHRC}, 跳过."
fi

info "🔗 正在链接 'home' 目录下的文件..."

# 需要链接的文件列表
files_to_link=(
    ".gitconfig"
    ".gitignore_global"
    ".editorconfig"
    ".tigrc"
    ".tmux.conf"
    ".vimrc"
    ".config/htop/htoprc"
    ".config/fastfetch/config.jsonc"
    ".config/starship.toml"
)

for filename in "${files_to_link[@]}"; do
    src="${DOTFILES_DIR}/home/${filename}"
    dest="${HOME}/${filename}"

    mkdir -p "$(dirname "${dest}")"

    # 尝试创建硬链接, 如果失败则复制. -f 选项会覆盖已存在的目标文件.
    if ln -f "${src}" "${dest}" 2>/dev/null; then
        info "🔗 创建硬链接: ${dest}"
    else
        info "↗️ 硬链接失败, 转为复制文件: ${dest}"
        cp -fP "${src}" "${dest}"
    fi

done

# 3. 强制同步目录
info "⌛ 正在同步目录 (rsync)..."
dirs_to_sync=(
    ".vim/colors"
)

for dirname in "${dirs_to_sync[@]}"; do
    src="${DOTFILES_DIR}/home/${dirname}/"
    dest="${HOME}/${dirname}/"

    info "  同步中: ${src} -> ${dest}"
    mkdir -p "${dest}" && rsync -av --delete "${src}" "${dest}" >/dev/null
done


# 4. 如果在中国,为 Git 设置代理,加速 clone
if [[ "$is_china" -eq 1 ]]; then
    info "🔧 正在为 Git 配置代理..."
    git config --global url."${PREFIX_PROXY}github.com/".insteadOf "https://github.com/"
fi

# 5. 安装 Vim 插件
info "🔌 正在安装 Vim 插件..."
if [ ! -f "${HOME}/.vim/autoload/plug.vim" ]; then
    info "  正在下载 vim-plug 插件管理器..."
    curl -fsLo "${HOME}/.vim/autoload/plug.vim" --create-dirs \
        ${PREFIX_PROXY}https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi
info "  通过 vim-plug 安装或更新插件 (vim +PlugUpdate +qa)..."
vim +PlugUpdate +qa
info "  清理已删除的插件 (vim +PlugClean! +qa)..."
vim +PlugClean! +qa

info "🎉 安装完成!"
info "💡 请重启您的 Shell, 或运行 'source ~/.bashrc' 来使配置生效."
