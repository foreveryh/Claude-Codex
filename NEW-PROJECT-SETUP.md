# 在新项目中使用 Claude Code + Codex 能力

## 📋 问题

如何在新项目（如 `~/Projects/A`）中使用当前 Claude-Codex 仓库配置的所有 MCP 能力？

---

## 🎯 Claude Code 配置系统说明

Claude Code 支持 **4 个配置层级**，优先级从高到低：

| 层级 | 存储位置 | 适用范围 | 优先级 |
|------|---------|---------|--------|
| **Enterprise** | `/Library/Application Support/ClaudeCode/managed-mcp.json` (macOS) | 企业管理 | 最高 |
| **Local** | 项目内部设置（不在文件中） | 当前项目的个人配置 | 高 |
| **Project** | `.mcp.json`（项目根目录） | 团队共享，版本控制 | 中 |
| **User** | 用户全局配置 | 所有项目可用 | 低 |

**配置优先级**：`Enterprise > Local > Project > User`

同名的 MCP server 会被优先级更高的配置覆盖。

---

## ✅ 推荐方案：使用 User Scope（用户级配置）

### 方案优势
- ✅ **一次配置，处处可用**：在所有项目中都可以使用
- ✅ **无需重复安装**：不需要在每个项目中运行 install.sh
- ✅ **保持独立性**：每个项目可以选择性启用或覆盖
- ✅ **适合个人工具**：sequential-thinking、codex、code-index 等开发工具

### 实施步骤

#### 1. 使用 claude mcp add 添加 User Scope MCP Servers

```bash
# sequential-thinking（深度思考）
claude mcp add \
  --scope user \
  --transport stdio \
  sequential-thinking \
  --env WORKING_DIR=.claude \
  -- npx -y @modelcontextprotocol/server-sequential-thinking

# shrimp-task-manager（任务管理）
claude mcp add \
  --scope user \
  --transport stdio \
  shrimp-task-manager \
  --env DATA_DIR=.claude/shrimp \
  --env TEMPLATES_USE=zh \
  --env ENABLE_GUI=false \
  -- npx -y mcp-shrimp-task-manager

# codex（代码分析和重构）
claude mcp add \
  --scope user \
  --transport stdio \
  codex \
  --env WORKING_DIR=.claude \
  -- codex mcp-server

# code-index（代码索引）
claude mcp add \
  --scope user \
  --transport stdio \
  code-index \
  --env WORKING_DIR=.claude \
  -- uvx code-index-mcp

# chrome-devtools（浏览器调试）
claude mcp add \
  --scope user \
  --transport stdio \
  chrome-devtools \
  --env WORKING_DIR=.claude \
  -- npx -y chrome-devtools-mcp@latest
```

#### 2. 验证 User Scope 配置

```bash
# 列出所有配置的 MCP servers
claude mcp list

# 预期输出应包含上述 5 个 servers
```

#### 3. 在新项目中使用

```bash
# 创建新项目
mkdir -p ~/Projects/A
cd ~/Projects/A

# 初始化项目（可选）
git init

# 创建工作目录（MCP servers 需要）
mkdir -p .claude/shrimp .claude/codex .claude/context .claude/logs .claude/cache

# 直接启动 Claude Code
claude

# 在 Claude Code 中测试 MCP 工具
# 输入：请使用 sequential-thinking 分析这个项目的架构
```

**就这样！** 不需要额外配置，所有 User Scope 的 MCP servers 已经可用。

---

## 🔧 其他方案

### 方案 2：项目级配置（适合团队协作）

如果你的项目需要**团队共享**配置，可以复制 `.mcp.json`：

```bash
# 从 Claude-Codex 仓库复制配置模板
cp ~/Dev/AI_CODING/Claude-Codex/.mcp.json ~/Projects/A/.mcp.json

# 创建工作目录
mkdir -p ~/Projects/A/.claude/shrimp

# 将 .mcp.json 加入版本控制
cd ~/Projects/A
git add .mcp.json
git commit -m "feat: 添加 Claude Code MCP 配置"
```

**适用场景**：
- ✅ 团队项目需要统一工具链
- ✅ 项目需要特定的 MCP server 配置
- ✅ 需要版本控制 MCP 配置

**缺点**：
- ❌ 每个项目都需要复制配置
- ❌ 配置更新需要手动同步

---

### 方案 3：混合方案（推荐用于复杂场景）

- **User Scope**：放置通用开发工具（sequential-thinking、codex、code-index）
- **Project Scope**：放置项目特定工具（如特定 API 的 MCP server、团队工具）

```bash
# User Scope：通用工具（已通过方案1配置）

# Project Scope：项目特定工具
cd ~/Projects/A
claude mcp add \
  --scope project \
  --transport http \
  sentry \
  https://mcp.sentry.dev/mcp

# 这样 .mcp.json 只包含项目特定配置，更轻量
```

**优势**：
- ✅ 最佳灵活性
- ✅ 团队成员可以有个人偏好（User Scope）
- ✅ 项目需求统一管理（Project Scope）

---

## 📦 快速安装脚本

如果你需要在多个项目中快速设置，可以使用以下脚本：

```bash
#!/bin/bash
# setup-user-mcp.sh - 一键配置 User Scope MCP Servers

echo "正在配置 Claude Code User Scope MCP Servers..."

# Sequential Thinking
claude mcp add --scope user --transport stdio sequential-thinking \
  --env WORKING_DIR=.claude \
  -- npx -y @modelcontextprotocol/server-sequential-thinking

# Shrimp Task Manager
claude mcp add --scope user --transport stdio shrimp-task-manager \
  --env DATA_DIR=.claude/shrimp \
  --env TEMPLATES_USE=zh \
  --env ENABLE_GUI=false \
  -- npx -y mcp-shrimp-task-manager

# Codex
claude mcp add --scope user --transport stdio codex \
  --env WORKING_DIR=.claude \
  -- codex mcp-server

# Code Index
claude mcp add --scope user --transport stdio code-index \
  --env WORKING_DIR=.claude \
  -- uvx code-index-mcp

# Chrome DevTools
claude mcp add --scope user --transport stdio chrome-devtools \
  --env WORKING_DIR=.claude \
  -- npx -y chrome-devtools-mcp@latest

echo "✅ 配置完成！运行 'claude mcp list' 查看所有 MCP servers"
```

保存为 `setup-user-mcp.sh`，然后：

```bash
chmod +x setup-user-mcp.sh
./setup-user-mcp.sh
```

---

## 🧪 测试新项目配置

```bash
# 1. 创建测试项目
mkdir -p ~/Projects/test-claude-codex
cd ~/Projects/test-claude-codex

# 2. 创建工作目录
mkdir -p .claude/shrimp .claude/codex .claude/context

# 3. 创建测试文件
echo "# Test Project" > README.md
echo "console.log('Hello Claude Code');" > index.js

# 4. 启动 Claude Code
claude

# 5. 在 Claude Code 中测试
# 输入：请使用 code-index 分析这个项目的结构
# 输入：请使用 sequential-thinking 帮我规划一个新功能
```

---

## 🔍 故障排查

### 问题 1：MCP servers 显示未连接

**症状**：`claude mcp list` 显示 "⚠ Disconnected"

**解决方案**：
```bash
# 检查依赖是否已安装
npx @modelcontextprotocol/server-sequential-thinking --help
npx mcp-shrimp-task-manager --help
codex --version
uvx code-index-mcp --help
npx chrome-devtools-mcp@latest --help

# 如果缺少依赖，安装它们
npm install -g @modelcontextprotocol/server-sequential-thinking
npm install -g mcp-shrimp-task-manager
npm install -g chrome-devtools-mcp
# codex 和 uvx 需要单独安装（见安装文档）
```

### 问题 2：找不到 .claude 工作目录

**症状**：MCP server 报错 "WORKING_DIR not found"

**解决方案**：
```bash
# 在项目根目录创建必要的工作目录
mkdir -p .claude/{shrimp,codex,context,logs,cache}

# 或者修改环境变量指向绝对路径（不推荐）
```

### 问题 3：User Scope 配置在哪里存储？

User Scope 配置由 Claude Code 内部管理，不暴露为文件。

查看配置：
```bash
claude mcp list
claude mcp get <server-name>  # 查看具体 server 配置
```

删除配置：
```bash
claude mcp remove <server-name>
```

---

## 📚 参考资料

- [Claude Code MCP 文档](https://code.claude.com/docs/en/mcp)
- [MCP 协议规范](https://modelcontextprotocol.io/)
- 当前仓库的配置示例：`.mcp.json`
- 安装脚本文档：`INSTALL-FIX-NOTES.md`

---

## 💡 最佳实践建议

### 1. 对于个人项目
- ✅ 使用 **User Scope** 配置通用工具
- ✅ 不需要在每个项目中重复配置
- ✅ 保持项目干净，不添加 `.mcp.json`（除非团队需要）

### 2. 对于团队项目
- ✅ 使用 **Project Scope** (`.mcp.json`) 配置团队工具
- ✅ 将 `.mcp.json` 加入版本控制
- ✅ 在 README 中说明需要的 MCP servers

### 3. 对于企业环境
- ✅ 考虑使用 **Enterprise Scope** 强制标准化工具
- ✅ 管理员统一部署 `managed-mcp.json`
- ✅ 允许用户通过 User/Local Scope 个性化

---

## 🎉 总结

**推荐的最简方案**：

1️⃣ **运行一次**：
```bash
./setup-user-mcp.sh  # 或手动执行 claude mcp add --scope user 命令
```

2️⃣ **在任何新项目中**：
```bash
mkdir -p ~/Projects/NewProject/.claude
cd ~/Projects/NewProject
claude  # 直接启动，所有 MCP 工具已可用
```

3️⃣ **享受 Claude Code + Codex 的强大能力！** 🚀
