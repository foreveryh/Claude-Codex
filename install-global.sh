#!/bin/bash

# ============================================
# Claude Code User Scope MCP 配置脚本
# ============================================
#
# 用途：一键配置所有 MCP servers 到 User Scope
# 优势：配置一次，所有项目都可以使用
#
# 使用方法：
#   chmod +x setup-user-mcp.sh
#   ./setup-user-mcp.sh
# ============================================

set -e  # 遇到错误立即退出

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_step() {
    echo -e "${BLUE}==>${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# 检查 claude 命令是否可用
check_claude_cli() {
    if ! command -v claude &> /dev/null; then
        print_error "未找到 claude 命令，请先安装 Claude Code CLI"
        echo "安装方法: npm install -g @anthropic-ai/claude-code"
        exit 1
    fi
    print_success "Claude Code CLI 已安装"
}

# 检查依赖
check_dependencies() {
    print_step "检查必要的依赖..."

    local all_ok=true

    # 检查 npx
    if command -v npx &> /dev/null; then
        print_success "npx 已安装"
    else
        print_error "npx 未安装（需要 Node.js）"
        all_ok=false
    fi

    # 检查 codex
    if command -v codex &> /dev/null; then
        print_success "codex 已安装"
    else
        print_warning "codex 未安装（可选，但推荐安装）"
        print_warning "安装方法: brew install codex 或访问 https://github.com/anthropics/codex"
    fi

    # 检查 uvx
    if command -v uvx &> /dev/null; then
        print_success "uvx 已安装"
    else
        print_warning "uvx 未安装（可选，用于 code-index）"
        print_warning "安装方法: pip install uv"
    fi

    if [ "$all_ok" = false ]; then
        print_error "缺少必要依赖，请先安装"
        exit 1
    fi

    echo ""
}

# 添加 MCP server
add_mcp_server() {
    local name=$1
    local description=$2
    shift 2

    print_step "添加 $name ($description)..."

    # 先检查是否已存在
    if claude mcp get "$name" &> /dev/null; then
        print_warning "$name 已存在，将先删除旧配置"
        claude mcp remove "$name" 2>/dev/null || true
    fi

    # 添加新配置
    if "$@"; then
        print_success "$name 配置成功"
        return 0
    else
        print_error "$name 配置失败"
        return 1
    fi
}

# 主函数
main() {
    echo ""
    echo "========================================"
    echo "  Claude Code User Scope MCP 配置工具"
    echo "========================================"
    echo ""

    # 检查依赖
    check_claude_cli
    check_dependencies

    print_step "开始配置 User Scope MCP Servers..."
    echo ""

    # 1. Sequential Thinking（深度思考）
    add_mcp_server "sequential-thinking" "深度思考工具" \
        claude mcp add \
        --scope user \
        --transport stdio \
        sequential-thinking \
        --env WORKING_DIR=.claude \
        -- npx -y @modelcontextprotocol/server-sequential-thinking

    echo ""

    # 2. Shrimp Task Manager（任务管理）
    add_mcp_server "shrimp-task-manager" "任务管理工具" \
        claude mcp add \
        --scope user \
        --transport stdio \
        shrimp-task-manager \
        --env DATA_DIR=.claude/shrimp \
        --env TEMPLATES_USE=zh \
        --env ENABLE_GUI=false \
        -- npx -y mcp-shrimp-task-manager

    echo ""

    # 3. Codex（代码分析和重构）
    if command -v codex &> /dev/null; then
        add_mcp_server "codex" "代码分析和重构工具" \
            claude mcp add \
            --scope user \
            --transport stdio \
            codex \
            --env WORKING_DIR=.claude \
            -- codex mcp-server
        echo ""
    else
        print_warning "跳过 codex（未安装）"
        echo ""
    fi

    # 4. Code Index（代码索引）
    if command -v uvx &> /dev/null; then
        add_mcp_server "code-index" "代码索引工具" \
            claude mcp add \
            --scope user \
            --transport stdio \
            code-index \
            --env WORKING_DIR=.claude \
            -- uvx code-index-mcp
        echo ""
    else
        print_warning "跳过 code-index（需要 uvx）"
        echo ""
    fi

    # 5. Chrome DevTools（浏览器调试）
    add_mcp_server "chrome-devtools" "浏览器调试工具" \
        claude mcp add \
        --scope user \
        --transport stdio \
        chrome-devtools \
        --env WORKING_DIR=.claude \
        -- npx -y chrome-devtools-mcp@latest

    echo ""
    echo "========================================"
    print_success "配置完成！"
    echo "========================================"
    echo ""

    # 显示配置结果
    print_step "当前配置的 MCP Servers："
    echo ""
    claude mcp list || true

    echo ""
    echo "========================================"
    echo "下一步："
    echo "========================================"
    echo ""
    echo "1. 在任何项目中创建工作目录："
    echo "   mkdir -p .claude/shrimp .claude/codex .claude/context"
    echo ""
    echo "2. 启动 Claude Code："
    echo "   claude"
    echo ""
    echo "3. 在 Claude Code 中测试 MCP 工具："
    echo "   - 请使用 sequential-thinking 分析这个问题"
    echo "   - 请使用 shrimp-task-manager 创建任务计划"
    echo "   - 请使用 codex 分析这段代码"
    echo ""
    echo "详细文档: NEW-PROJECT-SETUP.md"
    echo ""
}

# 执行主函数
main "$@"
