# 规范

> Agent Skills 的完整格式规范。

本文档定义了 Agent Skills 格式。

## 目录结构

一个 skill 是一个至少包含 `SKILL.md` 文件的目录：

```
skill-name/
└── SKILL.md          # 必需
```

<Tip>
  你可以选择性地包含[附加目录](#可选目录)，如 `scripts/`、`references/` 和 `assets/` 来支持你的 skill。
</Tip>

## SKILL.md 格式

`SKILL.md` 文件必须包含 YAML frontmatter，后跟 Markdown 内容。

### Frontmatter（必需）

```yaml  theme={null}
---
name: skill-name
description: 描述这个 skill 做什么以及何时使用它。
---
```

带可选字段：

```yaml  theme={null}
---
name: pdf-processing
description: 从 PDF 文件中提取文本和表格，填写表单，合并文档。
license: Apache-2.0
metadata:
  author: example-org
  version: "1.0"
---
```

| 字段            | 必需 | 约束                                                                                                              |
| --------------- | ---- | ----------------------------------------------------------------------------------------------------------------- |
| `name`          | 是   | 最多 64 个字符。仅允许小写字母、数字和连字符。不能以连字符开头或结尾。                                             |
| `description`   | 是   | 最多 1024 个字符。非空。描述 skill 做什么以及何时使用它。                                                         |
| `license`       | 否   | 许可证名称或对捆绑许可证文件的引用。                                                                              |
| `compatibility` | 否   | 最多 500 个字符。指示环境要求（目标产品、系统包、网络访问等）。                                                   |
| `metadata`      | 否   | 任意键值映射，用于附加元数据。                                                                                    |
| `allowed-tools` | 否   | 以空格分隔的预批准工具列表，skill 可以使用这些工具。（实验性）                                                    |

#### `name` 字段

必需的 `name` 字段：

* 必须是 1-64 个字符
* 只能包含 Unicode 小写字母数字字符和连字符（`a-z` 和 `-`）
* 不能以 `-` 开头或结尾
* 不能包含连续的连字符（`--`）
* 必须与父目录名称匹配

有效示例：

```yaml  theme={null}
name: pdf-processing
```

```yaml  theme={null}
name: data-analysis
```

```yaml  theme={null}
name: code-review
```

无效示例：

```yaml  theme={null}
name: PDF-Processing  # 不允许大写
```

```yaml  theme={null}
name: -pdf  # 不能以连字符开头
```

```yaml  theme={null}
name: pdf--processing  # 不允许连续连字符
```

#### `description` 字段

必需的 `description` 字段：

* 必须是 1-1024 个字符
* 应该描述 skill 做什么以及何时使用它
* 应该包含特定的关键词，帮助 agent 识别相关任务

好的示例：

```yaml  theme={null}
description: 从 PDF 文件中提取文本和表格，填写 PDF 表单，合并多个 PDF。当处理 PDF 文档或用户提到 PDF、表单或文档提取时使用。
```

差的示例：

```yaml  theme={null}
description: 帮助处理 PDF。
```

#### `license` 字段

可选的 `license` 字段：

* 指定应用于 skill 的许可证
* 我们建议保持简短（许可证名称或捆绑许可证文件的名称）

示例：

```yaml  theme={null}
license: Proprietary. LICENSE.txt has complete terms
```

#### `compatibility` 字段

可选的 `compatibility` 字段：

* 如果提供，必须是 1-500 个字符
* 只有当你的 skill 有特定环境要求时才应包含
* 可以指示目标产品、所需系统包、网络访问需求等

示例：

```yaml  theme={null}
compatibility: 为 Claude Code（或类似产品）设计
```

```yaml  theme={null}
compatibility: 需要 git、docker、jq 和互联网访问
```

<Note>
  大多数 skill 不需要 `compatibility` 字段。
</Note>

#### `metadata` 字段

可选的 `metadata` 字段：

* 从字符串键到字符串值的映射
* 客户端可以使用它来存储 Agent Skills 规范未定义的附加属性
* 我们建议使你的键名足够独特，以避免意外冲突

示例：

```yaml  theme={null}
metadata:
  author: example-org
  version: "1.0"
```

#### `allowed-tools` 字段

可选的 `allowed-tools` 字段：

* 以空格分隔的预批准运行工具列表
* 实验性。对此字段的支持可能因 agent 实现而异

示例：

```yaml  theme={null}
allowed-tools: Bash(git:*) Bash(jq:*) Read
```

### 正文内容

frontmatter 之后的 Markdown 正文包含 skill 指令。没有格式限制。写任何有助于 agent 有效执行任务的内容。

推荐的部分：

* 分步说明
* 输入和输出示例
* 常见边缘情况

请注意，agent 在决定激活 skill 后会加载整个文件。考虑将较长的 `SKILL.md` 内容拆分为引用文件。

## 可选目录

### scripts/

包含 agent 可以运行的可执行代码。脚本应该：

* 自包含或清楚地记录依赖项
* 包含有用的错误消息
* 优雅地处理边缘情况

支持的语言取决于 agent 实现。常见选项包括 Python、Bash 和 JavaScript。

### references/

包含 agent 在需要时可以阅读的附加文档：

* `REFERENCE.md` - 详细的技术参考
* `FORMS.md` - 表单模板或结构化数据格式
* 特定领域文件（`finance.md`、`legal.md` 等）

保持单个[引用文件](#文件引用)的专注性。Agent 按需加载这些文件，因此较小的文件意味着更少的上下文使用。

### assets/

包含静态资源：

* 模板（文档模板、配置模板）
* 图像（图表、示例）
* 数据文件（查找表、模式）

## 渐进式披露

Skill 应该结构化以高效使用上下文：

1. **元数据**（约 100 个 token）：`name` 和 `description` 字段在启动时为所有 skill 加载
2. **指令**（建议 < 5000 个 token）：当 skill 被激活时加载完整的 `SKILL.md` 正文
3. **资源**（按需）：文件（例如 `scripts/`、`references/` 或 `assets/` 中的文件）仅在需要时加载

保持你的主 `SKILL.md` 在 500 行以下。将详细的参考材料移至单独的文件。

## 文件引用

在你的 skill 中引用其他文件时，使用相对于 skill 根目录的相对路径：

```markdown  theme={null}
详情请参阅[参考指南](references/REFERENCE.md)。

运行提取脚本：
scripts/extract.py
```

保持文件引用在 `SKILL.md` 的一层深度内。避免深度嵌套的引用链。

## 验证

使用 [skills-ref](https://github.com/agentskills/agentskills/tree/main/skills-ref) 参考库来验证你的 skill：

```bash  theme={null}
skills-ref validate ./my-skill
```

这会检查你的 `SKILL.md` frontmatter 是否有效并遵循所有命名约定。


---
