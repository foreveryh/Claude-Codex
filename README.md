# Claude Code + Codex 协作开发环境

> 🚀 一键配置，3 分钟上手，让 AI 协作开发变得简单

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20Linux%20%7C%20Windows-blue)](https://github.com/foreveryh/Claude-Codex)

---

## 📋 快速开始

### 🎯 方式 1：交互式安装（推荐新手 ⭐）

一条命令，自动引导选择：

```bash
bash <(curl -sSL https://raw.githubusercontent.com/foreveryh/Claude-Codex/main/install)
```

脚本会引导你选择：
- **[1] 全局安装** - 配置一次，所有项目可用（推荐个人使用）
- **[2] 项目安装** - 配置可版本控制（推荐团队协作）
- **[3] 快速初始化** - 仅创建工作目录（需已有全局配置）

---

### ⚡ 方式 2：直接安装（老手专用）

#### 个人开发者 - 全局安装

```bash
# 配置一次，处处可用
curl -sSL https://raw.githubusercontent.com/foreveryh/Claude-Codex/main/install-global.sh | bash
```

**使用场景**：
- ✅ 个人项目，多个项目需要相同工具
- ✅ 无需在每个项目中重复配置
- ✅ 配置由 Claude Code 内部管理

#### 团队协作 - 项目安装

```bash
# 在项目根目录运行
cd your-project
curl -sSL https://raw.githubusercontent.com/foreveryh/Claude-Codex/main/install-project.sh | bash
```

**使用场景**：
- ✅ 团队项目，需要统一工具链
- ✅ 配置可见（.mcp.json），可版本控制
- ✅ 团队成员 pull 后自动生效

#### 快速初始化 - 已有全局配置

```bash
# 仅创建工作目录，1 秒完成
cd new-project
curl -sSL https://raw.githubusercontent.com/foreveryh/Claude-Codex/main/init-workspace.sh | bash
```

---

## 🎯 配置级别

安装脚本会提供三种配置选项：

| 配置级别 | 包含工具 | 适用场景 |
|---------|---------|---------|
| **简单配置** | Sequential-thinking, Codex | 快速体验，学习使用 |
| **标准配置** | + Shrimp任务管理, Code-index | 日常开发，完整工具链 |
| **高级配置** | + Chrome-devtools, Exa搜索 | 复杂项目，企业级需求 |

---

## 💡 使用场景对比

### 🏠 个人开发者

```bash
# 1. 全局安装（一次）
bash <(curl -sSL https://raw.githubusercontent.com/.../install-global.sh)

# 2. 在任何新项目中使用
cd ~/Projects/my-project
mkdir -p .claude
claude  # 直接使用，无需配置
```

### 👥 团队协作

```bash
# 1. 项目安装（生成 .mcp.json）
cd team-project
bash <(curl -sSL https://raw.githubusercontent.com/.../install-project.sh)

# 2. 提交到版本控制
git add .mcp.json
git commit -m "feat: 添加 Claude-Codex 配置"
git push

# 3. 团队成员 pull 后自动生效
git pull
claude  # 自动加载团队配置
```

---

## 🤖 核心功能

### AI 协作模式

- **Claude Code**: 项目管理和代码执行
- **Codex**: 深度代码分析和生成
- **智能分工**: 简单任务 Claude 直接处理，复杂逻辑委托 Codex

### 智能工作流

1. **需求理解** → Sequential-thinking 深度分析
2. **上下文收集** → Code-index 全面检索
3. **任务规划** → Shrimp 智能分解
4. **代码执行** → Codex 小步迭代开发
5. **质量验证** → 自动化测试和审查

### 核心优势

- ✅ **零学习成本**: 基于熟悉的 Claude Code 界面
- ✅ **智能默认**: 预配置最佳实践，减少配置决策
- ✅ **渐进增强**: 从简单到高级，按需扩展功能
- ✅ **高可靠性**: 完整的错误处理和自动恢复

---

## 📚 使用示例

### 基础对话

```
用户: 帮我创建一个 React 组件，显示用户列表

Claude: 我来帮你创建一个 React 组件显示用户列表。
        让我先调用 Codex 进行深度分析，然后实现这个功能。
```

### 复杂任务

```
用户: 实现一个完整的用户管理系统，包括认证、CRUD 操作和权限管理

Claude: 这是一个复杂的多模块任务。
        让我使用 sequential-thinking 进行深度分析，
        然后制定详细的实施计划。
```

---

## 🔍 故障排除

### 常见问题

**Q: 看不到 codex 工具？**
A: 确保配置文件正确安装，然后重启 Claude Code

**Q: Codex 连接失败？**
A: 确保 Codex 已正确安装并可以运行 `codex mcp-server` 命令

**Q: MCP 服务器连接失败？**
A: 运行 `claude mcp list` 查看状态，或重新运行安装脚本

**Q: 如何查看已配置的 MCP servers？**
A: 运行 `claude mcp list`

**Q: 如何删除某个 MCP server？**
A: 运行 `claude mcp remove <server-name>`

详细故障排除指南请查看：[troubleshooting.md](troubleshooting.md)

---

## 📖 更多文档

- **[使用指南](USAGE-GUIDE.md)** - 详细的场景对比和最佳实践
- **[新项目设置](NEW-PROJECT-SETUP.md)** - 技术细节和配置说明
- **[故障排除](troubleshooting.md)** - 常见问题解决方案
- **[安装修复说明](INSTALL-FIX-NOTES.md)** - 最新修复记录

---

## 🛠️ 手动配置

如果你想手动配置，可以直接使用 Claude Code CLI：

```bash
# 全局安装示例
claude mcp add --scope user --transport stdio sequential-thinking \
  --env WORKING_DIR=.claude \
  -- npx -y @modelcontextprotocol/server-sequential-thinking

# 项目安装示例
claude mcp add --scope project --transport stdio codex \
  --env WORKING_DIR=.claude \
  -- codex mcp-server
```

更多配置选项请查看：[配置文件说明](README-config.md)

---

## 🤝 贡献

欢迎贡献代码和改进建议！

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

---

## 📄 许可证

MIT License - 详见 [LICENSE](LICENSE) 文件

---

## 🌟 Star History

如果这个项目对你有帮助，请给我们一个 Star ⭐️

---

**开始你的 AI 协作开发之旅吧！** 🚀

有问题？查看 [USAGE-GUIDE.md](USAGE-GUIDE.md) 或提交 [Issue](https://github.com/foreveryh/Claude-Codex/issues)
