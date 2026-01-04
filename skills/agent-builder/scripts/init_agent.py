#!/usr/bin/env python3
"""
Agent 脚手架脚本 - 使用最佳实践创建新的 agent 项目。

使用方法：
    python init_agent.py <agent-name> [--level 0-4] [--path <output-dir>]

示例：
    python init_agent.py my-agent                 # 级别 1（4 个工具）
    python init_agent.py my-agent --level 0      # 最小（仅 bash）
    python init_agent.py my-agent --level 2      # 带 TodoWrite
    python init_agent.py my-agent --path ./bots  # 自定义输出目录
"""

import argparse
import sys
from pathlib import Path

# 每个级别的 Agent 模板
TEMPLATES = {
    0: '''#!/usr/bin/env python3
"""
级别 0 Agent - Bash 就是你需要的一切（约 50 行）

核心洞察：一个工具（bash）可以做所有事情。
通过自递归实现子 agent：python {name}.py "子任务"
"""

from anthropic import Anthropic
from dotenv import load_dotenv
import subprocess
import os

load_dotenv()

client = Anthropic(
    api_key=os.getenv("ANTHROPIC_API_KEY"),
    base_url=os.getenv("ANTHROPIC_BASE_URL")
)
MODEL = os.getenv("MODEL_NAME", "claude-sonnet-4-20250514")

SYSTEM = """你是一个编码 agent。使用 bash 做所有事情：
- 读取：cat、grep、find、ls
- 写入：echo 'content' > file
- 子 agent：python {name}.py "子任务"
"""

TOOL = [{{
    "name": "bash",
    "description": "执行 shell 命令",
    "input_schema": {{"type": "object", "properties": {{"command": {{"type": "string"}}}}, "required": ["command"]}}
}}]

def run(prompt, history=[]):
    history.append({{"role": "user", "content": prompt}})
    while True:
        r = client.messages.create(model=MODEL, system=SYSTEM, messages=history, tools=TOOL, max_tokens=8000)
        history.append({{"role": "assistant", "content": r.content}})
        if r.stop_reason != "tool_use":
            return "".join(b.text for b in r.content if hasattr(b, "text"))
        results = []
        for b in r.content:
            if b.type == "tool_use":
                print(f"> {{b.input['command']}}")
                try:
                    out = subprocess.run(b.input["command"], shell=True, capture_output=True, text=True, timeout=60)
                    output = (out.stdout + out.stderr).strip() or "(空)"
                except Exception as e:
                    output = f"错误：{{e}}"
                results.append({{"type": "tool_result", "tool_use_id": b.id, "content": output[:50000]}})
        history.append({{"role": "user", "content": results}})

if __name__ == "__main__":
    h = []
    print("{name} - 级别 0 Agent\\n输入 'q' 退出。\\n")
    while (q := input(">> ").strip()) not in ("q", "quit", ""):
        print(run(q, h), "\\n")
''',

    1: '''#!/usr/bin/env python3
"""
级别 1 Agent - 模型即 Agent（约 200 行）

核心洞察：4 个工具覆盖 90% 的编码任务。
模型就是 agent。代码只是运行循环。
"""

from anthropic import Anthropic
from dotenv import load_dotenv
from pathlib import Path
import subprocess
import os

load_dotenv()

client = Anthropic(
    api_key=os.getenv("ANTHROPIC_API_KEY"),
    base_url=os.getenv("ANTHROPIC_BASE_URL")
)
MODEL = os.getenv("MODEL_NAME", "claude-sonnet-4-20250514")
WORKDIR = Path.cwd()

SYSTEM = f"""你是一个在 {{WORKDIR}} 工作的编码 agent。

规则：
- 工具优先于散文。行动，不只是解释。
- 永远不要编造文件路径。如果不确定，先使用 ls/find。
- 做最小的更改。不要过度工程。
- 完成后，总结更改了什么。"""

TOOLS = [
    {{"name": "bash", "description": "运行 shell 命令",
     "input_schema": {{"type": "object", "properties": {{"command": {{"type": "string"}}}}, "required": ["command"]}}}},
    {{"name": "read_file", "description": "读取文件内容",
     "input_schema": {{"type": "object", "properties": {{"path": {{"type": "string"}}}}, "required": ["path"]}}}},
    {{"name": "write_file", "description": "将内容写入文件",
     "input_schema": {{"type": "object", "properties": {{"path": {{"type": "string"}}, "content": {{"type": "string"}}}}, "required": ["path", "content"]}}}},
    {{"name": "edit_file", "description": "替换文件中的精确文本",
     "input_schema": {{"type": "object", "properties": {{"path": {{"type": "string"}}, "old_text": {{"type": "string"}}, "new_text": {{"type": "string"}}}}, "required": ["path", "old_text", "new_text"]}}}},
]

def safe_path(p: str) -> Path:
    """防止路径逃逸攻击。"""
    path = (WORKDIR / p).resolve()
    if not path.is_relative_to(WORKDIR):
        raise ValueError(f"路径逃逸工作区：{{p}}")
    return path

def execute(name: str, args: dict) -> str:
    """执行工具并返回结果。"""
    if name == "bash":
        dangerous = ["rm -rf /", "sudo", "shutdown", "> /dev/"]
        if any(d in args["command"] for d in dangerous):
            return "错误：危险命令被阻止"
        try:
            r = subprocess.run(args["command"], shell=True, cwd=WORKDIR, capture_output=True, text=True, timeout=60)
            return (r.stdout + r.stderr).strip()[:50000] or "(空)"
        except subprocess.TimeoutExpired:
            return "错误：超时（60s）"
        except Exception as e:
            return f"错误：{{e}}"

    if name == "read_file":
        try:
            return safe_path(args["path"]).read_text()[:50000]
        except Exception as e:
            return f"错误：{{e}}"

    if name == "write_file":
        try:
            p = safe_path(args["path"])
            p.parent.mkdir(parents=True, exist_ok=True)
            p.write_text(args["content"])
            return f"写入 {{len(args['content'])}} 字节到 {{args['path']}}"
        except Exception as e:
            return f"错误：{{e}}"

    if name == "edit_file":
        try:
            p = safe_path(args["path"])
            content = p.read_text()
            if args["old_text"] not in content:
                return f"错误：在 {{args['path']}} 中未找到文本"
            p.write_text(content.replace(args["old_text"], args["new_text"], 1))
            return f"已编辑 {{args['path']}}"
        except Exception as e:
            return f"错误：{{e}}"

    return f"未知工具：{{name}}"

def agent(prompt: str, history: list = None) -> str:
    """运行 agent 循环。"""
    if history is None:
        history = []
    history.append({{"role": "user", "content": prompt}})

    while True:
        response = client.messages.create(
            model=MODEL, system=SYSTEM, messages=history, tools=TOOLS, max_tokens=8000
        )
        history.append({{"role": "assistant", "content": response.content}})

        if response.stop_reason != "tool_use":
            return "".join(b.text for b in response.content if hasattr(b, "text"))

        results = []
        for block in response.content:
            if block.type == "tool_use":
                print(f"> {{block.name}}: {{str(block.input)[:100]}}")
                output = execute(block.name, block.input)
                print(f"  {{output[:100]}}...")
                results.append({{"type": "tool_result", "tool_use_id": block.id, "content": output}})
        history.append({{"role": "user", "content": results}})

if __name__ == "__main__":
    print(f"{name} - 级别 1 Agent 在 {{WORKDIR}}")
    print("输入 'q' 退出。\\n")
    h = []
    while True:
        try:
            query = input(">> ").strip()
        except (EOFError, KeyboardInterrupt):
            break
        if query in ("q", "quit", "exit", ""):
            break
        print(agent(query, h), "\\n")
''',
}

ENV_TEMPLATE = '''# API 配置
ANTHROPIC_API_KEY=sk-xxx
ANTHROPIC_BASE_URL=https://api.anthropic.com
MODEL_NAME=claude-sonnet-4-20250514
'''


def create_agent(name: str, level: int, output_dir: Path):
    """创建新的 agent 项目。"""
    # 验证级别
    if level not in TEMPLATES and level not in (2, 3, 4):
        print(f"错误：级别 {level} 在脚手架中尚未实现。")
        print("可用级别：0（最小）、1（4 个工具）")
        print("对于级别 2-4，从 mini-claude-code 仓库复制。")
        sys.exit(1)

    # 创建输出目录
    agent_dir = output_dir / name
    agent_dir.mkdir(parents=True, exist_ok=True)

    # 写入 agent 文件
    agent_file = agent_dir / f"{name}.py"
    template = TEMPLATES.get(level, TEMPLATES[1])
    agent_file.write_text(template.format(name=name))
    print(f"已创建：{agent_file}")

    # 写入 .env.example
    env_file = agent_dir / ".env.example"
    env_file.write_text(ENV_TEMPLATE)
    print(f"已创建：{env_file}")

    # 写入 .gitignore
    gitignore = agent_dir / ".gitignore"
    gitignore.write_text(".env\n__pycache__/\n*.pyc\n")
    print(f"已创建：{gitignore}")

    print(f"\nAgent '{name}' 已创建在 {agent_dir}")
    print(f"\n下一步：")
    print(f"  1. cd {agent_dir}")
    print(f"  2. cp .env.example .env")
    print(f"  3. 用你的 API 密钥编辑 .env")
    print(f"  4. pip install anthropic python-dotenv")
    print(f"  5. python {name}.py")


def main():
    parser = argparse.ArgumentParser(
        description="搭建新的 AI 编码 agent 项目",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
级别：
  0  最小（约 50 行）  - 单个 bash 工具，自递归用于子 agent
  1  基础（约 200 行） - 4 个核心工具：bash、read、write、edit
  2  Todo（约 300 行） - + TodoWrite 用于结构化规划
  3  子 Agent（约 450）- + Task 工具用于上下文隔离
  4  Skills（约 550）  - + Skill 工具用于领域专业知识
        """
    )
    parser.add_argument("name", help="要创建的 agent 名称")
    parser.add_argument("--level", type=int, default=1, choices=[0, 1, 2, 3, 4],
                       help="复杂度级别（默认：1）")
    parser.add_argument("--path", type=Path, default=Path.cwd(),
                       help="输出目录（默认：当前目录）")

    args = parser.parse_args()
    create_agent(args.name, args.level, args.path)


if __name__ == "__main__":
    main()
