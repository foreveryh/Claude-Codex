# Claude Code + Codex Skill 完整使用指南

> 🎯 通过 Skill 增强 MCP 工具的使用效率，实现标准化、自动化的 AI 协作工作流

---

## 📋 目录

- [项目概述](#项目概述)
- [快速开始](#快速开始)
- [完整安装](#完整安装)
- [文件结构](#文件结构)
- [使用指南](#使用指南)
- [实战示例](#实战示例)
- [配置说明](#配置说明)
- [故障排除](#故障排除)
- [最佳实践](#最佳实践)
- [FAQ](#faq)

---

## 🎯 项目概述

### 这是什么？

这是一个 **Claude Code Skill 配置包**，用于优化 Claude Code + Codex MCP 服务器的协作工作流程。

### 为什么需要它？

**没有 Skill 的情况**：
```
用户: 帮我重构这段代码
Claude: [直接开始写代码]
      ❌ 可能缺少深度思考
      ❌ 没有全面扫描代码库
      ❌ 输出格式不统一
      ❌ 缺少质量审查
```

**有 Skill 的情况**：
```
用户: 帮我重构这段代码
Claude: [自动加载 codex-workflow skill]
      ✅ 1. sequential-thinking 深度分析
      ✅ 2. codex 全面扫描代码库
      ✅ 3. shrimp 智能任务规划
      ✅ 4. 分工执行开发
      ✅ 5. codex 质量审查
      ✅ 6. 记录决策过程
```

### 核心价值

| 维度 | 提升效果 |
|------|---------|
| **标准化** | 统一的6步工作流程 |
| **自动化** | Claude 自动激活和编排 |
| **可追溯** | 所有决策和输出都有记录 |
| **质量保证** | 强制代码审查和评分 |
| **学习曲线** | 零额外学习成本 |

---

## 🚀 快速开始

### 前置条件

```bash
# 1. 已安装 Claude Code
# 2. 已配置 MCP 服务器（运行过 install.sh）
# 3. 确保项目包含以下配置：
cat ~/Library/Application\ Support/Claude/claude_desktop_config.json
# 应包含 codex, sequential-thinking 等 MCP 服务器
```

### 3分钟快速部署

```bash
# 步骤1：项目已包含 Skill 配置（在 .claude/skills/ 目录）
ls -la .claude/skills/codex-workflow/

# 步骤2：运行健康检查
chmod +x check-skill-health.sh
./check-skill-health.sh

# 步骤3：（可选）复制到全局配置目录
# macOS
cp -r .claude/skills/codex-workflow ~/Library/Application\ Support/Claude/skills/

# Linux
cp -r .claude/skills/codex-workflow ~/.config/claude/skills/

# 步骤4：重启 Claude Code

# 步骤5：测试
# 在 Claude Code 中输入："帮我分析并优化这段代码"
# Claude 应该自动遵循6步工作流程
```

---

## 📦 完整安装

### 方法1：使用现有配置（推荐）

如果你已经克隆了 Claude-Codex 项目：

```bash
# 1. 确保在项目根目录
cd /path/to/Claude-Codex

# 2. 验证 Skill 文件存在
ls -la .claude/skills/codex-workflow/SKILL.md

# 3. 运行健康检查
./check-skill-health.sh

# 4. Claude Code 会自动识别项目本地的 .claude/skills/
# 无需额外配置！
```

### 方法2：全局安装

如果希望在所有项目中使用：

```bash
# 1. 确定 Claude 配置目录
# macOS
CLAUDE_DIR="$HOME/Library/Application Support/Claude"
# Linux
CLAUDE_DIR="$HOME/.config/claude"

# 2. 创建 skills 目录
mkdir -p "$CLAUDE_DIR/skills"

# 3. 复制 Skill 配置
cp -r .claude/skills/codex-workflow "$CLAUDE_DIR/skills/"

# 4. 验证
ls -la "$CLAUDE_DIR/skills/codex-workflow/"

# 5. 重启 Claude Code
```

### 方法3：手动创建

如果需要自定义：

```bash
# 1. 创建目录结构
mkdir -p .claude/skills/codex-workflow/templates

# 2. 复制核心文件
# SKILL.md - 核心工作流定义
# templates/ - 各类模板文件

# 3. 参考本项目的文件内容
```

---

## 📁 文件结构

```
.claude/skills/codex-workflow/
├── SKILL.md                               # 核心 Skill 定义（必需）
└── templates/                             # 模板文件夹（辅助）
    ├── task-marker-format.txt             # Task Marker 格式说明
    ├── codex-prompt-template.md           # Codex 调用模板
    ├── context-initial-template.json      # 上下文收集模板
    ├── review-checklist.md                # 代码审查清单
    └── skill-troubleshooting.md           # 故障排除指南
```

### 核心文件说明

#### SKILL.md
- **作用**：定义 Claude 的工作流程
- **格式**：Markdown + YAML frontmatter
- **大小**：~15KB
- **关键内容**：
  - 激活条件
  - 6步标准工作流
  - 工具调用规范
  - 文件组织规范

#### templates/
- **作用**：提供标准化模板供参考
- **使用**：Claude 可以参考这些模板生成输出
- **可选**：不影响 Skill 核心功能

---

## 📖 使用指南

### Skill 如何工作？

```
用户输入
    ↓
Claude 分析请求
    ↓
匹配 Skill description
    ↓
加载 SKILL.md 内容
    ↓
按照定义的流程执行
    ↓
生成标准化输出
```

### 激活条件

Skill 会在以下情况自动激活：

✅ **必定激活**
- 代码分析或重构（>10行）
- 多文件修改
- 架构设计
- 代码审查请求
- 明确提到"深度分析"

⚡ **可能激活**
- 复杂的实现任务
- 需要全面理解代码库
- 涉及多个模块

❌ **不会激活**
- 简单文件操作（<5行）
- 纯信息查询
- 文档编写

### 标准工作流程

#### 第1步：深度需求分析
```
工具：sequential-thinking
时长：30-60秒
输出：任务理解、风险清单
```

#### 第2步：全面上下文收集
```
工具：mcp__codex__codex
时长：1-3分钟
输出：.claude/context-initial.json
关键：生成 Task Marker，记录 conversationId
```

#### 第3步：智能任务规划
```
工具：shrimp-task-manager（可选）
时长：30秒
输出：任务执行计划
```

#### 第4步：分工执行开发
```
主AI：简单逻辑、文件操作
Codex：复杂算法、深度分析
输出：.claude/coding-progress.json
```

#### 第5步：质量验证审查
```
工具：mcp__codex__codex + sequential-thinking
时长：1-2分钟
输出：.claude/review-report.md
包含：评分、建议、风险评估
```

#### 第6步：知识沉淀记录
```
输出：.claude/operations-log.md
内容：决策过程、工具调用链、关键选择
```

### 输出文件说明

所有输出文件在 `.claude/` 目录：

| 文件 | 作用 | 生成时机 |
|------|------|---------|
| `context-initial.json` | 初步代码扫描 | 第2步 |
| `context-question-N.json` | 深度问题分析 | 第4步（按需） |
| `coding-progress.json` | 实时编码状态 | 第4步 |
| `review-report.md` | 代码审查报告 | 第5步 |
| `operations-log.md` | 决策记录 | 第6步 |
| `codex-sessions.json` | 会话管理 | 第2步起 |

---

## 🎬 实战示例

### 示例1：重构复杂函数

**用户输入**：
```
帮我重构 src/auth/login.ts 中的 authenticateUser 函数，
这个函数有150行代码，太复杂了。
```

**Claude 执行流程**：

```
[自动加载 codex-workflow skill]

1️⃣ 深度分析（sequential-thinking）
   ✓ 识别：复杂度高（150行）
   ✓ 风险：可能影响认证流程
   ✓ 策略：先理解逻辑，再拆解函数

2️⃣ 上下文收集（codex）
   调用：mcp__codex__codex(
     prompt="[TASK_MARKER: 20251112-230000-0001]
             扫描 src/auth/ 模块..."
   )
   ✓ 生成：.claude/context-initial.json
   ✓ 发现：3个相似的认证函数
   ✓ 记录：conversationId: conv-xyz123

3️⃣ 任务规划（shrimp-task-manager）
   ✓ 子任务1：提取密码验证逻辑
   ✓ 子任务2：提取session创建逻辑
   ✓ 子任务3：提取日志记录逻辑
   ✓ 子任务4：主函数重组

4️⃣ 分工执行
   主AI：
   - 创建 src/auth/validators.ts
   - 创建 src/auth/session-manager.ts
   - 更新测试文件

   Codex（继续会话 conv-xyz123）：
   - 设计复杂的密码验证算法
   - 优化session创建逻辑

   ✓ 更新：.claude/coding-progress.json

5️⃣ 质量审查（codex + sequential-thinking）
   调用：mcp__codex__codex(
     prompt="[TASK_MARKER: 20251112-230000-0001]
             深度审查重构后的代码..."
   )
   ✓ 评分：88/100
   ✓ 建议：需讨论 - session过期时间配置化
   ✓ 输出：.claude/review-report.md

6️⃣ 决策记录
   ✓ 记录：采纳Codex的密码验证建议
   ✓ 记录：推翻session缓存建议（项目特殊需求）
   ✓ 输出：.claude/operations-log.md
```

**最终输出**：
```
✅ 重构完成！
- 主函数从150行降到40行
- 提取了3个独立模块
- 测试覆盖率保持100%
- 代码审查评分：88/100

📁 相关文件：
- .claude/context-initial.json
- .claude/review-report.md
- .claude/operations-log.md
```

### 示例2：新功能开发

**用户输入**：
```
实现一个用户权限管理系统，支持RBAC模型
```

**执行流程**（简化版）：

```
1️⃣ 分析：理解RBAC需求，识别关键组件
2️⃣ 扫描：查找现有认证系统，寻找相似实现
3️⃣ 规划：拆解为数据模型、API、前端、测试4个阶段
4️⃣ 执行：主AI创建基础结构，Codex设计权限判断逻辑
5️⃣ 审查：Codex全面审查安全性和性能
6️⃣ 记录：文档化架构决策和安全考虑
```

---

## ⚙️ 配置说明

### 必需的 MCP 配置

在 `claude_desktop_config.json` 中必须包含：

```json
{
  "mcpServers": {
    "sequential-thinking": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-sequential-thinking"],
      "env": {
        "WORKING_DIR": ".claude"
      }
    },
    "codex": {
      "type": "stdio",
      "command": "codex",
      "args": ["mcp-server"],
      "env": {
        "WORKING_DIR": ".claude"
      }
    }
  }
}
```

### 可选的 MCP 配置

```json
{
  "mcpServers": {
    "shrimp-task-manager": {
      "command": "npx",
      "args": ["-y", "mcp-shrimp-task-manager"],
      "env": {
        "DATA_DIR": ".claude/shrimp",
        "TEMPLATES_USE": "zh"
      }
    },
    "code-index": {
      "command": "uvx",
      "args": ["code-index-mcp"],
      "env": {
        "WORKING_DIR": ".claude"
      }
    }
  }
}
```

### Skill 自定义

编辑 `SKILL.md` 以自定义行为：

```markdown
---
name: Your Custom Skill Name
description: Customize when to activate this skill
---

# 自定义内容
...
```

**可自定义项**：
- 激活条件（description 字段）
- 工作流程步骤
- 文件输出格式
- 决策规则

---

## 🔧 故障排除

### 问题1：Skill 未激活

**症状**：Claude 没有遵循定义的工作流

**检查清单**：
```bash
# 1. 文件是否存在
ls -la .claude/skills/codex-workflow/SKILL.md

# 2. YAML 格式是否正确
head -5 .claude/skills/codex-workflow/SKILL.md
# 应该看到 "---" 开头和结尾

# 3. Claude Code 是否重启
# 修改 Skill 后必须重启

# 4. description 是否明确
# 确保清楚说明何时激活
```

**解决方案**：
- 运行 `./check-skill-health.sh` 诊断
- 查看 `.claude/skills/codex-workflow/templates/skill-troubleshooting.md`

### 问题2：Codex 调用失败

**症状**：Error: mcp__codex__codex tool not found

**检查清单**：
```bash
# 1. Codex 是否安装
which codex
codex --version

# 2. MCP 配置是否正确
cat ~/Library/Application\ Support/Claude/claude_desktop_config.json | grep -A 5 codex

# 3. 工作目录是否存在
ls -la .claude/
```

**解决方案**：
- 安装 Codex：https://github.com/openai/codex
- 运行 `./install.sh` 修复 MCP 配置

### 问题3：输出文件缺失

**症状**：找不到 context-initial.json 等文件

**检查清单**：
```bash
# 1. 目录是否存在
mkdir -p .claude/{codex,context,logs,cache}

# 2. 权限是否正确
chmod -R 755 .claude/

# 3. Codex 是否成功执行
tail -f .claude/logs/*.log
```

### 完整故障排除

查看详细指南：
```bash
cat .claude/skills/codex-workflow/templates/skill-troubleshooting.md
```

---

## 💡 最佳实践

### 1. 合理设置激活条件

```markdown
❌ 太宽泛
description: Help with coding tasks

✅ 具体明确
description: When user requests complex code analysis (>10 lines),
refactoring, architectural design, code review, or multi-file changes
```

### 2. 定期清理工作文件

```bash
# 保留最近30天的文件
find .claude/context/ -type f -mtime +30 -delete
find .claude/logs/ -type f -mtime +30 -delete
```

### 3. 版本控制排除

```bash
# .gitignore
.claude/context/
.claude/logs/
.claude/cache/
.claude/codex-sessions.json
.claude/coding-progress.json

# 保留配置
!.claude/skills/
```

### 4. 项目团队共享

```bash
# 提交 Skill 配置到仓库
git add .claude/skills/
git commit -m "feat: 添加 Codex workflow skill"

# 团队成员克隆后自动生效
```

### 5. 监控和优化

```bash
# 定期查看决策日志
cat .claude/operations-log.md

# 分析审查报告趋势
grep "综合评分" .claude/review-report.md

# 优化 Skill 定义
vim .claude/skills/codex-workflow/SKILL.md
```

### 6. 结合 Git Hooks

```bash
# .git/hooks/pre-commit
#!/bin/bash
# 提交前运行代码审查
if [ -f ".claude/review-report.md" ]; then
    SCORE=$(grep "综合评分" .claude/review-report.md | grep -oP '\d+')
    if [ "$SCORE" -lt 80 ]; then
        echo "代码审查评分过低：$SCORE/100"
        exit 1
    fi
fi
```

---

## ❓ FAQ

### Q1: Skill 和 MCP 的区别是什么？

**A**:
- **MCP**：提供工具能力（如 codex, sequential-thinking）
- **Skill**：定义如何使用这些工具的工作流程
- **关系**：Skill 编排 MCP 工具，就像指挥家指挥乐队

### Q2: 项目本地 vs 全局安装，选哪个？

**A**:
- **项目本地** (`.claude/skills/`)：推荐
  - ✅ 团队共享
  - ✅ 版本控制
  - ✅ 项目特定配置

- **全局安装** (`~/Library/.../skills/`)：
  - ✅ 所有项目通用
  - ❌ 不便于版本控制
  - ❌ 团队协作困难

### Q3: Skill 会增加响应时间吗？

**A**:
- **加载时间**：<100ms（仅读取 Markdown）
- **执行时间**：取决于工作流程复杂度
- **令牌消耗**：metadata 仅几十 tokens，全文按需加载
- **性价比**：质量提升远大于时间成本

### Q4: 可以修改 Skill 吗？

**A**:
- ✅ 完全可以！Skill.md 就是普通 Markdown
- 建议：修改后运行 `./check-skill-health.sh`
- 注意：修改后必须重启 Claude Code

### Q5: Skill 在 API 中可用吗？

**A**:
- ✅ 是的！Skill 支持：
  - Claude Code (Desktop)
  - claude.ai (Web)
  - Claude API
- 配置位置可能不同，查阅官方文档

### Q6: 如何调试 Skill？

**A**:
```bash
# 1. 启用详细日志
export CLAUDE_LOG_LEVEL=debug

# 2. 查看 Skill 是否加载
# 在对话中观察 Claude 是否提到 Skill 相关内容

# 3. 创建最小测试 Skill
cat > .claude/skills/test/SKILL.md << 'EOF'
---
name: Test
description: When user says "test", respond with "OK"
---
Say "Skill works!"
EOF

# 4. 测试
# 输入 "test"，应该看到 "Skill works!"
```

### Q7: Skill 的优先级如何？

**A**:
- Claude 会根据 description 相似度选择最匹配的 Skill
- 多个 Skill 可以同时存在
- 越具体的 description 越容易被选中

### Q8: 可以在 Skill 中调用其他 Skill 吗？

**A**:
- ❌ 不能直接调用
- ✅ 可以在 Skill 中说明"如需 XX，参考 YY Skill"
- 建议：保持 Skill 独立和自包含

---

## 📚 参考资源

### 官方文档
- [Claude Code Skills](https://docs.claude.com/en/docs/claude-code/skills)
- [MCP 协议](https://developers.openai.com/codex/mcp/)
- [OpenAI Codex](https://github.com/openai/codex)

### 项目文档
- [README.md](README.md) - 项目主文档
- [advanced.md](advanced.md) - 高级配置
- [api.md](api.md) - API 参考
- [troubleshooting.md](troubleshooting.md) - 故障排除

### 社区资源
- GitHub Issues: 报告问题和建议
- Discord/Slack: 社区讨论
- 博客文章: 使用经验分享

---

## 🤝 贡献

欢迎改进这个 Skill 配置！

### 如何贡献

```bash
# 1. Fork 项目
# 2. 创建特性分支
git checkout -b feature/improve-skill

# 3. 修改 Skill 配置
vim .claude/skills/codex-workflow/SKILL.md

# 4. 测试修改
./check-skill-health.sh

# 5. 提交 PR
git add .
git commit -m "feat: 改进 XX 功能"
git push origin feature/improve-skill
```

### 改进建议
- 添加更多使用示例
- 优化工作流程
- 改进提示模板
- 修复文档错误
- 增加语言支持

---

## 📄 许可证

MIT License - 详见 [LICENSE](LICENSE) 文件

---

## 🎉 总结

通过配置这个 Skill，你可以：

✅ **标准化** AI 协作工作流程
✅ **自动化** 工具调用和编排
✅ **可视化** 决策过程和输出
✅ **提升** 代码质量和一致性
✅ **加速** 开发效率和团队协作

**开始你的智能开发之旅吧！** 🚀

---

**更新日期**: 2025-11-12
**版本**: 1.0.0
**维护者**: Claude-Codex Team
