#!/bin/bash

# Git 仓库路径（可以根据自身情况修改）
DOTFILES_REPO="$HOME/dotfiles"

# 克隆 Git 仓库（如果尚未克隆）
if [ ! -d "$DOTFILES_REPO" ]; then
    git clone <your_dotfiles_repo_url> "$DOTFILES_REPO"  # 替换为你的仓库 URL
fi

# 创建软链接函数
create_symlink() {
    local source_file="$1"
    local target_file="$2"

    # 检查目标文件是否已经存在
    if [ -e "$target_file" ] || [ -L "$target_file" ]; then
        # 如果目标文件是符号链接，则先删除
        if [ -L "$target_file" ]; then
            rm "$target_file"
            echo "Deleted existing symlink: $target_file"
        # 如果目标文件是普通文件，则提示用户是否备份
        else
            read -p "$target_file already exists. Do you want to backup and replace it? (y/n) " answer
            if [ "$answer" = "y" ]; then
                mv "$target_file" "$target_file.backup"
                echo "Backed up $target_file to $target_file.backup"
            else
                echo "Skipping $source_file -> $target_file"
                return
            fi
        fi
    fi

    # 创建软链接
    ln -s "$source_file" "$target_file"
    echo "Created symlink: $target_file -> $source_file"
}

# 应用常用软件配置
# 以下是一些常见软件配置的示例，你可以根据实际情况进行修改和扩展
create_symlink "$DOTFILES_REPO/.bashrc" "$HOME/.bashrc"
create_symlink "$DOTFILES_REPO/.vimrc" "$HOME/.vimrc"
create_symlink "$DOTFILES_REPO/.tmux.conf" "$HOME/.tmux.conf"
create_symlink "$DOTFILES_REPO/.gitconfig" "$HOME/.gitconfig"
create_symlink "$DOTFILES_REPO/.config/nvim/init.vim" "$HOME/.config/nvim/init.vim"
create_symlink "$DOTFILES_REPO/.config/alacritty/alacritty.yml" "$HOME/.config/alacritty/alacritty.yml"

echo "Configuration applied successfully!"
