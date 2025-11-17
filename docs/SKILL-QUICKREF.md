# Claude Code + Codex Skill 快速参考

> 📌 一页纸速查手册

---

## 🚀 快速开始

```bash
# 1. 检查健康状态
./check-skill-health.sh

# 2. （可选）全局安装
cp -r .claude/skills/codex-workflow ~/Library/Application\ Support/Claude/skills/

# 3. 重启 Claude Code

# 4. 测试
# 输入: "帮我分析并优化这段代码"
```

---

## 📋 6步工作流程

```
1️⃣ 深度分析    → sequential-thinking
2️⃣ 上下文收集  → codex 扫描 → context-initial.json
3️⃣ 任务规划    → shrimp 拆解
4️⃣ 分工执行    → 主AI简单 + Codex复杂 → coding-progress.json
5️⃣ 质量审查    → codex + sequential-thinking → review-report.md
6️⃣ 知识记录    → operations-log.md
```

---

## 📁 关键文件

| 文件 | 位置 | 作用 |
|------|------|------|
| **SKILL.md** | `.claude/skills/codex-workflow/` | 核心工作流定义 |
| **context-initial.json** | `.claude/` | Codex 代码扫描结果 |
| **review-report.md** | `.claude/` | 代码审查报告 |
| **operations-log.md** | `.claude/` | 决策记录 |
| **codex-sessions.json** | `.claude/` | 会话管理 |

---

## 🎯 激活条件

**✅ 会激活：**
- 代码分析/重构（>10行）
- 多文件修改
- 架构设计
- 代码审查

**❌ 不激活：**
- 简单文件操作（<5行）
- 纯信息查询
- 文档编写

---

## 🔧 Task Marker 格式

```
格式：YYYYMMDD-HHMMSS-XXXX
示例：20251112-230000-0001

生成：date +%Y%m%d-%H%M%S-0001
```

---

## 📊 Codex 调用模板

### 首次调用（上下文收集）
```javascript
mcp__codex__codex(
  model="gpt-5-codex",
  prompt="[TASK_MARKER: 20251112-230000-0001]

目标：扫描 {模块} 收集上下文
交付物：输出到 .claude/context-initial.json"
)
```

### 继续会话
```javascript
mcp__codex__codex-reply(
  conversationId="conv-xyz123",
  prompt="基于之前的分析，请..."
)
```

### 代码审查
```javascript
mcp__codex__codex(
  prompt="[TASK_MARKER: {同上}]

使用 sequential-thinking 审查：
文件：{列表}
输出到：.claude/review-report.md"
)
```

---

## 📈 评分规则

```
≥90分 且"通过"     → ✅ 直接合并
<80分 且"退回"     → ❌ 需要返工
80-89分 或"需讨论" → ⚠️ 人工决策
```

---

## 🔍 故障排除

### Skill 未激活
```bash
# 检查文件
ls -la .claude/skills/codex-workflow/SKILL.md

# 检查 YAML
head -5 .claude/skills/codex-workflow/SKILL.md

# 重启 Claude Code
```

### Codex 调用失败
```bash
# 检查安装
which codex
codex --version

# 检查 MCP 配置
cat ~/Library/Application\ Support/Claude/claude_desktop_config.json | grep codex

# 检查工作目录
mkdir -p .claude/{codex,context,logs,cache}
```

### 输出文件缺失
```bash
# 创建目录
mkdir -p .claude/{codex,context,logs,cache}

# 检查权限
chmod -R 755 .claude/

# 查看日志
tail -f .claude/logs/*.log
```

---

## ⚙️ 必需的 MCP 配置

```json
{
  "mcpServers": {
    "sequential-thinking": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-sequential-thinking"]
    },
    "codex": {
      "type": "stdio",
      "command": "codex",
      "args": ["mcp-server"]
    }
  }
}
```

---

## 📝 输出文件格式

### context-initial.json
```json
{
  "project_location": "模块路径",
  "current_implementation": "现有实现",
  "similar_cases": ["案例1", "案例2"],
  "tech_stack": ["技术栈"],
  "observations": {
    "anomalies": ["异常"],
    "risks": ["风险"]
  }
}
```

### review-report.md
```markdown
## 评分
- 技术维度：XX/50
- 战略维度：XX/50
- 综合评分：XX/100

## 建议
【通过/退回/需讨论】
```

---

## 💡 最佳实践

1. **定期清理**：删除30天前的临时文件
2. **版本控制**：提交 `.claude/skills/` 到仓库
3. **团队共享**：统一 Skill 配置
4. **监控质量**：定期查看审查报告
5. **优化流程**：根据实际调整 SKILL.md

---

## 🔗 快速链接

- 📖 [完整指南](SKILL-GUIDE.md)
- 🔧 [故障排除](.claude/skills/codex-workflow/templates/skill-troubleshooting.md)
- 📋 [审查清单](.claude/skills/codex-workflow/templates/review-checklist.md)
- 🎯 [调用模板](.claude/skills/codex-workflow/templates/codex-prompt-template.md)

---

## 🎯 示例对话

```
用户: 帮我重构 src/auth/login.ts，函数太长了

Claude:
[加载 codex-workflow skill]

1️⃣ 使用 sequential-thinking 分析...
   ✓ 识别复杂度高，需全面分析

2️⃣ 调用 codex 扫描 auth 模块...
   ✓ 生成 context-initial.json
   ✓ conversationId: conv-xyz123

3️⃣ 制定重构计划...
   ✓ 拆分为3个子任务

4️⃣ 执行重构...
   ✓ 提取验证逻辑到独立模块
   ✓ 优化复杂算法

5️⃣ 质量审查...
   ✓ 评分：88/100
   ✓ 建议：需讨论配置化方案

6️⃣ 记录决策...
   ✓ 更新 operations-log.md

✅ 重构完成！
```

---

**需要帮助？** 运行 `./check-skill-health.sh` 或查看 [SKILL-GUIDE.md](SKILL-GUIDE.md)

---

**版本**: 1.0.0 | **更新**: 2025-11-12
