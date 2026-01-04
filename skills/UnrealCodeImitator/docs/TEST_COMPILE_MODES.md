# 编译模式测试指南

## 快速测试

### 测试 1：DebugGame 模式
```
用户输入：
参考 Unreal 源码，创建一个简单的 Actor Component，然后编译G。

预期结果：
1. LLM 生成 Actor Component 代码
2. 调用 compile.bat DebugGame
3. 控制台显示：[Info] Build Configuration: DebugGame
4. 生成 UnrealEditor-XXX-Win64-DebugGame.dll
```

### 测试 2：Development 模式（默认）
```
用户输入：
参考 Unreal 源码，创建一个简单的 Actor Component，然后编译。

预期结果：
1. LLM 生成 Actor Component 代码
2. 调用 compile.bat Development（或 compile.bat 无参数）
3. 控制台显示：[Info] Build Configuration: Development
4. 生成 UnrealEditor-XXX.dll
```

### 测试 3：Development 模式（显式）
```
用户输入：
参考 Unreal 源码，创建一个简单的 Actor Component，然后编译V。

预期结果：
1. LLM 生成 Actor Component 代码
2. 调用 compile.bat Development
3. 控制台显示：[Info] Build Configuration: Development
4. 生成 UnrealEditor-XXX.dll
```

### 测试 4：Shipping 模式
```
用户输入：
参考 Unreal 源码，创建一个简单的 Actor Component，然后编译S。

预期结果：
1. LLM 生成 Actor Component 代码
2. 调用 compile.bat Shipping
3. 控制台显示：[Info] Build Configuration: Shipping
4. 生成 UnrealEditor-XXX-Win64-Shipping.dll
```

---

## 验证清单

### ✅ 编译脚本
- [ ] `compile.bat` 接受命令行参数
- [ ] 无参数时默认使用 Development
- [ ] 传入 DebugGame 参数时正确编译
- [ ] 传入 Development 参数时正确编译
- [ ] 传入 Shipping 参数时正确编译
- [ ] 日志中正确显示编译配置

### ✅ 关键词识别
- [ ] "编译G" 触发 DebugGame 编译
- [ ] "编译V" 触发 Development 编译
- [ ] "编译" 触发 Development 编译（默认）
- [ ] "编译S" 触发 Shipping 编译

### ✅ 配置文件
- [ ] `config.json` 包含 compilation 配置节
- [ ] modeAliases 正确映射关键词
- [ ] description 正确描述各模式

### ✅ 文档
- [ ] SKILL.md 更新编译模式说明
- [ ] PROMPT_INSTRUCTION.md 更新关键词表
- [ ] COMPILE_MODES.md 提供详细指南
- [ ] COMPILE_QUICK_REFERENCE.md 提供快速参考
- [ ] UPDATE_LOG.md 记录改进内容

---

## 手动测试步骤

### 步骤 1：直接测试编译脚本

打开命令行，进入 Skill 目录：

```batch
cd h:\UE5_Projects\_CodeBuddy_Extras\Skills\UnrealCodeImitator

# 测试 DebugGame
scripts\compile.bat DebugGame

# 测试 Development（默认）
scripts\compile.bat Development
# 或
scripts\compile.bat

# 测试 Shipping
scripts\compile.bat Shipping
```

**检查点：**
- 脚本执行无错误
- 日志中显示正确的 Build Configuration
- 编译成功后生成对应的 DLL 文件

### 步骤 2：通过 LLM 测试

在对话中输入：

```
参考 Unreal 源码，创建一个简单的 UActorComponent 子类 UMyTestComponent，
添加一个 Tick 函数。然后编译G。
```

**检查点：**
- LLM 生成代码
- LLM 调用 compile.bat DebugGame
- 编译成功

重复测试其他模式（编译、编译V、编译S）。

### 步骤 3：验证编译产物

检查生成的 DLL 文件位置：

```
Plugins/BuildingEditor/AncientBuilding/Binaries/Win64/
├── UnrealEditor-AncientBuilding.dll                        (Development)
├── UnrealEditor-AncientBuilding-Win64-DebugGame.dll       (DebugGame)
└── UnrealEditor-AncientBuilding-Win64-Shipping.dll        (Shipping)
```

**检查点：**
- 文件存在
- 文件大小符合预期（DebugGame > Development > Shipping）
- 时间戳正确（最近编译）

---

## 常见问题排查

### 问题 1：编译脚本不识别参数
**症状：** 无论传入什么参数，都使用默认配置

**排查：**
```batch
# 检查脚本是否正确解析参数
echo %1
```

**解决：** 确保脚本中的参数解析代码正确

### 问题 2：LLM 不识别编译关键词
**症状：** 用户说"编译G"，LLM 只生成代码不编译

**排查：**
- 检查 PROMPT_INSTRUCTION.md 是否更新
- 检查 SKILL.md 是否包含关键词说明

**解决：** 重新加载 Skill 或重启会话

### 问题 3：编译失败
**症状：** 调用编译脚本后报错

**排查：**
```batch
# 检查日志
type scripts\build_logs\latest_errors.txt
```

**解决：**
- 确认 config.json 中的引擎路径正确
- 确认项目文件存在
- 确认 Visual Studio 已安装

---

## 性能基准

不同编译模式的预期性能：

| 模式 | 编译时间 | 运行速度 | DLL 大小 |
|------|---------|---------|---------|
| DebugGame | ⏱️ 较长 | 🐌 慢 | 📦 大 |
| Development | ⏱️ 适中 | ⚡ 中等 | 📦 中等 |
| Shipping | ⏱️ 较长 | 🚀 快 | 📦 小 |

---

## 测试完成检查清单

- [ ] 所有 4 个测试场景通过
- [ ] 编译脚本参数解析正确
- [ ] 关键词识别正确
- [ ] 编译产物正确生成
- [ ] 日志显示正确的配置
- [ ] 文档完整且准确
- [ ] 向后兼容性保持

---

**测试准备时间：** < 5 分钟  
**测试执行时间：** < 15 分钟  
**总计：** < 20 分钟
