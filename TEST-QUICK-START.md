# 🚀 快速测试指南

> 5 分钟快速测试 Codex Workflow Skill

---

## Step 1: 拉取代码

```bash
git checkout claude/analyze-project-logic-011CV4iSiKLMQmoWULGYvChi
git pull
./check-skill-health.sh
```

---

## Step 2: 重启 Claude Code

**重要！** 必须完全重启才能加载 Skill

---

## Step 3: 测试 Skill 激活

在 Claude Code 中打开此项目，输入：

```
帮我分析并重构 install.sh 脚本，这个脚本有 400 多行，太复杂了
```

### 成功标志：

Claude 提到：
- ✅ "6 步工作流程"
- ✅ "sequential-thinking"
- ✅ "codex 扫描"

### 失败标志：

Claude 直接开始分析，没提到工作流

---

## Step 4: 观察 Codex 返回内容

当 Claude 调用 Codex 后，看它显示了多少内容：

### 可能性A：简短 ✅
```
✓ Codex 扫描完成
- 分析了 install.sh
- 详细结果已保存
```
(~50-200 字)

### 可能性B：详细 ⚠️
```
Codex 返回了详细分析：
{
  "project_location": "...",
  "current_implementation": "[大量内容]",
  ...
}
```
(>1000 字)

---

## Step 5: 检查输出文件

```bash
ls -lh .claude/
cat .claude/context-initial.json | head -20
```

---

## 📊 告诉我

把以下信息发给我：

1. **Skill 是否激活**？（是/否）
2. **Codex 返回内容类型**？（简短/详细）
3. **Claude 显示的内容长度**？（估计字数）
4. **生成了哪些文件**？（ls 输出）
5. **任何错误信息**

---

**详细步骤**: 见 [TESTING-GUIDE.md](TESTING-GUIDE.md)
