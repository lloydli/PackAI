# UnrealCodeImitator Skill 更新日志

## 最新更新：网络搜索工具优先级调整 (2025-12-10)

### ✅ 更新内容

**重要更新：原生 `web_search` 优先，MCP `ddg-search` 作为备选**

由于系统现在原生支持网络搜索功能，网络搜索的工具优先级调整如下：

| 优先级 | 工具 | 说明 |
|--------|------|------|
| ⭐ **首选** | `web_search` | 原生网络搜索，更稳定、响应更快 |
| 备选 | MCP `ddg-search` | 当原生搜索结果不足时使用 |

### 📝 使用方式

**首选：原生 web_search**
```python
web_search(
    explanation="搜索 Unreal Engine 相关教程和最佳实践",
    searchTerm="Unreal Engine [功能名称] tutorial best practice"
)
```

**备选/补充：MCP ddg-search**
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

### 📚 文档更新

1. **SKILL.md** - 更新
   - 更新"第二步：并行调用网络搜索"部分
   - 更新"第二轮：网络搜索与教程"部分
   - 更新"步骤 2：网络搜索获取社区方案"部分
   - 更新"自动执行的工具调用"中的网络搜索部分
   - 更新"搜索优先级说明"部分

2. **MCP_SearchGuide.md** - 更新
   - 添加网络搜索工具优先级说明
   - 添加原生 web_search 使用示例

### 🎯 优势

1. **更稳定** - 原生 web_search 集成更紧密，稳定性更好
2. **更快速** - 原生工具响应速度更快
3. **兼容性** - 保留 MCP ddg-search 作为备选，确保搜索能力不降低

---

## 历史更新：编译模式支持修正 (2025-11-28)

### ✅ 修正内容

**重要修正：明确 Unreal Engine 编译配置体系**

1. **编译配置命名规则**
   - Unreal 编译配置 = Configuration（配置状态）+ Target Type（目标类型）
   - 例如：`DebugGame Editor`、`Development Editor`

2. **本 Skill 支持的配置**
   - 目标类型固定为 `Editor`（编辑器插件开发）
   - 支持两种 Configuration：
     - `DebugGame` → 完整编译配置为 `DebugGame Editor`
     - `Development` → 完整编译配置为 `Development Editor`

3. **移除不常用配置**
   - 移除 `Shipping Editor` 配置（插件开发很少使用）
   - 专注于最常用的两种编译模式

4. **更新说明文档**
   - 明确 Configuration 和 Target Type 的区别
   - 说明引擎优化 vs 插件代码优化的差异
   - 更新所有示例和使用场景

### 📝 编译模式对比

| 用户关键词 | 完整编译配置 | Configuration | 引擎代码 | 插件代码 | 适用场景 |
|----------|------------|--------------|---------|---------|---------|
| **编译G** | **DebugGame Editor** | DebugGame | ✅ 优化 | ❌ 未优化（可调试） | 调试插件代码 |
| **编译V** 或 **编译** | **Development Editor** | Development | ✅ 优化 | ✅ 优化 | 日常开发（推荐） |

### 🎯 实际编译命令

**DebugGame Editor：**
```batch
dotnet "UnrealBuildTool.dll" ^
    ProjectNameEditor ^
    Win64 ^
    DebugGame ^
    -Project="ProjectPath.uproject" ^
    ...
```

**Development Editor：**
```batch
dotnet "UnrealBuildTool.dll" ^
    ProjectNameEditor ^
    Win64 ^
    Development ^
    -Project="ProjectPath.uproject" ^
    ...
```

### 📦 配置更新

**config.json：**
```json
{
  "compilation": {
    "defaultMode": "Development",
    "availableModes": ["DebugGame", "Development"],
    "modeAliases": {
      "编译G": "DebugGame",
      "编译V": "Development"
    },
    "description": {
      "DebugGame": "DebugGame Editor - 调试游戏代码模式，引擎优化但游戏代码可调试",
      "Development": "Development Editor - 开发模式，引擎和游戏代码都优化，默认编译模式"
    },
    "notes": "当前编译的是Editor目标，配置参数(DebugGame/Development)会自动组合成完整的编译配置"
  }
}
```

### 📚 文档更新

1. **COMPILE_MODES.md** - 重写
   - 明确 Configuration + Target Type 体系
   - 说明 DebugGame Editor 和 Development Editor 的区别
   - 移除 Shipping Editor 相关内容

2. **COMPILE_QUICK_REFERENCE.md** - 重写
   - 更新编译模式对比表
   - 明确引擎和插件代码优化差异

3. **SKILL.md** - 更新
   - 更新编译模式说明表
   - 明确 Editor 目标类型

4. **PROMPT_INSTRUCTION.md** - 更新
   - 更新编译模式关键词说明
   - 移除 Shipping 相关内容

### 🚀 使用指南

**日常开发（推荐）：**
```
请生成一个建筑编辑器插件，然后编译。
或
请生成一个建筑编辑器插件，然后编译V。
```

**调试问题：**
```
插件崩溃了，请修复代码，然后编译G进行调试。
```

---

## 历史更新：编译模式支持初版 (2025-11-28)

### ✅ 新增功能

1. **多编译模式支持**
   - 新增 DebugGame Editor 模式 - 完整调试符号
   - 保留 Development Editor 模式 - 默认开发模式
   - 新增 Shipping Editor 模式 - 发布优化模式

2. **关键词别名**
   - `编译G` → DebugGame Editor 模式
   - `编译V` 或 `编译` → Development Editor 模式
   - `编译S` → Shipping Editor 模式

3. **脚本增强**
   - `compile.bat` 现在支持命令行参数：`compile.bat [BuildConfiguration]`
   - 自动识别用户意图并传递正确的编译配置
   - 在日志中显示使用的编译模式

4. **配置文件扩展**
   - 在 `config.json` 中添加 `compilation` 配置节
   - 定义可用编译模式和别名映射
   - 包含每种模式的详细说明

5. **文档更新**
   - 更新 `SKILL.md` - 添加编译模式说明和示例
   - 更新 `PROMPT_INSTRUCTION.md` - 添加编译模式关键词和使用方法
   - 新增 `COMPILE_MODES.md` - 编译模式的完整使用指南

### 📝 使用示例

**DebugGame 模式（深度调试）：**
```
请生成一个自定义组件，然后编译G。
```

**Development 模式（日常开发）：**
```
请生成一个自定义组件，然后编译V。
或
请生成一个自定义组件，然后编译。
```

**Shipping 模式（性能测试）：**
```
请优化性能，然后编译S验证。
```

### 🎯 优势

1. **灵活性** - 可以根据开发阶段选择合适的编译模式
2. **效率** - 调试时用 DebugGame，日常开发用 Development，性能测试用 Shipping
3. **直观** - 简短的关键词 G/V/S 便于记忆和使用
4. **兼容** - 保持向后兼容，"编译"默认使用 Development 模式

### 📦 技术细节

**命令行格式：**
```batch
dotnet "UnrealBuildTool.dll" ^
    ProjectNameEditor ^
    Win64 ^
    [DebugGame|Development|Shipping] ^
    -Project="ProjectPath.uproject" ^
    ...
```

**配置示例（config.json）：**
```json
{
  "compilation": {
    "defaultMode": "Development",
    "availableModes": ["DebugGame", "Development", "Shipping"],
    "modeAliases": {
      "编译G": "DebugGame",
      "编译V": "Development",
      "编译S": "Shipping"
    }
  }
}
```

---

## 历史更新：UE5 知识库集成优化 (2025-11-13)

### ✅ 完成内容

1. **统一 UE5 知识库搜索前缀**
   - 统一使用 `@UE5` 标准前缀（而非之前的多种关键词）
   - 格式清晰、易记：`@UE5 [查询内容]`

2. **更新文档**
   - 更新 SKILL.md 第一部分的自动触发条件
   - 添加 `📖 **UE5 知识库查询：** @UE5 [查询内容]`
   - 更新所有示例代码为 `@UE5` 前缀格式
   - 更新常见使用场景中的 API 查询示例

3. **三层搜索策略明确化**
   ```
   第一层：@UE5 官方知识库 ⭐ 最权威、最快
   第二层：网络搜索与教程 ⭐⭐ 范围广、包含技巧
   第三层：Unreal 源码分析 ⭐⭐⭐ 最详细、最深入
   ```

### 📝 使用示例

**原来的方式（已废弃）：**
```
查询 UE5 知识库，Lumen 全局光照如何实现
官方文档中关于 Enhanced Input System 的说明
```

**新的标准方式：**
```
@UE5 Lumen 全局光照如何实现
@UE5 Enhanced Input System 的使用方法
@UE5 Nanite 虚拟化几何体 API 说明
```

### 🎯 优势

1. **前缀统一** - 所有 UE5 知识库查询都用 `@UE5` 前缀，与其他知识库（`@Hippy`、`@TencentOS` 等）保持一致
2. **易记易用** - 短小精悍的前缀，用户体验更好
3. **符合规范** - 遵循系统中其他知识库的命名习惯
4. **自动激活** - 无需手动调用 Skill，在提示词中出现 `@UE5` 即可自动识别并触发

---

**维护者**: UnrealCodeImitator Skill
