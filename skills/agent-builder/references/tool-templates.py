"""
工具模板 - 复制并自定义这些用于你的 agent。

每个工具需要：
1. 定义（给模型的 JSON 模式）
2. 实现（Python 函数）
"""

from pathlib import Path
import subprocess

WORKDIR = Path.cwd()


# =============================================================================
# 工具定义（用于 TOOLS 列表）
# =============================================================================

BASH_TOOL = {
    "name": "bash",
    "description": "运行 shell 命令。用于：ls、find、grep、git、npm、python 等。",
    "input_schema": {
        "type": "object",
        "properties": {
            "command": {
                "type": "string",
                "description": "要执行的 shell 命令"
            }
        },
        "required": ["command"],
    },
}

READ_FILE_TOOL = {
    "name": "read_file",
    "description": "读取文件内容。返回 UTF-8 文本。",
    "input_schema": {
        "type": "object",
        "properties": {
            "path": {
                "type": "string",
                "description": "文件的相对路径"
            },
            "limit": {
                "type": "integer",
                "description": "最大读取行数（默认：全部）"
            },
        },
        "required": ["path"],
    },
}

WRITE_FILE_TOOL = {
    "name": "write_file",
    "description": "将内容写入文件。如果需要，创建父目录。",
    "input_schema": {
        "type": "object",
        "properties": {
            "path": {
                "type": "string",
                "description": "文件的相对路径"
            },
            "content": {
                "type": "string",
                "description": "要写入的内容"
            },
        },
        "required": ["path", "content"],
    },
}

EDIT_FILE_TOOL = {
    "name": "edit_file",
    "description": "替换文件中的精确文本。用于精确编辑。",
    "input_schema": {
        "type": "object",
        "properties": {
            "path": {
                "type": "string",
                "description": "文件的相对路径"
            },
            "old_text": {
                "type": "string",
                "description": "要查找的精确文本（必须精确匹配）"
            },
            "new_text": {
                "type": "string",
                "description": "替换文本"
            },
        },
        "required": ["path", "old_text", "new_text"],
    },
}

TODO_WRITE_TOOL = {
    "name": "TodoWrite",
    "description": "更新任务列表。用于规划和跟踪进度。",
    "input_schema": {
        "type": "object",
        "properties": {
            "items": {
                "type": "array",
                "description": "完整的任务列表",
                "items": {
                    "type": "object",
                    "properties": {
                        "content": {"type": "string", "description": "任务描述"},
                        "status": {"type": "string", "enum": ["pending", "in_progress", "completed"]},
                        "activeForm": {"type": "string", "description": "现在时态，例如 '正在读取文件'"},
                    },
                    "required": ["content", "status", "activeForm"],
                },
            }
        },
        "required": ["items"],
    },
}

TASK_TOOL_TEMPLATE = """
# 使用 agent 类型动态生成
TASK_TOOL = {
    "name": "Task",
    "description": f"生成一个子 agent 来处理聚焦的子任务。\\n\\nAgent 类型：\\n{get_agent_descriptions()}",
    "input_schema": {
        "type": "object",
        "properties": {
            "description": {"type": "string", "description": "简短的任务名称（3-5 个词）"},
            "prompt": {"type": "string", "description": "详细指令"},
            "agent_type": {"type": "string", "enum": list(AGENT_TYPES.keys())},
        },
        "required": ["description", "prompt", "agent_type"],
    },
}
"""


# =============================================================================
# 工具实现
# =============================================================================

def safe_path(p: str) -> Path:
    """
    安全性：确保路径保持在工作区内。
    防止 ../../../etc/passwd 攻击。
    """
    path = (WORKDIR / p).resolve()
    if not path.is_relative_to(WORKDIR):
        raise ValueError(f"路径逃逸工作区：{p}")
    return path


def run_bash(command: str) -> str:
    """
    执行带安全检查的 shell 命令。

    安全特性：
    - 阻止明显危险的命令
    - 60 秒超时
    - 输出截断到 50KB
    """
    dangerous = ["rm -rf /", "sudo", "shutdown", "reboot", "> /dev/"]
    if any(d in command for d in dangerous):
        return "错误：危险命令被阻止"

    try:
        result = subprocess.run(
            command,
            shell=True,
            cwd=WORKDIR,
            capture_output=True,
            text=True,
            timeout=60
        )
        output = (result.stdout + result.stderr).strip()
        return output[:50000] if output else "(无输出)"

    except subprocess.TimeoutExpired:
        return "错误：命令超时（60s）"
    except Exception as e:
        return f"错误：{e}"


def run_read_file(path: str, limit: int = 0) -> str:
    """
    读取文件内容，可选行数限制。

    特性：
    - 安全路径解析
    - 可选行数限制用于大文件
    - 输出截断到 50KB
    """
    try:
        text = safe_path(path).read_text()
        lines = text.splitlines()

        if limit and limit < len(lines):
            lines = lines[:limit]
            lines.append(f"... (还有 {len(text.splitlines()) - limit} 行)")

        return "\n".join(lines)[:50000]

    except Exception as e:
        return f"错误：{e}"


def run_write_file(path: str, content: str) -> str:
    """
    将内容写入文件，如果需要创建父目录。

    特性：
    - 安全路径解析
    - 自动创建父目录
    - 返回字节数用于确认
    """
    try:
        fp = safe_path(path)
        fp.parent.mkdir(parents=True, exist_ok=True)
        fp.write_text(content)
        return f"写入 {len(content)} 字节到 {path}"

    except Exception as e:
        return f"错误：{e}"


def run_edit_file(path: str, old_text: str, new_text: str) -> str:
    """
    替换文件中的精确文本（精确编辑）。

    特性：
    - 精确字符串匹配（不是正则）
    - 只替换第一次出现（安全）
    - 如果文本未找到则清晰报错
    """
    try:
        fp = safe_path(path)
        content = fp.read_text()

        if old_text not in content:
            return f"错误：在 {path} 中未找到文本"

        new_content = content.replace(old_text, new_text, 1)
        fp.write_text(new_content)
        return f"已编辑 {path}"

    except Exception as e:
        return f"错误：{e}"


# =============================================================================
# 调度器模式
# =============================================================================

def execute_tool(name: str, args: dict) -> str:
    """
    将工具调用分发到实现。

    这种模式使添加新工具变得容易：
    1. 将定义添加到 TOOLS 列表
    2. 添加实现函数
    3. 将 case 添加到此调度器
    """
    if name == "bash":
        return run_bash(args["command"])
    if name == "read_file":
        return run_read_file(args["path"], args.get("limit") or 0)
    if name == "write_file":
        return run_write_file(args["path"], args["content"])
    if name == "edit_file":
        return run_edit_file(args["path"], args["old_text"], args["new_text"])
    # 在这里添加更多工具...
    return f"未知工具：{name}"
