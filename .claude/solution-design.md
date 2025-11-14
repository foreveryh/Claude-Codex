# Claude Codex Installer – Solution Design

Task marker: `20251113-153000-0001`

本方案针对 `install.sh` 中的三个高优先级问题给出技术设计、关键伪代码、实现注意事项与测试建议。

---

## 问题 1：修复 JSON 生成（P1-fix-json-generation）

### 技术方案
- **抛弃 sed 直接编辑 JSON**：使用内嵌 `python3`（已是硬性依赖）读取模板、修改节点并重新序列化，保证任何情况下输出都是合法 JSON。
- **统一处理所有模板**：`generate_config()` 无论 simple/standard/advanced 都使用相同逻辑；只有当模板里存在 `mcpServers.exa` 时才执行额外处理。
- **Exa 逻辑**：
  - 当提供 `EXA_API_KEY`：确保 `mcpServers["exa"].env["EXA_API_KEY"]` 被替换为真实值（若 `env` 缺失则先创建），保留 workflow 中的 `exa`。
  - 当未提供密钥：删除 `mcpServers["exa"]`，并同步清理 `workflow.execution_order` 里的 `exa` 项，彻底避免尾随逗号或悬空引用。
- **结果校验**：Python 写出文件后再运行 `python3 -m json.tool "$output_file" >/dev/null` 做快速语法校验，若失败立即报错并终止安装。
- **保持单文件特性**：Python 代码通过 heredoc 内嵌在 `generate_config()` 中，不新增外部脚本或依赖。

### 关键伪代码
```bash
generate_config() {
  local template_file=$1
  local exa_api_key=$2
  local output_file=$3

  python3 <<'PY' "$template_file" "$output_file" "$exa_api_key"
import json, sys, pathlib
template_path, output_path, exa_key = sys.argv[1:4]
data = json.load(open(template_path, encoding="utf-8"))
servers = data.setdefault("mcpServers", {})
workflow = data.get("workflow", {})
order = workflow.get("execution_order", [])

exa = servers.get("exa")
if exa:
    if exa_key:
        exa.setdefault("env", {})["EXA_API_KEY"] = exa_key
    else:
        servers.pop("exa", None)
        if isinstance(order, list):
            workflow["execution_order"] = [name for name in order if name != "exa"]

with open(output_path, "w", encoding="utf-8") as fh:
    json.dump(data, fh, indent=2, ensure_ascii=False)
    fh.write("\n")
PY

  python3 -m json.tool "$output_file" >/dev/null || {
    print_error "生成的配置文件不是合法 JSON"
    return 1
  }
}
```

### 实现难点与注意事项
- **跨模板兼容**：simple/standard 模板没有 `exa`；Python 逻辑必须在 `mcpServers` 缺少 `exa` 时直接落盘，不得报错。
- **workflow 同步**：需要确保 `workflow` 或 `execution_order` 缺失时不会访问空值；必须做类型检测或安全默认值。
- **编码 & 权限**：写文件时统一使用 UTF-8，保持与模板一致；若写入失败要 propagate 到 Bash。
- **依赖声明**：`check_dependencies()` 仍然保证 `python3` 可用，因此无需新增 `jq`。

### 测试建议
- advanced 模板：
  1. 带 `--exa-key`（或交互输入）生成文件，使用 `jq '.mcpServers.exa.env.EXA_API_KEY'` 验证值被替换。
  2. 未提供密钥，确认 `mcpServers` 中无 `exa`，`workflow.execution_order` 不含 `exa`，并能通过 `python3 -m json.tool`。
- simple/standard 模板：比较生成的 JSON 与原模板（如 `diff <(jq -S . template) <(jq -S . output)`）应只存在格式化差异。
- 人为破坏模板（例如删掉 `}`）后运行，验证脚本能在 Python 解析阶段失败并阻断安装。

---

## 问题 2：增强验证逻辑（P1-enhanced-validation）

### 技术方案
- **将 `verify_installation` 转为多阶段校验器**：接收 `config_level` 与 Exa 使用状态，执行结构化检查并在任何致命错误时 `return 1`。
- **JSON 语法校验**：复用 `python3 -m json.tool "$config_file"`；失败时立刻报错。
- **MCP server 存在性**：
  - 新增 `get_required_servers()`，根据 `config_level` 返回必备 server 列表：  
    `simple = ["sequential-thinking","codex"]`  
    `standard = simple + ["shrimp-task-manager","code-index"]`  
    `advanced = standard + ["chrome-devtools"]`（`exa` 仅在用户提供密钥或显式启用时必需）。
  - 用 Python 解析配置并输出现有 server 名称；Bash 循环校验缺失项（缺失 -> fatal）。
  - 若文件仍包含 `exa`，同时确认 `env.EXA_API_KEY` 已被替换（不等于 `your-exa-api-key-here` 且非空），否则报错提醒。
- **npm 全局包验证**：
  - 根据配置级别映射所需包集合，与安装逻辑一致（如 `chrome-devtools-mcp`、`exa-mcp-server` 仅在对应级别/启用时检查）。
  - 封装 `check_npm_global package_name` => `npm list -g --depth=0 "$package" >/dev/null`，失败则致命。
- **uvx 与 code-index-mcp 校验**：
  - 对 `standard`/`advanced` 必须 `command_exists uvx`，并运行 `uvx code-index-mcp --version >/dev/null` 验证可执行性；失败视为致命。
- **其他命令**：`codex` 必须存在（所有级别），已在 `check_codex()` 中但在验证阶段再确认，确保安装阶段没被忽略。
- **失败策略**：
  - 维护 `local failures=0`；每个致命错误 `((failures++))`。  
  - 最终 `return 0` 仅当 `failures==0`，否则打印总结并 `return 1`，让 `main()` 中止。
  - 非致命情况（例如 `npm` 可执行但发出 warning）仅适用于真正可选项，目前范围内全部 fatal，以匹配 P1 严肃性。

### 关键伪代码
```bash
get_required_servers() {
  case "$1" in
    simple)   echo "sequential-thinking codex" ;;
    standard) echo "sequential-thinking shrimp-task-manager codex code-index" ;;
    advanced) echo "sequential-thinking shrimp-task-manager codex code-index chrome-devtools" ;;
  esac
}

verify_installation() {
  local config_level=$1
  local config_file="$(get_claude_config_dir)/claude_desktop_config.json"
  local failures=0

  python3 -m json.tool "$config_file" >/dev/null || {
    print_error "配置文件 JSON 无效"; return 1; }

  mapfile -t configured_servers < <(python3 <<'PY' "$config_file"
import json, sys
data = json.load(open(sys.argv[1]))
for key in (data.get("mcpServers") or {}).keys():
    print(key)
PY
  )

  for required in $(get_required_servers "$config_level"); do
    if ! printf '%s\n' "${configured_servers[@]}" | grep -qx "$required"; then
      print_error "缺少 MCP server: $required"
      ((failures++))
    fi
  done

  if printf '%s\n' "${configured_servers[@]}" | grep -qx "exa"; then
    python3 <<'PY' "$config_file" || failures=$((failures+1))
import json, sys
env = (((json.load(open(sys.argv[1])).get("mcpServers") or {})
        .get("exa") or {}).get("env") or {})
key = env.get("EXA_API_KEY", "")
assert key and key != "your-exa-api-key-here", "Exa API key 未设置"
PY
  fi

  for pkg in $(get_required_packages "$config_level" "${configured_servers[@]}"); do
    npm list -g --depth=0 "$pkg" >/dev/null 2>&1 || {
      print_error "npm 包缺失: $pkg"; ((failures++)); }
  done

  if [[ "$config_level" != "simple" ]]; then
    command_exists uvx && uvx code-index-mcp --version >/dev/null 2>&1 \
      || { print_error "uvx / code-index-mcp 不可用"; ((failures++)); }
  fi

  command_exists codex || { print_error "Codex CLI 未安装"; ((failures++)); }

  if (( failures > 0 )); then
    print_error "安装验证失败：${failures} 个检查未通过"
    return 1
  fi

  print_message "所有验证通过 ✓"
}
```

### 实现难点与注意事项
- **npm list 速度**：多次调用可能较慢，可通过 `npm list -g --depth=0` 一次性输出，再 grep 多个包以减少调用次数。
- **Python/Bash 交互**：`mapfile` 读取 Python 输出需确保无额外日志；在 Python 发生异常时 Bash 需要捕获非零退出码。
- **Exa 条件**：仅当最终 JSON 包含 `exa` 时才检查 env/key；否则跳过，避免在用户选择“跳过”时误报。
- **跨平台路径差异**：验证阶段必须像生成阶段一样使用 `get_claude_config_dir()`，而非假定 `~/.config/claude`。

### 测试建议
- 对每种配置级别运行安装 + `verify_installation`，确认所有检查通过。
- 手动删除 JSON 中某个 server，运行验证应失败并报告缺失项。
- 卸载一个 npm 全局包（如 `npm uninstall -g mcp-shrimp-task-manager`），验证应失败。
- 将 `EXA_API_KEY` 恢复为占位符后运行验证，确认会报错。
- 将 `uvx` 从 `PATH` 中暂时移除（或重命名），标准/高级验证应失败。

---

## 问题 3：添加非交互式模式（P2-non-interactive-mode）

### 技术方案
- **参数解析**：新增 `parse_args()` 处理下列选项：
  - `--config-level {simple|standard|advanced}`（支持 `-c` 缩写）
  - `--exa-key <value>`（支持 `EXA_API_KEY=...` env）
  - `--non-interactive`（或 `-y`）禁止脚本调用任何 `read`，缺少必要数据时立即报错或使用安全默认值。
  - `--help` / `-h`：打印用法示例并退出。
  - `--version` / `-V`：输出 `SCRIPT_VERSION` 常量。
- **环境变量回退**：
  - `CLAUDE_CONFIG_LEVEL` 作为 `--config-level` 的备选；
  - `CLAUDE_INSTALL_NON_INTERACTIVE=1` 触发非交互模式；
  - 继续沿用（或新增）`EXA_API_KEY` 供密钥输入。
  - 优先级：CLI 参数 > 环境变量 > 交互输入。
- **配置选择流程改写**：
  - `resolve_config_level()`：若已有预选值则验证合法性并设置 `TEMPLATE_FILE`/`CONFIG_LEVEL`；否则调用旧的 `choose_config()` 走交互。
  - `NON_INTERACTIVE` 为真但仍未指定级别时，记录 warning 并默认 `simple`（保持可用性），同时允许通过 `CLAUDE_DEFAULT_CONFIG=simple` 等方式覆盖。
- **Exa 密钥流程**：
  - 若 `EXA_API_KEY` 已通过参数/环境提供，直接使用并跳过 `read -s`。
  - `NON_INTERACTIVE` 模式且高级配置但未提供密钥 => 自动跳过 Exa，提示用户如何后续添加。
- **帮助 / 版本输出**：在 `parse_args()` 早期处理，一旦命中直接 `exit 0`。
- **兼容性**：未传入任何参数时，脚本行为与今天完全一致（交互式问题/回答流）。

### 关键伪代码
```bash
SCRIPT_VERSION="1.5.0"
NON_INTERACTIVE=false
CLI_CONFIG_LEVEL=""
CLI_EXA_KEY=""

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --config-level|-c)
        CLI_CONFIG_LEVEL="$2"; shift 2 ;;
      --exa-key)
        CLI_EXA_KEY="$2"; shift 2 ;;
      --non-interactive|-y)
        NON_INTERACTIVE=true; shift ;;
      --help|-h)
        show_help; exit 0 ;;
      --version|-V)
        echo "$SCRIPT_VERSION"; exit 0 ;;
      *)
        print_error "未知参数: $1"; show_help; exit 1 ;;
    esac
  done
}

resolve_config_level() {
  local desired="${CLI_CONFIG_LEVEL:-${CLAUDE_CONFIG_LEVEL:-}}"
  if [[ -n "$desired" ]]; then
    validate_config_level "$desired" || exit 1
    CONFIG_LEVEL="$desired"
    TEMPLATE_FILE="$(template_for_level "$desired")"
    return
  fi

  if $NON_INTERACTIVE; then
    print_warning "非交互模式未指定 --config-level，默认 simple"
    CONFIG_LEVEL="simple"
    TEMPLATE_FILE="$(template_for_level simple)"
    return
  fi

  choose_config   # 进入现有交互逻辑
}

resolve_exa_key() {
  local provided="${CLI_EXA_KEY:-${EXA_API_KEY:-}}"
  if [[ -n "$provided" ]]; then
    echo "$provided"; return
  fi
  if [[ "$CONFIG_LEVEL" == "advanced" && $NON_INTERACTIVE == false ]]; then
    print_message "高级配置可输入 Exa API Key（可留空）"
    get_exa_api_key
  fi
}
```

### 实现难点与注意事项
- **curl | bash 输入**：在非交互场景（stdin 非 TTY）即使用户未传 `--non-interactive` 也可能导致 `read` 阻塞；可在 `main()` 中检测 `[[ ! -t 0 ]]` 并默认开启非交互模式，再提示用户。需确保不会影响正常终端运行。
- **参数验证**：用户输入非法 config-level 时要立即报错并显示 `simple|standard|advanced` 选项。
- **安全日志**：`--exa-key` 通过 CLI 传递可能出现在 shell 历史，文档/帮助需提醒优先使用环境变量或交互输入。
- **版本号维护**：引入 `SCRIPT_VERSION` 常量后需在 README/CHANGELOG 同步，但本次设计专注于脚本部分。

### 测试建议
- `./install.sh --help` 与 `--version`，确认输出并立即退出。
- `./install.sh --non-interactive --config-level standard`：整个流程应无任何 `read` 调用，完成安装。
- `CLAUDE_CONFIG_LEVEL=advanced CLAUDE_INSTALL_NON_INTERACTIVE=1 bash install.sh`：应默认跳过 Exa（若未提供密钥），且最终可生成有效 JSON。
- `./install.sh --config-level simple`（无 `--non-interactive`）：应跳过选择菜单但仍在终端展示其余交互提示。
- 在非交互 shell（如 `cat install.sh | bash -s -- --config-level simple --non-interactive`）中运行，确认不会挂起。

---

以上方案确保安装脚本在生成配置、验证安装与自动化执行三个维度全面提升健壮性，同时保持单文件、跨平台的既有特性。***
