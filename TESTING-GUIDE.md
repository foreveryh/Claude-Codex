# Codex Workflow Skill 测试指南

> 🧪 用于测试 Skill 功能并验证 Codex 返回内容的实际大小

---

## 📦 第一步：拉取最新代码

```bash
# 1. 确保在正确的分支
git fetch origin
git checkout claude/analyze-project-logic-011CV4iSiKLMQmoWULGYvChi
git pull origin claude/analyze-project-logic-011CV4iSiKLMQmoWULGYvChi

# 2. 验证 Skill 文件存在
ls -la .claude/skills/codex-workflow/

# 应该看到：
# - SKILL.md (核心文件)
# - README.md (说明文档)
# - templates/ (模板目录)
```

---

## ✅ 第二步：验证环境

```bash
# 运行健康检查脚本
./check-skill-health.sh

# 关键检查项：
# ✓ Skill 文件存在
# ✓ YAML frontmatter 格式正确
# ✓ 模板文件完整
# ⚠️ Codex 安装状态（可能显示未安装，这是正常的）
```

**预期输出**：
```
✓ Skill 文件存在
✓ YAML frontmatter 格式正确
✓ 所有模板文件存在
...
```

---

## 🔧 第三步：配置 Claude Code

### 选项A：项目本地使用（推荐，无需配置）

**Claude Code 会自动识别项目中的 `.claude/skills/` 目录**

无需任何配置！直接进入测试步骤。

### 选项B：全局安装（可选）

如果想在所有项目中使用：

```bash
# macOS
cp -r .claude/skills/codex-workflow ~/Library/Application\ Support/Claude/skills/

# Linux
cp -r .claude/skills/codex-workflow ~/.config/claude/skills/

# Windows (Git Bash)
cp -r .claude/skills/codex-workflow $APPDATA/Claude/skills/
```

### 验证 MCP 配置

检查 Claude Code 的 MCP 配置文件：

```bash
# macOS
cat ~/Library/Application\ Support/Claude/claude_desktop_config.json

# Linux
cat ~/.config/claude/claude_desktop_config.json

# Windows
cat $APPDATA/Claude/claude_desktop_config.json
```

**必须包含 codex 配置**：
```json
{
  "mcpServers": {
    "codex": {
      "type": "stdio",
      "command": "codex",
      "args": ["mcp-server"]
    }
  }
}
```

---

## 🧪 第四步：测试计划

我们需要测试三个关键问题：

### 测试1：Skill 是否被激活？
### 测试2：Codex 返回多少内容？
### 测试3：工作流是否正确执行？

---

## 🎯 测试1：验证 Skill 激活

### 测试步骤：

1. **重启 Claude Code**（重要！）
   - 完全退出应用
   - 重新启动

2. **在 Claude Code 中打开这个项目**
   ```
   File > Open > 选择 Claude-Codex 目录
   ```

3. **发起测试对话**

   **测试请求1（应该激活 Skill）**：
   ```
   帮我分析并重构 install.sh 脚本，这个脚本有 400 多行，太复杂了
   ```

4. **观察 Claude 的响应**

### 期望行为：

**如果 Skill 激活成功**：
```
Claude 的回复应该提到：
- "我会遵循 6 步工作流程"
- "第1步：使用 sequential-thinking 深度分析"
- "第2步：调用 codex 扫描代码"
- 或其他明确引用工作流步骤的内容
```

**如果 Skill 未激活**：
```
Claude 会直接开始分析代码，
不会提到工作流程步骤
```

### 📊 收集信息1：Skill 激活状态

**请记录**：
```markdown
## 测试1结果

**测试时间**：[时间]

**测试请求**：
```
帮我分析并重构 install.sh 脚本，这个脚本有 400 多行，太复杂了
```

**Claude 响应开头**（前200字）：
```
[粘贴 Claude 的回复开头]
```

**Skill 是否激活**：[ ] 是  [ ] 否

**判断依据**：
[是否提到工作流程步骤]
```

---

## 🔍 测试2：验证 Codex 返回内容大小

这是**最关键的测试**！用于验证我的分析是否正确。

### 测试步骤：

1. **如果测试1中 Skill 已激活**，继续当前对话

2. **如果测试1中 Skill 未激活**，先让 Skill 激活：
   ```
   请使用 codex-workflow skill 来分析这个脚本
   ```

3. **当 Claude 准备调用 Codex 时**，仔细观察

4. **关键观察点**：
   - Codex 调用完成后，Claude 的响应长度
   - Claude 是否显示了大量的扫描结果
   - 还是只是简短的确认消息

### 期望的两种可能：

**可能性A：简短返回（优化模式）** ✅
```
Claude 可能说：
"✓ Codex 扫描完成
- 分析了 install.sh (447 行)
- 发现 5 个复杂度热点
- 详细结果已保存到 .claude/context-initial.json

现在让我查看详细分析..."
```

**可能性B：详细返回（传统模式）** ⚠️
```
Claude 可能说：
"Codex 返回了详细的分析结果：

{
  "project_location": "install.sh:1-447",
  "current_implementation": "这是一个 Bash 安装脚本...[大量文字]",
  "similar_cases": [...],
  "observations": {
    "anomalies": [
      "函数 check_dependencies (line 53-85) 复杂度过高",
      "函数 install_packages_by_config (line 176-195) 缺少错误处理",
      [... 更多详细内容]
    ]
  }
}

基于这些分析..."
```

### 📊 收集信息2：Codex 返回内容

**请记录**：
```markdown
## 测试2结果

**Codex 调用时机**：
[Claude 在什么时候调用了 Codex]

**Codex 返回后，Claude 的完整响应**：
```
[粘贴 Claude 在 Codex 返回后的完整回复]
```

**返回内容估算**：
[ ] 简短确认（~50-200 字）
[ ] 中等摘要（~200-1000 字）
[ ] 详细输出（>1000 字，包含完整 JSON）

**Claude 是否展示了 context-initial.json 的完整内容**：
[ ] 是  [ ] 否

**额外观察**：
[任何其他相关信息]
```

---

## 📁 测试3：检查输出文件

### 测试步骤：

1. **查看生成的文件**
   ```bash
   # 在项目目录执行
   ls -lh .claude/

   # 查看 context-initial.json（如果生成）
   cat .claude/context-initial.json | head -50

   # 或者查看完整文件大小
   wc -l .claude/context-initial.json
   du -h .claude/context-initial.json
   ```

2. **对比文件内容 vs Claude 显示的内容**
   - 文件中有什么？
   - Claude 显示了文件的多少内容？

### 📊 收集信息3：文件输出

**请记录**：
```markdown
## 测试3结果

**生成的文件**：
```bash
$ ls -lh .claude/
[粘贴输出]
```

**context-initial.json 大小**：
```bash
$ wc -l .claude/context-initial.json
[行数]

$ du -h .claude/context-initial.json
[文件大小]
```

**文件内容摘要**（前 20 行）：
```bash
$ head -20 .claude/context-initial.json
[粘贴输出]
```

**对比分析**：
- 文件总行数：[X] 行
- Claude 显示的行数：[估计 Y] 行
- Claude 是否展示了完整内容：[ ] 是  [ ] 否
```

---

## 🎯 测试4：继续会话测试（可选但重要）

如果前面的测试进行顺利，可以测试"继续会话"功能：

### 测试步骤：

1. **在同一对话中继续**
   ```
   基于刚才的分析，请 Codex 设计一个重构方案
   ```

2. **观察 Claude 是否使用 codex-reply**
   - 是否提到 conversationId
   - 是否引用之前的 context-initial.json

3. **观察返回内容**
   - 新的输出大小
   - 是否又生成了 context-question-1.json

### 📊 收集信息4：继续会话

**请记录**：
```markdown
## 测试4结果

**继续会话请求**：
```
[你的请求]
```

**Claude 是否使用 codex-reply**：[ ] 是  [ ] 否

**Claude 的响应**：
```
[粘贴响应]
```

**新生成的文件**：
```bash
$ ls -lh .claude/
[列出所有文件]
```
```

---

## 📤 提供测试结果

### 方式1：汇总报告

把上面的信息整理成一个完整的报告发给我：

```markdown
# Codex Workflow Skill 测试报告

## 环境信息
- 操作系统：[macOS/Linux/Windows]
- Claude Code 版本：[版本号]
- Codex 状态：[已安装/未安装]

## 测试1：Skill 激活
[粘贴信息]

## 测试2：Codex 返回内容
[粘贴信息]

## 测试3：文件输出
[粘贴信息]

## 测试4：继续会话（可选）
[粘贴信息]

## 总结观察
[你的整体观察和感受]
```

### 方式2：分步反馈

也可以每完成一个测试就告诉我结果，我们边测边分析。

---

## 🚨 可能遇到的问题

### 问题1：Skill 不激活

**症状**：Claude 没有提到工作流步骤

**可能原因**：
1. Claude Code 未重启
2. Skill 文件未正确识别
3. description 不匹配请求

**解决方案**：
```bash
# 检查 SKILL.md 的 YAML
head -10 .claude/skills/codex-workflow/SKILL.md

# 确保看到：
---
name: Codex Workflow Orchestrator
description: When user requests complex code analysis...
---

# 然后重启 Claude Code
```

### 问题2：Codex 未安装

**症状**：Claude 提示 "codex tool not found"

**说明**：这是正常的！说明：
1. ✅ Skill 成功激活了
2. ✅ Claude 尝试调用 Codex
3. ⚠️ Codex MCP 服务器未配置

**不影响测试目标1**（验证 Skill 激活）

**但无法完成测试2-4**（需要 Codex 实际运行）

### 问题3：权限错误

**症状**：无法写入 .claude/ 目录

**解决方案**：
```bash
chmod -R 755 .claude/
mkdir -p .claude/{codex,context,logs,cache}
```

---

## ✅ 测试成功标准

### 最小成功标准：

- ✅ Skill 文件存在且格式正确
- ✅ Skill 被 Claude 成功激活（提到工作流步骤）

### 完整成功标准：

- ✅ 上述最小标准
- ✅ Codex 成功调用并返回结果
- ✅ 生成了 context-initial.json 文件
- ✅ 确认了 Codex 返回内容的实际大小

### 额外收获：

- ✅ 验证了继续会话功能
- ✅ 确认了完整的 6 步工作流
- ✅ 收集了实际使用体验

---

## 📞 获取帮助

如果遇到任何问题：

1. **先运行健康检查**：`./check-skill-health.sh`
2. **查看故障排除文档**：`.claude/skills/codex-workflow/templates/skill-troubleshooting.md`
3. **把错误信息发给我**，我会帮你解决

---

## 🎯 测试的核心目标

通过这次测试，我们要回答：

1. **Skill 是否正常工作**？（验证我的设计）
2. **Codex 实际返回多少内容**？（验证我的分析假设）
3. **工作流是否如预期执行**？（验证整体架构）

这些数据将帮助我们：
- 确认当前 Skill 的实际行为
- 决定是否需要优化
- 设计更准确的改进方案

---

**准备好了吗？Let's test! 🚀**
