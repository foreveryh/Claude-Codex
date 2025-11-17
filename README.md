# Claude Code + Codex 协作开发环境

> 🚀 一键配置，3 分钟上手，让 AI 协作开发变得简单

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20Linux%20%7C%20Windows-blue)](https://github.com/foreveryh/Claude-Codex)

---

## 📋 快速开始

### 🎯 方式 1：远程一键安装（推荐 ⭐）

无需克隆仓库，一条命令完成：

```bash
bash <(curl -sSL https://raw.githubusercontent.com/foreveryh/Claude-Codex/main/install)
```

**工作原理**：
- 自动下载安装脚本和 Skill 文件到临时目录
- 在当前项目目录创建 `.claude/` 和 `.mcp.json`
- 安装完成后自动清理临时文件

---

### 📦 方式 2：本地安装

如果你已经克隆了仓库：

```bash
# 克隆仓库
git clone https://github.com/foreveryh/Claude-Codex.git
cd Claude-Codex

# 运行安装脚本
./install
# 或
./install.sh
```

**安装过程**：
1. **检查依赖** - Node.js, npm 等
2. **选择配置** - 简单/标准/高级
3. **创建目录** - .claude/skills/codex-workflow
4. **安装 Skill** - 复制 Skill 文件和模板
5. **生成配置** - 创建 .mcp.json
6. **安装包** - npm 全局包和 Python 工具

---

## 🎯 配置级别

安装脚本会提供三种配置选项：

| 配置级别 | 包含工具 | 适用场景 |
|---------|---------|---------|
| **简单配置** | Sequential-thinking, Codex | 快速体验，学习使用 |
| **标准配置** | + Shrimp任务管理, Code-index | 日常开发，完整工具链 |
| **高级配置** | + Chrome-devtools, Exa搜索 | 复杂项目，企业级需求 |

---

## 💡 使用场景

### 🏠 个人项目

```bash
# 1. 在项目中安装
cd ~/Projects/my-project
/path/to/Claude-Codex/install.sh

# 2. 使用 Claude Code
claude  # 自动加载 .mcp.json 配置
```

### 👥 团队协作

```bash
# 1. 在团队项目中安装
cd team-project
/path/to/Claude-Codex/install.sh

# 2. 提交到版本控制
git add .mcp.json .claude/
git commit -m "feat: 添加 Claude-Codex 配置"
git push

# 3. 团队成员自动生效
git pull
claude  # 自动加载团队配置（首次需批准）
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

## 🔍 安装后验证

不论选择哪种安装方式，建议执行以下命令确认环境就绪：

```bash
./check-skill-health.sh
```

脚本会检查：
- `.mcp.json` 是否存在且语法正确
- Codex Workflow Skill 及其模板是否已安装
- 必要的 npm/pip 包是否可用

如发现缺失组件，它会给出修复步骤（重新运行相应安装脚本或补装依赖）。

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

详细故障排除指南请查看：[troubleshooting.md](docs/troubleshooting.md)

---

## 📖 更多文档

- **[快速开始](docs/QUICKSTART.md)** - 5 分钟快速上手
- **[使用指南](docs/USAGE-GUIDE.md)** - 详细的场景对比和最佳实践
- **[新项目设置](docs/NEW-PROJECT-SETUP.md)** - 技术细节和配置说明
- **[Skill 指南](docs/SKILL-GUIDE.md)** - Codex Workflow Skill 完整说明
- **[配置说明](docs/README-config.md)** - MCP 配置文件详解
- **[故障排除](docs/troubleshooting.md)** - 常见问题解决方案
- **[高级指南](docs/advanced.md)** - 高级功能和最佳实践
- **[API 文档](docs/api.md)** - API 参考文档

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

更多配置选项请查看：[配置文件说明](docs/README-config.md)

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

有问题？查看 [docs/USAGE-GUIDE.md](docs/USAGE-GUIDE.md) 或提交 [Issue](https://github.com/foreveryh/Claude-Codex/issues)
