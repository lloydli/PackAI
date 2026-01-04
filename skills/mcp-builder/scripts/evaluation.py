"""MCP 服务器评估工具

此脚本通过使用 Claude 运行测试问题来评估 MCP 服务器。
"""

import argparse
import asyncio
import json
import re
import sys
import time
import traceback
import xml.etree.ElementTree as ET
from pathlib import Path
from typing import Any

from anthropic import Anthropic

from connections import create_connection

EVALUATION_PROMPT = """你是一个可以访问工具的 AI 助手。

当给定任务时，你必须：
1. 使用可用工具完成任务
2. 提供你方法中每个步骤的摘要，包装在 <summary> 标签中
3. 提供对所提供工具的反馈，包装在 <feedback> 标签中
4. 提供你的最终响应，包装在 <response> 标签中

摘要要求：
- 在 <summary> 标签中，你必须解释：
  - 你完成任务所采取的步骤
  - 你使用了哪些工具，按什么顺序，为什么
  - 你提供给每个工具的输入
  - 你从每个工具收到的输出
  - 你如何得出响应的摘要

反馈要求：
- 在 <feedback> 标签中，提供对工具的建设性反馈：
  - 评论工具名称：它们是否清晰和描述性？
  - 评论输入参数：它们是否有良好的文档？必需和可选参数是否清晰？
  - 评论描述：它们是否准确描述了工具的功能？
  - 评论工具使用过程中遇到的任何错误
  - 识别具体的改进领域并解释为什么它们会有帮助
  - 在建议中要具体和可操作

响应要求：
- 你的响应应该简洁并直接回答所问的问题
- 始终将最终响应包装在 <response> 标签中
- 如果无法解决任务返回 <response>NOT_FOUND</response>
- 对于数字响应，只提供数字
- 对于 ID，只提供 ID
- 对于名称或文本，提供请求的确切文本
- 你的响应应该放在最后"""


def parse_evaluation_file(file_path: Path) -> list[dict[str, Any]]:
    """解析带有 qa_pair 元素的 XML 评估文件。"""
    try:
        tree = ET.parse(file_path)
        root = tree.getroot()
        evaluations = []

        for qa_pair in root.findall(".//qa_pair"):
            question_elem = qa_pair.find("question")
            answer_elem = qa_pair.find("answer")

            if question_elem is not None and answer_elem is not None:
                evaluations.append({
                    "question": (question_elem.text or "").strip(),
                    "answer": (answer_elem.text or "").strip(),
                })

        return evaluations
    except Exception as e:
        print(f"解析评估文件 {file_path} 时出错：{e}")
        return []


def extract_xml_content(text: str, tag: str) -> str | None:
    """从 XML 标签中提取内容。"""
    pattern = rf"<{tag}>(.*?)</{tag}>"
    matches = re.findall(pattern, text, re.DOTALL)
    return matches[-1].strip() if matches else None


async def agent_loop(
    client: Anthropic,
    model: str,
    question: str,
    tools: list[dict[str, Any]],
    connection: Any,
) -> tuple[str, dict[str, Any]]:
    """使用 MCP 工具运行代理循环。"""
    messages = [{"role": "user", "content": question}]

    response = await asyncio.to_thread(
        client.messages.create,
        model=model,
        max_tokens=4096,
        system=EVALUATION_PROMPT,
        messages=messages,
        tools=tools,
    )

    messages.append({"role": "assistant", "content": response.content})
    tool_metrics = {}

    while response.stop_reason == "tool_use":
        tool_use = next(block for block in response.content if block.type == "tool_use")
        tool_name = tool_use.name
        tool_input = tool_use.input

        tool_start_ts = time.time()
        try:
            tool_result = await connection.call_tool(tool_name, tool_input)
            tool_response = json.dumps(tool_result) if isinstance(tool_result, (dict, list)) else str(tool_result)
        except Exception as e:
            tool_response = f"执行工具 {tool_name} 时出错：{str(e)}\n"
            tool_response += traceback.format_exc()
        tool_duration = time.time() - tool_start_ts

        if tool_name not in tool_metrics:
            tool_metrics[tool_name] = {"count": 0, "durations": []}
        tool_metrics[tool_name]["count"] += 1
        tool_metrics[tool_name]["durations"].append(tool_duration)

        messages.append({
            "role": "user",
            "content": [{
                "type": "tool_result",
                "tool_use_id": tool_use.id,
                "content": tool_response,
            }]
        })

        response = await asyncio.to_thread(
            client.messages.create,
            model=model,
            max_tokens=4096,
            system=EVALUATION_PROMPT,
            messages=messages,
            tools=tools,
        )
        messages.append({"role": "assistant", "content": response.content})

    response_text = next(
        (block.text for block in response.content if hasattr(block, "text")),
        None,
    )
    return response_text, tool_metrics


async def run_evaluation(eval_path: Path, connection: Any, model: str = "claude-3-7-sonnet-20250219") -> str:
    """使用 MCP 服务器工具运行评估。"""
    print("🚀 开始评估")

    client = Anthropic()
    tools = await connection.list_tools()
    print(f"📋 从 MCP 服务器加载了 {len(tools)} 个工具")

    qa_pairs = parse_evaluation_file(eval_path)
    print(f"📋 加载了 {len(qa_pairs)} 个评估任务")

    results = []
    for i, qa_pair in enumerate(qa_pairs):
        print(f"处理任务 {i + 1}/{len(qa_pairs)}")
        start_time = time.time()
        response, tool_metrics = await agent_loop(client, model, qa_pair["question"], tools, connection)
        
        response_value = extract_xml_content(response, "response")
        summary = extract_xml_content(response, "summary")
        feedback = extract_xml_content(response, "feedback")
        
        results.append({
            "question": qa_pair["question"],
            "expected": qa_pair["answer"],
            "actual": response_value,
            "score": int(response_value == qa_pair["answer"]) if response_value else 0,
            "total_duration": time.time() - start_time,
            "tool_calls": tool_metrics,
            "summary": summary,
            "feedback": feedback,
        })

    correct = sum(r["score"] for r in results)
    accuracy = (correct / len(results)) * 100 if results else 0

    report = f"""
# 评估报告

## 摘要

- **准确率**: {correct}/{len(results)} ({accuracy:.1f}%)
- **总工具调用次数**: {sum(sum(len(m["durations"]) for m in r["tool_calls"].values()) for r in results)}

---
"""

    for i, result in enumerate(results):
        report += f"""
### 任务 {i + 1}

**问题**: {result["question"]}
**预期答案**: `{result["expected"]}`
**实际答案**: `{result["actual"] or "N/A"}`
**正确**: {"✅" if result["score"] else "❌"}

---
"""

    return report


async def main():
    parser = argparse.ArgumentParser(description="使用测试问题评估 MCP 服务器")
    parser.add_argument("eval_file", type=Path, help="评估 XML 文件路径")
    parser.add_argument("-t", "--transport", choices=["stdio", "sse", "http"], default="stdio")
    parser.add_argument("-m", "--model", default="claude-3-7-sonnet-20250219")
    parser.add_argument("-c", "--command", help="运行 MCP 服务器的命令")
    parser.add_argument("-a", "--args", nargs="+", help="命令参数")
    parser.add_argument("-e", "--env", nargs="+", help="KEY=VALUE 格式的环境变量")
    parser.add_argument("-u", "--url", help="MCP 服务器 URL")
    parser.add_argument("-H", "--header", nargs="+", dest="headers")
    parser.add_argument("-o", "--output", type=Path)

    args = parser.parse_args()

    headers = {}
    if args.headers:
        for h in args.headers:
            if ":" in h:
                k, v = h.split(":", 1)
                headers[k.strip()] = v.strip()

    env_vars = {}
    if args.env:
        for e in args.env:
            if "=" in e:
                k, v = e.split("=", 1)
                env_vars[k.strip()] = v.strip()

    connection = create_connection(
        transport=args.transport,
        command=args.command,
        args=args.args,
        env=env_vars or None,
        url=args.url,
        headers=headers or None,
    )

    async with connection:
        report = await run_evaluation(args.eval_file, connection, args.model)
        if args.output:
            args.output.write_text(report, encoding='utf-8')
            print(f"✅ 报告已保存到 {args.output}")
        else:
            print(report)


if __name__ == "__main__":
    asyncio.run(main())
