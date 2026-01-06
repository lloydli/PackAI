# PackAI - 通用 Agent Skills 集合

一套高质量的 Agent Skills，用于扩展 AI Agent 的专业能力。

---

## 核心理念

> **Skill = 专家独有知识 − Claude 已知的知识**

Skill 不是教程，而是**知识外化机制**——把领域专家的思维方式、决策原则、反模式直觉压缩成可加载的 Markdown 文件。当 Agent 加载 Skill 时，它继承的是专家思维，而非操作步骤。

```
传统方式：收集数据 → GPU 训练 → 部署新版本（$10,000+，数周）
Skill 方式：编辑 SKILL.md → 保存 → 即时生效（$0，即时）
```

---

## 仓库结构

```
PackAI/
├── commands/                # 命令模板
│   └── commit-push-pr.md        # Git 提交/PR 工作流命令
├── config/                  # 配置文件
│   └── sync_project_paths.txt   # 同步目标路径配置
├── docs/                    # 文档
│   ├── agent-skill-spec.md      # Skill 格式规范
│   └── how-to-create-great-agent-skill.md  # Skill 设计指南
├── rules/                   # 通用规则
│   ├── general-rule.md          # 协作协议和编码规范
│   └── frontend-architecture-rule.md  # Vue3 前端架构规范
├── skills/                  # Skills 集合
│   ├── agent-builder/           # Agent 构建器
│   ├── fast-search/             # 极速代码搜索
│   ├── frontend-design/         # 前端设计
│   ├── mcp-builder/             # MCP 服务器构建器
│   ├── skill-creator/           # Skill 创建器
│   ├── skill-judge/             # Skill 评审官
│   └── UnrealCodeImitator/      # Unreal 源码学习与插件开发
├── mcp.json                 # MCP 服务器配置（同步到用户目录）
└── sync.bat                 # 同步工具脚本
```

---

## Skills 一览

| Skill | 描述 | 适用场景 |
|-------|------|----------|
| **agent-builder** | 设计和构建任意领域的 AI Agent | 创建助手、自主系统、工作流编排 |
| **fast-search** | 极速代码搜索，并行执行，智能过滤 | 大规模代码搜索、符号追踪、重构分析 |
| **frontend-design** | 创建独特的生产级前端界面 | Web 组件、页面、仪表盘、UI 设计 |
| **mcp-builder** | 构建 MCP 服务器的完整指南 | TypeScript/Python MCP 服务器开发 |
| **skill-creator** | 创建高效 Skill 的指南 | 新建或更新 Agent Skill |
| **skill-judge** | 多维度评估 Skill 设计质量 | 审查、审计、改进 SKILL.md |
| **UnrealCodeImitator** | Unreal 源码学习与插件开发 | UE 源码分析、插件开发、自动编译迭代 |

---

## 文档说明

### `docs/agent-skill-spec.md`
Skill 的完整格式规范，包括：
- 目录结构要求
- YAML frontmatter 格式
- 可选目录（scripts/、references/、assets/）
- 渐进式披露设计原则

### `docs/how-to-create-great-agent-skill.md`
深度指南，涵盖：
- Skill 的本质（知识外化机制）
- 6 条核心判断标准
- 5 种 Skill 设计模式
- 好 Skill vs 坏 Skill 对比
- 加载触发机制设计

---

## 快速开始

### 使用 Skill
将 `skills/` 目录下的 Skill 文件夹复制到你的 Agent 项目中，Agent 会根据 `description` 字段自动识别何时激活。

### 创建新 Skill
1. 阅读 `docs/how-to-create-great-agent-skill.md`
2. 使用 `skill-creator` Skill 指导创建流程
3. 使用 `skill-judge` Skill 评估质量

---

## 设计原则

### Token 效率
上下文窗口是公共资源。只添加 Claude 不知道的专家知识，删除所有冗余解释。

### 思维模式 > 机械步骤
传递专家的思维方式（"在做 X 之前，问自己..."），而非 Step 1, 2, 3。

### 反模式清单
明确的"绝对不要"清单，带具体原因——这是专家踩坑后的经验。

### 渐进式披露
```
第 1 层：元数据（~100 token）→ 始终在内存
第 2 层：SKILL.md 正文（<500 行）→ 触发后加载
第 3 层：references/（无限制）→ 按需加载
```

### 自由度校准
- 创意任务 → 高自由度（原则，不是步骤）
- 脆弱操作 → 低自由度（精确脚本）

---

## 相关链接

- [Anthropic Skills 官方仓库](https://github.com/anthropics/skills)
- [shareAI-skills](https://github.com/shareAI-lab/shareAI-skills)

---

## 同步工具

运行 `sync.bat` 可将 `commands`、`rules`、`skills` 同步到配置文件指定的项目目录，同时将 `mcp.json` 同步到用户配置目录：

```batch
# 双击运行或命令行执行
d:\PackAI\sync.bat
```

### 配置说明

编辑 `config/sync_project_paths.txt` 添加目标项目路径：

```
# 每行一个路径，# 开头为注释
C:\MyProject\.codebuddy
D:\AnotherProject\.codebuddy
```

### 同步内容

| 源 | 目标 |
|----|------|
| `commands/` | `<项目>/.codebuddy/commands/` |
| `rules/` | `<项目>/.codebuddy/rules/` |
| `skills/` | `<项目>/.codebuddy/skills/` |
| `mcp.json` | `%USERPROFILE%/.codebuddy/mcp.json` |

---

## Commands 命令模板

| 命令 | 描述 |
|------|------|
| **commit-push-pr** | 标准化 Git 提交/PR 工作流（读取 diff → 生成 commit message → PR 描述） |
