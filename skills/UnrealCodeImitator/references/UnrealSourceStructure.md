# Unreal 引擎源码结构速查表

## 目录结构概览

```
UE_5.x/
├── Engine/
│   ├── Source/
│   │   ├── Runtime/          # 运行时核心功能
│   │   ├── Editor/           # 编辑器特定代码
│   │   └── ThirdParty/       # 第三方库
│   ├── Content/              # 引擎默认资源
│   ├── Plugins/              # 内置插件
│   └── Binaries/             # 编译后的二进制文件
├── Samples/                  # 示例项目
└── Documentation/            # 文档
```

## 核心模块详解

### 1. Core 模块
**路径：** `Engine/Source/Runtime/Core/`

**主要功能：**
- 基础数据类型 (FString, FVector, FMatrix 等)
- 内存管理 (FMemory, malloc/free)
- 容器 (TArray, TMap, TSet 等)
- 数学库 (FMath)
- 平台抽象层 (FPlatformMisc, FPlatformProcess)

**关键文件：**
```
Core/Public/
├── Containers/          # TArray, TMap, TSet, TLinkedList 等
├── Math/                # FVector, FMatrix, FQuat, FMath 等
├── Memory/              # FMemory, 智能指针
├── Misc/                # FString, FGuid, FDateTime, FTickableObject
├── Serialization/       # FArchive, 序列化相关
└── Logging/             # UE_LOG 相关
```

**常用类：**
- `FString` - 字符串类
- `TArray<T>` - 动态数组
- `TMap<K,V>` - 哈希表
- `FVector / FVector2D / FVector4` - 向量
- `FMatrix` - 矩阵
- `FQuat` - 四元数
- `FColor` - 颜色

---

### 2. CoreUObject 模块
**路径：** `Engine/Source/Runtime/CoreUObject/`

**主要功能：**
- Unreal 对象系统 (UObject)
- 反射系统 (UPROPERTY, UFUNCTION, UPROPERTY)
- 垃圾回收 (Garbage Collection)
- 序列化和资产加载

**关键文件：**
```
CoreUObject/Public/
├── UObject/
│   ├── Object.h          # UObject 基类
│   ├── Class.h           # UClass 定义
│   ├── Property.h        # UProperty 及其子类
│   ├── Function.h        # UFunction 定义
│   └── Interface.h       # 接口定义
├── Serialization/        # 序列化相关
├── Misc/
│   └── ObjectHandle.h    # 对象句柄
└── Reflection/           # 反射系统
```

**反射系统关键宏：**
```cpp
UCLASS()              // 声明一个可被反射的类
USTRUCT()             // 声明一个可被反射的结构体
UENUM()               // 声明一个可被反射的枚举
UPROPERTY()           // 声明可编辑的属性
UFUNCTION()           // 声明可调用的函数
UMETA()               // 元数据标记
```

**常用类：**
- `UObject` - 所有 Unreal 对象的基类
- `UClass` - 类的元数据
- `UProperty` - 属性的元数据
- `UFunction` - 函数的元数据
- `UPackage` - 包（资产容器）

---

### 3. Engine 模块
**路径：** `Engine/Source/Runtime/Engine/`

**主要功能：**
- Actor 系统
- Component 系统
- Pawn 和 Character
- 物理和碰撞
- 动画系统
- 音频系统
- 粒子系统
- UI 框架 (UMG)

**子模块：**
```
Engine/Public/
├── GameFramework/       # Actor, Pawn, Character, Controller
├── Components/          # Actor Component, Scene Component
├── Physics/             # 物理引擎集成
├── Animation/           # 动画系统
├── Audio/               # 音频系统
├── Particles/           # 粒子系统
├── Slate/               # 低级 UI 框架
├── UMG/                 # 高级 UI 框架
├── Input/               # 输入处理
├── Camera/              # 摄像机系统
├── Rendering/           # 渲染相关
├── Navigation/          # 导航系统
└── AI/                  # AI 相关
```

**常用类：**
```cpp
AActor              // 游戏世界中的对象基类
APawn               // 可被控制的角色
ACharacter          // 具有物理形态的 Pawn
APlayerController   // 玩家控制器
UActorComponent     // Actor 的组件基类
USceneComponent     // 具有位置的组件
UPrimitiveComponent // 可渲染的组件
AGameModeBase       // 游戏规则定义
AGameStateBase      // 游戏状态
APlayerState        // 玩家状态
```

---

### 4. UnrealEd 模块
**路径：** `Engine/Source/Editor/UnrealEd/`

**主要功能：**
- 编辑器 UI 和窗口
- 编辑器命令系统
- 资产编辑器
- 详情面板 (Details Panel)
- 编辑工具
- 撤销/重做系统

**关键文件：**
```
UnrealEd/Public/
├── Editor.h              # 编辑器主类
├── EditorViewportClient.h # 视口
├── Kismet2/              # 蓝图相关
├── UnrealEd.h            # 通用编辑器 API
├── SAssetSearchUI.h      # 资产搜索
└── Commands/             # 编辑器命令
```

**常用类：**
- `FEditor` - 编辑器主控制器
- `FEditorViewportClient` - 编辑器视口
- `FAssetEditorManager` - 资产编辑器管理
- `FPropertyEditorModule` - 属性编辑器模块

---

### 5. Slate 模块
**路径：** `Engine/Source/Runtime/Slate/`

**主要功能：**
- 低级原生 UI 框架
- 窗口和控件
- 输入处理
- 布局系统

**关键文件：**
```
Slate/Public/
├── Widgets/             # 所有 Slate 控件
│   ├── SCompoundWidget.h
│   ├── SPanel.h
│   ├── SButton.h
│   ├── STextBlock.h
│   └── ...
├── Framework/           # 框架核心
└── Layout/              # 布局相关
```

**常用类：**
- `SWidget` - 所有 Slate 控件的基类
- `SCompoundWidget` - 复合控件基类
- `SButton` - 按钮
- `STextBlock` - 文本
- `SPanel` - 面板容器

---

### 6. Plugins 模块
**路径：** `Engine/Source/Runtime/Plugins/` 和 `Engine/Plugins/`

**主要功能：**
- 插件系统实现
- 插件加载/卸载
- 插件管理

**关键文件：**
```
Engine/Plugins/
├── PluginBrowser/       # 插件浏览器
├── EnhancedInput/       # 增强输入系统
├── PlanarReflection/    # 平面反射
├── Procedural/          # 程序化生成
├── FX/                  # 特效相关
├── Media/               # 媒体播放
└── Runtime/             # 运行时插件
```

---

## 常见学习路径

### 学习路径 1: 反射系统
```
1. 学习基础
   → Engine/Source/Runtime/CoreUObject/Public/UObject/Object.h
   → Engine/Source/Runtime/CoreUObject/Public/UObject/Class.h

2. 深入宏系统
   → Engine/Source/Runtime/CoreUObject/Public/UObject/ObjectMacros.h
   → Engine/Intermediate/Build/[Platform]/[Config]/CoreUObject/Generated/

3. 实践应用
   → 查看引擎内置类如 AActor, ACharacter 的声明
```

### 学习路径 2: 事件系统
```
1. 委托 (Delegates)
   → Engine/Source/Runtime/Core/Public/Delegates/Delegate.h
   → Engine/Source/Runtime/Core/Public/Delegates/MulticastDelegate.h

2. 事件 (Events)
   → Engine/Source/Runtime/Engine/Public/GameFramework/Actor.h (BeginPlay, Tick 等)

3. 输入事件
   → Engine/Source/Runtime/Engine/Public/Input/InputComponent.h
```

### 学习路径 3: Actor 生命周期
```
1. 基础生命周期
   → Engine/Source/Runtime/Engine/Public/GameFramework/Actor.h
   
2. 关键函数
   → PreInitializeComponents()
   → PostInitializeComponents()
   → BeginPlay()
   → Tick()
   → EndPlay()
   → Destroyed()
```

### 学习路径 4: 组件系统
```
1. 基类
   → Engine/Source/Runtime/Engine/Public/Components/ActorComponent.h
   → Engine/Source/Runtime/Engine/Public/Components/SceneComponent.h

2. 常见组件
   → Engine/Source/Runtime/Engine/Public/Components/PrimitiveComponent.h
   → Engine/Source/Runtime/Engine/Public/Components/SkeletalMeshComponent.h
```

### 学习路径 5: 插件开发
```
1. 插件架构
   → Engine/Plugins/Marketplace/ (参考已有插件)
   → Engine/Source/Runtime/Projects/Public/Interfaces/IPluginManager.h

2. 模块系统
   → Engine/Build/BuildVersion.h
   → 查看 .uplugin 文件格式
```

---

## 快速查找技巧

### 按功能查找

| 功能 | 查找路径 |
|------|---------|
| 字符串操作 | `Core/Public/Containers/String.h` |
| 数组/容器 | `Core/Public/Containers/` |
| 数学运算 | `Core/Public/Math/` |
| 对象反射 | `CoreUObject/Public/UObject/` |
| Actor/Pawn | `Engine/Public/GameFramework/` |
| 组件系统 | `Engine/Public/Components/` |
| 物理系统 | `Engine/Public/Physics/` |
| 动画系统 | `Engine/Public/Animation/` |
| UI 框架 | `Engine/Public/UMG/` 或 `Slate/Public/Widgets/` |
| 输入处理 | `Engine/Public/Input/` |
| 编辑器 | `UnrealEd/Public/` |
| 插件 | `Engine/Plugins/` 或 `Engine/Source/Runtime/Plugins/` |

### 按文件类型查找

| 类型 | 特征 |
|------|------|
| 类声明 | `*.h` 文件 + `UCLASS()` 宏 |
| 结构体声明 | `*.h` 文件 + `USTRUCT()` 宏 |
| 实现 | `*.cpp` 文件（同名） |
| 生成的代码 | `*.generated.h` 和 `*.generated.cpp` |
| 接口 | 文件名以 `I` 开头，如 `IInputInterface.h` |

---

## 核心概念速查

### UObject 系统
```cpp
// 基类
class UObject

// 子类关系
UObject
├── UClass              // 类的元信息
├── UProperty           // 属性的元信息
├── UFunction           // 函数的元信息
└── UField              // 字段的基类

// 反射宏
UCLASS()               // 类声明
USTRUCT()              // 结构体声明
UPROPERTY()            // 属性声明
UFUNCTION()            // 函数声明
```

### Actor 系统
```cpp
// 基类
class AActor : public UObject

// 主要子类
AActor
├── APawn               // 可被控制的对象
│   └── ACharacter      // 具有物理形态的角色
├── AGameModeBase       // 游戏规则
└── AInfo               // 信息容器（无物理形态）

// 组件
UActorComponent        // 组件基类
├── USceneComponent    // 有位置的组件
│   └── UPrimitiveComponent  // 可渲染的组件
└── UMovementComponent // 移动组件
```

### 属性系统
```cpp
// 属性类型
UProperty (基类)
├── UObjectProperty     // UObject 指针
├── UNumericProperty    // 数值类型
├── UBoolProperty       // 布尔值
├── UStructProperty     // 结构体
└── UArrayProperty      // 数组
```

---

## 获取源码的方法

### 方法 1: 从 Visual Studio 查看
在 Visual Studio 中按 `F12` 或右键选择"Go to Definition"

### 方法 2: 直接打开文件
路径：`H:/Program Files/Epic Games/UE_5.x/Engine/Source/Runtime/`

### 方法 3: 搜索工具
使用 VS Code 或 Visual Studio 的全局搜索功能搜索类名或函数名

### 方法 4: 在线文档
https://docs.unrealengine.com/ (官方文档)

---

## 模块依赖关系

```
Core (最底层)
  ↓
CoreUObject
  ↓
Engine
  ↓
UnrealEd (仅编辑器)

Slate (独立的 UI 框架)
  ↓
SlateCore

Plugins (依赖于上述模块)
```

---

## 文件命名约定

| 前缀 | 含义 | 示例 |
|------|------|------|
| `I` | 接口 | `IInputInterface.h` |
| `A` | Actor 类 | `AActor.h`, `ACharacter.h` |
| `U` | UObject 类 | `UObject.h`, `UComponent.h` |
| `F` | 基础数据类型 | `FVector.h`, `FString.h` |
| `E` | 枚举类型 | `EMovementMode.h` |
| `T` | 模板类 | `TArray.h`, `TMap.h` |
| `S` | Slate 控件 | `SButton.h`, `SPanel.h` |

---

## 搜索技巧

### 查找特定功能的实现

```
1. 猜测可能的类名
   例：学习反射 → 搜索 "UClass", "UProperty"

2. 查找相关的公开头文件
   通常在 Public/ 目录下

3. 阅读头文件注释和宏定义
   理解该功能的设计

4. 查找实现文件 (.cpp)
   理解具体实现细节

5. 查找使用示例
   搜索在其他地方如何使用这个类
```

### 常用搜索模式

```
搜索类声明：  UCLASS().*ClassName
搜索函数：    virtual.*FunctionName
搜索属性：    UPROPERTY()
搜索宏：      #define.*MACRO_NAME
```

---

## 更新与版本

本文档适用于 **UE 5.0+**。不同版本可能有细微差异。

查看版本信息：`Engine/Source/Runtime/Core/Public/GenericPlatform/GenericPlatformMisc.h`
