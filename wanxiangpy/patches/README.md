# 万象方案自定义补丁

本目录保存对万象拼音方案的手动改动，用于方案更新后快速恢复。

## 改动清单

### 1. super_replacer.lua — Config 兼容性修复（Bug Fix）

- **文件**：`lua/wanxiang/super_replacer.lua`
- **补丁**：`super_replacer_Config_fix.patch`
- **原因**：`enabled_schema_ids()` 函数调用全局 `Config("default")`，部分 librime 版本未导出此函数导致崩溃，进而使 emoji 候选、颜文字候选等所有 super_replacer 功能失效。
- **修复**：用 `type()` 检查 + `pcall` 保护，失败时走 `MERGED_SCHEMA_IDS` 降级路径。
- **关键行**：约 213-222 行

### 2. super_symbols.lua — 颜文字加载支持（Feature）

- **文件**：`lua/wanxiang/super_symbols.lua`
- **补丁**：`super_symbols_kaomoji.patch`
- **改动**：在数据加载逻辑中增加 `kaomoji` store，读取 `data_kaomoji` 配置路径。
- **关键行**：约 132-140 行

### 3. 颜文字数据文件（新增）

- `lua/data/kaomoji.txt` — 141 条颜文字，按 `/kk` 指令搜索（分类/拼音 key）
- `lua/data/kaomoji_replacer.txt` — 约 70 条中文词→颜文字映射，打字直接出候选

### 4. wanxiang.custom.yaml（用户配置，不会被覆盖）

无需备份，方案更新不会动 `.custom.yaml`。内容包含：
- `super_symbols/triggers`：新增 kaomoji 类型，前缀 `/kk`
- `super_symbols/data_kaomoji`：数据文件路径
- `recognizer/patterns/super_kaomoji`：`/kk` 指令识别
- `super_replacer/rules/+`：追加颜文字候选规则

## 恢复方法

更新万象方案后，运行：

```bash
bash ~/.local/share/fcitx5/rime/custom/patches/restore_wanxiang_patches.sh
```

脚本会：
1. 检测 lua 文件是否需要打补丁（已打过会跳过）
2. 恢复颜文字数据文件
3. 检查 wanxiang.custom.yaml 配置完整性
4. 提示是否需要重新部署

## 目录结构

```
custom/patches/
├── README.md                              # 本文件
├── restore_wanxiang_patches.sh            # 一键恢复脚本
├── super_replacer_Config_fix.patch        # 补丁 1
├── super_symbols_kaomoji.patch            # 补丁 2
└── kaomoji_backup/                        # 数据文件备份
    ├── kaomoji.txt
    └── kaomoji_replacer.txt
```

## 注意事项

- 补丁针对 **v17.1.0** 生成。若新版 lua 代码结构变化导致补丁无法应用，脚本会提示具体文件，需手动对比适配。
- 如果官方在新版修复了 Config 问题，可移除补丁 1（删除 `.patch` 文件即可，脚本会自动忽略）。
- `replacer.userdb` 是缓存数据库，删除后会在下次输入时自动重建，无需备份。
