#!/bin/bash

# Claude Code + Codex Skill 一键安装脚本
# 适用于 Claude Code CLI（非 Claude Desktop）
# 在当前目录创建 Project Scope 配置

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# 脚本所在目录（包含 Skill 源文件）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 打印函数
print_header() {
    echo ""
    echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║   Claude Code + Codex Skill 安装向导   ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    echo ""
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

print_info() {
    echo -e "${CYAN}ℹ${NC} $1"
}

print_step() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}▶ $1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# 检查命令是否存在
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# 检查系统依赖
check_dependencies() {
    print_step "步骤 1/6: 检查系统依赖"

    local missing_deps=()
    local optional_deps=()

    # 必需依赖
    if ! command_exists node; then
        missing_deps+=("Node.js")
    else
        print_success "Node.js $(node --version)"
    fi

    if ! command_exists npm; then
        missing_deps+=("npm")
    else
        print_success "npm $(npm --version)"
    fi

    # 可选依赖
    if ! command_exists python3; then
        optional_deps+=("Python 3")
    else
        print_success "Python 3 $(python3 --version 2>&1 | cut -d' ' -f2)"
    fi

    if ! command_exists codex; then
        optional_deps+=("Codex")
    else
        print_success "Codex $(codex --version 2>&1 || echo 'installed')"
    fi

    if ! command_exists jq; then
        optional_deps+=("jq")
    else
        print_success "jq $(jq --version 2>&1)"
    fi

    # 错误处理
    if [ ${#missing_deps[@]} -ne 0 ]; then
        echo ""
        print_error "缺少必需依赖: ${missing_deps[*]}"
        echo ""
        print_info "安装指南:"
        echo "  Node.js & npm: https://nodejs.org/"
        exit 1
    fi

    if [ ${#optional_deps[@]} -ne 0 ]; then
        echo ""
        print_warning "建议安装: ${optional_deps[*]}"
        echo ""
        read -p "是否继续安装？(y/N): " continue_install
        if [[ ! "$continue_install" =~ ^[Yy]$ ]]; then
            print_info "安装已取消"
            exit 0
        fi
    fi

    echo ""
    print_success "依赖检查完成"
}

# 选择配置级别
choose_config_level() {
    print_step "步骤 2/6: 选择配置级别" >&2

    echo "" >&2
    echo "请选择 MCP 配置级别：" >&2
    echo "" >&2
    echo "  ${GREEN}1)${NC} 简单配置 ${YELLOW}(推荐新手)${NC}" >&2
    echo "     └─ sequential-thinking + codex" >&2
    echo "" >&2
    echo "  ${GREEN}2)${NC} 标准配置 ${YELLOW}(推荐日常使用)${NC}" >&2
    echo "     └─ sequential-thinking + shrimp + codex + code-index" >&2
    echo "" >&2
    echo "  ${GREEN}3)${NC} 高级配置 ${YELLOW}(完整功能)${NC}" >&2
    echo "     └─ 标准配置 + chrome-devtools + exa-search" >&2
    echo "" >&2

    while true; do
        read -p "请输入选择 (1-3): " choice >&2
        case $choice in
            1)
                echo "simple"
                return
                ;;
            2)
                echo "standard"
                return
                ;;
            3)
                echo "advanced"
                return
                ;;
            *)
                print_warning "请输入 1、2 或 3" >&2
                ;;
        esac
    done
}

# 创建项目目录结构
create_project_structure() {
    print_step "步骤 3/6: 创建项目目录结构"

    local target_dir=$(pwd)

    print_info "目标目录: $target_dir"
    echo ""

    # 创建 .claude 目录结构
    local dirs=(
        ".claude"
        ".claude/skills"
        ".claude/skills/codex-workflow"
        ".claude/skills/codex-workflow/templates"
        ".claude/context"
        ".claude/codex"
        ".claude/shrimp"
        ".claude/logs"
        ".claude/cache"
    )

    for dir in "${dirs[@]}"; do
        if [ ! -d "$dir" ]; then
            mkdir -p "$dir"
            print_success "创建: $dir/"
        else
            print_info "已存在: $dir/"
        fi
    done

    echo ""
    print_success "目录结构创建完成"
}

# 复制 Skill 文件
copy_skill_files() {
    print_step "步骤 4/6: 安装 Codex Workflow Skill"

    local source_skill="$SCRIPT_DIR/.claude/skills/codex-workflow"
    local target_skill=".claude/skills/codex-workflow"

    if [ ! -d "$source_skill" ]; then
        print_error "源 Skill 目录不存在: $source_skill"
        exit 1
    fi

    # 复制 SKILL.md
    if [ -f "$source_skill/SKILL.md" ]; then
        cp "$source_skill/SKILL.md" "$target_skill/"
        print_success "复制: SKILL.md"
    else
        print_error "SKILL.md 不存在"
        exit 1
    fi

    # 复制 README.md（可选）
    if [ -f "$source_skill/README.md" ]; then
        cp "$source_skill/README.md" "$target_skill/"
        print_success "复制: README.md"
    fi

    # 复制模板文件
    if [ -d "$source_skill/templates" ]; then
        cp -r "$source_skill/templates/"* "$target_skill/templates/"
        local template_count=$(find "$target_skill/templates" -type f | wc -l)
        print_success "复制: $template_count 个模板文件"
    else
        print_warning "模板目录不存在，跳过"
    fi

    echo ""
    print_success "Skill 安装完成"
}

# 生成 .mcp.json 配置
generate_mcp_config() {
    local config_level=$1
    print_step "步骤 5/6: 生成 MCP 配置文件"

    local mcp_file=".mcp.json"

    print_info "配置级别: $config_level"
    print_info "配置文件: $(pwd)/$mcp_file"
    echo ""

    case $config_level in
        "simple")
            cat > "$mcp_file" <<'EOF'
{
  "mcpServers": {
    "sequential-thinking": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-sequential-thinking"],
      "env": {
        "WORKING_DIR": ".claude"
      }
    },
    "codex": {
      "command": "codex",
      "args": ["mcp-server"],
      "env": {
        "WORKING_DIR": ".claude"
      }
    }
  }
}
EOF
            ;;
        "standard")
            cat > "$mcp_file" <<'EOF'
{
  "mcpServers": {
    "sequential-thinking": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-sequential-thinking"],
      "env": {
        "WORKING_DIR": ".claude"
      }
    },
    "shrimp-task-manager": {
      "command": "npx",
      "args": ["-y", "mcp-shrimp-task-manager"],
      "env": {
        "DATA_DIR": ".claude/shrimp",
        "TEMPLATES_USE": "zh",
        "ENABLE_GUI": "false"
      }
    },
    "codex": {
      "command": "codex",
      "args": ["mcp-server"],
      "env": {
        "WORKING_DIR": ".claude"
      }
    },
    "code-index": {
      "command": "uvx",
      "args": ["code-index-mcp"],
      "env": {
        "WORKING_DIR": ".claude"
      }
    }
  }
}
EOF
            ;;
        "advanced")
            cat > "$mcp_file" <<'EOF'
{
  "mcpServers": {
    "sequential-thinking": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-sequential-thinking"],
      "env": {
        "WORKING_DIR": ".claude"
      }
    },
    "shrimp-task-manager": {
      "command": "npx",
      "args": ["-y", "mcp-shrimp-task-manager"],
      "env": {
        "DATA_DIR": ".claude/shrimp",
        "TEMPLATES_USE": "zh",
        "ENABLE_GUI": "false"
      }
    },
    "codex": {
      "command": "codex",
      "args": ["mcp-server"],
      "env": {
        "WORKING_DIR": ".claude"
      }
    },
    "code-index": {
      "command": "uvx",
      "args": ["code-index-mcp"],
      "env": {
        "WORKING_DIR": ".claude"
      }
    },
    "chrome-devtools": {
      "command": "npx",
      "args": ["-y", "chrome-devtools-mcp@latest"]
    },
    "exa": {
      "command": "npx",
      "args": ["-y", "exa-mcp-server"],
      "env": {
        "EXA_API_KEY": "your-exa-api-key-here"
      }
    }
  }
}
EOF
            print_warning "Exa Search 需要 API Key，请编辑 .mcp.json 设置 EXA_API_KEY"
            ;;
    esac

    # 验证 JSON 格式
    if command_exists jq; then
        if jq empty "$mcp_file" 2>/dev/null; then
            print_success "JSON 格式验证通过"
        else
            print_error "JSON 格式错误"
            exit 1
        fi
    else
        print_warning "jq 未安装，跳过 JSON 验证"
    fi

    echo ""
    print_success "MCP 配置文件已生成"
    print_info "注意: .mcp.json 会被 Claude Code 自动加载"
    print_info "首次使用时会要求安全批准"
}

# 安装 npm 包
install_packages() {
    local config_level=$1
    print_step "步骤 6/6: 安装 MCP 服务器包"

    echo ""
    print_info "正在安装全局 npm 包..."
    echo ""

    local packages=()

    case $config_level in
        "simple")
            packages=(
                "@modelcontextprotocol/server-sequential-thinking"
            )
            ;;
        "standard")
            packages=(
                "@modelcontextprotocol/server-sequential-thinking"
                "mcp-shrimp-task-manager"
            )
            ;;
        "advanced")
            packages=(
                "@modelcontextprotocol/server-sequential-thinking"
                "mcp-shrimp-task-manager"
                "chrome-devtools-mcp@latest"
                "exa-mcp-server"
            )
            ;;
    esac

    local installed=0
    local failed=0

    for package in "${packages[@]}"; do
        print_info "安装: $package"
        if npm install -g "$package" >/dev/null 2>&1; then
            print_success "$package 安装成功"
            ((installed++))
        else
            print_warning "$package 安装失败（可稍后手动安装）"
            ((failed++))
        fi
    done

    # 安装 Python 工具（仅标准和高级配置）
    if [[ "$config_level" == "standard" || "$config_level" == "advanced" ]]; then
        echo ""
        print_info "安装 Python 工具..."

        if command_exists pip || command_exists pip3; then
            local pip_cmd="pip3"
            command_exists pip && pip_cmd="pip"

            if $pip_cmd install uv >/dev/null 2>&1; then
                print_success "uv (uvx) 安装成功"
                ((installed++))
            else
                print_warning "uv 安装失败（可稍后手动安装）"
                ((failed++))
            fi
        else
            print_warning "pip 未安装，跳过 Python 工具"
        fi
    fi

    echo ""
    print_success "安装完成: $installed 个成功"
    if [ $failed -gt 0 ]; then
        print_warning "失败: $failed 个（可稍后手动安装）"
    fi
}

# 验证安装
verify_installation() {
    print_step "验证安装结果"

    echo ""

    # 检查目录结构
    if [ -d ".claude/skills/codex-workflow" ]; then
        print_success "Skill 目录已创建"
    else
        print_error "Skill 目录缺失"
        return 1
    fi

    # 检查 SKILL.md
    if [ -f ".claude/skills/codex-workflow/SKILL.md" ]; then
        print_success "SKILL.md 已安装"
    else
        print_error "SKILL.md 缺失"
        return 1
    fi

    # 检查 .mcp.json
    if [ -f ".mcp.json" ]; then
        print_success ".mcp.json 已生成"
    else
        print_error ".mcp.json 缺失"
        return 1
    fi

    # 检查 Codex
    if command_exists codex; then
        if codex mcp-server --help >/dev/null 2>&1; then
            print_success "Codex MCP 服务器可用"
        else
            print_warning "Codex 已安装，但 MCP 服务器可能不可用"
        fi
    else
        print_warning "Codex 未安装（需单独安装）"
    fi

    echo ""
    print_success "安装验证完成"
}

# 显示完成信息
show_completion() {
    local config_level=$1

    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║          🎉 安装成功完成！              ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
    echo ""

    print_info "安装位置: $(pwd)"
    print_info "配置级别: $config_level"
    echo ""

    echo -e "${CYAN}已安装的组件：${NC}"
    case $config_level in
        "simple")
            echo "  ✓ Sequential-thinking (深度推理)"
            echo "  ✓ Codex (代码分析)"
            echo "  ✓ Codex Workflow Skill"
            ;;
        "standard")
            echo "  ✓ Sequential-thinking (深度推理)"
            echo "  ✓ Shrimp Task Manager (任务管理)"
            echo "  ✓ Codex (代码分析)"
            echo "  ✓ Code Index (代码索引)"
            echo "  ✓ Codex Workflow Skill"
            ;;
        "advanced")
            echo "  ✓ Sequential-thinking (深度推理)"
            echo "  ✓ Shrimp Task Manager (任务管理)"
            echo "  ✓ Codex (代码分析)"
            echo "  ✓ Code Index (代码索引)"
            echo "  ✓ Chrome DevTools (浏览器调试)"
            echo "  ✓ Exa Search (网络搜索)"
            echo "  ✓ Codex Workflow Skill"
            ;;
    esac

    echo ""
    echo -e "${CYAN}下一步操作：${NC}"
    echo "  1. 在此目录启动 Claude Code CLI"
    echo "  2. .mcp.json 会被自动加载（首次需批准）"
    echo "  3. Skill 会在合适时机自动触发"
    echo ""

    echo -e "${CYAN}测试 Skill：${NC}"
    echo "  在对话中说："帮我重构 install.sh 脚本""
    echo "  或："分析这个项目的架构""
    echo ""

    echo -e "${CYAN}检查配置健康状态：${NC}"
    echo "  ./check-skill-health.sh"
    echo ""

    echo -e "${YELLOW}注意事项：${NC}"
    echo "  • claude mcp list 不显示 project scope 的 servers（已知 BUG #5963）"
    echo "  • 这不影响实际使用，servers 已正常加载"
    echo "  • 如需重置批准选择：claude mcp reset-project-choices"
    echo ""

    if [[ "$config_level" == "advanced" ]]; then
        echo -e "${YELLOW}高级配置提醒：${NC}"
        echo "  • Exa API Key 需手动设置：编辑 .mcp.json"
        echo "  • 获取 API Key: https://exa.ai/"
        echo ""
    fi

    print_success "安装完成！开始使用 Claude Code + Codex Workflow 吧！"
    echo ""
}

# 主函数
main() {
    print_header

    # 步骤 1: 检查依赖
    check_dependencies

    # 步骤 2: 选择配置级别
    local config_level=$(choose_config_level)

    # 步骤 3: 创建目录结构
    create_project_structure

    # 步骤 4: 复制 Skill 文件
    copy_skill_files

    # 步骤 5: 生成 MCP 配置
    generate_mcp_config "$config_level"

    # 步骤 6: 安装包
    install_packages "$config_level"

    # 验证安装
    verify_installation

    # 显示完成信息
    show_completion "$config_level"
}

# 运行主函数
main "$@"
