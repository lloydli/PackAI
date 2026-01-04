#!/usr/bin/env python3
"""
最小 Agent 模板 - 复制并自定义。

这是最简单的可工作 agent（约 80 行）。
它有你需要的一切：3 个工具 + 循环。

使用方法：
    1. 设置 ANTHROPIC_API_KEY 环境变量
    2. python minimal-agent.py
    3. 输入命令，'q' 退出
"""

from anthropic import Anthropic
from pathlib import Path
import subprocess
import os

# 配置
client = Anthropic(api_key=os.getenv("ANTHROPIC_API_KEY"))
MODEL = os.getenv("MODEL_NAME", "claude-sonnet-4-20250514")
WORKDIR = Path.cwd()

# 系统提示 - 保持简单
SYSTEM = f"""你是一个在 {WORKDIR} 工作的编码 agent。

规则：
- 使用工具完成任务
- 行动优先于解释
- 完成后总结你做了什么"""

# 最小工具集 - 根据需要添加更多
TOOLS = [
    {
        "name": "bash",
        "description": "运行 shell 命令",
        "input_schema": {
            "type": "object",
            "properties": {"command": {"type": "string"}},
            "required": ["command"]
        }
    },
    {
        "name": "read_file",
        "description": "读取文件内容",
        "input_schema": {
            "type": "object",
            "properties": {"path": {"type": "string"}},
            "required": ["path"]
        }
    },
    {
        "name": "write_file",
        "description": "将内容写入文件",
        "input_schema": {
            "type": "object",
            "properties": {
                "path": {"type": "string"},
                "content": {"type": "string"}
            },
            "required": ["path", "content"]
        }
    },
]


def execute_tool(name: str, args: dict) -> str:
    """执行工具并返回结果。"""
    if name == "bash":
        try:
            r = subprocess.run(
                args["command"], shell=True, cwd=WORKDIR,
                capture_output=True, text=True, timeout=60
            )
            return (r.stdout + r.stderr).strip() or "(空)"
        except subprocess.TimeoutExpired:
            return "错误：超时"

    if name == "read_file":
        try:
            return (WORKDIR / args["path"]).read_text()[:50000]
        except Exception as e:
            return f"错误：{e}"

    if name == "write_file":
        try:
            p = WORKDIR / args["path"]
            p.parent.mkdir(parents=True, exist_ok=True)
            p.write_text(args["content"])
            return f"写入 {len(args['content'])} 字节到 {args['path']}"
        except Exception as e:
            return f"错误：{e}"

    return f"未知工具：{name}"


def agent(prompt: str, history: list = None) -> str:
    """运行 agent 循环。"""
    if history is None:
        history = []

    history.append({"role": "user", "content": prompt})

    while True:
        response = client.messages.create(
            model=MODEL,
            system=SYSTEM,
            messages=history,
            tools=TOOLS,
            max_tokens=8000,
        )

        # 构建助手消息
        history.append({"role": "assistant", "content": response.content})

        # 如果没有工具调用，返回文本
        if response.stop_reason != "tool_use":
            return "".join(b.text for b in response.content if hasattr(b, "text"))

        # 执行工具
        results = []
        for block in response.content:
            if block.type == "tool_use":
                print(f"> {block.name}: {block.input}")
                output = execute_tool(block.name, block.input)
                print(f"  {output[:100]}...")
                results.append({
                    "type": "tool_result",
                    "tool_use_id": block.id,
                    "content": output
                })

        history.append({"role": "user", "content": results})


if __name__ == "__main__":
    print(f"最小 Agent - {WORKDIR}")
    print("输入 'q' 退出。\n")

    history = []
    while True:
        try:
            query = input(">> ").strip()
        except (EOFError, KeyboardInterrupt):
            break
        if query in ("q", "quit", "exit", ""):
            break
        print(agent(query, history))
        print()
