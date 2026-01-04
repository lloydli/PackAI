# 编译模式详细说明

## Unreal Engine 编译配置体系

### 完整的编译配置命名规则

Unreal Engine 的编译配置由两部分组成：

```
[Configuration] [Target Type]
```

**Configuration（配置状态）：**
- Debug - 完全调试模式（引擎和游戏代码都包含调试信息）
- DebugGame - 调试游戏模式（引擎优化，游戏代码可调试）
- Development - 开发模式（标准开发配置）
- Shipping - 发布模式（最大优化，移除调试代码）
- Test - 测试模式（类似 Shipping 但保留部分工具）

**Target Type（目标类型）：**
- （空）- 独立游戏可执行文件
- Editor - 编辑器目标
- Client - 客户端
- Server - 服务器

### 本 Skill 支持的编译模式

由于本 Skill 主要用于**插件开发**，我们编译的目标始终是 **Editor**。

因此，我们支持的两种编译模式实际上是：

| 用户关键词 | 实际编译配置 | 说明 |
|-----------|-------------|------|
| **编译G** | **DebugGame Editor** | 引擎优化，游戏/插件代码可调试 |
| **编译V** 或 **编译** | **Development Editor** | 标准开发模式（默认） |

> **注意：** Shipping Editor 和 Debug Editor 配置虽然理论上存在，但在插件开发中很少使用。本 Skill 专注于最常用的两种模式。

---

## 两种模式对比

| 特性 | DebugGame Editor | Development Editor |
|------|-----------------|-------------------|
| **关键词** | 编译G | 编译V 或 编译 |
| **引擎优化** | ✅ 完全优化 | ✅ 完全优化 |
| **插件代码优化** | ❌ 未优化（可调试） | ✅ 部分优化 |
| **调试能力** | ✅ 完整调试符号 | ✅ 部分调试符号 |
| **执行速度** | 中等（插件代码慢） | 快（全部优化） |
| **编译速度** | 适中 | 适中 |
| **适用场景** | 调试插件代码 | 日常开发（推荐） |

---

## 使用指南

### DebugGame Editor 模式（编译G）

**完整配置名：** `DebugGame Editor`

**特点：**
- 引擎代码完全优化（UE5 引擎部分）
- 游戏/插件代码未优化，包含完整调试符号
- 适合调试自己编写的插件逻辑
- 可以在 Visual Studio 中设置断点

**适用场景：**
```
✅ 插件崩溃需要调试
✅ 需要单步跟踪插件代码
✅ 验证插件逻辑的正确性
✅ 开发早期阶段
```

**使用示例：**
```
我的插件崩溃了，请修复代码，然后编译G进行调试。
```

---

### Development Editor 模式（编译V / 编译）

**完整配置名：** `Development Editor`

**特点：**
- 引擎和插件代码都进行优化
- 保留基本的调试信息
- 执行速度快，开发效率高
- **推荐的日常开发模式**

**适用场景：**
```
✅ 日常插件开发
✅ 功能测试
✅ 大部分开发工作
✅ 不需要深度调试时
```

**使用示例：**
```
请生成一个建筑编辑器插件，然后编译。
或
请生成一个建筑编辑器插件，然后编译V。
```

---

## 实际编译命令

### 命令格式

```batch
dotnet "UnrealBuildTool.dll" ^
    ProjectNameEditor ^
    Win64 ^
    [Configuration] ^
    -Project="ProjectPath.uproject" ^
    -WaitMutex ^
    -FromMsBuild ^
    -architecture=x64
```

### 参数说明

- `ProjectNameEditor` - 目标名称（总是带 Editor 后缀，因为我们编译的是编辑器插件）
- `[Configuration]` - 配置状态：`DebugGame` 或 `Development`
- 目标类型 `Editor` 已经包含在 `ProjectNameEditor` 中

### 实际示例

**DebugGame Editor 编译：**
```batch
dotnet "H:/Program Files/Epic Games/UE_5.5/Engine/Binaries/DotNET/UnrealBuildTool/UnrealBuildTool.dll" ^
    BuildingEditorSampleEditor ^
    Win64 ^
    DebugGame ^
    -Project="H:/UE5_Projects/BuildingEditorSample/BuildingEditorSample.uproject" ^
    -WaitMutex ^
    -FromMsBuild ^
    -architecture=x64
```

**Development Editor 编译：**
```batch
dotnet "H:/Program Files/Epic Games/UE_5.5/Engine/Binaries/DotNET/UnrealBuildTool/UnrealBuildTool.dll" ^
    BuildingEditorSampleEditor ^
    Win64 ^
    Development ^
    -Project="H:/UE5_Projects/BuildingEditorSample/BuildingEditorSample.uproject" ^
    -WaitMutex ^
    -FromMsBuild ^
    -architecture=x64
```

---

## 常见问题

### Q1: 为什么只有两种模式？

**A:** 因为插件开发主要在编辑器环境中进行，所以目标类型固定为 `Editor`。而配置状态中：
- `Debug Editor` - 很少使用（引擎也未优化，太慢）
- `DebugGame Editor` - 常用（引擎优化，插件可调试）
- `Development Editor` - 最常用（全部优化，日常开发）
- `Shipping Editor` - 很少使用（编辑器发布配置不常见）
- `Test Editor` - 很少使用（编辑器测试配置不常见）

所以实际上只需要关注 `DebugGame Editor` 和 `Development Editor` 两种。

### Q2: 编译G 和 编译V 的区别是什么？

**A:** 主要区别在于**你编写的插件代码**是否优化：
- 编译G（DebugGame）：插件代码未优化，可以完整调试
- 编译V（Development）：插件代码优化，执行更快

**引擎代码在两种模式下都是优化的。**

### Q3: 什么时候用编译G，什么时候用编译V？

**A:** 简单记忆：
```
遇到 Bug 需要调试  →  编译G
正常开发和测试    →  编译V（或"编译"）
```

### Q4: 可以在两种模式之间切换吗？

**A:** 可以，随时重新编译即可：
```
先用 Development 开发：编译V
遇到问题切换到 DebugGame：编译G
问题解决后回到 Development：编译V
```

### Q5: 编译产物在哪里？

**A:** 编译后的 DLL 文件在：
```
Plugins/YourPlugin/Binaries/Win64/
├── UnrealEditor-YourPlugin.dll                      (Development)
└── UnrealEditor-YourPlugin-Win64-DebugGame.dll      (DebugGame)
```

---

## 配置说明

在 `config.json` 中的配置：

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

---

## 开发工作流推荐

### 典型的插件开发流程

```
1. 新功能开发
   ↓
   使用 Development Editor（编译V）
   快速编译，快速测试
   ↓
2. 遇到崩溃或逻辑错误
   ↓
   切换到 DebugGame Editor（编译G）
   在 Visual Studio 中设置断点调试
   ↓
3. 问题定位并修复
   ↓
   可以继续用 DebugGame 验证修复
   或切回 Development 继续开发
   ↓
4. 功能测试通过
   ↓
   使用 Development Editor 最终验证
```

### 最佳实践

✅ **推荐做法：**
- 日常开发默认使用 `Development Editor`（编译V）
- 遇到需要调试的问题时才切换到 `DebugGame Editor`（编译G）
- 问题解决后切回 `Development Editor`

❌ **不推荐：**
- 一直使用 `DebugGame Editor` 开发（插件代码未优化，运行较慢）
- 从不使用 `DebugGame Editor`（遇到问题难以调试）

---

## 技术参考

### Unreal Engine 官方文档

- [Build Configurations](https://docs.unrealengine.com/4.27/en-US/ProductionPipelines/DevelopmentSetup/BuildConfigurations/)
- [Building Unreal Engine from Source](https://docs.unrealengine.com/4.27/en-US/ProductionPipelines/DevelopmentSetup/BuildingUnrealEngine/)

### 配置状态详细说明

| Configuration | 引擎代码 | 游戏代码 | 调试信息 | 性能 | 用途 |
|--------------|---------|---------|---------|------|-----|
| Debug | 未优化 | 未优化 | 完整 | 最慢 | 引擎调试 |
| DebugGame | ✅ 优化 | 未优化 | 完整 | 中等 | **游戏/插件调试** |
| Development | ✅ 优化 | ✅ 优化 | 部分 | 快 | **日常开发** |
| Shipping | ✅ 优化 | ✅ 优化 | 最少 | 最快 | 发布 |
| Test | ✅ 优化 | ✅ 优化 | 部分 | 快 | 测试 |

> **插件开发重点关注：** DebugGame Editor 和 Development Editor

---

## 版本历史

- **2025-11-28 (修订)**: 更正编译模式说明
  - 明确 Unreal 编译配置体系（Configuration + Target Type）
  - 说明本 Skill 支持的是 Editor 目标
  - 重点关注 DebugGame Editor 和 Development Editor 两种模式
  - 移除不常用的 Shipping Editor 配置

- **2025-11-28 (初版)**: 添加编译模式支持
  - 新增编译模式文档

---

**相关文档：**
- [PROMPT_INSTRUCTION.md](PROMPT_INSTRUCTION.md) - 提示词指令
- [COMPILE_QUICK_REFERENCE.md](COMPILE_QUICK_REFERENCE.md) - 快速参考
- [CompileAndIterateGuide.md](CompileAndIterateGuide.md) - 编译和迭代指南
- [SKILL.md](../SKILL.md) - Skill 完整文档
