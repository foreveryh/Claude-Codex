# 遗留配置文件说明

本目录包含一些旧的配置模板文件，这些文件是为 **Claude Desktop** 设计的，不适用于 **Claude Code CLI**。

⚠️ **这些文件仅供参考，请勿直接使用**

## 文件列表

### `claude-desktop-config.json`
- **用途**: Claude Desktop 的 MCP 配置模板
- **问题**: 包含 `"type": "stdio"` 字段，Claude Code CLI 不需要此字段
- **替代**: 使用 `install.sh` 生成的 `.mcp.json`

### `config-simple.json`
- **用途**: 简单配置模板（sequential-thinking + codex）
- **问题**: 格式为 Claude Desktop，且包含不必要的 workflow 配置
- **替代**: 运行 `./install.sh` 并选择"简单配置"

### `config-advanced.json`
- **用途**: 高级配置模板（完整 MCP servers）
- **问题**: 格式为 Claude Desktop
- **替代**: 运行 `./install.sh` 并选择"高级配置"

---

## 正确的安装方式

**不要手动编辑这些文件**，请使用：

```bash
./install.sh
```

安装脚本会：
1. ✅ 在当前目录创建 `.mcp.json`（Claude Code CLI 格式）
2. ✅ 安装 Codex Workflow Skill 到 `.claude/skills/`
3. ✅ 创建正确的目录结构
4. ✅ 安装必需的 npm 包
5. ✅ 验证配置

---

## Claude Desktop vs Claude Code CLI 配置对比

### Claude Desktop 格式 ❌
```json
{
  "mcpServers": {
    "codex": {
      "type": "stdio",        // ← Claude Desktop 需要
      "command": "codex",
      "args": ["mcp-server"]
    }
  }
}
```

### Claude Code CLI 格式 ✅
```json
{
  "mcpServers": {
    "codex": {
      "command": "codex",     // ← 无 "type" 字段
      "args": ["mcp-server"]
    }
  }
}
```

---

## 删除建议

这些遗留文件可以安全删除：

```bash
rm claude-desktop-config.json config-simple.json config-advanced.json LEGACY-CONFIGS.md
```

如果你需要参考配置，请查看 `install.sh` 中的配置生成逻辑。
