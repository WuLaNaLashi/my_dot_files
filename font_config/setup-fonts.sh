#!/usr/bin/env bash
# setup-fonts.sh — 一键配置 Linux 系统字体策略（Inter + MiSans + MiWith）
#
# 作者: hanxiao（由 ZCode 辅助生成）
# 适用: 任何 GNOME 桌面 + fontconfig + flatpak 的 Linux 发行版
# 测试: Ubuntu 24.04 / GNOME 46 / fontconfig 2.x
# =============================================================================
#
# 【这个脚本做什么】
#   1. 写入 fontconfig 用户配置（~/.config/fontconfig/conf.d/99-fonts-h.conf）
#      - sans-serif  → Inter（英文）+ MiSans（中文 fallback）
#      - serif       → Noto Serif CJK SC（避免命中日文字形）
#      - monospace   → MiWithJBMonoHalfNL
#   2. 给 Inter 补 zh-cn 语言声明（否则被 fontconfig 按 lang 过滤掉）
#   3. 给所有 flatpak 应用挂载宿主机 fontconfig 配置（沙箱字体一致）
#   4. 刷新 fontconfig 缓存
#   5. 给出验证报告
#
# 【前置条件】
#   - 以下字体必须已安装（脚本会检查）:
#       Inter                    (apt install fonts-inter)
#       MiSans                   (手动下载,放在 ~/.local/share/fonts/MiSans/)
#       MiWithJBMonoHalfNL       (手动下载,放在 ~/.local/share/fonts/MiWithJBMonoHalfNL/)
#       Noto Sans CJK SC / Serif (apt install fonts-noto-cjk)
#       Symbols Nerd Font        (Nerd Font 安装时附带)
#   - GNOME 桌面（非 GNOME 可用,但 gsettings 部分会跳过）
#   - flatpak 可选（未装则跳过 flatpak 段）
#
# 【使用方法】
#   bash setup-fonts.sh          # 默认:配置+应用
#   bash setup-fonts.sh --check  # 仅检查前置条件,不改动任何文件
#   bash setup-fonts.sh --reset  # 回滚所有更改
#
# 【效果】
#   配置完成后,所有应用（GTK/Qt/Electron/flatpak/CLI）字体策略统一:
#     - 界面/文档英文 → Inter
#     - 界面/文档中文 → MiSans（fallback）
#     - 等宽场景     → MiWithJBMonoHalfNL
#     - 中文 serif   → Noto Serif CJK SC（不是 JP）
#     - Nerd Font 图标 → Symbols Nerd Font（由 10-nerd-font-symbols.conf 自动接管）
#
# 【回滚】
#   bash setup-fonts.sh --reset
#   会: 删除 99-fonts-h.conf / 清除 flatpak override / 刷新缓存
#
# =============================================================================

set -euo pipefail

# ---------------------------- 配置区（可改） ---------------------------------

# 用户 fontconfig 配置目录
CONF_DIR="$HOME/.config/fontconfig/conf.d"

# 主配置文件（99 开头 = 最高优先级）
CONF_FILE="$CONF_DIR/99-fonts-h.conf"

# flatpak 挂载点（不要改,这是 flatpak 约定）
FLATPAK_OVERRIDE_TARGET="xdg-config/fontconfig:ro"

# 配置内容（heredoc）
read -r -d '' CONF_CONTENT <<'XML' || true
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>

  <!-- 让 Inter 声明支持中文（实际由 fallback 渲染中文 glyph）-->
  <match target="pattern">
    <test name="family"><string>Inter</string></test>
    <edit name="lang" mode="append"><string>zh-cn</string><string>zh-sg</string></edit>
  </match>

  <!-- 默认 sans-serif:英文 Inter 优先,中文 fallback MiSans -->
  <alias binding="strong">
    <family>sans-serif</family>
    <prefer>
      <family>Inter</family>
      <family>MiSans</family>
      <family>Noto Sans CJK SC</family>
      <family>Noto Sans CJK TC</family>
      <family>Apple Color Emoji</family>
    </prefer>
  </alias>

  <!-- 默认 serif:中文衬线 SC 优先 -->
  <alias binding="strong">
    <family>serif</family>
    <prefer>
      <family>Noto Serif CJK SC</family>
      <family>Noto Serif CJK TC</family>
      <family>Noto Serif CJK JP</family>
    </prefer>
  </alias>

  <!-- 默认 monospace:MiWith 强制优先 -->
  <alias binding="strong">
    <family>monospace</family>
    <prefer>
      <family>MiWithJBMonoHalfNL</family>
      <family>Noto Sans Mono CJK SC</family>
    </prefer>
  </alias>

</fontconfig>
XML

# ---------------------------- 函数区 ----------------------------------------

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log()  { echo -e "${BLUE}»${NC} $*"; }
ok()   { echo -e "${GREEN}✓${NC} $*"; }
warn() { echo -e "${YELLOW}!${NC} $*"; }
err()  { echo -e "${RED}✗${NC} $*" >&2; }

# 检查单个字体是否安装
check_font() {
  local family="$1"
  # grep 找不到时返回非 0,但 pipefail 会把整个管道标记为失败;
  # 把结果存到变量里再做判断,避免 pipefail 干扰
  local found
  found=$(fc-list 2>/dev/null | grep -ci "$family" || true)
  if [[ "$found" -gt 0 ]]; then
    ok "字体已装: $family"
    return 0
  else
    err "字体缺失: $family"
    return 1
  fi
}

# 检查所有前置条件
do_check() {
  log "检查前置条件..."
  echo ""
  log "必需字体:"
  local missing=0
  check_font "Inter"                    || missing=1
  check_font "MiSans"                   || missing=1
  check_font "MiWithJBMonoHalfNL"       || missing=1
  check_font "Noto Sans CJK SC"         || missing=1
  check_font "Noto Serif CJK SC"        || missing=1
  check_font "Symbols Nerd Font"        || missing=1
  check_font "Apple Color Emoji"        || warn "  (可选,emoji 回退)"

  echo ""
  log "工具检查:"
  command -v fc-cache >/dev/null && ok "fontconfig 已装" || { err "fontconfig 未装"; missing=1; }
  command -v xmllint  >/dev/null && ok "xmllint 已装"    || warn "xmllint 未装(语法校验会跳过)"
  command -v gsettings >/dev/null && ok "gsettings 已装" || warn "gsettings 未装(非 GNOME?)"
  command -v flatpak  >/dev/null && ok "flatpak 已装"    || warn "flatpak 未装(将跳过 flatpak 段)"

  echo ""
  if [[ $missing -eq 1 ]]; then
    err "有必需字体缺失,请先安装后再运行(不带 --check)"
    return 1
  else
    ok "前置条件全部满足,可以运行(不带 --check)"
    return 0
  fi
}

# 写入 fontconfig 配置
do_write_config() {
  log "写入 fontconfig 配置..."
  mkdir -p "$CONF_DIR"

  # 备份已有配置
  if [[ -f "$CONF_FILE" ]]; then
    cp "$CONF_FILE" "$CONF_FILE.bak.$(date +%Y%m%d-%H%M%S)"
    ok "已有配置已备份: $CONF_FILE.bak.*"
  fi

  echo "$CONF_CONTENT" > "$CONF_FILE"

  # 语法校验
  if command -v xmllint >/dev/null; then
    if xmllint --noout "$CONF_FILE" 2>/dev/null; then
      ok "配置文件语法 OK: $CONF_FILE"
    else
      err "配置文件语法错误,请检查"
      return 1
    fi
  fi
}

# 配置 flatpak override
do_flatpak() {
  if ! command -v flatpak >/dev/null; then
    warn "flatpak 未安装,跳过 flatpak 段"
    return 0
  fi

  log "配置 flatpak 全局 override..."

  # 检查是否已配置(避免重复)
  local override_file="$HOME/.local/share/flatpak/overrides/global"
  if [[ -f "$override_file" ]] && grep -q "xdg-config/fontconfig" "$override_file"; then
    ok "flatpak override 已存在,跳过"
    return 0
  fi

  flatpak override --user --filesystem="$FLATPAK_OVERRIDE_TARGET"
  ok "flatpak override 已应用: 所有用户级 flatpak 应用共享宿主机 fontconfig 配置"
}

# 刷新 fontconfig 缓存
do_refresh() {
  log "刷新 fontconfig 缓存..."
  fc-cache -f
  ok "fontconfig 缓存已刷新"
}

# GNOME 设置（可选,脚本不强行改用户已有的 Tweaks 设置）
do_gnome_hint() {
  if ! command -v gsettings >/dev/null; then
    return 0
  fi

  log "检查 GNOME 字体设置..."
  local interface_font monospace_font
  interface_font=$(gsettings get org.gnome.desktop.interface font-name 2>/dev/null || echo "")
  monospace_font=$(gsettings get org.gnome.desktop.interface monospace-font-name 2>/dev/null || echo "")

  echo "  当前界面字体: ${interface_font:-未设置}"
  echo "  当前等宽字体: ${monospace_font:-未设置}"

  # 仅当包含 Inter 或 MiWith 时提示（说明用户已经配过）
  if [[ "$interface_font" == *Inter* ]]; then
    ok "GNOME 界面字体已是 Inter"
  else
    warn "GNOME 界面字体不是 Inter,如需对齐请手动设: gsettings set org.gnome.desktop.interface font-name 'Inter 11'"
  fi

  if [[ "$monospace_font" == *MiWith* ]]; then
    ok "GNOME 等宽字体已是 MiWithJBMonoHalfNL"
  else
    warn "GNOME 等宽字体不是 MiWith,如需对齐请手动设: gsettings set org.gnome.desktop.interface monospace-font-name 'MiWithJBMonoHalfNL 15'"
  fi
}

# 验证配置生效
do_verify() {
  log "验证命中..."
  echo ""
  printf "  %-30s %s\n" "sans-serif"            "$(fc-match sans-serif | awk -F: '{print $2}' | awk -F'\"' '{print $2}')"
  printf "  %-30s %s\n" "sans-serif:lang=zh-cn" "$(fc-match 'sans-serif:lang=zh-cn' | awk -F: '{print $2}' | awk -F'\"' '{print $2}')"
  printf "  %-30s %s\n" "monospace"             "$(fc-match monospace | awk -F: '{print $2}' | awk -F'\"' '{print $2}')"
  printf "  %-30s %s\n" "monospace:lang=zh-cn"  "$(fc-match 'monospace:lang=zh-cn' | awk -F: '{print $2}' | awk -F'\"' '{print $2}')"
  printf "  %-30s %s\n" "serif:lang=zh-cn"      "$(fc-match 'serif:lang=zh-cn' | awk -F: '{print $2}' | awk -F'\"' '{print $2}')"
  echo ""

  log "flatpak 应用验证（如已装）:"
  if command -v flatpak >/dev/null; then
    local apps
    apps=$(flatpak list --app --columns=application 2>/dev/null || true)
    if [[ -z "$apps" ]]; then
      echo "  (无已装 flatpak app)"
    else
      while IFS= read -r app; do
        local sans_result
        sans_result=$(flatpak run --command=sh "$app" -c 'fc-match sans-serif' 2>/dev/null | awk -F: '{print $2}' | awk -F'\"' '{print $2}')
        if [[ "$sans_result" == "Inter" ]]; then
          ok "$app → $sans_result"
        else
          warn "$app → $sans_result (期望 Inter,可能需要重启该 app)"
        fi
      done <<< "$apps"
    fi
  fi
}

# 回滚所有更改
do_reset() {
  log "回滚所有更改..."

  # 1. 删除 fontconfig 配置
  if [[ -f "$CONF_FILE" ]]; then
    rm -v "$CONF_FILE"
    ok "已删除: $CONF_FILE"
  fi

  # 2. 还原最新备份（如有）
  local latest_backup
  latest_backup=$(ls -t "$CONF_FILE".bak.* 2>/dev/null | head -1 || true)
  if [[ -n "$latest_backup" ]]; then
    cp "$latest_backup" "$CONF_FILE"
    ok "已还原备份: $latest_backup → $CONF_FILE"
  fi

  # 3. 清除 flatpak override
  if command -v flatpak >/dev/null; then
    flatpak override --user --reset --filesystem="$FLATPAK_OVERRIDE_TARGET" 2>/dev/null || true
    # 如果 global override 文件变得空了,顺手清掉
    local override_file="$HOME/.local/share/flatpak/overrides/global"
    if [[ -f "$override_file" ]] && [[ ! -s "$override_file" ]]; then
      rm -v "$override_file"
    fi
    ok "flatpak override 已清除"
  fi

  # 4. 刷新缓存
  fc-cache -f
  ok "fontconfig 缓存已刷新"
  echo ""
  warn "回滚完成。建议注销重登让 GTK 应用重新加载字体。"
}

# ---------------------------- 主流程 ----------------------------------------

main() {
  local mode="${1:-apply}"

  echo ""
  echo "=========================================="
  echo "  setup-fonts.sh"
  echo "  字体策略一键配置（Inter + MiSans + MiWith）"
  echo "=========================================="
  echo ""

  case "$mode" in
    --check)
      do_check
      ;;
    --reset)
      do_reset
      ;;
    apply|"")
      do_check || { err "前置检查未通过,终止"; exit 1; }
      echo ""
      do_write_config
      do_flatpak
      do_refresh
      do_gnome_hint
      echo ""
      do_verify
      echo ""
      ok "全部完成。建议注销重登让所有应用重新加载字体。"
      ;;
    *)
      err "未知参数: $mode"
      echo "用法: bash setup-fonts.sh [--check|--reset|apply]"
      exit 1
      ;;
  esac
}

main "$@"
