---
title: 前端架构规范
description: Vue3 应用开发的技术栈、架构模式和最佳实践指南
---

# 前端架构规范

本文档定义了项目的前端技术栈、架构模式和开发规范。

## 技术栈

### 核心框架
- **Vue 3** 
  - Composition API - 推荐使用 `<script setup>` 语法
  - 响应式系统 - `ref`、`reactive`、`computed`、`watch`
  - 生命周期钩子 - `onMounted`、`onUnmounted` 等

### 构建工具
- **Vite** 
  - 快速的开发服务器和 HMR 热更新
  - 基于 Rollup 的生产构建
  - 插件生态系统

### 状态管理
- **Pinia** 
  - Vue 3 官方推荐的状态管理库
  - 组合式 stores（推荐）或 options stores
  - TypeScript 完美支持
  - DevTools 集成

### UI 框架
- **TDesign Vue Next** 
  - 腾讯企业级 UI 组件库
  - 主要组件库，优先使用 TDesign 组件
  - 完善的类型定义和文档

- **Tailwind CSS** 
  - 实用优先的 CSS 框架
  - 用于补充 TDesign 未覆盖的样式需求
  - 快速实现响应式设计

### 类型系统
- **TypeScript** 
  - 强类型检查
  - 智能代码提示
  - 组件 Props 和 Emits 类型定义

### 测试工具
- **Vitest** 
  - 基于 Vite 的单元测试框架
  - 组件测试和单元测试

## 架构模式

### 组件架构

#### 1. 组件分层
```
src/
├── components/           # 公共组件
│   ├── base/            # 基础组件（Button、Input等封装）
│   ├── business/        # 业务组件
│   └── layout/          # 布局组件
├── views/               # 页面视图
├── composables/         # 组合式函数
└── stores/              # Pinia stores
```

#### 2. 组件设计原则
- **单一职责**: 每个组件只负责一个功能
- **可复用性**: 提取通用逻辑到 composables
- **可组合性**: 使用 Composition API 组合功能
- **Props 向下，Events 向上**: 遵循 Vue 数据流

### 状态管理策略

#### 1. 使用 Pinia Stores
```typescript
// stores/user.ts
import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

export const useUserStore = defineStore('user', () => {
  // State
  const user = ref<User | null>(null)
  
  // Getters
  const isLoggedIn = computed(() => !!user.value)
  
  // Actions
  async function login(credentials: Credentials) {
    // ...
  }
  
  return { user, isLoggedIn, login }
})
```

#### 2. 状态分类
- **全局状态**: 使用 Pinia stores（用户信息、主题设置等）
- **组件状态**: 使用 `ref`/`reactive`（表单数据、UI 状态等）
- **URL 状态**: 使用 Vue Router（路由参数、查询参数）

### 样式管理

#### 1. 样式优先级
1. **优先使用 TDesign 组件** - 标准 UI 组件
2. **Tailwind 辅助样式** - 间距、颜色、布局等
3. **CSS Modules** - 组件特定样式（必要时）

#### 2. 响应式设计
- **移动优先**: 使用 Tailwind 的响应式断点
  ```html
  <div class="w-full md:w-1/2 lg:w-1/3">
  ```
- **断点系统**:
  - `sm`: 640px
  - `md`: 768px
  - `lg`: 1024px
  - `xl`: 1280px
  - `2xl`: 1536px

## 开发规范

### 代码风格

#### 1. Vue 组件
```vue
<script setup lang="ts">
import { ref, computed } from 'vue'

// Props 定义
interface Props {
  title: string
  count?: number
}

const props = withDefaults(defineProps<Props>(), {
  count: 0
})

// Emits 定义
interface Emits {
  (e: 'update', value: number): void
  (e: 'close'): void
}

const emit = defineEmits<Emits>()

// 响应式数据
const localCount = ref(props.count)

// 计算属性
const displayText = computed(() => `${props.title}: ${localCount.value}`)

// 方法
function handleClick() {
  localCount.value++
  emit('update', localCount.value)
}
</script>

<template>
  <div class="p-4">
    <t-button @click="handleClick">{{ displayText }}</t-button>
  </div>
</template>
```

#### 2. Composables
```typescript
// composables/useCounter.ts
import { ref, computed } from 'vue'

export function useCounter(initialValue = 0) {
  const count = ref(initialValue)
  const doubled = computed(() => count.value * 2)
  
  function increment() {
    count.value++
  }
  
  function decrement() {
    count.value--
  }
  
  return {
    count,
    doubled,
    increment,
    decrement
  }
}
```

### 命名规范

#### 1. 文件命名
- **组件**: PascalCase - `UserProfile.vue`
- **Composables**: camelCase - `useUserData.ts`
- **Stores**: camelCase - `userStore.ts`
- **工具函数**: camelCase - `formatDate.ts`

#### 2. 变量命名
- **组件**: PascalCase - `UserCard`
- **函数/变量**: camelCase - `getUserInfo`
- **常量**: UPPER_SNAKE_CASE - `API_BASE_URL`
- **类型/接口**: PascalCase - `UserProfile`

### TypeScript 规范

#### 1. 类型定义
```typescript
// types/user.ts
export interface User {
  id: string
  name: string
  email: string
  role: UserRole
}

export enum UserRole {
  Admin = 'admin',
  User = 'user',
  Guest = 'guest'
}

export type UserProfile = Pick<User, 'name' | 'email'>
```

#### 2. Props 类型
- 使用 `interface` 定义 Props 类型
- 使用 `withDefaults` 设置默认值
- 必填 props 不设默认值

## 性能优化

### 1. 组件优化
- **异步组件**: 路由级别代码分割
  ```typescript
  const UserProfile = defineAsyncComponent(() => 
    import('./components/UserProfile.vue')
  )
  ```
- **懒加载**: 按需加载大型组件和库
- **v-memo**: 缓存大列表中的静态内容

### 2. 性能目标
- **首屏加载**: < 3 秒
- **交互响应**: < 100ms
- **包大小**: 主 bundle < 500KB (gzipped)

### 3. 构建优化
- **Tree Shaking**: 移除未使用的代码
- **代码分割**: 按路由拆分 chunks
- **资源压缩**: 图片、字体优化

## 可访问性 (A11y)

### 1. WCAG 2.1 AA 标准
- **语义化 HTML**: 使用正确的 HTML 标签
- **ARIA 标签**: 必要时添加 `aria-*` 属性
- **键盘导航**: 确保所有交互可通过键盘操作
- **颜色对比度**: 文本对比度 ≥ 4.5:1

### 2. TDesign 可访问性
- TDesign 组件已内置基础可访问性支持
- 自定义组件需额外添加 ARIA 属性

## 测试策略

### 1. 单元测试
```typescript
// UserCard.test.ts
import { mount } from '@vue/test-utils'
import { describe, it, expect } from 'vitest'
import UserCard from './UserCard.vue'

describe('UserCard', () => {
  it('renders user name', () => {
    const wrapper = mount(UserCard, {
      props: { name: 'John Doe' }
    })
    expect(wrapper.text()).toContain('John Doe')
  })
})
```

### 2. 测试覆盖率目标
- **关键业务逻辑**: 100%
- **UI 组件**: 80%
- **工具函数**: 90%

## 开发工具

### 1. IDE 配置
- **VSCode**: 推荐 IDE
- **必装插件**:
  - Vue Language Features (Volar)
  - TypeScript Vue Plugin (Volar)
  - Tailwind CSS IntelliSense
  - ESLint
  - Prettier

### 2. 代码质量
- **ESLint**: 代码规范检查
- **Prettier**: 代码格式化
- **Husky**: Git hooks
- **lint-staged**: 提交前检查

## 最佳实践

### 1. 组件设计
✅ **推荐**:
- 使用 `<script setup>` 语法
- Props 使用 TypeScript 接口定义
- 提取可复用逻辑到 composables
- 优先使用 TDesign 组件

❌ **避免**:
- 在组件中直接操作 DOM
- 过深的组件嵌套（> 3 层）
- 大型单文件组件（> 500 行）
- 直接修改 props

### 2. 状态管理
✅ **推荐**:
- 全局状态使用 Pinia
- 组件本地状态使用 ref/reactive
- 组合式 stores 优于 options stores

❌ **避免**:
- 过度使用全局状态
- 在多个组件间传递复杂对象
- 直接修改 store state（应使用 actions）

### 3. 样式管理
✅ **推荐**:
- 优先使用 TDesign 组件默认样式
- 使用 Tailwind 工具类快速开发
- 响应式设计使用 Tailwind 断点

❌ **避免**:
- 覆盖 TDesign 组件的核心样式
- 使用内联样式
- 硬编码颜色值（使用 Tailwind 色板）

## 项目结构示例

```
project-root/
├── .vscode/              # VSCode 配置
├── public/               # 静态资源
├── src/
│   ├── assets/          # 资源文件
│   │   ├── images/
│   │   └── styles/
│   ├── components/      # 组件
│   │   ├── base/       # 基础组件
│   │   ├── business/   # 业务组件
│   │   └── layout/     # 布局组件
│   ├── composables/     # 组合式函数
│   ├── router/          # 路由配置
│   ├── stores/          # Pinia stores
│   ├── types/           # TypeScript 类型
│   ├── utils/           # 工具函数
│   ├── views/           # 页面视图
│   ├── App.vue
│   └── main.ts
├── tests/               # 测试文件
├── .eslintrc.js        # ESLint 配置
├── .prettierrc         # Prettier 配置
├── tailwind.config.js  # Tailwind 配置
├── tsconfig.json       # TypeScript 配置
├── vite.config.ts      # Vite 配置
└── package.json
```

## 参考资源

- [Vue 3 官方文档](https://vuejs.org/)
- [Vite 官方文档](https://vitejs.dev/)
- [Pinia 官方文档](https://pinia.vuejs.org/)
- [TDesign Vue Next 文档](https://tdesign.tencent.com/vue-next/overview)
- [Tailwind CSS 文档](https://tailwindcss.com/)
- [TypeScript 官方文档](https://www.typescriptlang.org/)
