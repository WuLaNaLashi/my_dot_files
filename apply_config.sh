#!/bin/bash

# 注意用户名： hanxiao

# Git 仓库路径（可以根据自身情况修改）
DOTFILES_REPO="$HOME/BackUp_config/some-config-backup"

# 克隆 Git 仓库（如果尚未克隆）
if [ ! -d "$DOTFILES_REPO" ]; then
    git clone https://gitee.com/hanxiao1994/some-config-backup.git "$DOTFILES_REPO"  # 替换为你的仓库 URL
fi

# 创建软链接函数
create_symlink() {
    local source_file="$1"
    local target_file="$2"

    # 检查目标文件是否已经存在
    if [ -e "$target_file" ] || [ -L "$target_file" ]; then
        # 如果目标文件是符号链接，则先删除 hxg 这里后续决定是否保留
        if [ -L "$target_file" ]; then
            rm "$target_file"
            echo "*** Deleted existing symlink: $target_file"
        # 如果目标文件是普通文件，则提示用户是否备份
        else
            read -p "$target_file already exists. Do you want to backup and replace it? (y/n) " answer
            if [ "$answer" = "y" ]; then
                mv "$target_file" "$target_file.backup"
                echo "*** Backed up $target_file to $target_file.backup"
            else
                echo "*** Skipping $source_file -> $target_file"
                return
            fi
        fi
    fi

    # 创建软链接
    ln -s "$source_file" "$target_file"
    echo "Created symlink: $target_file -> $source_file"
}

# 应用常用软件配置
echo "Applying common software configuration..."
# bash
echo ">>>>> Applying bash configuration..."
create_symlink "$DOTFILES_REPO/bash/.bashrc" "$HOME/.bashrc"
# vim
echo ">>>>> Applying vim configuration..."
create_symlink "$DOTFILES_REPO/vim/.vimrc" "$HOME/.vimrc"
# git
echo ">>>>> Applying git configuration..."
create_symlink "$DOTFILES_REPO/git/.gitconfig" "$HOME/.gitconfig"
# git ignore global
echo ">>>>> Applying git ignore global configuration..."
mkdir -p $HOME/GitIgnoreGlobal
create_symlink "$DOTFILES_REPO/git/ignore_global" "$HOME/GitIgnoreGlobal/ignore_global"
# zsh
echo ">>>>> Applying zsh configuration..."
create_symlink "$DOTFILES_REPO/zsh/.zshrc" "$HOME/.zshrc"
# ssh 某些远程主机使用明文密码登陆需要 sshpass
echo ">>>>> Applying ssh configuration..."
create_symlink "$DOTFILES_REPO/ssh/config" "$HOME/.ssh/config"
# terminator
echo ">>>>> Applying terminator configuration..."
create_symlink "$DOTFILES_REPO/terminator/config" "$HOME/.config/terminator/config"
#pip
echo ">>>>> Applying pip configuration..."
create_symlink "$DOTFILES_REPO/python/pip/pip.conf" "$HOME/.config/pip/pip.conf"
# uv
echo ">>>>> Applying uv configuration..."
create_symlink "$DOTFILES_REPO/python/uv/uv.toml" "$HOME/.config/uv/uv.toml"

# vscode 
echo ">>>>> Applying vscode configuration..."
create_symlink "$DOTFILES_REPO/vscode/settings.json" "$HOME/.config/Code/User/settings.json"

echo "Configuration applied successfully!"
