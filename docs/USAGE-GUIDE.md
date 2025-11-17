# Claude-Codex 使用指南

> 📚 详细的场景对比和最佳实践

---

## 📋 目录

1. [快速选择](#快速选择)
2. [使用场景对比](#使用场景对比)
3. [脚本说明](#脚本说明)
4. [安装步骤](#安装步骤)
5. [最佳实践](#最佳实践)
6. [故障排除](#故障排除)
7. [FAQ](#faq)

---

## 🚀 快速选择

不确定用哪个？用这个决策流程：

```
┌──────────────────────────────────┐
│ 你是个人开发者吗？               │
├──┬───────────────────────────────┘
│ 是 │ 不是
│    │
│ ┌──▼────────┐      ┌───────────▼──┐
│ │ 全局安装  │      │ 团队协作？   │
│ │ 一次配置  │      ├──┬───────────┘
│ │ 处处可用  │      │ 是 │ 不是
│ │ ⭐ 推荐   │      │    │
│ └───────────┘      │ ┌▼───────────┐
│                     │ │ 项目安装    │
│                     │ │ .mcp.json   │
│                     │ │ 版本控制    │
│                     │ └─────────────┘
│                     │
│                     │ 开始就选最简方案
│                     │ 先用全局，后续可改
└─────────────────────┴────────────────────
```

**一句话总结**：
- **个人用** → 选择 **全局安装**（`install-global.sh` 或交互式 `install`）
- **团队用** → 选择 **项目安装**（`install-project.sh`）

---

## 💡 使用场景对比

### 场景 1：个人开发者（最常见）⭐

**特征**：
- 在个人电脑上开发多个项目
- 希望在所有项目中使用相同的 AI 工具
- 不想重复配置，追求开箱即用的体验

**推荐方案**：**全局安装（User Scope）**

**优点**：
- ✅ 配置一次，所有项目自动生效
- ✅ 无需记住复杂的 URL 或命令
- ✅ 新项目只需要 `mkdir .claude` 即可使用
- ✅ 适合长期使用，维护成本低

**缺点**：
- ❌ 配置不可见（内部管理）
- ❌ 不适合团队协作（无法版本控制）

**使用流程**：

```bash
# 1. 全局安装（一次）
bash <(curl -sSL https://raw.githubusercontent.com/foreveryh/Claude-Codex/main/install-global.sh)

# 2. 在新项目中使用
cd ~/Projects/my-new-project
mkdir -p .claude

# 3. 直接启动 Claude Code
claude  # 所有 MCP 工具已可用！

# 或者使用快速初始化
curl -sSL https://raw.githubusercontent.com/foreveryh/Claude-Codex/main/init-workspace.sh | bash
```

---

### 场景 2：团队协作

**特征**：
- 多人开发同一个项目
- 需要统一的工具链配置
- 配置需要可版本控制

**推荐方案**：**项目安装（Project Scope）**

**优点**：
- ✅ 配置可见（.mcp.json）
- ✅ 可版本控制，提交到 Git
- ✅ 团队成员 pull 后自动生效
- ✅ 确保团队使用相同工具

**缺点**：
- ❌ 每个项目都需要单独配置
- ❌ 如果项目很多，维护成本高

**使用流程**：

```bash
# 1. 在项目根目录安装（生成 .mcp.json）
cd team-project
curl -sSL https://raw.githubusercontent.com/foreveryh/Claude-Codex/main/install-project.sh | bash

# 2. 提交到版本控制
git add .mcp.json
git commit -m "feat: 添加 Claude-Codex 配置"
git push

# 3. 团队成员 clone 或 pull 后
git pull
claude  # 配置自动加载，直接使用
```

---

### 场景 3：混合使用（高级）

**特征**：
- 既有个人项目，也参与团队项目
- 想在所有项目中使用基础工具
- 但团队项目需要额外工具

**推荐方案**：**全局 + 项目 组合**

**实现方式**：
1. 先运行全局安装（基础工具）
2. 在团队项目中运行项目安装（额外工具）

**工作原理**：
- Claude Code 会合并全局和项目配置
- 项目配置优先级更高（会覆盖同名工具）
- 最终配置 = 全局配置 + 项目配置

**示例**：

```bash
# 1. 全局安装（个人工具）
bash <(curl -sSL https://raw.githubusercontent.com/foreveryh/Claude-Codex/main/install-global.sh)
# 包含：sequential-thinking, codex

# 2. 在团队项目中安装（团队工具）
cd team-project
curl -sSL https://raw.githubusercontent.com/foreveryh/Claude-Codex/main/install-project.sh | bash
# 额外添加：团队自定义 MCP server

# 3. 最终配置
# - 基础工具（全局）
# - + 团队工具（项目级）
```

---

### 场景 4：快速体验

**特征**：
- 想快速了解 Claude-Codex 的功能
- 不想花费时间配置
- 可能已经用过，换项目了

**推荐方案**：**交互式安装 或 快速初始化**

**选项 A：交互式向导（推荐新手）**

```bash
bash <(curl -sSL https://raw.githubusercontent.com/foreveryh/Claude-Codex/main/install)

# 脚本交互式引导：
# [1] 全局安装（推荐个人）
# [2] 项目安装（推荐团队）
# [3] 快速初始化（已有全局配置）
```

**选项 B：快速初始化（已有全局配置）**

```bash
cd new-project
curl -sSL https://raw.githubusercontent.com/foreveryh/Claude-Codex/main/init-workspace.sh | bash

# 1 秒完成，只创建 .claude 目录
# 适合已经全局安装过，只需要工作目录
```

---

## 📦 脚本说明

### install（统一入口）

**用途**：交互式安装向导，引导用户选择合适的安装方式

**使用方法**：
```bash
bash <(curl -sSL https://raw.githubusercontent.com/foreveryh/Claude-Codex/main/install)
```

**适用场景**：
- 不确定该用哪个安装方式
- 第一次使用，希望有引导
- 想要一次看清所有选项

**功能特点**：
- ✅ 友好的交互式界面
- ✅ 清晰的选项说明
- ✅ 自动根据选择执行对应脚本
- ✅ 显示下一步操作指引

---

### install-global.sh（全局安装）

**用途**：配置 User Scope MCP servers，一次配置，所有项目可用

**使用方法**：
```bash
bash <(curl -sSL https://raw.githubusercontent.com/foreveryh/Claude-Codex/main/install-global.sh)
```

**配置级别**：User Scope（内部管理，不可见）

**包含工具**：
- sequential-thinking（深度思考）
- shrimp-task-manager（任务管理）
- codex（代码分析）
- code-index（代码索引）
- chrome-devtools（浏览器调试）

**存储位置**：Claude Code 内部管理（~/.claude/）

**适用场景**：
- 个人开发者，多个项目
- 不想重复配置
- 追求便捷性

---

### install-project.sh（项目安装）

**用途**：生成 .mcp.json 配置文件，可版本控制，团队共享

**使用方法**：
```bash
cd project/
bash <(curl -sSL https://raw.githubusercontent.com/foreveryh/Claude-Codex/main/install-project.sh)
```

**配置级别**：Project Scope（.mcp.json，可见）

**存储位置**：`<project>/.mcp.json`

**适用场景**：
- 团队项目
- 需要共享配置
- 需要版本控制

---

### init-workspace.sh（快速初始化）

**用途**：快速创建 .claude 工作目录

**使用方法**：
```bash
cd project/
curl -sSL https://raw.githubusercontent.com/foreveryh/Claude-Codex/main/init-workspace.sh | bash
```

**功能**：
- 创建 .claude 及子目录（shrimp, codex, context, logs, cache）
- 更新 .gitignore（自动忽略日志和缓存）
- 检查全局配置是否已设置

**适用场景**：
- 已完成全局安装
- 新项目需要创建工作目录
- 追求快速初始化（1 秒完成）

**前提条件**：
- 已经运行过 `install-global.sh` 或 `install`（已配置 User Scope）

---

## 📋 安装步骤

### 个人开发者（推荐）

**第 1 步：全局安装**

```bash
# 方式 A：交互式向导（推荐）
bash <(curl -sSL https://raw.githubusercontent.com/foreveryh/Claude-Codex/main/install)
# 选择 [1] 全局安装

# 方式 B：直接安装
bash <(curl -sSL https://raw.githubusercontent.com/foreveryh/Claude-Codex/main/install-global.sh)
```

**第 2 步：验证配置**

```bash
claude mcp list
# 应显示 5 个 MCP servers
```

**第 3 步：在新项目中使用**

```bash
cd ~/Projects/new-project

# 方式 A：快速初始化（推荐）
curl -sSL https://raw.githubusercontent.com/foreveryh/Claude-Codex/main/init-workspace.sh | bash

# 方式 B：手动创建
mkdir -p .claude

# 启动 Claude Code
claude
```

---

### 团队协作

**第 1 步：项目安装**

```bash
cd team-project

# 方式 A：交互式向导
bash <(curl -sSL https://raw.githubusercontent.com/foreveryh/Claude-Codex/main/install)
# 选择 [2] 项目安装

# 方式 B：直接安装
bash <(curl -sSL https://raw.githubusercontent.com/foreveryh/Claude-Codex/main/install-project.sh)
```

**第 2 步：提交到版本控制**

```bash
git add .mcp.json
git commit -m "feat: 添加 Claude-Codex 配置"
git push
```

**第 3 步：团队成员使用**

```bash
git clone team-project
cd team-project
claude  # 配置自动加载
```

---

## 🎯 最佳实践

### ✅ 推荐做法

1. **新手用户**：
   - 从 `install`（交互式向导）开始
   - 仔细阅读每一步的说明
   - 可以先看效果，不懂再查文档

2. **个人开发者**：
   - 使用 `install-global.sh`（全局安装）
   - 所有新项目直接使用，无需重复配置
   - 习惯后使用 `init-workspace.sh` 快速初始化

3. **团队项目**：
   - 使用 `install-project.sh`（项目安装）
   - 将 `.mcp.json` 提交到版本控制
   - 在 `README.md` 中说明配置和使用方法

4. **混合使用**：
   - 先全局安装基础工具
   - 团队项目额外添加项目级工具
   - 避免配置冲突（使用不同的 server 名称）

5. **工作目录管理**：
   - 使用 `init-workspace.sh` 自动创建目录
   - 确保 `.claude/logs/` 和 `.claude/cache/` 被 .gitignore
   - 定期清理 `.claude/cache/`（可选）

### ❌ 避免做法

1. **不要混用同名工具**：
   - 不要在全局和项目中都配置名为 "codex" 的 server
   - 如果需要区分，使用不同的名称（如 "codex-personal", "codex-team"）

2. **不要提交敏感信息**：
   - API 密钥不要直接写入 .mcp.json
   - 使用环境变量存储敏感信息
   - 使用 `claude mcp add --env` 添加环境变量

3. **不要过度配置**：
   - 只安装需要的工具，避免资源浪费
   - 简单项目用简单配置，复杂项目再升级

4. **不要忽略错误提示**：
   - 安装失败时仔细阅读错误信息
   - 检查依赖是否已安装（npx, codex, uvx）
   - 使用 `claude mcp list` 验证连接

---

## 🔧 故障排除

### 问题 1：安装后看不到 MCP 工具

**症状**：`claude mcp list` 显示为空或不完整

**排查步骤**：

```bash
# 1. 检查 Claude Code 是否安装
which claude

# 2. 检查全局配置（如果使用了全局安装）
claude mcp list

# 3. 检查项目配置（如果使用了项目安装）
cat .mcp.json  # 应该存在且有内容

# 4. 重新安装
bash <(curl -sSL https://raw.githubusercontent.com/foreveryh/Claude-Codex/main/install)

# 5. 重启 Claude Code
# 退出后重新运行 `claude`
```

---

### 问题 2：MCP 服务器连接失败

**症状**：`claude mcp list` 显示 "Disconnected"

**原因**：
- 依赖未安装（npx, codex, uvx）
- 网络问题
- 端口冲突
- 环境变量错误

**解决方案**：

```bash
# 1. 检查依赖
npx --version    # 应该返回版本号
codex --version  # 应该返回版本号
uvx --version    # 应该返回版本号

# 2. 重新安装依赖
npm install -g @anthropic-ai/claude-code  # Claude Code
npm install -g codex                      # Codex CLI
pip install uv                            # uvx runner

# 3. 验证 MCP server
npx @modelcontextprotocol/server-sequential-thinking --help
codex mcp-server --help
uvx code-index-mcp --help

# 4. 重启 Claude Code
claude

# 5. 验证连接
claude mcp list  # 应该显示 Connected
```

---

### 问题 3：权限错误

**症状**：Permission denied 或无法创建目录

**解决方案**：

```bash
# 1. 检查当前目录权限
ls -la

# 2. 确保有写入权限
mkdir -p .claude  # 手动创建工作目录

# 3. 如果使用了 sudo 安装，可能需要更改权限
sudo chown -R $(whoami) ~/.claude/
```

---

### 问题 4：配置文件损坏

**症状**：JSON 语法错误，配置无法加载

**解决方案**：

```bash
# 1. 备份现有配置
cp .mcp.json .mcp.json.backup 2>/dev/null || true

# 2. 重新安装
bash <(curl -sSL https://raw.githubusercontent.com/foreveryh/Claude-Codex/main/install-project.sh)

# 3. 验证配置文件
cat .mcp.json | python3 -m json.tool  # 应该显示格式化后的 JSON

# 4. 如果仍然失败，使用备份恢复
cp .mcp.json.backup .mcp.json
```

---

### 问题 5：Git 冲突

**症状**：.mcp.json 产生合并冲突

**解决方案**：

```bash
# 1. 查看冲突
GIT MERGE TOOL  # 或使用编辑器查看冲突

# 2. 解决冲突（保留需要的配置）
# 例如：保留自己的 codex 配置，合并团队的自定义工具

# 3. 验证 JSON 语法
cat .mcp.json | python3 -m json.tool

# 4. 提交解决后的配置
git add .mcp.json
git commit -m "fix: 解决 .mcp.json 合并冲突"
```

---

### 问题 6：快速初始化失败

**症状**：`init-workspace.sh` 提示找不到全局配置

**解决方案**：

```bash
# 1. 验证是否已全局安装
claude mcp list

# 2. 如果为空，运行全局安装
bash <(curl -sSL https://raw.githubusercontent.com/foreveryh/Claude-Codex/main/install-global.sh)

# 3. 再次运行快速初始化
curl -sSL https://raw.githubusercontent.com/foreveryh/Claude-Codex/main/init-workspace.sh | bash
```

---

## ❓ FAQ

### Q1: 我应该选择全局安装还是项目安装？

**A1**: 看这个判断流程：

```
你是个人开发者吗？
├─ 是 → 全局安装（推荐）
└─ 否 → 是团队项目吗？
         ├─ 是 → 项目安装
         └─ 否 → 全局安装（最简方案）
```

一句话：**个人用全局，团队用项目**

---

### Q2: 全局配置存储在哪里？

**A2**: Claude Code 内部管理，存储在 `~/.claude/` 目录中，但不是普通文本文件。

- 不可见（无法直接编辑）
- 只能通过 `claude mcp` 命令管理
- 使用 `claude mcp list` 查看配置

---

### Q3: 项目配置存储在哪里？

**A3**: 项目根目录的 `.mcp.json` 文件。

- 可见（可直接编辑）
- 可版本控制（建议提交到 Git）
- 团队成员会自动共享

---

### Q4: 两者可以混用吗？

**A4**: 可以！

- 全局：基础工具（如 codex, sequential-thinking）
- 项目：额外工具（如团队自定义 server）
- 项目配置优先级更高（会覆盖同名全局工具）

---

### Q5: 配置后如何验证？

**A5**: 运行：

```bash
claude mcp list
```

应显示：
- ✅ Connected（正常连接）
- ⚠ Disconnected（连接失败，需要排查）

---

### Q6: 安装后看不到工具？

**A6**：

1. 退出 Claude Code
2. 重新运行 `claude`
3. 在对话中输入：`使用 sequential-thinking 分析这个问题`
4. 如果 Claude 能够调用工具，说明配置成功

---

### Q7: 如何卸载？

**A7**：

```bash
# 删除全局配置
claude mcp list  # 列出所有 MCP servers
claude mcp remove <server-name>  # 逐个删除

# 删除项目配置
rm .mcp.json

# 删除工作目录
rm -rf .claude/
```

---

### Q8: 有哪些可用的 MCP servers？

**A8**：安装脚本提供的：

| Server | 功能 | 用途 |
|--------|------|------|
| sequential-thinking | 深度思考 | 复杂问题分析 |
| shrimp-task-manager | 任务管理 | 任务规划和跟踪 |
| codex | 代码分析 | 深度代码分析和重构 |
| code-index | 代码索引 | 代码检索和理解 |
| chrome-devtools | 浏览器调试 | Web 开发和调试 |

---

### Q9: URL 太长记不住？

**A9**：

1. **使用交互式向导**：
   ```bash
   bash <(curl -sSL https://raw.githubusercontent.com/foreveryh/Claude-Codex/main/install)
   ```

2. **使用书签**：浏览器书签保存

3. **使用别名**：在 `.bashrc` 或 `.zshrc` 中添加：
   ```bash
   alias claude-install='bash <(curl -sSL https://raw.githubusercontent.com/foreveryh/Claude-Codex/main/install)'
   alias claude-init='curl -sSL https://raw.githubusercontent.com/foreveryh/Claude-Codex/main/init-workspace.sh | bash'
   ```

4. **复制粘贴**：从 README.md 复制

---

### Q10: 如何贡献？

**A10**：

1. Fork 本仓库
2. 创建特性分支：`git checkout -b feature/AmazingFeature`
3. 提交更改：`git commit -m 'Add some AmazingFeature'`
4. 推送到分支：`git push origin feature/AmazingFeature`
5. 开启 Pull Request

---

## 🎯 一句话总结

| 你的情况 | 推荐方案 | 命令 |
|---------|---------|------|
| 第一次使用，不知道选哪个 | 交互式向导 | `bash <(curl -sSL https://raw.githubusercontent.com/foreveryh/Claude-Codex/main/install)` |
| 个人项目，不想折腾 | 全局安装 | `bash <(curl -sSL https://raw.githubusercontent.com/foreveryh/Claude-Codex/main/install-global.sh)` |
| 团队项目，需要共享 | 项目安装 | `bash <(curl -sSL https://raw.githubusercontent.com/foreveryh/Claude-Codex/main/install-project.sh)` |
| 已全局安装，新项目 | 快速初始化 | `curl -sSL https://raw.githubusercontent.com/foreveryh/Claude-Codex/main/init-workspace.sh \| bash` |
| 只想完整了解 | 看本文档 | 从头读到尾 |

---

**开始你的 AI 协作开发之旅吧！** 🚀

有问题？提交 [Issue](https://github.com/foreveryh/Claude-Codex/issues) 或查看 [安装修复说明](INSTALL-FIX-NOTES.md)
