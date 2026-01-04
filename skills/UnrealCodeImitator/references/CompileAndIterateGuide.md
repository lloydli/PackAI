# 编译与迭代指南 - 自动化编译和错误修复

## 概述

本指南说明如何利用编译系统和 LLM 的协作，实现自动化的编译-错误分析-修复循环，快速从源码学习到可编译的功能实现。

## 编译流程

### 工作流程

```
LLM 生成代码
    ↓
执行编译脚本
    ↓
编译成功？
    ├─ YES → 功能可用 ✅
    └─ NO  → 收集编译错误日志
              ↓
         发送错误日志给 LLM
              ↓
         LLM 分析和修复
              ↓
         应用修复代码
              ↓
         重新编译
              ↓
         重复直到成功
```

## 编译脚本使用

### 1. 编译脚本位置

**脚本路径：**
```
H:/UE5_Projects/_CodeBuddy_Extras/Skills/UnrealCodeImitator/scripts/compile.bat
```

### 2. 脚本功能

编译脚本 (`compile.bat`) 是本 Skill 的**唯一编译入口**（通过读取 Skill 根目录下的 `config.json` 获取 `unrealEnginePath`）：

- ✅ 自动检测 Unreal 引擎路径（从 config.json）
- ✅ **全自动执行，无需用户交互**（移除所有 `pause` 命令，适合 Agent 调用）
- ✅ **正确解析 Windows 路径**（支持包含盘符的路径，如 `H:/Program Files/...`）
- ✅ **自动检测 Unreal 引擎版本**（从 Build.version 读取主版本号和次版本号）
- ✅ **自动检测 Visual Studio 路径**（使用 vswhere.exe 定位最新安装的 VS）
- ✅ **验证 MSBuild 工具**（确保编译环境完整）
- 🔨 执行 UE 插件编译
- 📝 收集完整的编译错误日志
- 📁 按时间戳保存错误日志（便于追踪）
- 🎯 输出结构化的错误信息供 LLM 分析
- 🔄 支持多次迭代编译

### 3. 运行编译

**PowerShell 命令：**
```powershell
# 进入项目目录
cd "H:/UE5_Projects/BuildingEditorSample/Plugins/BuildingEditor/AncientBuilding"

# 运行编译脚本（BAT 版本，会从 config.json 读取 unrealEnginePath）
..\..\..\..\_CodeBuddy_Extras\Skills\UnrealCodeImitator\scripts\compile.bat
```

或者直接在 IDE 中运行：
```powershell
& "H:/UE5_Projects/_CodeBuddy_Extras/Skills/UnrealCodeImitator/scripts/compile.bat"
```

### 4. 脚本输出

编译脚本会生成：

```
编译输出日志/
├── compile_YYYYMMDD_HHMMSS.log      # 完整编译日志
├── errors_YYYYMMDD_HHMMSS.txt       # 错误摘要（供 LLM 分析）
└── latest_errors.txt                 # 最新错误（快捷访问）
```

**错误日志格式（供 LLM 分析）：**
```
==== 编译错误摘要 (2025-11-11 14:30:45) ====

[错误数量] 3 errors, 2 warnings

[错误 1]
文件: Source/AncientBuilding/Public/MyActor.h
行号: 45
错误: undefined reference to 'UMyClass'
上下文:
  43 | void OnBeginPlay()
  44 | {
  45 |   UMyClass* MyObj = NewObject<UMyClass>();
     |                     ^^^^^^^^^^^^^^^^^^
  46 | }

[错误 2]
...

[警告信息]
警告 1: 未使用的变量 'unused_var'
...
```

## 错误分析和修复流程

### 第一步：获取错误日志

编译失败后，脚本自动生成 `errors_YYYYMMDD_HHMMSS.txt`

### 第二步：发送给 LLM 分析

**向 LLM 说：**
```
我的编译出现了以下错误，请帮我分析和修复：

[粘贴 errors_YYYYMMDD_HHMMSS.txt 的内容]

错误位置：
- 文件：Source/AncientBuilding/Public/MyActor.h
- 行号：45

代码上下文：
[粘贴相关代码]

请：
1. 分析错误原因
2. 提出修复方案
3. 生成修复后的代码
```

### 第三步：应用 LLM 的修复

根据 LLM 的建议：
1. 修改相应的代码文件
2. 保存修改
3. 重新运行编译脚本

### 第四步：重复迭代

如果仍有错误，重复步骤 1-3

## 常见编译错误及快速修复

### 错误 1: 未定义的符号

```
error: undefined reference to 'SomeClass'
```

**原因：** 
- 头文件未 include
- 模块依赖未正确配置

**修复步骤：**
1. 检查是否 #include 了正确的头文件
2. 检查 .Build.cs 中是否添加了模块依赖
3. 检查是否正确 forward declared

**示例：**
```cpp
// 错误代码
class MyClass
{
    UMyOtherClass* Ptr;  // 未 include MyOtherClass.h
};

// 正确代码
#include "MyOtherClass.h"  // 添加 include

class MyClass
{
    UMyOtherClass* Ptr;
};
```

### 错误 2: UPROPERTY/UFUNCTION 宏问题

```
error: unknown type 'UProperty'
error: UPROPERTY must be used on class member variables
```

**原因：**
- 宏使用位置不正确
- 修饰符搭配有问题

**修复步骤：**
1. 确保 UPROPERTY/UFUNCTION 在类声明内
2. 检查宏参数是否有效
3. 确保头文件被 Unreal Header Tool (UHT) 处理

**示例：**
```cpp
// 错误代码
UPROPERTY()
int32 MyVar = 0;  // 在类外

class MyClass
{
};

// 正确代码
class MyClass
{
public:
    UPROPERTY()
    int32 MyVar = 0;  // 在类内
};
```

### 错误 3: 模块依赖缺失

```
error: cannot open include file: 'xxx.h'
```

**原因：**
- .Build.cs 中未添加必要的模块依赖

**修复步骤：**
1. 打开 .Build.cs 文件
2. 在 PublicDependencyModuleNames 中添加模块
3. 重新编译

**示例：**
```csharp
// AncientBuilding.Build.cs
PublicDependencyModuleNames.AddRange(new string[] {
    "Core",
    "CoreUObject",
    "Engine",
    "UnrealEd",      // 添加编辑器模块
    "Slate"          // 添加 Slate UI 模块
});
```

### 错误 4: 引擎版本不匹配

```
error: version mismatch
error: compiled with different version of Unreal Engine
```

**原因：**
- 代码与引擎版本不兼容

**修复步骤：**
1. 检查 .uplugin 文件中的版本号
2. 确保代码兼容当前引擎版本
3. 必要时使用 preprocessor directives 处理版本差异

**示例：**
```cpp
// 处理版本差异
#if ENGINE_MAJOR_VERSION >= 5 && ENGINE_MINOR_VERSION >= 3
    // UE 5.3+ 代码
#else
    // 旧版本代码
#endif
```

## LLM 协作最佳实践

### 1. 提供完整的错误信息

**好的做法：**
```
编译错误：
文件：Source/AncientBuilding/Public/MyComponent.h
行：25
错误：'UObjectProperty' has no member named 'GetPropertyValue'

代码片段：
  22 | void MyComponent::InitProperty()
  23 | {
  24 |     for (TFieldIterator<UObjectProperty> Prop(Class); Prop; ++Prop)
  25 |     {
  26 |         void* Value = Prop->GetPropertyValue(Object);  ← 这行报错
  27 |     }
  28 | }
```

**不好的做法：**
```
编译失败了，很多错误，帮我修
```

### 2. 描述修改背景

告诉 LLM：
- 你想实现什么功能
- 参考了哪些源码
- 期望的行为

**示例：**
```
我正在实现自定义的属性编辑器，参考了 Engine/Source/Editor/UnrealEd/Private/Kismet2/PropertyEditorHelpers.cpp

目标是：遍历 UClass 的所有属性，并获取它们的值

错误信息：...
```

### 3. 一次修复一个错误

不要试图同时修复所有错误。优先：
1. 先修复链接错误（undefined reference）
2. 再修复语法错误
3. 最后修复警告

### 4. 验证修复

修复后，确保：
- ✅ 编译通过
- ✅ 没有新的错误
- ✅ 功能逻辑正确

## 编译配置说明

### UE 项目编译方式

根据项目类型选择编译方式：

#### 方式 1: 使用 UnrealBuildTool.dll 编译 Editor 目标（当前脚本采用方式）

```powershell
# 使用 UnrealBuildTool.dll（dotnet）编译 Editor 目标
# UE_ENGINE_PATH 对应 config.json 中的 unrealEnginePath
cd "H:/UE5_Projects/BuildingEditorSample"

dotnet "UE_ENGINE_PATH/Engine/Binaries/DotNET/UnrealBuildTool/UnrealBuildTool.dll" `
    BuildingEditorSampleEditor `
    Win64 `
    Development `
    -Project="H:/UE5_Projects/BuildingEditorSample/BuildingEditorSample.uproject" `
    -WaitMutex `
    -FromMsBuild `
    -architecture=x64
```

#### 方式 2: 完整项目编译

```powershell
# 编译完整项目
& "UE_ENGINE_PATH/Engine/Build/BatchFiles/Build.bat" `
    -Target="ProjectNameEditor" `
    -Platform="Win64" `
    -Configuration="Development"
```

#### 方式 3: 增量编译（开发中使用）

```powershell
# 只编译修改过的文件
& "UE_ENGINE_PATH/Engine/Build/BatchFiles/Build.bat" `
    -Target="ProjectNameEditor" `
    -Platform="Win64" `
    -Configuration="Development" `
    -Incremental
```

## 错误日志管理

### 日志位置

```
编译输出日志/
├── compile_YYYYMMDD_HHMMSS.log      # 完整编译日志（用于深度分析）
├── errors_YYYYMMDD_HHMMSS.txt       # 错误摘要（用于 LLM 分析）
├── latest_errors.txt                 # 最新错误快捷链接
└── build_history.csv                 # 编译历史记录
```

### 查看日志

**查看最新错误（快速）：**
```powershell
Get-Content "编译输出日志/latest_errors.txt"
```

**查看完整日志（详细分析）：**
```powershell
Get-Content "编译输出日志/compile_20251111_143045.log" -Tail 100
```

**搜索特定错误：**
```powershell
Select-String "undefined reference" "编译输出日志/latest_errors.txt"
```

## 自动化迭代工作流

### 快速迭代脚本（可选）

创建一个快速迭代脚本 `iterate.ps1`：

```powershell
# iterate.ps1 - 自动编译和错误收集

param(
    [string]$ProjectPath = "H:/UE5_Projects/BuildingEditorSample"
)

$SkillPath = "H:/UE5_Projects/_CodeBuddy_Extras/Skills/UnrealCodeImitator"

# 1. 编译
Write-Host "正在编译..." -ForegroundColor Cyan
& "$SkillPath/scripts/compile.bat"

# 2. 检查是否有错误
$ErrorLog = Get-ChildItem "$SkillPath/编译输出日志" -Filter "errors_*.txt" | Sort-Object LastWriteTime -Descending | Select-Object -First 1

if ($ErrorLog) {
    Write-Host "`n编译出现错误！" -ForegroundColor Red
    Write-Host "`n错误日志已保存到：$($ErrorLog.FullName)" -ForegroundColor Yellow
    Write-Host "`n请发送以下内容给 LLM：`n" -ForegroundColor Cyan
    Get-Content $ErrorLog.FullName
} else {
    Write-Host "`n编译成功！🎉" -ForegroundColor Green
}
```

**使用方式：**
```powershell
& "H:/UE5_Projects/_CodeBuddy_Extras/Skills/UnrealCodeImitator/iterate.ps1"
```

## 编译性能优化

### 加速编译的方法

1. **使用增量编译（概念）**
   ```text
   仅重新编译最近修改的模块（当前 BAT 版本脚本暂未暴露命令行开关，可通过后续脚本扩展支持）
   ```

2. **使用并行编译（概念）**
   ```text
   将编译任务分发到多核 CPU（由 Unreal 官方构建工具内部控制，例如 UnrealBuildTool/RunUAT 提供的并行开关；本 Skill 的 BAT 脚本采用工具默认的并行设置）
   ```

3. **使用预编译头**
   - 在 .Build.cs 中启用 PCH（Precompiled Headers）

4. **清理中间文件**
   ```powershell
   # 清理 Intermediate 目录
   Remove-Item -Path "Intermediate" -Recurse -Force
   ```

## 常见问题

### Q1: 编译太慢怎么办？

**A:** 
- 使用增量编译：目前建议通过合理拆分模块和减少不必要的依赖来缩短编译时间（BAT 版本脚本暂未提供 `-Incremental` 参数）
- 清理 Intermediate 目录
- 检查是否有大量模板实例化

### Q2: 同一个错误反复出现怎么办？

**A:**
- 检查是否正确应用了修复
- 清理 Intermediate 目录并重新编译
- 向 LLM 提供更详细的上下文信息

### Q3: 警告能忽略吗？

**A:**
- 推荐修复所有警告，因为警告通常是潜在的 bug
- 如果必须忽略，在 .Build.cs 中配置警告级别

## 最佳实践总结

✅ **推荐做法：**
1. 先编译，快速找到所有问题
2. 一次修复一个错误
3. 为 LLM 提供完整的错误上下文
4. 保存编译日志便于追踪
5. 编译成功后测试功能

❌ **避免做法：**
1. 猜测错误原因而不看完整错误信息
2. 同时修复多个不相关的错误
3. 忽视编译警告
4. 不保存编译历史
5. 编译通过后跳过功能测试

## 下一步

编译成功后：
1. 运行插件验证其功能
2. 测试与其他模块的交互
3. 检查性能和内存使用
4. 如果需要，向 LLM 请求优化建议

---

**更新记录：**
- **2025-11-11**: 初始版本
- 支持 UE 5.0+
- 集成编译脚本和错误分析工作流
