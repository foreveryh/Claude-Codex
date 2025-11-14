#!/bin/bash

# ============================================
# Claude-Codex 快速工作空间初始化
# ============================================
#
# 用途：在项目中快速创建 .claude 工作目录
#       适用于已经完成全局安装的用户
#
# 使用方法：
#   cd your-project
#   ./init-workspace.sh
#
#   或远程执行：
#   curl -sSL https://raw.githubusercontent.com/.../init-workspace.sh | bash
# ============================================

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 打印消息函数
print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# 显示欢迎信息
show_welcome() {
    echo ""
    echo -e "${CYAN}╔════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║  Claude-Codex 工作空间快速初始化      ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════╝${NC}"
    echo ""
}

# 检查是否已有全局配置
check_global_config() {
    print_info "检查全局配置..."

    if ! command -v claude &> /dev/null; then
        print_warning "未找到 claude 命令"
        print_warning "请先安装 Claude Code CLI"
        return 1
    fi

    # 检查是否有配置的 MCP servers
    local mcp_count=$(claude mcp list 2>/dev/null | grep -c "Connected\|Disconnected" || echo "0")

    if [ "$mcp_count" -eq 0 ]; then
        print_warning "未找到任何 MCP server 配置"
        echo ""
        echo -e "${YELLOW}建议先运行全局安装：${NC}"
        echo "  bash <(curl -sSL https://raw.githubusercontent.com/.../install-global.sh)"
        echo ""
        read -p "是否继续初始化工作目录？[y/N] " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    else
        print_success "找到 $mcp_count 个已配置的 MCP servers"
    fi
}

# 创建工作目录
create_directories() {
    print_info "创建工作目录..."

    local base_dir=".claude"
    local dirs=(
        "$base_dir"
        "$base_dir/shrimp"
        "$base_dir/codex"
        "$base_dir/context"
        "$base_dir/logs"
        "$base_dir/cache"
    )

    for dir in "${dirs[@]}"; do
        if [ -d "$dir" ]; then
            print_warning "$dir 已存在，跳过"
        else
            mkdir -p "$dir"
            print_success "创建 $dir"
        fi
    done
}

# 创建或更新 .gitignore
update_gitignore() {
    print_info "配置 .gitignore..."

    local gitignore=".gitignore"
    local claude_ignore="# Claude-Codex working directories
.claude/logs/
.claude/cache/
.claude/context/
.claude/shrimp/*.tmp
.claude/codex/cache/"

    if [ -f "$gitignore" ]; then
        # 检查是否已包含 Claude-Codex 规则
        if grep -q "Claude-Codex" "$gitignore" 2>/dev/null; then
            print_success ".gitignore 已包含 Claude-Codex 规则"
        else
            echo "" >> "$gitignore"
            echo "$claude_ignore" >> "$gitignore"
            print_success "添加规则到 .gitignore"
        fi
    else
        echo "$claude_ignore" > "$gitignore"
        print_success "创建 .gitignore"
    fi
}

# 显示完成信息
show_completion() {
    echo ""
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}✨ 工作空间初始化完成！${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${CYAN}目录结构：${NC}"
    echo "  .claude/"
    echo "  ├── shrimp/      # 任务管理数据"
    echo "  ├── codex/       # Codex 工作目录"
    echo "  ├── context/     # 上下文缓存"
    echo "  ├── logs/        # 日志文件"
    echo "  └── cache/       # 临时缓存"
    echo ""
    echo -e "${CYAN}下一步：${NC}"
    echo "  1. 运行 'claude' 启动 Claude Code"
    echo "  2. 开始你的 AI 协作开发之旅！"
    echo ""
    echo -e "${CYAN}提示：${NC}"
    echo "  - 工作目录会自动被 .gitignore 忽略（日志和缓存）"
    echo "  - 如需查看配置的 MCP servers: claude mcp list"
    echo "  - 如需重新配置: 运行 install-global.sh"
    echo ""
}

# 主函数
main() {
    show_welcome

    # 检查当前目录
    if [ ! -w "." ]; then
        print_error "当前目录不可写，请检查权限"
        exit 1
    fi

    # 检查全局配置
    check_global_config

    echo ""

    # 创建目录
    create_directories

    echo ""

    # 更新 .gitignore
    update_gitignore

    # 显示完成信息
    show_completion
}

# 执行主函数
main "$@"
