# install.sh 修复说明

## 📅 修复日期
2025-11-14

## 🎯 修复目标
将 install.sh 从支持 **Claude Desktop** 改为支持 **Claude Code**

---

## 🐛 修复的问题

### 问题 1：配置文件路径错误
**症状**：配置文件被写到 `~/Library/Application Support/Claude/claude_desktop_config.json`
**原因**：脚本设计时针对 Claude Desktop，而不是 Claude Code
**影响**：Claude Code 无法读取配置，MCP servers 无法加载

### 问题 2：Exa API 密钥输入污染
**症状**：生成的配置文件中 EXA_API_KEY 包含了所有提示信息
**原因**：`get_exa_api_key()` 函数的所有 echo 输出都被捕获到返回值
**影响**：Exa 功能完全无法使用，API 密钥无效

### 问题 3：code-index 验证失败
**症状**：安装验证阶段报错 "code-index-mcp 无法通过 uvx 执行"
**原因**：验证脚本使用了 `--version` 参数，但 code-index-mcp 不支持
**影响**：即使 code-index 正常安装，验证也会失败

---

## ✅ 解决方案

### 1. 配置文件路径修复

#### 新增函数
```bash
# 获取 Claude Code 配置文件路径（项目本地）
get_claude_config_file() {
    echo ".mcp.json"
}

# 获取 Claude Code 工作目录
get_claude_working_dir() {
    echo ".claude"
}
```

#### 移除函数
- ❌ `get_claude_config_dir()` - 返回 Claude Desktop 路径
- ❌ `create_config_dir()` - 创建 Claude Desktop 目录

#### 修改影响
- **配置文件位置**：`~/Library/Application Support/Claude/` → `.mcp.json`
- **工作目录**：`~/Library/Application Support/.claude/` → `./.claude/`

---

### 2. Exa API 密钥输入修复

#### 修改前
```bash
get_exa_api_key() {
    echo ""                          # ❌ 输出到 stdout
    print_message "请输入..."         # ❌ 输出到 stdout
    read -s -p "..." exa_key
    echo "$exa_key"
}
```

#### 修改后
```bash
get_exa_api_key() {
    echo "" >&2                      # ✅ 输出到 stderr
    print_message "请输入..." >&2     # ✅ 输出到 stderr
    read -s -p "..." exa_key
    echo "$exa_key"                  # ✅ 只有密钥输出到 stdout
}
```

#### 原理说明
- **stdout（标准输出）**：用于函数返回值
- **stderr（标准错误）**：用于提示和日志信息
- 使用 `>&2` 将提示信息重定向到 stderr，避免污染返回值

---

### 3. code-index 验证修复

#### 修改前
```bash
uvx code-index-mcp --version >/dev/null 2>&1  # ❌ 不支持 --version
```

#### 修改后
```bash
uvx code-index-mcp --help >/dev/null 2>&1     # ✅ 支持 --help
```

---

### 4. main 函数更新

#### 修改前
```bash
# 获取配置目录
local config_dir=$(create_config_dir)

# 生成配置文件
local config_file="$config_dir/claude_desktop_config.json"

# 创建工作目录
create_working_directories "$config_dir"
```

#### 修改后
```bash
# 获取配置文件路径
local config_file=$(get_claude_config_file)

# 生成配置文件
print_message "配置文件将写入到: $config_file"
generate_config "$template_file" "$api_key" "$config_file"

# 创建工作目录
create_working_directories
```

---

### 5. verify_installation 更新

#### 修改前
```bash
local config_dir=$(get_claude_config_dir)
local config_file="$config_dir/claude_desktop_config.json"
```

#### 修改后
```bash
local config_file=$(get_claude_config_file)
```

---

### 6. show_completion 更新

#### 修改前
```bash
echo "下一步操作:"
echo "1. 重启Claude Code应用"
echo "2. 在Claude Code中输入: /available-tools"
echo ""
echo "配置文件位置:"
echo "~/Library/Application Support/Claude/claude_desktop_config.json"
```

#### 修改后
```bash
echo "下一步操作:"
echo "1. 在项目目录中启动 Claude Code"
echo "2. 运行: claude mcp list"
echo "3. 确认能看到已安装的 MCP 工具"
echo ""
echo "配置文件位置:"
echo "$(pwd)/.mcp.json"
echo ""
echo "验证安装:"
echo "claude mcp list    # 查看所有 MCP servers"
```

---

## 🧪 测试验证

### 语法检查
```bash
bash -n install.sh
# ✅ 脚本语法检查通过
```

### 功能测试
```bash
# 1. 运行安装（高级配置）
./install.sh

# 2. 验证配置文件
cat .mcp.json | python3 -m json.tool

# 3. 验证 MCP servers
claude mcp list

# 预期输出：
# sequential-thinking: ✓ Connected
# shrimp-task-manager: ✓ Connected
# codex: ✓ Connected
# code-index: ✓ Connected
# chrome-devtools: ✓ Connected
```

---

## 📊 影响范围

### 文件修改
- ✅ `install.sh` - 主安装脚本

### 配置文件
- ⚠️ 配置模板文件（config-*.json）**无需修改**，格式已正确

### 破坏性变更
- ⚠️ 旧版本安装的配置不兼容（使用 Claude Desktop 路径）
- ✅ 新版本正确使用 Claude Code 配置方式

---

## 🚀 使用说明

### 全新安装
```bash
# 克隆仓库
git clone <repo-url>
cd Claude-Codex

# 运行安装脚本
./install.sh

# 选择配置级别（1/2/3）
# 如果选择高级配置，可选择是否设置 Exa API 密钥

# 验证安装
claude mcp list
```

### 从旧版本升级
```bash
# 1. 备份旧配置（如果需要）
cp .mcp.json .mcp.json.bak

# 2. 拉取最新代码
git pull

# 3. 重新运行安装
./install.sh

# 4. 验证
claude mcp list
```

---

## 📝 注意事项

1. **配置文件位置变更**
   - 旧版：`~/Library/Application Support/Claude/claude_desktop_config.json`
   - 新版：`./mcp.json`（项目本地）

2. **Exa API 密钥输入**
   - 如果不需要 Exa 功能，直接按 Enter 跳过即可
   - 密钥会被正确保存到配置文件中（不会再有污染问题）

3. **验证命令变更**
   - 旧版：在 Claude Desktop 中查看
   - 新版：使用 `claude mcp list` 命令验证

4. **工作目录**
   - 所有工作文件都在项目的 `.claude/` 目录下
   - 包括：shrimp、codex、context、logs、cache

---

## 🔗 相关链接

- Claude Code 文档: https://docs.claude.com/
- MCP 协议: https://modelcontextprotocol.io/
- 问题反馈: https://github.com/claude-codex/setup/issues

---

## ✅ 修复检查清单

- [x] 配置文件路径改为 `.mcp.json`
- [x] Exa API 密钥输入不再被污染
- [x] code-index 验证使用正确参数
- [x] main 函数更新配置路径
- [x] verify_installation 更新
- [x] show_completion 更新说明
- [x] 脚本语法检查通过
- [ ] 实际安装测试（待用户测试）

