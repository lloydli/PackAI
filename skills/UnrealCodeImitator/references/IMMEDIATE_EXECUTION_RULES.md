# UnrealCodeImitator Skill 立即执行规则

> **版本：** 1.0  
> **目的：** 明确 Skill 触发时应立即执行的行为  
> **更新日期：** 2025-11-14  
> **优先级：** ⭐⭐⭐ 最高 - Skill 开发者必读

---

## 问题背景

### 发现的问题

虽然 SKILL.md 中描述了"应该执行三层搜索"，但实际上当 Skill 被触发时：

❌ **没有立即调用搜索工具**
- 用户说"用 UnrealCodeImitator..."
- Skill 被触发了 ✓
- 但 @UE5、网络搜索、源码分析工具**没有被调用**

### 根本原因

SKILL.md 是**描述性文档**，说明 Skill 应该做什么，但：

- ❌ 没有用**命令式语言**明确指示"立即执行"
- ❌ 没有明确的"执行时机" 
- ❌ 没有明确的"工具调用代码"
- ❌ 没有告诉 Claude "不要等待，立即行动"

### 解决方案

在 SKILL.md 最前面添加**"【立即执行】"章节**，用**命令式、强制性语言**，明确告诉 Claude：

当 Skill 触发时，**立即调用**三个搜索工具，**不要等待**，**不要询问**。

---

## 立即执行规则（强制）

### Rule 1: 触发即执行

**条件：** Skill 被触发（用户包含任何触发关键词）

**行为：** 立即调用三层搜索工具

**时机：** 不等待用户进一步指示，立即开始

```
用户消息包含触发关键词
        ↓
Skill 被触发
        ↓
【立即】调用 @UE5 搜索
【立即】调用网络搜索
【立即】调用源码分析
        ↓
（并行进行，不等待）
```

### Rule 2: 并行执行，不序列执行

**原则：** 三层搜索**同时进行**，不是一个接一个

**实现：**
```python
# ✅ 正确：并行执行
RAG_search(...)  # 立即开始
mcp_call_tool(...)  # 同时开始
search_source(...)  # 同时开始
# 等待全部完成（可以是 1-2 分钟）

# ❌ 错误：串联执行
RAG_search(...)
wait()  # 等待完成
mcp_call_tool(...)
wait()  # 等待完成
search_source(...)
```

**优势：** 总耗时 2-5 分钟（最长的那个），而不是 5-10 分钟

### Rule 3: 不需要用户同意

**错误做法：**
```
我需要执行三层搜索吗？你同意吗？
```

**正确做法：**
```
正在执行三层搜索...
```

**理由：** 这是 Skill 的**核心职责**，不需要询问

### Rule 4: 充分性是最低要求

**Rule 4a: 除非极简，否则必须三层都执行**

```
问题评估
├─ 极简（查函数名） → @UE5 即可
├─ 极确定（已知唯一解） → @UE5 即可
└─ 其他（99% 情况） → 三层都执行 ⭐
```

**Rule 4b: 必须向用户报告搜索结果**

```
【@UE5 官方知识库】
- 找到：[具体内容]

【网络搜索结果】
- 找到：[具体内容]

【源码分析】
- 找到：[具体内容]

【综合结论】
...
```

---

## 具体执行步骤

### Step 1: 立即调用 @UE5 搜索

**何时：** Skill 被触发的第一时间

**如何调用：**
```python
# 根据用户问题转换搜索关键词
query = convert_user_question_to_ue5_keywords(user_message)

# 立即调用 RAG_search
RAG_search(
    queryString=query,
    knowledgeBaseNames="UE5"
)
```

**转换规则示例：**

| 用户问题 | @UE5 搜索词 |
|---------|-----------|
| 我想实现一个自定义编辑器面板 | "UE5 Slate SCompoundWidget 编辑器面板实现" |
| 怎么优化游戏加载性能 | "UE5 资源加载性能优化 FStreamingManager" |
| 学习反射系统 | "UE5 FProperty UClass 反射系统" |
| 参考 Unreal 的事件系统 | "UE5 事件系统 Delegate Multicast" |

**不要等待。立即执行下一步。**

### Step 2: 并行调用网络搜索

**何时：** 与 Step 1 同时（不等 Step 1 完成）

**如何调用：**
```python
# 构造网络搜索查询词
search_query = construct_network_query(user_problem)

# 调用 MCP 搜索工具
mcp_call_tool(
    serverName="ddg-search",
    toolName="search",
    arguments=json.dumps({
        "query": search_query,
        "max_results": 10
    })
)
```

**网络搜索关键词构造规则：**

```
基础：Unreal Engine + [功能名] + [关键词]

例子：
- "Unreal Engine custom editor panel tutorial"
- "UE5 asset loading performance optimization best practice"
- "Unreal reflection system implementation guide"
- "Unreal event delegate system 2024"
```

**不要等待。继续 Step 3。**

### Step 3: 并行调用源码分析

**何时：** 与 Step 1、2 同时

**如何调用：**
```python
# 从 config.json 读取配置
engine_path = config.unrealEnginePath
search_modules = config.focusModules
search_depth = config.searchDepth

# 从用户问题提取关键词
keywords = extract_keywords(user_problem)

# 在源码中搜索
search_results = search_unreal_source_code(
    engine_path=engine_path,
    keywords=keywords,
    modules=search_modules,
    depth=search_depth
)

# 分析关键类和模式
analyze_source_code(search_results)
```

**源码定位规则：**

| 功能 | 搜索位置 | 关键类 |
|------|--------|-------|
| Slate UI | `Source/Runtime/Slate/Public` | SCompoundWidget, SPanel |
| 属性系统 | `Source/Runtime/CoreUObject/Public` | FProperty, UProperty |
| 反射系统 | `Source/Runtime/CoreUObject/Public` | UClass, UStruct |
| 事件系统 | `Source/Runtime/Core/Public/Delegates` | FDelegate, TMulticastDelegate |
| Actor 系统 | `Source/Runtime/Engine/Public/GameFramework` | AActor, APawn |

### Step 4: 综合结果（三层都完成后）

**何时：** 当三层搜索都返回结果（2-5 分钟后）

**如何综合：**
```python
# 1. 对比三层结果
official_plan = ue5_results  # 官方方案
community_plan = network_results  # 社区方案
source_pattern = source_analysis  # 源码模式

# 2. 找共同点和差异
commonalities = find_common_practices(official_plan, community_plan, source_pattern)
differences = identify_differences(official_plan, community_plan, source_pattern)

# 3. 选择最佳实践
best_practice = select_best_practices(
    official_priority=1,  # 官方优先
    community_priority=2,  # 社区次之
    source_priority=3     # 源码参考
)

# 4. 形成最终方案
final_solution = synthesize_solution(
    base=official_plan,  # 官方框架为基础
    enhancements=community_plan,  # 社区技巧增强
    patterns=source_pattern  # 源码模式应用
)
```

### Step 5: 生成完整回复

**何时：** 综合完成后

**格式：**
```
📊 【三层搜索结果汇总】

✅ @UE5 官方知识库搜索
- [主要发现 1]
- [主要发现 2]
- [官方推荐方案]

✅ 网络搜索
- [主要发现 1]
- [主要发现 2]
- [社区最佳实践]

✅ 源码分析
- [主要发现 1]
- [主要发现 2]
- [设计模式提取]

🎯 【综合分析】
官方推荐：...
社区方案：...
源码模式：...
推荐方案：...

💻 【代码实现】
[基于综合结果的代码]
```

---

## 关键时机和触发点

### 何时立即执行

| 用户消息示例 | Skill 被触发 | 是否立即执行三层搜索 |
|-----------|----------|------------------|
| "参考 Unreal 源码，实现..." | ✅ YES | ✅ YES（立即） |
| "用 UnrealCodeImitator..." | ✅ YES | ✅ YES（立即） |
| "学习 Unreal 中的..." | ✅ YES | ✅ YES（立即） |
| "@UE5 查询 XXX" | ✅ YES | ✅ YES（立即） |
| "我想优化性能，参考..." | ✅ YES | ✅ YES（立即） |

### 不要等待的情况

❌ 不要说："我需要搜索吗？"
❌ 不要说："你同意我执行搜索吗？"
❌ 不要说："让我先查一下..."（然后只查一层）
❌ 不要说："这个问题太简单，不需要搜索"

✅ 要说："正在执行三层搜索..."
✅ 要做：立即启动所有搜索
✅ 要报告：每一层的搜索结果

---

## 为什么这样设计

### 问题 1：用户期望

**用户说："用 UnrealCodeImitator"**

用户的隐含期望：
- ✅ 立即开始工作
- ✅ 充分收集信息
- ✅ 基于完整信息给出方案

**不是：**
- ❌ 问我是否需要搜索
- ❌ 只查一层信息
- ❌ 立即生成代码（没有搜索）

### 问题 2：信息质量

**三层搜索的理由：**

1. **官方文档不全** - API 文档不包含实现细节
2. **社区有独特价值** - 教程、技巧、最佳实践
3. **源码有设计模式** - 文档里找不到的架构细节

缺少任何一层 → 解决方案不够完整

### 问题 3：时间成本

并行执行三层搜索：
- 总耗时：**2-5 分钟**（最长的那个）
- 优于串联：**5-10 分钟**

立即开始搜索而不是询问 → **节省时间**

---

## 检查清单

当改进或维护此 Skill 时，确保：

- [ ] SKILL.md 最前面有"【立即执行】"章节
- [ ] 【立即执行】章节有明确的工具调用代码
- [ ] 说明了"立即"的含义（不等待、不询问）
- [ ] 说明了三层搜索是并行的
- [ ] 有具体的关键词转换规则
- [ ] 有三层搜索都完成后的综合步骤
- [ ] 有完整的回复格式示例
- [ ] 文档中避免使用"如果"、"可能"、"询问"等犹豫词汇
- [ ] Skill 开发者有这份文档的链接

---

## 示例场景

### 场景 1：用户说"用 UnrealCodeImitator..."

```
用户：用 UnrealCodeImitator 帮我实现一个自定义编辑器面板

【立即发生】
✓ @UE5 搜索启动：Slate SCompoundWidget 编辑器实现
✓ 网络搜索启动：Unreal custom editor panel tutorial
✓ 源码分析启动：查询 SDetailView 等源代码
（三个同时进行）

【2-5 分钟后】
✓ 三层搜索都完成
✓ 综合搜索结果
✓ 生成完整方案和代码

【回复格式】
【@UE5 官方知识库】
- 找到：Slate SCompoundWidget 的官方 API...
- 找到：编辑器面板的推荐实现...

【网络搜索】
- 找到：教程 1: xxx
- 找到：教程 2: xxx

【源码分析】
- 找到：SDetailView 的架构...
- 找到：事件处理的设计模式...

【综合结论】
基于三层信息，推荐方案...

【代码实现】
...
```

### 场景 2：用户说"参考源码..."

```
用户：参考 Unreal 源码，教我如何实现一个自定义的属性编辑器

【立即发生】
✓ @UE5 搜索：FProperty 编辑器相关
✓ 网络搜索：Unreal property editor implementation
✓ 源码分析：查询 FProperty、FPropertyHandle 等源码
（三个同时进行）

【结果】
三层充分信息 → 完整方案 → 代码实现
```

---

## 总结

### 核心原则

1. **立即执行** - 触发 Skill = 立即启动三层搜索
2. **并行进行** - 三层同时执行，不是依次等待
3. **充分收集** - 等三层都完成，再综合和生成方案
4. **完整报告** - 告诉用户每层搜索的结果
5. **不要犹豫** - 用命令式语言，避免"如果""可能""需要询问"

### 实现方式

在 SKILL.md 最前面添加：

```markdown
## ⚡ 【立即执行】Skill 被触发时的自动行为

当此 Skill 被触发时，立即执行以下步骤：

### 步骤 1：立即调用三层搜索工具（不等待）
[具体代码...] 

### 步骤 2：综合三层搜索结果

### 步骤 3：生成回复
```

这样，当 Skill 被触发时，我（Claude 实例）会**立即看到这些命令式指令**，而不是被动等待。

---

**版本：** 1.0  
**状态：** ✅ 已实现  
**生效日期：** 2025-11-14  
**优先级：** ⭐⭐⭐ 最高
