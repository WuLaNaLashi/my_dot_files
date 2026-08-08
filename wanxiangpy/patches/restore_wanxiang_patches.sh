#!/usr/bin/env bash
# 万象方案补丁恢复脚本
# 用途：更新万象方案后，重新应用自定义补丁和恢复颜文字数据文件
# 用法：bash custom/patches/restore_wanxiang_patches.sh
set -uo pipefail

# 定位 rime 用户目录（脚本所在目录往上数 2 层 = rime user data dir）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RIME_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
PATCH_DIR="$SCRIPT_DIR"
BACKUP_DIR="$SCRIPT_DIR/kaomoji_backup"

# 颜色输出
red()    { printf '\033[31m%s\033[0m\n' "$*"; }
green()  { printf '\033[32m%s\033[0m\n' "$*"; }
yellow() { printf '\033[33m%s\033[0m\n' "$*"; }
info()   { printf '%s\n' "$*"; }

echo ""
info "════════════════════════════════════════════"
info " 万象方案补丁恢复"
info " RIME_DIR: $RIME_DIR"
info "════════════════════════════════════════════"
echo ""

# ── 步骤 1：打 lua 补丁 ──
info "【1/3】应用 lua 补丁"

apply_patch() {
    local patch_file="$1"
    local target_file="$2"
    local patch_name="$3"

    if [ ! -f "$target_file" ]; then
        red "  ✗ $patch_name: 目标文件不存在 $target_file"
        red "    可能新版改了文件结构，请手动检查"
        return 1
    fi

    # 先用 --check 检测能否干净应用（目标是否为未打补丁的原版）
    if patch --dry-run -p0 -d "$RIME_DIR" < "$patch_file" >/dev/null 2>&1; then
        # 可以打 → 原版，执行
        if patch -p0 -d "$RIME_DIR" < "$patch_file"; then
            green "  ✓ $patch_name: 补丁已应用"
            return 0
        else
            red "  ✗ $patch_name: 补丁应用失败"
            return 1
        fi
    else
        # dry-run 失败：要么已打过，要么代码变化太大
        # 检测是否已经打过（grep 特征字符串）
        local marker
        case "$patch_name" in
            *"Config_fix"*) marker="用 pcall 保护" ;;
            *"kaomoji"*)    marker="data_kaomoji" ;;
            *)              marker="" ;;
        esac
        if [ -n "$marker" ] && grep -q "$marker" "$target_file" 2>/dev/null; then
            green "  ✓ $patch_name: 已应用过，跳过"
            return 0
        else
            yellow "  ! $patch_name: 无法应用（新版代码已变动）"
            yellow "    目标文件: $target_file"
            yellow "    请手动对比补丁内容与新版代码重新适配"
            yellow "    补丁内容: $patch_file"
            return 1
        fi
    fi
}

fail_count=0

apply_patch "$PATCH_DIR/super_replacer_Config_fix.patch" \
            "$RIME_DIR/lua/wanxiang/super_replacer.lua" \
            "super_replacer Config_fix" || fail_count=$((fail_count+1))

apply_patch "$PATCH_DIR/super_symbols_kaomoji.patch" \
            "$RIME_DIR/lua/wanxiang/super_symbols.lua" \
            "super_symbols kaomoji" || fail_count=$((fail_count+1))

echo ""

# ── 步骤 2：恢复颜文字数据文件 ──
info "【2/3】恢复颜文字数据文件"

for data_file in kaomoji.txt kaomoji_replacer.txt; do
    src="$BACKUP_DIR/$data_file"
    dst="$RIME_DIR/lua/data/$data_file"
    if [ ! -f "$src" ]; then
        red "  ✗ 备份文件不存在: $src"
        fail_count=$((fail_count+1))
        continue
    fi
    if [ -f "$dst" ]; then
        if diff -q "$src" "$dst" >/dev/null 2>&1; then
            green "  ✓ $data_file: 已存在且一致，跳过"
            continue
        else
            yellow "  ! $data_file: 已存在但内容不同，备份当前版本后覆盖"
            cp "$dst" "$dst.bak.$(date +%Y%m%d%H%M%S)"
        fi
    fi
    if cp "$src" "$dst"; then
        green "  ✓ $data_file: 已恢复"
    else
        red "  ✗ $data_file: 恢复失败"
        fail_count=$((fail_count+1))
    fi
done

echo ""

# ── 步骤 3：提示重新部署 ──
info "【3/3】检查 wanxiang.custom.yaml 配置"

custom_file="$RIME_DIR/wanxiang.custom.yaml"
if grep -q "kaomoji" "$custom_file" 2>/dev/null && grep -q "_kk_" "$custom_file" 2>/dev/null; then
    green "  ✓ wanxiang.custom.yaml 颜文字配置在位（此文件不会被方案更新覆盖）"
else
    red "  ✗ wanxiang.custom.yaml 缺少颜文字配置！"
    red "    custom 文件应不被覆盖，若丢失需从备份恢复"
    fail_count=$((fail_count+1))
fi

echo ""
echo "════════════════════════════════════════════"
if [ "$fail_count" -eq 0 ]; then
    green "全部完成，$fail_count 个失败"
    echo ""
    yellow "下一步：重新部署 fcitx5 让补丁生效"
    info "  命令: fcitx5 -r &"
    info "  或:   fcitx5 托盘菜单 → 重新部署"
    echo ""
    info "可选：删除旧的 replacer.userdb 强制重建 emoji 数据库"
    info "  rm -rf $RIME_DIR/replacer.userdb"
else
    red "完成，但有 $fail_count 个失败，请按上方提示处理"
fi
echo "════════════════════════════════════════════"
echo ""
