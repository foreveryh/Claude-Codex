#!/bin/bash

# Skill 健康检查脚本
# 用于验证 Claude Code + Codex Skill 配置是否正确

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 计数器
PASSED=0
FAILED=0
WARNINGS=0

# 打印函数
print_check() {
    echo -e "${BLUE}[检查]${NC} $1"
}

print_pass() {
    echo -e "${GREEN}[✓]${NC} $1"
    ((PASSED++))
}

print_fail() {
    echo -e "${RED}[✗]${NC} $1"
    ((FAILED++))
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
    ((WARNINGS++))
}

print_header() {
    echo ""
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}  Skill 健康检查            ${NC}"
    echo -e "${BLUE}================================${NC}"
    echo ""
}

# 检测操作系统
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
        echo "windows"
    else
        echo "unknown"
    fi
}

# 获取 Claude 配置目录
get_claude_config_dir() {
    local os=$(detect_os)
    case $os in
        "macos")
            echo "$HOME/Library/Application Support/Claude"
            ;;
        "linux")
            echo "$HOME/.config/claude"
            ;;
        "windows")
            echo "$APPDATA/Claude"
            ;;
        *)
            echo ""
            ;;
    esac
}

print_header

# 1. 检查 Skill 文件
print_check "检查 Skill 文件..."
if [ -f ".claude/skills/codex-workflow/SKILL.md" ]; then
    print_pass "Skill 文件存在"

    # 检查 YAML frontmatter
    if head -1 .claude/skills/codex-workflow/SKILL.md | grep -q "^---$"; then
        print_pass "YAML frontmatter 格式正确"
    else
        print_fail "YAML frontmatter 格式错误"
    fi
else
    print_fail "Skill 文件缺失"
fi

# 2. 检查模板文件
print_check "检查模板文件..."
TEMPLATES=(
    "templates/task-marker-format.txt"
    "templates/codex-prompt-template.md"
    "templates/context-initial-template.json"
    "templates/review-checklist.md"
    "templates/skill-troubleshooting.md"
)

for template in "${TEMPLATES[@]}"; do
    if [ -f ".claude/skills/codex-workflow/$template" ]; then
        print_pass "$(basename $template) 存在"
    else
        print_fail "$(basename $template) 缺失"
    fi
done

# 3. 验证 JSON 模板
print_check "验证 JSON 模板格式..."
if command -v python3 &> /dev/null; then
    if python3 -m json.tool .claude/skills/codex-workflow/templates/context-initial-template.json > /dev/null 2>&1; then
        print_pass "JSON 模板格式正确"
    else
        print_fail "JSON 模板格式错误"
    fi
else
    print_warning "Python3 未安装，跳过 JSON 验证"
fi

# 4. 检查 MCP 配置
print_check "检查 MCP 配置..."
CONFIG_DIR=$(get_claude_config_dir)
if [ -n "$CONFIG_DIR" ]; then
    CONFIG_FILE="$CONFIG_DIR/claude_desktop_config.json"
    if [ -f "$CONFIG_FILE" ]; then
        print_pass "MCP 配置文件存在"

        # 检查 codex 配置
        if command -v jq &> /dev/null; then
            if jq -e '.mcpServers.codex' "$CONFIG_FILE" > /dev/null 2>&1; then
                print_pass "Codex MCP 配置存在"
            else
                print_warning "Codex MCP 配置缺失"
            fi

            # 检查 sequential-thinking 配置
            if jq -e '.mcpServers["sequential-thinking"]' "$CONFIG_FILE" > /dev/null 2>&1; then
                print_pass "Sequential-thinking MCP 配置存在"
            else
                print_warning "Sequential-thinking MCP 配置缺失"
            fi
        else
            print_warning "jq 未安装，跳过 MCP 配置详细检查"
        fi
    else
        print_fail "MCP 配置文件不存在: $CONFIG_FILE"
    fi
else
    print_fail "无法确定 Claude 配置目录"
fi

# 5. 检查 Codex 安装
print_check "检查 Codex 安装..."
if command -v codex &> /dev/null; then
    VERSION=$(codex --version 2>&1 || echo "未知版本")
    print_pass "Codex 已安装: $VERSION"

    # 测试 MCP 服务器
    if codex mcp-server --help > /dev/null 2>&1; then
        print_pass "Codex MCP 服务器可用"
    else
        print_warning "Codex MCP 服务器命令可能不可用"
    fi
else
    print_warning "Codex 未安装（需要单独安装）"
fi

# 6. 检查工作目录
print_check "检查工作目录结构..."
WORK_DIRS=(
    ".claude"
    ".claude/skills"
    ".claude/codex"
    ".claude/context"
    ".claude/logs"
    ".claude/cache"
)

for dir in "${WORK_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        if [ -w "$dir" ]; then
            print_pass "$dir (可写)"
        else
            print_fail "$dir (不可写)"
        fi
    else
        print_warning "$dir 不存在（将自动创建）"
        mkdir -p "$dir"
    fi
done

# 7. 检查依赖工具
print_check "检查依赖工具..."
TOOLS=("node" "npm" "python3" "jq")
for tool in "${TOOLS[@]}"; do
    if command -v $tool &> /dev/null; then
        print_pass "$tool 已安装"
    else
        print_warning "$tool 未安装（部分功能可能受限）"
    fi
done

# 8. 检查 npm 全局包
print_check "检查 npm 全局包..."
if command -v npm &> /dev/null; then
    if npm list -g @modelcontextprotocol/server-sequential-thinking > /dev/null 2>&1; then
        print_pass "sequential-thinking 已安装"
    else
        print_warning "sequential-thinking 未安装"
    fi
else
    print_warning "npm 未安装，跳过包检查"
fi

# 总结
echo ""
echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}  检查结果汇总              ${NC}"
echo -e "${BLUE}================================${NC}"
echo ""
echo -e "${GREEN}通过: $PASSED${NC}"
echo -e "${RED}失败: $FAILED${NC}"
echo -e "${YELLOW}警告: $WARNINGS${NC}"
echo ""

# 建议
if [ $FAILED -gt 0 ]; then
    echo -e "${RED}发现 $FAILED 个错误，请修复后再使用${NC}"
    echo ""
    echo "修复建议："
    echo "1. 运行安装脚本: ./install.sh"
    echo "2. 检查文件权限: chmod -R 755 .claude/"
    echo "3. 查看故障排除文档: .claude/skills/codex-workflow/templates/skill-troubleshooting.md"
    exit 1
elif [ $WARNINGS -gt 0 ]; then
    echo -e "${YELLOW}有 $WARNINGS 个警告，建议查看${NC}"
    echo ""
    echo "可选优化："
    echo "1. 安装 Codex: 参考 https://github.com/openai/codex"
    echo "2. 安装缺失的工具: jq, python3 等"
    echo "3. 完善 MCP 配置: 参考 config-advanced.json"
    exit 0
else
    echo -e "${GREEN}所有检查通过！✅${NC}"
    echo ""
    echo "下一步："
    echo "1. 如果使用项目本地 Skill，无需其他操作"
    echo "2. 如果要全局使用，复制到 Claude 配置目录："
    echo "   cp -r .claude/skills/codex-workflow $CONFIG_DIR/skills/"
    echo "3. 重启 Claude Code 应用"
    echo "4. 测试 Skill: 在对话中尝试 '帮我重构这段代码'"
    exit 0
fi
