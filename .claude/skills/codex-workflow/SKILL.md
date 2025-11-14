---
name: Codex Workflow Orchestrator
description: When user requests complex code analysis (>10 lines), refactoring, architectural design, code review, or multi-file changes, use this skill to coordinate sequential-thinking, codex, and shrimp-task-manager MCP servers following the standard 6-step workflow
---

# Codex 协作工作流编排器

## 🎯 激活场景

此 Skill 应在以下情况下自动激活：

### 必须激活
- ✅ 用户请求代码分析或重构（>10行核心逻辑）
- ✅ 需要深度理解复杂代码库
- ✅ 多文件协调修改
- ✅ 架构设计或技术选型
- ✅ 代码质量审查和优化建议

### 可选激活
- ⚡ 用户明确提到"深度分析"、"全面审查"
- ⚡ 任务涉及多个模块或组件
- ⚡ 需要生成详细的技术文档

### 不激活
- ❌ 简单的文件读写（<5行代码）
- ❌ 纯信息查询
- ❌ 文档编写（非代码相关）

---

## 📋 标准6步工作流程

### 第1步：深度需求分析
**工具**: `sequential-thinking`

**目标**: 深度理解用户需求，识别风险和复杂度

**调用方式**:
```
使用 sequential-thinking 分析：
1. 用户真实需求是什么
2. 任务复杂度评估
3. 潜在风险识别
4. 需要哪些上下文信息
```

**输出**: 清晰的任务理解和风险清单

---

### 第2步：全面上下文收集
**工具**: `mcp__codex__codex`

**目标**: 结构化扫描代码库，收集相关上下文

**调用模板**:
```javascript
mcp__codex__codex(
  model="gpt-5-codex",
  sandbox="danger-full-access",
  approval-policy="on-failure",
  prompt="[TASK_MARKER: {YYYYMMDD-HHMMSS-XXXX}]

目标：结构化快速扫描，收集 {任务描述} 相关的所有上下文

交付物：
1. 输出到 `.claude/context-initial.json`，包含：
   - project_location: 功能在哪个模块/文件
   - current_implementation: 现有实现方式
   - similar_cases: 代码库中的相似案例
   - tech_stack: 使用的技术栈
   - testing_info: 现有测试文件
   - observations: 发现的异常、信息不足之处、风险

时间限制：充分时间进行全面扫描"
)
```

**关键要求**:
- ⚠️ 必须生成 `TASK_MARKER` 格式: `YYYYMMDD-HHMMSS-XXXX`
- ⚠️ 输出必须到 `.claude/context-initial.json`
- ⚠️ 记录返回的 `conversationId` 用于后续调用

**输出**: `.claude/context-initial.json`

---

### 第3步：智能任务规划
**工具**: `shrimp-task-manager` (如果可用)

**目标**: 将复杂任务拆解为可执行的小步骤

**策略**:
1. 基于 `.claude/context-initial.json` 分析
2. 识别关键疑问
3. 拆解为具体子任务
4. 确定优先级和依赖关系

**输出**: 清晰的任务执行计划

---

### 第4步：分工执行开发

#### 主AI职责（我的工作）
- ✅ 简单逻辑编写（<10行）
- ✅ 文件读写操作
- ✅ 配置文件修改
- ✅ 文档更新
- ✅ 最终决策确认

#### Codex职责（委托工作）
- ✅ 复杂算法设计（>10行核心逻辑）
- ✅ 深度问题分析
- ✅ 技术方案对比

**Codex继续会话**:
```javascript
mcp__codex__codex-reply(
  conversationId="{从第2步获取的ID}",
  prompt="基于 `.claude/context-initial.json`，请{具体指令}

输出到：`.claude/context-question-{N}.json`"
)
```

**实时更新**:
创建/更新 `.claude/coding-progress.json`:
```json
{
  "current_task_id": "task-{MARKER}",
  "files_modified": ["src/file1.ts", "src/file2.ts"],
  "last_update": "{ISO8601时间戳}",
  "status": "coding",
  "pending_questions": [],
  "complexity_estimate": "moderate",
  "progress_percentage": 50
}
```

---

### 第5步：质量验证审查
**工具**: `mcp__codex__codex` + `sequential-thinking`

**目标**: 深度审查代码质量，生成评分报告

**调用方式**:
```javascript
mcp__codex__codex(
  model="gpt-5-codex",
  sandbox="danger-full-access",
  approval-policy="on-failure",
  prompt="[TASK_MARKER: {同上}]

使用 sequential-thinking 进行深度代码审查：

审查文件：
- {列出所有修改的文件}

审查维度：
1. 技术维度（代码质量、测试覆盖、规范遵循）
2. 战略维度（需求匹配、架构一致、风险评估）

输出到：`.claude/review-report.md`，必须包含：
- 评分（0-100）
- 明确建议（通过/退回/需讨论）
- 核对清单结果
- 风险与阻塞点
- 支持论据
"
)
```

**决策规则**:
- ≥90分 且建议"通过" → 直接确认通过
- <80分 且建议"退回" → 直接确认退回
- 80-89分 或建议"需讨论" → 仔细审阅后决策

**输出**: `.claude/review-report.md`

---

### 第6步：知识沉淀记录
**目标**: 记录决策过程，便于追溯

**操作**:
更新 `.claude/operations-log.md`:
```markdown
## {时间戳} - {任务描述}

### 操作记录
- 工具调用：sequential-thinking → codex → shrimp → codex
- 会话ID：{conversationId}

### 关键决策
- 决策1：{描述}
  - 理由：{原因}
  - 是否采纳Codex建议：是/否
  - 如否，原因：{说明}

### 输出文件
- context-initial.json
- context-question-{N}.json
- coding-progress.json
- review-report.md

### 最终结果
- 状态：completed/blocked
- 质量评分：{分数}
```

---

## 📁 文件组织规范

所有工作文件必须在项目本地 `.claude/` 目录：

```
<project>/.claude/
├── context-initial.json        # Codex 初步扫描
├── context-question-1.json     # Codex 深度分析1
├── context-question-2.json     # Codex 深度分析2
├── coding-progress.json        # 实时编码状态
├── operations-log.md           # 决策记录
├── review-report.md            # 审查报告
├── codex-sessions.json         # 会话管理
├── shrimp/                     # 任务管理数据
├── codex/                      # Codex 工作数据
├── context/                    # 上下文数据
├── logs/                       # 日志文件
└── cache/                      # 缓存数据
```

---

## 🎯 调用规范细节

### Task Marker 格式
```
格式：YYYYMMDD-HHMMSS-XXXX
示例：20251112-143025-0001

生成规则：
- YYYYMMDD：日期
- HHMMSS：时间
- XXXX：4位序号（从0001开始）
```

### ConversationId 管理
```javascript
// 首次调用返回格式：
"[CONVERSATION_ID]: conv-abc123xyz"

// 持久化到 codex-sessions.json：
{
  "sessions": [
    {
      "task_marker": "20251112-143025-0001",
      "conversation_id": "conv-abc123xyz",
      "timestamp": "2025-11-12T14:30:25Z",
      "description": "重构用户认证模块",
      "status": "active"
    }
  ]
}
```

---

## ⚡ 自动化执行策略

### 默认自动执行（无需确认）
- ✅ 所有文件读写操作
- ✅ 调用 sequential-thinking
- ✅ 调用 mcp__codex__codex
- ✅ 调用 mcp__codex__codex-reply
- ✅ 调用 shrimp-task-manager
- ✅ 代码编写、修改、重构
- ✅ 测试执行

### 需要用户确认
- ⚠️ Git push 到远程仓库
- ⚠️ 删除核心配置文件
- ⚠️ 数据库破坏性变更
- ⚠️ 连续3次相同错误后的策略调整

---

## 🔍 故障恢复策略

### Codex 调用失败
```
1. 检查 codex 是否安装：which codex
2. 验证 MCP 配置：检查 claude_desktop_config.json
3. 查看错误日志：tail -f .claude/logs/*.log
4. 重试（最多3次）
5. 如仍失败，降级为主AI独立完成
```

### 文件写入失败
```
1. 检查 .claude/ 目录权限：ls -la .claude/
2. 尝试创建目录：mkdir -p .claude/{context,logs}
3. 记录错误但继续任务
```

### 会话ID丢失
```
1. 查看 codex-sessions.json 最近记录
2. 基于 task_marker 恢复
3. 如无法恢复，启动新会话
```

---

## 📊 质量标准

### 上下文收集质量
- ✅ project_location 必须明确
- ✅ current_implementation 必须包含代码片段
- ✅ similar_cases 至少2个案例
- ✅ observations 必须包含风险评估

### 代码审查质量
- ✅ 技术维度和战略维度都有具体评分
- ✅ 明确的通过/退回/需讨论建议
- ✅ 至少3个核对清单项
- ✅ 风险点必须有缓解方案

### 决策记录质量
- ✅ 每个关键决策都有理由
- ✅ 推翻Codex建议必须说明原因
- ✅ 包含完整的工具调用链
- ✅ 文件路径必须准确

---

## 🎓 使用示例

### 示例1：重构复杂函数
```
用户: 帮我重构 src/auth/login.ts 的登录函数，优化性能

我的工作流程：
1. [使用 sequential-thinking 分析]
   → 识别：复杂度高，需全面分析

2. [调用 codex 上下文收集]
   → 扫描 auth 模块所有文件
   → 输出：.claude/context-initial.json

3. [制定任务计划]
   → 拆解为：性能分析、代码优化、测试验证

4. [执行开发]
   → 主AI：简单优化（缓存、去重）
   → Codex：复杂算法优化

5. [质量审查]
   → Codex 深度审查 + 评分
   → 输出：.claude/review-report.md

6. [记录决策]
   → 更新：.claude/operations-log.md
```

### 示例2：新功能开发
```
用户: 实现一个用户权限管理系统

我的工作流程：
1. [深度思考]
   → 理解：RBAC还是ABAC？需要哪些功能？

2. [上下文收集]
   → Codex 扫描现有认证系统
   → 查找相似的权限检查逻辑

3. [任务规划]
   → 数据模型 → API设计 → 前端集成 → 测试

4. [分工执行]
   → 主AI：配置文件、简单CRUD
   → Codex：权限判断算法、复杂查询

5. [审查验证]
   → Codex 全面审查安全性

6. [知识沉淀]
   → 记录架构决策和安全考虑
```

---

## 🚨 注意事项

1. **严格遵守工具调用顺序**
   - sequential-thinking → codex → shrimp → 执行 → 审查

2. **所有文件必须写入 .claude/ 目录**
   - 不要写入临时目录或用户目录

3. **Task Marker 必须一致**
   - 同一任务的所有操作使用同一个 marker

4. **ConversationId 必须记录**
   - 每次 codex 调用后立即记录到 codex-sessions.json

5. **决策透明化**
   - 推翻 Codex 建议必须说明理由

6. **错误处理**
   - 工具调用失败不应中断整个流程
   - 记录错误后降级处理

---

## 📚 参考资源

- 配置文件：`claude_desktop_config.json`
- 高级指南：`advanced.md`
- API 参考：`api.md`
- 故障排除：`troubleshooting.md`

---

**遵循此 Skill，确保 Claude Code + Codex 协作高效、规范、可追溯！**
