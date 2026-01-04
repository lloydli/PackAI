# 编译模式快速参考

## 一句话记忆

```
编译G = 调试插件代码（DebugGame Editor）
编译V = 日常开发（Development Editor）
编译  = 日常开发（Development Editor，默认）
```

---

## 快速选择表

| 你的需求 | 使用命令 | 实际配置 |
|---------|---------|---------|
| 🐛 **调试崩溃** | 编译G | DebugGame Editor |
| 🐛 **单步跟踪** | 编译G | DebugGame Editor |
| ⚡ **日常开发** | 编译V 或 编译 | Development Editor |
| ⚡ **功能测试** | 编译V 或 编译 | Development Editor |

---

## 配置对比（核心差异）

|  | DebugGame Editor | Development Editor |
|--|-----------------|-------------------|
| **关键词** | 编译G | 编译V / 编译 |
| **引擎代码** | ✅ 优化 | ✅ 优化 |
| **插件代码** | ❌ 未优化（可调试） | ✅ 优化 |
| **执行速度** | 中等 | 快 |
| **适用场景** | 调试问题 | 日常开发 |

---

## 工作流程图

```
开始新功能
    ↓
使用 Development Editor（编译V）← ─ ─ ─ ─ ─ ─ ┐
    ↓                                      │
正常工作                                    │
    ↓                                      │
遇到崩溃/Bug                               │
    ↓                                      │
切换到 DebugGame Editor（编译G）            │
    ↓                                      │
Visual Studio 调试                         │
    ↓                                      │
修复问题                                    │
    ↓                                      │
验证修复  ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┘
```

---

## 使用示例

### 场景1：日常开发
```
请生成一个建筑编辑器插件，然后编译。
```

### 场景2：遇到崩溃
```
插件崩溃了，请修复，然后编译G进行调试。
```

### 场景3：问题修复后
```
问题已修复，请重新编译V验证。
```

---

## 常见错误提示

### ❌ 错误：一直使用编译G开发
**问题：** 插件代码未优化，运行较慢，影响开发效率

**正确：** 日常开发用编译V，需要调试时才用编译G

### ❌ 错误：遇到Bug不用编译G
**问题：** 无法设置断点，难以定位问题

**正确：** 遇到崩溃或逻辑错误时切换到编译G

---

## 命令行调用（手动）

```batch
# DebugGame Editor
scripts\compile.bat DebugGame

# Development Editor
scripts\compile.bat Development
或
scripts\compile.bat
```

---

## 编译产物位置

```
Plugins/YourPlugin/Binaries/Win64/
├── UnrealEditor-YourPlugin.dll                    ← Development
└── UnrealEditor-YourPlugin-Win64-DebugGame.dll    ← DebugGame
```

---

## 配置文件（config.json）

```json
{
  "compilation": {
    "defaultMode": "Development",
    "modeAliases": {
      "编译G": "DebugGame",
      "编译V": "Development"
    }
  }
}
```

---

## 记忆口诀

```
G = Game调试（DebugGame）
V = 通用开发（DeVelopment）

日常开发用 V，
遇到问题用 G。
```

---

**更详细的说明请参考：** [COMPILE_MODES.md](COMPILE_MODES.md)
