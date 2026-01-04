# 网络搜索指南 - Unreal 源码学习助手

## 概述

本指南说明如何利用网络搜索工具来增强 Unreal 源码学习，快速获取：
- 源码实现原理的解释
- 最佳实践和设计模式
- 常见问题和解决方案
- 官方文档和教程

## ⚠️ 网络搜索工具优先级

**重要：优先使用原生 `web_search` 工具，MCP `ddg-search` 作为备选/补充**

| 优先级 | 工具 | 说明 |
|--------|------|------|
| ⭐ **首选** | `web_search` | 原生网络搜索，更稳定、响应更快 |
| 备选 | MCP `ddg-search` | 当原生搜索结果不足时使用 |

### 原生 web_search 使用方式
```python
web_search(
    explanation="搜索 Unreal Engine 相关教程和最佳实践",
    searchTerm="Unreal Engine [功能名称] tutorial best practice"
)
```

### MCP ddg-search 使用方式（备选）
```python
mcp_call_tool(
    serverName="ddg-search",
    toolName="search",
    arguments=json.dumps({
        "query": "Unreal Engine [功能名称] tutorial",
        "max_results": 10
    })
)
```

## 搜索策略

### 1. 官方文档搜索
快速找到官方的解释和示例

**搜索模式：**
```
Unreal Engine 5 [功能名称] documentation
Unreal Engine [类名] official guide
UE5 [系统名称] architecture guide
```

**示例：**
```
Unreal Engine 5 reflection system documentation
Unreal Engine Actor lifecycle official guide
UE5 component system architecture guide
```

**用途：**
- 了解官方设计理念
- 获取快速概述
- 找到官方示例代码

---

### 2. 源码实现原理搜索
理解源码中的关键设计决策

**搜索模式：**
```
how does Unreal Engine implement [功能]
Unreal Engine [系统名称] implementation details
[类名] source code explanation
```

**示例：**
```
how does Unreal Engine implement garbage collection
Unreal Engine reflection system implementation details
UObject serialization source code explanation
```

**用途：**
- 理解设计思路
- 了解性能考虑
- 学习关键算法

---

### 3. 设计模式和最佳实践搜索
学习 Unreal 风格的代码组织

**搜索模式：**
```
Unreal Engine [功能] best practices
Unreal Engine coding patterns for [任务]
[系统名称] design pattern in Unreal
```

**示例：**
```
Unreal Engine component design best practices
Unreal Engine coding patterns for event handling
Actor lifecycle design pattern in Unreal
```

**用途：**
- 学习 Unreal 风格
- 避免常见陷阱
- 优化代码结构

---

### 4. 问题解决搜索
快速解决开发中的具体问题

**搜索模式：**
```
how to [操作] in Unreal Engine
Unreal Engine [问题描述] solution
[错误信息] Unreal Engine fix
```

**示例：**
```
how to implement custom property in Unreal Engine
Unreal Engine property reflection solution
reflection property serialization issue fix
```

**用途：**
- 快速找到解决方案
- 了解常见陷阱
- 获取实战经验

---

### 5. 性能优化搜索
学习优化相关代码的方式

**搜索模式：**
```
Unreal Engine [系统] performance optimization
optimize [功能] in Unreal Engine
Unreal Engine memory management best practices
```

**示例：**
```
Unreal Engine reflection system performance optimization
optimize garbage collection in Unreal Engine
Unreal Engine memory management best practices
```

**用途：**
- 了解性能瓶颈
- 学习优化技巧
- 避免常见性能问题

---

## 常见学习场景的搜索方案

### 场景 1: 学习反射系统

**第一步：获取概览**
```
search: "Unreal Engine 5 reflection system tutorial"
```
→ 找到官方文档和视频教程

**第二步：理解原理**
```
search: "how does Unreal Engine implement reflection"
```
→ 了解设计思路和实现细节

**第三步：查找源码位置**
参考 `UnrealSourceStructure.md` 中的反射系统部分：
```
CoreUObject/Public/UObject/Class.h
CoreUObject/Public/UObject/Property.h
```

**第四步：学习最佳实践**
```
search: "Unreal Engine reflection custom property best practices"
```
→ 获取实战代码示例

**第五步：实现自定义功能**
结合源码和搜索结果，在你的项目中实现

---

### 场景 2: 实现事件系统

**第一步：了解委托**
```
search: "Unreal Engine delegates tutorial"
```

**第二步：理解多播委托**
```
search: "Unreal Engine multicast delegate explanation"
```

**第三步：查找源码**
```
Core/Public/Delegates/Delegate.h
Core/Public/Delegates/MulticastDelegate.h
```

**第四步：学习实战应用**
```
search: "how to use Unreal Engine delegates events"
```

**第五步：实现自定义事件系统**
基于学到的知识在你的项目中实现

---

### 场景 3: 开发自定义插件

**第一步：插件基础**
```
search: "Unreal Engine 5 plugin development tutorial"
```

**第二步：插件架构**
```
search: "Unreal Engine plugin architecture guide"
```

**第三步：查找源码**
```
Engine/Plugins/
Engine/Source/Runtime/Plugins/
```

**第四步：参考现有插件**
```
search: "Unreal Engine plugin examples"
```

**第五步：开发自定义插件**
使用 config.json 中的模板框架

---

## 具体搜索实例库

### 反射系统相关
```
"Unreal Engine UPROPERTY macro reference"
"Unreal Engine UFUNCTION macro guide"
"how to iterate all properties Unreal Engine"
"Unreal Engine custom property editor"
"reflection change notification Unreal Engine"
```

### Event/Delegate 相关
```
"Unreal Engine delegate binding tutorial"
"Unreal Engine multicast delegate example"
"Unreal Engine event dispatching mechanism"
"bind function to delegate Unreal Engine"
```

### Actor 相关
```
"Unreal Engine Actor lifecycle explained"
"Unreal Engine Actor replication system"
"Actor spawn and destroy process Unreal Engine"
"Component attachment in Unreal Engine"
```

### 组件系统相关
```
"Unreal Engine component inheritance hierarchy"
"SceneComponent vs ActorComponent Unreal Engine"
"custom component best practices Unreal Engine"
"component tick order Unreal Engine"
```

### 物理系统相关
```
"Unreal Engine physics simulation guide"
"collision detection Unreal Engine tutorial"
"rigid body dynamics Unreal Engine"
```

### UI 相关
```
"Unreal Engine UMG tutorial"
"Slate widget creation Unreal Engine"
"custom widget in Unreal Engine"
"UMG binding data in Unreal Engine"
```

### 性能优化相关
```
"Unreal Engine garbage collection optimization"
"memory pooling Unreal Engine"
"profiling performance Unreal Engine"
"texture streaming Unreal Engine"
```

### 插件开发相关
```
"Unreal Engine plugin module dependencies"
"plugin initialization Unreal Engine"
"plugin command-line tools Unreal Engine"
"marketplace plugin requirements Unreal Engine"
```

---

## 搜索工作流程

### 标准工作流（推荐）

```
1. 定义学习目标
   ↓
2. 搜索官方文档和概述
   ↓
3. 理解核心概念
   ↓
4. 在源码中定位相关代码
   ↓
5. 搜索实现原理和最佳实践
   ↓
6. 阅读源码实现细节
   ↓
7. 搜索问题解决方案
   ↓
8. 开始你的实现
```

### 搜索优化技巧

1. **关键词组合**
   - 使用 + 号强调重要词：`Unreal Engine +reflection system`
   - 使用引号精确搜索：`"property editor" Unreal Engine`

2. **搜索限定**
   - 限定官网：`site:unrealengine.com reflection system`
   - 限定论坛：`site:forums.unrealengine.com plugin development`

3. **时效性考虑**
   - 搜索最新版本：`Unreal Engine 5.4 reflection system`
   - 搜索历史版本时标明版本号

4. **多语言搜索**
   - 除英文外，可搜索中文资源
   - 搜索：`虚幻引擎 反射系统`

---

## 搜索结果评估

### 优先级顺序

| 优先级 | 来源 | 特征 |
|--------|------|------|
| ⭐⭐⭐⭐⭐ | 官方文档 | docs.unrealengine.com |
| ⭐⭐⭐⭐ | 官方论坛 | forums.unrealengine.com |
| ⭐⭐⭐⭐ | YouTube 官方 | Epic Games 频道 |
| ⭐⭐⭐ | 知名社区 | GameDev 社区 |
| ⭐⭐⭐ | 技术博客 | 知名开发者博客 |
| ⭐⭐ | 通用搜索结果 | 普通网页 |

### 评估标准

✅ **可信的结果：**
- 包含代码示例
- 引用官方文档
- 有明确的日期（不过时）
- 多个来源一致

❌ **需要谨慎的结果：**
- 仅有理论，无代码
- 涉及过时版本
- 单一来源，缺乏验证
- 与官方文档不一致

---

## 与 LLM 协作的最佳实践

### 1. 搜索 → 分析 → 实现

```
用户：我想实现自定义属性编辑器
  ↓
LLM 搜索：
  - "Unreal Engine custom property editor tutorial"
  - "FProperty editor implementation"
  ↓
LLM 分析搜索结果和源码
  ↓
LLM 生成实现代码
  ↓
用户测试和调整
```

### 2. 追踪搜索来源

告诉 LLM 搜索关键词，让它：
1. 在网络中搜索相关信息
2. 分析搜索结果
3. 结合源码生成代码
4. 注明代码出处

```
用户：帮我查找如何在 Unreal 中实现自定义的 Actor 复制逻辑
  ↓
LLM 搜索相关资料
  ↓
LLM 给出：
  - 搜索来源链接
  - 源码位置
  - 实现代码
  - 最佳实践注意事项
```

### 3. 问题驱动的搜索

当遇到具体问题时：

```
用户：我的自定义属性不能正确序列化
  ↓
LLM 搜索：
  - "[问题描述] Unreal Engine solution"
  - "property serialization issue Unreal Engine"
  ↓
LLM 分析可能原因
  ↓
LLM 提出解决方案
```

---

## 搜索查询模板

### 模板 1: 学习新功能
```
Unreal Engine [版本] [功能名称] tutorial
how does Unreal Engine implement [功能]
[功能] best practices Unreal Engine
```

### 模板 2: 查找具体实现
```
[类名] source code Unreal Engine
[函数名] implementation Unreal Engine
where is [功能] implemented Unreal Engine
```

### 模板 3: 问题排查
```
how to fix [问题] Unreal Engine
[错误信息] Unreal Engine solution
[功能] not working Unreal Engine
```

### 模板 4: 性能相关
```
optimize [功能] Unreal Engine
[系统] performance bottleneck Unreal Engine
reduce memory usage [功能] Unreal Engine
```

### 模板 5: 设计和架构
```
[系统] architecture Unreal Engine
design pattern for [功能] Unreal Engine
Unreal Engine [系统] design decisions
```

---

## 常见搜索陷阱

❌ **避免的搜索方式：**
1. 过于宽泛：`Unreal Engine 编程` → 结果太多
2. 过时版本：搜索 UE4 的内容时没标明版本
3. 只搜中文或只搜英文：失去一半资源
4. 搜索错误信息的全文：应该只搜关键部分
5. 不验证来源：盲目相信第一个结果

✅ **推荐的搜索方式：**
1. 使用具体的类名或函数名
2. 标明 Unreal Engine 版本
3. 使用英文+中文双语搜索
4. 只搜关键错误代码
5. 检查多个来源的一致性

---

## 集成建议

### 在 Skill 使用中

**告诉 LLM：**
```
请帮我学习 [功能]：
1. 先在网络搜索相关教程和最佳实践
2. 在源码中定位实现位置
3. 分析源码逻辑
4. 生成我可以直接使用的代码
5. 给出参考链接和源码位置
```

### 搜索请求示例

```
我想创建一个自定义的 Actor 组件，能够自动与客户端同步数据。

请：
1. 搜索相关教程（"Unreal Engine Actor replication tutorial"）
2. 找到源码位置（UnrealSourceStructure.md）
3. 分析实现方式
4. 生成框架代码
5. 给出参考链接
```

---

## 更新记录

- **2025-12-10**: 更新网络搜索优先级，原生 `web_search` 优先，MCP `ddg-search` 作为备选
- **2025-11-11**: 初始版本
- 支持 UE 5.0+
- 集成 MCP ddg-search 工具
