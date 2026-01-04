"""
子 Agent 模式 - 如何实现 Task 工具进行上下文隔离。

关键洞察：生成具有隔离上下文的子 agent，以防止
"上下文污染"，即探索细节填满主对话。
"""

import time
import sys

# 假设 client、MODEL、execute_tool 在其他地方定义


# =============================================================================
# AGENT 类型注册表
# =============================================================================

AGENT_TYPES = {
    # 探索：只读，用于搜索和分析
    "explore": {
        "description": "只读 agent，用于探索代码、查找文件、搜索",
        "tools": ["bash", "read_file"],  # 没有写入权限！
        "prompt": "你是一个探索 agent。搜索和分析，但绝对不要修改文件。返回你发现的简洁总结。",
    },

    # 代码：全功能，用于实现
    "code": {
        "description": "全功能 agent，用于实现功能和修复 bug",
        "tools": "*",  # 所有工具
        "prompt": "你是一个编码 agent。高效地实现请求的更改。返回你更改内容的总结。",
    },

    # 规划：只读，用于设计工作
    "plan": {
        "description": "规划 agent，用于设计实现策略",
        "tools": ["bash", "read_file"],  # 只读
        "prompt": "你是一个规划 agent。分析代码库并输出一个编号的实现计划。不要做任何更改。",
    },

    # 在这里添加你自己的类型...
    # "test": {
    #     "description": "测试 agent，用于运行和分析测试",
    #     "tools": ["bash", "read_file"],
    #     "prompt": "运行测试并报告结果。不要修改代码。",
    # },
}


def get_agent_descriptions() -> str:
    """为 Task 工具模式生成描述。"""
    return "\n".join(
        f"- {name}: {cfg['description']}"
        for name, cfg in AGENT_TYPES.items()
    )


def get_tools_for_agent(agent_type: str, base_tools: list) -> list:
    """
    根据 agent 类型过滤工具。

    '*' 表示所有基础工具。
    否则，白名单特定工具名称。

    注意：子 agent 不获得 Task 工具以防止无限递归。
    """
    allowed = AGENT_TYPES.get(agent_type, {}).get("tools", "*")

    if allowed == "*":
        return base_tools  # 所有基础工具，但不包括 Task

    return [t for t in base_tools if t["name"] in allowed]


# =============================================================================
# TASK 工具定义
# =============================================================================

TASK_TOOL = {
    "name": "Task",
    "description": f"""生成一个子 agent 来处理聚焦的子任务。

子 agent 在隔离的上下文中运行 - 它们看不到父级的历史。
使用这个来保持主对话的干净。

Agent 类型：
{get_agent_descriptions()}

使用示例：
- Task(explore): "查找所有使用 auth 模块的文件"
- Task(plan): "为数据库设计迁移策略"
- Task(code): "实现用户注册表单"
""",
    "input_schema": {
        "type": "object",
        "properties": {
            "description": {
                "type": "string",
                "description": "简短的任务名称（3-5 个词）用于进度显示"
            },
            "prompt": {
                "type": "string",
                "description": "给子 agent 的详细指令"
            },
            "agent_type": {
                "type": "string",
                "enum": list(AGENT_TYPES.keys()),
                "description": "要生成的 agent 类型"
            },
        },
        "required": ["description", "prompt", "agent_type"],
    },
}


# =============================================================================
# 子 AGENT 执行
# =============================================================================

def run_task(description: str, prompt: str, agent_type: str,
             client, model: str, workdir, base_tools: list, execute_tool) -> str:
    """
    执行具有隔离上下文的子 agent 任务。

    关键概念：
    1. 隔离的历史 - 子 agent 从头开始，没有父级上下文
    2. 过滤的工具 - 基于 agent 类型权限
    3. Agent 特定提示 - 专门的行为
    4. 只返回总结 - 父级只看到最终结果

    参数：
        description: 用于进度显示的简短名称
        prompt: 给子 agent 的详细指令
        agent_type: AGENT_TYPES 中的键
        client: Anthropic 客户端
        model: 使用的模型
        workdir: 工作目录
        base_tools: 工具定义列表
        execute_tool: 执行工具的函数

    返回：
        子 agent 的最终文本输出
    """
    if agent_type not in AGENT_TYPES:
        return f"错误：未知的 agent 类型 '{agent_type}'"

    config = AGENT_TYPES[agent_type]

    # Agent 特定的系统提示
    sub_system = f"""你是一个在 {workdir} 的 {agent_type} 子 agent。

{config["prompt"]}

完成任务并返回清晰、简洁的总结。"""

    # 此 agent 类型的过滤工具
    sub_tools = get_tools_for_agent(agent_type, base_tools)

    # 关键：隔离的消息历史！
    # 子 agent 从头开始，看不到父级的对话
    sub_messages = [{"role": "user", "content": prompt}]

    # 进度显示
    print(f"  [{agent_type}] {description}")
    start = time.time()
    tool_count = 0

    # 运行相同的 agent 循环（但静默）
    while True:
        response = client.messages.create(
            model=model,
            system=sub_system,
            messages=sub_messages,
            tools=sub_tools,
            max_tokens=8000,
        )

        # 检查是否完成
        if response.stop_reason != "tool_use":
            break

        # 执行工具
        tool_calls = [b for b in response.content if b.type == "tool_use"]
        results = []

        for tc in tool_calls:
            tool_count += 1
            output = execute_tool(tc.name, tc.input)
            results.append({
                "type": "tool_result",
                "tool_use_id": tc.id,
                "content": output
            })

            # 更新进度（在同一行原地更新）
            elapsed = time.time() - start
            sys.stdout.write(
                f"\r  [{agent_type}] {description} ... {tool_count} 个工具, {elapsed:.1f}s"
            )
            sys.stdout.flush()

        sub_messages.append({"role": "assistant", "content": response.content})
        sub_messages.append({"role": "user", "content": str(results)})

    # 最终进度更新
    elapsed = time.time() - start
    sys.stdout.write(
        f"\r  [{agent_type}] {description} - 完成 ({tool_count} 个工具, {elapsed:.1f}s)\n"
    )

    # 提取并只返回最终文本
    # 这是父 agent 看到的 - 一个干净的总结
    for block in response.content:
        if hasattr(block, "text"):
            return block.text

    return "(子 agent 没有返回文本)"


# =============================================================================
# 使用示例
# =============================================================================

"""
# 在你的主 agent 的 execute_tool 函数中：

def execute_tool(name: str, args: dict) -> str:
    if name == "Task":
        return run_task(
            description=args["description"],
            prompt=args["prompt"],
            agent_type=args["agent_type"],
            client=client,
            model=MODEL,
            workdir=WORKDIR,
            base_tools=BASE_TOOLS,
            execute_tool=execute_tool  # 传递自身用于递归
        )
    # ... 其他工具 ...


# 在你的 TOOLS 列表中：
TOOLS = BASE_TOOLS + [TASK_TOOL]
"""
