# Skill 故障排除指南

## 🔍 常见问题

### 问题1：Skill 没有被激活

**症状**：
- Claude 没有遵循 Skill 中定义的工作流程
- 没有调用 sequential-thinking 或 codex
- 工作流程不符合预期

**可能原因**：

#### A. Skill 文件位置错误
**检查**：
```bash
# 正确的位置（项目本地）
ls -la .claude/skills/codex-workflow/SKILL.md

# 或全局位置（Claude Code 配置目录）
# macOS
ls -la ~/Library/Application\ Support/Claude/skills/codex-workflow/SKILL.md

# Linux
ls -la ~/.config/claude/skills/codex-workflow/SKILL.md

# Windows (Git Bash)
ls -la $APPDATA/Claude/skills/codex-workflow/SKILL.md
```

**解决方案**：
```bash
# 如果文件不存在，复制到正确位置
cp -r .claude/skills/codex-workflow ~/Library/Application\ Support/Claude/skills/
```

#### B. YAML 元数据格式错误
**检查**：
```bash
# 查看 SKILL.md 前几行
head -10 .claude/skills/codex-workflow/SKILL.md
```

应该看到：
```markdown
---
name: Codex Workflow Orchestrator
description: When user requests complex code analysis...
---
```

**常见错误**：
```markdown
❌ 缺少结束的 ---
---
name: Codex Workflow Orchestrator
description: ...

❌ 缩进错误
---
  name: Codex Workflow Orchestrator
  description: ...
---

❌ 使用了引号
---
name: "Codex Workflow Orchestrator"
description: "When user requests..."
---
```

**解决方案**：
确保 YAML frontmatter 格式正确

#### C. Description 不够明确
**检查**：
description 字段是否清楚说明了**何时**应该激活这个 Skill

**改进示例**：
```markdown
❌ 太模糊
description: Help with code tasks

✅ 清晰明确
description: When user requests complex code analysis (>10 lines), refactoring, architectural design, code review, or multi-file changes, use this skill...
```

#### D. Claude Code 未重启
**解决方案**：
```
1. 完全退出 Claude Code
2. 重新启动应用
3. 在聊天中测试
```

---

### 问题2：Codex 调用失败

**症状**：
```
Error: mcp__codex__codex tool not found
Error: Failed to call codex
```

**诊断步骤**：

#### 步骤1：检查 Codex 安装
```bash
# 检查 codex 命令
which codex
# 预期输出：/usr/local/bin/codex 或类似路径

# 检查版本
codex --version
# 预期输出：codex 1.x.x

# 测试 MCP 服务器
codex mcp-server --help
# 应该显示帮助信息
```

**如果未安装**：
```bash
# 参考 OpenAI 官方文档安装
# https://github.com/openai/codex
```

#### 步骤2：检查 MCP 配置
```bash
# macOS
cat ~/Library/Application\ Support/Claude/claude_desktop_config.json

# Linux
cat ~/.config/claude/claude_desktop_config.json
```

**应该包含**：
```json
{
  "mcpServers": {
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

**常见错误**：
```json
❌ 拼写错误
"command": "codex-mcp"  // 应该是 "codex"

❌ 参数错误
"args": ["server"]  // 应该是 ["mcp-server"]

❌ JSON 语法错误
"command": "codex",  // 最后一项不应有逗号
```

#### 步骤3：检查工作目录
```bash
# 确保 .claude 目录存在
mkdir -p .claude/{codex,context,logs,cache}

# 检查权限
ls -la .claude/
# 应该有读写权限
```

#### 步骤4：查看错误日志
```bash
# Claude Code 日志位置
# macOS
tail -f ~/Library/Logs/Claude/main.log

# Linux
tail -f ~/.config/claude/logs/main.log

# 项目日志
tail -f .claude/logs/*.log
```

---

### 问题3：文件写入失败

**症状**：
```
Error: EACCES: permission denied, open '.claude/context-initial.json'
Error: ENOENT: no such file or directory
```

**解决方案**：

#### A. 创建目录结构
```bash
mkdir -p .claude/{shrimp,codex,context,logs,cache}
chmod -R 755 .claude/
```

#### B. 检查磁盘空间
```bash
df -h .
# 确保有足够空间
```

#### C. 检查文件系统权限
```bash
# 检查当前用户对项目目录的权限
ls -la .

# 如果权限不足
sudo chown -R $USER:$USER .
```

---

### 问题4：Task Marker 格式错误

**症状**：
- Codex 无法识别任务
- 会话管理混乱
- 文件无法关联

**错误示例**：
```
❌ 2025-11-12-143025-0001  // 错误：使用了4个部分
❌ 20251112-143025         // 错误：缺少序号
❌ 20251112_143025_0001    // 错误：使用下划线
❌ 20251112-143025-1       // 错误：序号不够4位
```

**正确格式**：
```
✅ 20251112-143025-0001
格式：YYYYMMDD-HHMMSS-XXXX
```

**生成脚本**：
```bash
# Bash
date +%Y%m%d-%H%M%S-0001

# 添加到 .bashrc 或 .zshrc
alias task-marker='date +%Y%m%d-%H%M%S-0001'
```

---

### 问题5：ConversationId 丢失

**症状**：
- 无法继续 Codex 会话
- 每次都创建新会话
- 上下文丢失

**原因**：
未正确保存或读取 conversationId

**解决方案**：

#### A. 创建会话管理文件
```bash
cat > .claude/codex-sessions.json << 'EOF'
{
  "sessions": []
}
EOF
```

#### B. 检查 Codex 响应
Codex 响应末尾应包含：
```
[CONVERSATION_ID]: conv-abc123xyz
```

#### C. 手动记录（临时方案）
```bash
# 在项目根目录创建临时文件
echo "conv-abc123xyz" > .claude/current-conversation-id.txt

# 后续调用时读取
CONV_ID=$(cat .claude/current-conversation-id.txt)
```

---

### 问题6：Sequential-thinking 未生效

**症状**：
- Codex 没有进行深度推理
- 分析不够深入
- 缺少风险识别

**检查**：

#### A. MCP 配置
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
    }
  }
}
```

#### B. 安装状态
```bash
# 测试 sequential-thinking
npx -y @modelcontextprotocol/server-sequential-thinking --help

# 应该显示帮助信息
```

#### C. 在 Codex prompt 中明确要求
```
使用 sequential-thinking 进行深度分析：
1. ...
2. ...
```

---

### 问题7：输出文件不符合规范

**症状**：
- context-initial.json 缺少字段
- review-report.md 格式混乱
- operations-log.md 信息不完整

**解决方案**：

#### A. 使用模板
```bash
# 复制模板到工作目录
cp .claude/skills/codex-workflow/templates/context-initial-template.json \
   .claude/context-initial-template.json
```

#### B. 在 Codex prompt 中明确要求
```
输出到 `.claude/context-initial.json`，必须包含以下字段：
- project_location
- current_implementation
- similar_cases
- tech_stack
- testing_info
- observations
  - anomalies
  - info_gaps
  - suggestions
  - risks
```

#### C. 验证输出
```bash
# 使用 jq 验证 JSON 格式
cat .claude/context-initial.json | jq .

# 检查必需字段
jq 'has("project_location", "tech_stack", "observations")' \
   .claude/context-initial.json
```

---

## 🔧 调试技巧

### 技巧1：启用详细日志
```bash
# 设置环境变量
export DEBUG=mcp:*
export CLAUDE_LOG_LEVEL=debug

# 重启 Claude Code
```

### 技巧2：逐步验证
```bash
# 1. 验证 Skill 文件
cat .claude/skills/codex-workflow/SKILL.md

# 2. 验证 MCP 配置
cat ~/Library/Application\ Support/Claude/claude_desktop_config.json | jq .

# 3. 验证工具可用性
npx -y @modelcontextprotocol/server-sequential-thinking --version
codex --version

# 4. 验证目录权限
ls -la .claude/

# 5. 验证文件内容
cat .claude/context-initial.json | jq .
```

### 技巧3：使用最小化测试
创建简单的测试 Skill：
```markdown
---
name: Test Skill
description: When user says "test skill", respond with "Skill activated!"
---

# Test Skill

When activated, simply respond: "Skill activated! ✅"
```

测试：
```
用户: test skill
Claude: Skill activated! ✅
```

### 技巧4：对比工作案例
```bash
# 备份当前配置
cp ~/Library/Application\ Support/Claude/claude_desktop_config.json \
   ~/claude_desktop_config.backup.json

# 尝试最小配置
cat > ~/Library/Application\ Support/Claude/claude_desktop_config.json << 'EOF'
{
  "mcpServers": {
    "codex": {
      "type": "stdio",
      "command": "codex",
      "args": ["mcp-server"]
    }
  }
}
EOF

# 重启测试
# 如果工作，逐步添加配置项
```

---

## 📞 获取帮助

### 1. 检查官方文档
- Claude Code Skills: https://docs.claude.com/en/docs/claude-code/skills
- MCP 文档: https://developers.openai.com/codex/mcp/
- OpenAI Codex: https://github.com/openai/codex

### 2. 查看项目文档
```bash
cat README.md
cat troubleshooting.md
cat api.md
cat advanced.md
```

### 3. 运行验证脚本
```bash
./verify-config.sh
```

### 4. 社区支持
- GitHub Issues
- Discord/Slack 社区
- Stack Overflow

---

## ✅ 健康检查清单

运行此清单确保一切正常：

```bash
#!/bin/bash
echo "🔍 Skill 健康检查"

# 1. Skill 文件存在
if [ -f ".claude/skills/codex-workflow/SKILL.md" ]; then
    echo "✅ Skill 文件存在"
else
    echo "❌ Skill 文件缺失"
fi

# 2. MCP 配置正确
if jq -e '.mcpServers.codex' ~/Library/Application\ Support/Claude/claude_desktop_config.json > /dev/null 2>&1; then
    echo "✅ MCP 配置存在"
else
    echo "❌ MCP 配置缺失"
fi

# 3. Codex 已安装
if command -v codex &> /dev/null; then
    echo "✅ Codex 已安装: $(codex --version)"
else
    echo "❌ Codex 未安装"
fi

# 4. 工作目录存在
if [ -d ".claude" ]; then
    echo "✅ 工作目录存在"
else
    echo "❌ 工作目录缺失"
    mkdir -p .claude/{codex,context,logs,cache}
fi

# 5. 权限正确
if [ -w ".claude" ]; then
    echo "✅ 目录可写"
else
    echo "❌ 目录不可写"
fi

echo ""
echo "检查完成！"
```

保存为 `check-skill-health.sh` 并运行：
```bash
chmod +x check-skill-health.sh
./check-skill-health.sh
```

---

**遇到其他问题？请查看主项目的 troubleshooting.md 或提交 Issue！**
