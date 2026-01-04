# Python MCP 服务器实现指南

## 概述

本文档提供使用 MCP Python SDK 实现 MCP 服务器的 Python 特定最佳实践和示例。

---

## 快速参考

### 关键导入
```python
from mcp.server.fastmcp import FastMCP
from pydantic import BaseModel, Field, field_validator, ConfigDict
from typing import Optional, List, Dict, Any
from enum import Enum
import httpx
```

### 服务器初始化
```python
mcp = FastMCP("service_mcp")
```

### 工具注册模式
```python
@mcp.tool(name="tool_name", annotations={...})
async def tool_function(params: InputModel) -> str:
    # 实现
    pass
```

---

## 服务器命名约定

- **格式**：`{service}_mcp`（小写带下划线）
- **示例**：`github_mcp`、`jira_mcp`、`stripe_mcp`

## 工具命名

使用 snake_case，包含服务前缀以避免冲突：
- 使用 "slack_send_message" 而不是 "send_message"
- 使用 "github_create_issue" 而不是 "create_issue"

## Pydantic v2 关键功能

```python
from pydantic import BaseModel, Field, field_validator, ConfigDict

class CreateUserInput(BaseModel):
    model_config = ConfigDict(
        str_strip_whitespace=True,
        validate_assignment=True,
        extra='forbid'
    )

    name: str = Field(..., description="用户全名", min_length=1, max_length=100)
    email: str = Field(..., description="用户电子邮件", pattern=r'^[\w\.-]+@[\w\.-]+\.\w+$')

    @field_validator('email')
    @classmethod
    def validate_email(cls, v: str) -> str:
        return v.lower()
```

## 响应格式

```python
class ResponseFormat(str, Enum):
    MARKDOWN = "markdown"
    JSON = "json"
```

## 错误处理

```python
def _handle_api_error(e: Exception) -> str:
    if isinstance(e, httpx.HTTPStatusError):
        if e.response.status_code == 404:
            return "错误：未找到资源。"
        elif e.response.status_code == 429:
            return "错误：超出速率限制。"
    return f"错误：{type(e).__name__}"
```

## 完整示例

```python
#!/usr/bin/env python3
from typing import Optional
from enum import Enum
import httpx
from pydantic import BaseModel, Field, ConfigDict
from mcp.server.fastmcp import FastMCP

mcp = FastMCP("example_mcp")
API_BASE_URL = "https://api.example.com/v1"

class ResponseFormat(str, Enum):
    MARKDOWN = "markdown"
    JSON = "json"

class UserSearchInput(BaseModel):
    model_config = ConfigDict(str_strip_whitespace=True)
    query: str = Field(..., min_length=2, max_length=200)
    limit: Optional[int] = Field(default=20, ge=1, le=100)
    response_format: ResponseFormat = Field(default=ResponseFormat.MARKDOWN)

@mcp.tool(
    name="example_search_users",
    annotations={"readOnlyHint": True, "destructiveHint": False}
)
async def example_search_users(params: UserSearchInput) -> str:
    '''搜索用户。'''
    async with httpx.AsyncClient() as client:
        response = await client.get(
            f"{API_BASE_URL}/users/search",
            params={"q": params.query, "limit": params.limit}
        )
        response.raise_for_status()
        return response.text

if __name__ == "__main__":
    mcp.run()
```

## 质量检查清单

- [ ] 服务器名称遵循 `{service}_mcp` 格式
- [ ] 所有工具使用 Pydantic 模型验证输入
- [ ] 所有网络操作使用 async/await
- [ ] 错误处理清晰可操作
- [ ] 工具有全面的文档字符串
