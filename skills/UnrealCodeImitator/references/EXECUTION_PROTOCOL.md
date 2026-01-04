# UnrealCodeImitator Skill 执行协议

> **版本：** 1.0  
> **用途：** 定义 Skill 被触发时的自动执行流程和工具调用规范

---

## 目录

1. [触发机制](#触发机制)
2. [自动执行流程](#自动执行流程)
3. [三层搜索流程](#三层搜索流程)
4. [工具调用规范](#工具调用规范)
5. [结果综合与代码生成](#结果综合与代码生成)
6. [常见场景的执行路径](#常见场景的执行路径)

---

## 触发机制

### Skill 自动触发的关键词

当用户消息中包含以下任何关键词时，Skill 应自动激活：

**参考源码类：**
- 参考 Unreal 源码
- 参考 UE 源码
- 学习 Unreal 源码
- 看 Unreal 源码

**学习实现类：**
- 学习 Unreal 中的
- 了解 Unreal 如何实现
- Unreal 是怎么实现的
- 参考官方实现

**基于源码开发类：**
- 基于 Unreal 源码
- 参考 Unreal 模式
- 按 Unreal 风格
- 遵循 Unreal 最佳实践

**实现功能类：**
- 实现一个 [功能]，参考 Unreal 的
- 创建一个 [功能]，像 Unreal 的
- 参考 Unreal [系统名称]

**快速查询类（特殊处理）：**
- `@UE5 [查询内容]` - 直接触发 UE5 官方知识库查询

---

## 自动执行流程

### 总体流程图

```
用户消息
  ↓
Skill 触发检查
  ├─ YES → 继续
  └─ NO  → 不执行此 Skill
  ↓
解析用户需求类型
  ├─ API 快速查询      → 路径 A (快速)
  ├─ 实现需求          → 路径 B (标准)
  ├─ 性能优化          → 路径 C (优化重点)
  └─ 深度学习          → 路径 D (源码重点)
  ↓
自动执行相应搜索流程
  ↓
综合搜索结果
  ↓
生成代码实现
  ↓
输出给用户
```

### 执行路径详解

#### 路径 A：API 快速查询（特殊）

**触发条件：** 用户问题是关于 API 使用、函数说明等

**自动执行：**
1. 检查是否有 `@UE5` 前缀，有则直接查询
2. 否则自动构造 UE5 查询

**工具调用：**
```python
RAG_search(
    queryString=user_question,  # 或转化后的查询词
    knowledgeBaseNames="UE5"
)
```

**预期结果时间：** 1-3 分钟  
**优先级：** ① UE5 (完全满足则不需要后续)

---

#### 路径 B：标准实现需求

**触发条件：** 用户想要创建/实现某个功能，参考 Unreal

**自动执行顺序：**

1. **第一轮：UE5 官方知识库**
   ```python
   RAG_search(
       queryString=construct_ue5_query(user_requirement),
       knowledgeBaseNames="UE5"
   )
   ```
   - 时间：1-2 分钟
   - 目标：获取官方框架和推荐方式

2. **第二轮：网络搜索（并行）**
   ```python
   mcp_call_tool(
       serverName="ddg-search",
       toolName="search",
       arguments=json.dumps({
           "query": f"Unreal Engine {feature_name} tutorial best practice",
           "max_results": 10
       })
   )
   ```
   - 时间：1-2 分钟
   - 目标：获取社区方案和实现技巧

3. **第三轮：源码分析**
   - 定位源码关键文件
   - 分析实现代码
   - 提取设计模式
   - 时间：2-5 分钟
   - 目标：获取完整实现细节

**总耗时：** 4-9 分钟  
**优先级：** ① UE5 基础 → ② 网络补充 → ③ 源码深化

---

#### 路径 C：性能优化（特殊优先级）

**触发条件：** 用户问题涉及性能优化、加载速度等

**自动执行顺序：** (与标准路径不同)

1. **第二轮优先：网络搜索** (获取最新社区方案)
2. **第三轮补充：源码分析** (验证和深化)
3. **第一轮参考：UE5 官方** (作为背景)

**原因：** 性能优化的最新技巧通常在网络社区更新更快

**总耗时：** 4-9 分钟  
**优先级：** ② 网络优先 → ③ 源码验证 → ① UE5 背景

---

#### 路径 D：深度源码学习

**触发条件：** 用户想要深入学习 Unreal 的内部实现机制

**自动执行顺序：**

1. **第三轮重点：源码分析** (获取完整细节)
2. **第二轮补充：网络搜索** (获取高层总结)
3. **第一轮背景：UE5 官方** (获取文档链接)

**优先级：** ③ 源码为主 → ② 网络总结 → ① 官方背景

**总耗时：** 5-15 分钟 (取决于源码复杂度)

---

## 三层搜索流程

### 第一层：UE5 官方知识库 (@UE5)

**工具：** `RAG_search` with `knowledgeBaseNames="UE5"`

**搜索策略：**
```python
def search_ue5_knowledge_base(user_query: str):
    # 将用户自然语言查询转化为关键词
    keywords = [
        "UE5",
        feature_name,
        "API",
        "实现",
        "使用方法"
    ]
    
    query = " ".join(keywords)
    
    RAG_search(
        queryString=query,
        knowledgeBaseNames="UE5"
    )
```

**预期返回内容：**
- 官方 API 文档
- 推荐使用方法
- 代码示例
- 最新 UE5.x 特性说明
- 官方最佳实践

**评估标准：**
- ✅ 充分：内容清晰、包含示例、说明完整
- ⚠️ 部分：只有简要说明，需要补充
- ❌ 不足：缺少具体实现或示例

---

### 第二层：网络搜索 (MCP ddg-search)

**工具：** `mcp_call_tool` with `serverName="ddg-search"`, `toolName="search"`

**搜索策略：**
```python
def network_search(feature_name: str, context: str):
    # 构造多维度搜索查询
    queries = [
        f"Unreal Engine {feature_name} tutorial",
        f"Unreal {feature_name} best practices {context}",
        f"Unreal Engine {feature_name} implementation guide",
        f"UE5 {feature_name} 最佳实践",
    ]
    
    for query in queries:
        mcp_call_tool(
            serverName="ddg-search",
            toolName="search",
            arguments=json.dumps({
                "query": query,
                "max_results": 10
            })
        )
```

**预期返回内容：**
- 官方文档链接
- 社区教程和指南
- 博客文章和讨论
- 开源项目参考
- 性能优化建议
- 常见问题和解决方案

**评估标准：**
- ✅ 充分：多个视角、包含示例、有最新信息
- ⚠️ 部分：1-2 个可用资源，信息有限
- ❌ 不足：没有相关结果或都是过时信息

---

### 第三层：Unreal 源码分析

**数据来源：** 本地 Unreal 引擎源码 (`config.json` 的 `unrealEnginePath`)

**搜索策略：**
```python
def analyze_unreal_source(
    feature_name: str,
    focus_modules: List[str],  # 来自 config.json
    search_depth: int,         # 来自 config.json
    include_private: bool      # 来自 config.json
):
    # 定位关键文件
    search_locations = [
        f"{engine_path}/Source/Runtime/{module}",
        f"{engine_path}/Source/Editor",
        f"{engine_path}/Source/Developer"
    ]
    
    # 搜索关键类和函数
    key_patterns = [
        f"class.*{feature_name}",
        f"struct.*{feature_name}",
        f"void.*{feature_name}.*(",
        f"FProperty.*{feature_name}"
    ]
    
    # 分析代码
    # 1. 定位类和函数定义
    # 2. 追踪函数调用关系
    # 3. 提取设计模式
    # 4. 收集优化要点
```

**预期返回内容：**
- 关键类的完整源码
- 函数实现逻辑
- 设计模式分析
- 代码注释和文档
- 性能优化的具体实现
- 版本兼容性信息

**关键文件位置参考：**
```
Slate UI 框架
  → Source/Runtime/Slate/Public
  → Source/Runtime/Slate/Private
  → Source/Editor/UnrealEd/Private/Kismet2/

反射系统 (Reflection)
  → Source/Runtime/CoreUObject/Public
  → Source/Runtime/CoreUObject/Private

属性系统 (Property System)
  → Source/Runtime/CoreUObject/Public/Containers
  → Source/Runtime/CoreUObject/Public/Misc

Actor 系统
  → Source/Runtime/Engine/Public/GameFramework
  → Source/Runtime/Engine/Private/GameFramework

资源系统 (Asset System)
  → Source/Runtime/AssetRegistry/Public
  → Source/Runtime/AssetRegistry/Private
```

**评估标准：**
- ✅ 充分：找到关键实现、能提取设计模式
- ⚠️ 部分：找到相关代码但不完整
- ❌ 不足：找不到或代码路径不存在

---

## 工具调用规范

### RAG_search 调用规范

```python
RAG_search(
    queryString: str,              # 必需：查询关键词
    knowledgeBaseNames: str        # 必需："UE5" (当前唯一支持)
)
```

**示例：**
```python
# 查询 Enhanced Input System
RAG_search(
    queryString="UE5 Enhanced Input System 如何使用",
    knowledgeBaseNames="UE5"
)

# 查询自定义属性编辑器
RAG_search(
    queryString="Unreal FProperty 自定义编辑器实现",
    knowledgeBaseNames="UE5"
)
```

---

### MCP ddg-search 调用规范

```python
mcp_call_tool(
    serverName: str,               # 必需："ddg-search"
    toolName: str,                 # 必需："search"
    arguments: str                 # 必需：JSON 格式
)

# arguments 格式
{
    "query": str,                  # 搜索查询词
    "max_results": int = 10        # 返回结果数，默认 10
}
```

**示例：**
```python
mcp_call_tool(
    serverName="ddg-search",
    toolName="search",
    arguments=json.dumps({
        "query": "Unreal Engine Slate 自定义编辑器面板教程",
        "max_results": 10
    })
)
```

---

## 结果综合与代码生成

### 综合策略

```
收集三层搜索结果
    ↓
按优先级排序
    ├─ 官方推荐方案 (UE5)
    ├─ 社区验证方案 (网络)
    └─ 源码实现模式 (源码)
    ↓
识别共同点和最佳实践
    ↓
整合成最优方案
    ↓
生成代码
```

### 代码生成原则

1. **优先官方方案** - 如果 UE5 官方有推荐，优先使用
2. **社区验证** - 检查网络上是否有多个项目采用了这个方案
3. **源码参考** - 如果与源码实现一致，增加可信度
4. **性能优化** - 从网络和源码中提取的优化要点必须包含
5. **兼容性** - 检查是否适用于目标 UE 版本
6. **注释完整** - 标注参考来源和关键决策原因

### 代码注释格式

```cpp
// [参考来源]
// UE5 官方 API 文档 / 社区最佳实践 / Unreal 源码
// 
// [关键设计说明]
// 为什么选择这个实现方式
//
// [参考位置]
// 路径: Source/...
// 类/函数: FClassName::FunctionName
//
// [性能说明]
// 如果有特殊性能考虑

class MyCustomPanel : public SCompoundWidget
{
    // [参考: Unreal Engine SDetailView 实现]
    // 源码位置: Engine/Source/Editor/UnrealEd/Private/SDetailView.cpp
    
public:
    // 实现细节...
};
```

---

## 常见场景的执行路径

### 场景 1：快速 API 查询

**用户问题：**
```
@UE5 Enhanced Input System 的 InputMappingContext 如何使用？
```

**执行路径：** A (快速查询)

**步骤：**
1. 识别 `@UE5` 前缀
2. 直接调用 RAG_search
3. 返回官方文档和示例
4. 完成

**耗时：** 1-2 分钟

---

### 场景 2：创建自定义编辑器面板

**用户问题：**
```
我想创建一个自定义编辑器面板，类似 Details Panel，参考 Unreal 源码。
```

**执行路径：** B (标准实现)

**步骤：**
1. 第一轮：查 UE5 知识库获取 Slate/Details Panel API
2. 第二轮：网络搜索 "Unreal Custom Editor Panel tutorial"
3. 第三轮：分析源码 SDetailView 等实现
4. 综合结果生成代码
5. 输出完整的面板实现

**耗时：** 5-8 分钟

---

### 场景 3：性能优化

**用户问题：**
```
我的游戏加载太慢，参考 Unreal 源码，如何优化资源加载？
```

**执行路径：** C (性能优化)

**步骤：**
1. 第二轮优先：网络搜索最新优化方案
2. 第三轮：分析源码了解底层机制
3. 第一轮：查官方文档获取背景信息
4. 综合生成优化建议
5. 输出优化方案和代码示例

**耗时：** 5-10 分钟

---

### 场景 4：深入学习反射系统

**用户问题：**
```
我想深入学习 Unreal 的反射系统，了解 FProperty 等类的实现原理。
```

**执行路径：** D (深度学习)

**步骤：**
1. 第三轮重点：深入分析源码
   - Property.h / Property.cpp
   - Class.h / Class.cpp
   - 反射宏系统
2. 第二轮：网络搜索总结和教程
3. 第一轮：官方文档作为背景
4. 生成详细的学习文档和代码示例
5. 输出完整的学习路径

**耗时：** 10-20 分钟

---

## 实现检查清单

当改进或维护此 Skill 时，确保以下所有项目都已完成：

- [ ] 所有触发关键词都已列出
- [ ] 四种执行路径都已明确定义
- [ ] 工具调用规范清晰无误
- [ ] 代码生成原则已编写
- [ ] 常见场景的执行路径已列出
- [ ] config.json 的所有参数都已说明
- [ ] 源码关键位置都已记录在 UnrealSourceStructure.md
- [ ] 文档与 SKILL.md 保持一致

---

**最后更新：** 2025-11-14  
**维护者：** UnrealCodeImitator Skill Team
