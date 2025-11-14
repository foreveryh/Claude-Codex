总体评分: 25/100
建议: 退回

## 主要发现
- Python 重构未实际运行：`generate_config()` 调用 `python3 <<'PYTHON_SCRIPT' "$template_file" "$output_file" "$exa_api_key"` (install.sh:239-275) 少了 `-` 参数，Python 会尝试把 `$template_file` 当作脚本执行，而不是读取 heredoc。模板 JSON 恰好是合法的 Python 字面量，所以不会报错但也不会写出配置文件，后续 `python3 -m json.tool "$output_file"` 永远在旧文件或不存在的文件上运行，整个安装流程被阻塞，且偏离 `.claude/solution-design.md:11-49` 要求的“使用 Python 重写 JSON 并写回”。
- 验证阶段的 Python 校验同样失效：`configured_servers=$(python3 <<'PYTHON_SCRIPT' "$config_file" ...)` 和 Exa key 检查 (install.sh:484-531) 与上面相同的问题，导致 `configured_servers` 始终为空、Exa 校验逻辑从未触发。脚本会把所有必需 server 误判为缺失，无法完成 `P1-enhanced-validation` 目标（参考 `.claude/solution-design.md:71-147`）。
- Exa 占位符仅发出 warning：当配置仍包含 `exa` 但密钥缺失或仍是占位符时，脚本只调用 `print_warning`，没有把失败计入 `failures` (install.sh:512-531)。设计文档强调这是致命错误并应阻止安装通过（`.claude/solution-design.md:82-134`）。
- npm 依赖检查未根据实际启用的 server 细化：`get_required_npm_packages()` 对 advanced 总是返回 `exa-mcp-server` (install.sh:441-452)，即使用户跳过 Exa。设计稿要求“仅在对应级别/启用时检查” (`.claude/solution-design.md:84-85`)，否则会让跳过 Exa 的高级安装在验证阶段被误判失败。
- 测试覆盖缺失：方案第 62-67 行列出的关键场景（带/不带 Exa、模板破坏）都没有自动化或脚本化验证，也没有手动验证记录；当前严重回归表明这些测试没有被执行。

## 核对清单
- [ ] Python heredoc 正确读取参数并生成配置
- [ ] verify_installation 能解析 JSON 并校验 servers / npm / Exa
- [ ] Exa 占位符触发致命错误
- [ ] npm 依赖检查与实际启用的组件一致
- [ ] 关键场景已有可复现的测试步骤/记录

## 风险与阻塞点
- 配置文件无法生成，安装流程被阻断（阻塞发布）。
- 验证逻辑无法获取真实数据，导致所有安装路径都被判定失败。
- Exa 校验降级为 warning，无法防止占位符泄露到生产使用。
- 对 Exa 包的硬性要求与“可选启用”策略相悖，未来一旦允许跳过安装会立即失败。

## 改进建议
1. 在所有 heredoc Python 调用中使用 `python3 - <<'PY' ...`（或 `python3 /usr/bin/env python3 <<'PY'`），并添加单元/集成测试来验证 `generate_config` 真实写入文件、`verify_installation` 能读回预期 server 列表。
2. 将 Exa 校验恢复为致命错误：当 `mcpServers.exa` 存在且密钥缺失时 `((failures++))`，并在信息里提示如何修复。
3. 让 `get_required_npm_packages()` 根据配置文件是否包含 `exa` 决定是否检查 `exa-mcp-server`，以符合“仅在启用时检查”的设计；同时记录验证前置条件或在日志中说明可选依赖的安装策略。
4. 按方案 62-67/164-169 的建议补齐最小回归脚本（例如 `python3 -m pytest` 或 bash smoke tests）并把结果写入提交说明，防止此类回归再次发生。

## 支持论据
- `.claude/solution-design.md:11-49` 要求通过 Python 生成合法 JSON，并在写入后运行 `python3 -m json.tool` 验证。
- `install.sh:239-275` 的 `python3 <<'PYTHON_SCRIPT' "$template_file" ...` 缺少 `-`，Python 实际执行模板文件而不是 heredoc，因此没有任何写文件逻辑被触发。
- `.claude/solution-design.md:71-147` 详细规定了 JSON 解析、server 列表检查、npm 校验以及将错误计入 `failures` 的流程。
- `install.sh:484-531` 里的两个 Python heredoc 同样缺少 `-`，导致 `configured_servers` 为空且 Exa 校验永远不会失败。
- `.claude/solution-design.md:82-85` 指出 Exa/Chrome 仅在“对应级别/启用”时才检查；`install.sh:441-452` 却无条件要求 `exa-mcp-server`，与设计不符。
