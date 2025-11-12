# Codex Workflow Skill

> 🎯 标准化的 Claude Code + Codex 协作工作流程

---

## 📋 文件说明

### SKILL.md
- **作用**：核心 Skill 定义文件
- **大小**：~15KB
- **内容**：
  - YAML frontmatter（name, description）
  - 激活场景定义
  - 6步标准工作流程
  - 工具调用规范
  - 文件组织标准
  - 故障恢复策略

### templates/

#### task-marker-format.txt
- **作用**：Task Marker 格式规范
- **格式**：YYYYMMDD-HHMMSS-XXXX
- **用途**：标识和关联任务

#### codex-prompt-template.md
- **作用**：Codex 调用提示模板
- **包含**：
  - 上下文收集模板
  - 深度问题分析模板
  - 复杂算法设计模板
  - 代码质量审查模板

#### context-initial-template.json
- **作用**：初始上下文收集JSON模板
- **字段**：
  - project_location
  - current_implementation
  - similar_cases
  - tech_stack
  - testing_info
  - observations

#### review-checklist.md
- **作用**：代码审查清单
- **维度**：
  - 技术维度（50分）：代码质量、测试覆盖、规范遵循
  - 战略维度（50分）：需求匹配、架构一致、风险评估

#### skill-troubleshooting.md
- **作用**：Skill 故障排除指南
- **包含**：
  - 常见问题及解决方案
  - 调试技巧
  - 健康检查清单

---

## 🚀 快速使用

### 方法1：项目本地使用（推荐）

```bash
# 1. Skill 已在项目中（.claude/skills/）
# 2. Claude Code 自动识别
# 3. 无需额外配置
```

### 方法2：全局安装

```bash
# macOS
cp -r /path/to/project/.claude/skills/codex-workflow \
     ~/Library/Application\ Support/Claude/skills/

# Linux
cp -r /path/to/project/.claude/skills/codex-workflow \
     ~/.config/claude/skills/

# 重启 Claude Code
```

---

## 🎯 工作原理

```
用户输入
    ↓
Claude 分析请求
    ↓
匹配 description: "complex code analysis (>10 lines)..."
    ↓
加载 SKILL.md
    ↓
执行6步工作流程
    ↓
生成标准化输出
```

---

## 📊 工作流程

```
1️⃣ 深度分析 (sequential-thinking)
   ↓
2️⃣ 上下文收集 (codex → context-initial.json)
   ↓
3️⃣ 任务规划 (shrimp-task-manager)
   ↓
4️⃣ 分工执行 (主AI + Codex → coding-progress.json)
   ↓
5️⃣ 质量审查 (codex → review-report.md)
   ↓
6️⃣ 知识记录 (operations-log.md)
```

---

## 🔧 自定义

### 修改激活条件

编辑 `SKILL.md` 的 YAML frontmatter：

```yaml
---
name: Codex Workflow Orchestrator
description: 修改这里以改变激活条件
---
```

### 调整工作流程

编辑 `SKILL.md` 的主体内容，修改或添加步骤

### 添加自定义模板

在 `templates/` 目录添加新文件，然后在 `SKILL.md` 中引用

---

## 📁 输出文件

Skill 执行后会在项目的 `.claude/` 目录生成：

```
.claude/
├── context-initial.json        # 初始代码扫描
├── context-question-N.json     # 深度分析（按需）
├── coding-progress.json        # 实时编码状态
├── review-report.md            # 代码审查报告
├── operations-log.md           # 决策记录
└── codex-sessions.json         # 会话管理
```

---

## ✅ 验证安装

```bash
# 返回项目根目录
cd /path/to/project

# 运行健康检查
./check-skill-health.sh

# 预期输出
# ✓ Skill 文件存在
# ✓ YAML frontmatter 格式正确
# ✓ 所有模板文件存在
# ...
```

---

## 🔍 测试 Skill

在 Claude Code 中输入测试请求：

```
测试1：帮我分析并优化这段代码
测试2：重构 src/module/file.ts
测试3：实现一个用户权限管理系统
```

预期：Claude 应该遵循6步工作流程执行

---

## 📚 相关文档

- [完整使用指南](../../SKILL-GUIDE.md)
- [快速参考](../../SKILL-QUICKREF.md)
- [项目主文档](../../README.md)
- [故障排除](../../troubleshooting.md)

---

## 🤝 贡献

欢迎改进 Skill！

```bash
# 1. 修改 SKILL.md 或模板
# 2. 测试修改
./check-skill-health.sh
# 3. 提交 PR
```

---

## 📝 版本历史

- **v1.0.0** (2025-11-12): 初始版本
  - 6步标准工作流
  - 完整模板库
  - 健康检查脚本

---

## 📄 许可证

MIT License

---

**开始使用吧！** 🚀
