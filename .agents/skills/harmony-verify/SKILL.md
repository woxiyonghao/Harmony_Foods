---
name: harmony-verify
description: >-
  Automated verification system for HarmonyOS ArkTS/ArkUI applications.
  Validates ArkUI reactivity cycles, infinite loops in @Watch and AppStorage,
  runs automated logic unit tests, checks dark mode UX compliance, and verifies
  compilation packaging beyond just basic build success.
---

# HarmonyOS Automated Quality & Runtime Verifier Skill

本 Skill 为 HarmonyOS (ArkTS / ArkUI) 移动应用提供全方位的自动化验证、质量防御与运行时死锁检测体系。避免仅依靠“hvigorw 编译成功”，而是从静态响应式依赖、核心计算逻辑与包体打包三方面进行端到端闭环验证。

## 适用场景

- 修改了 `@StorageLink`、`@StorageProp`、`@State`、`@Watch` 等 ArkUI 响应式状态时；
- 进行了页面间数据联动、二级页面返回刷新、`Tabs` 缓存更新设计时；
- 调整了数据库读写（`relationalStore`、`FoodDBHelper`）逻辑时；
- 更新了营养学计算、健康评分公式或慢病限制规则时；
- 需要在交付前一键运行全链路自动化质量检查时。

## 验证项目三步法

### 1. 静态响应式依赖与死循环防御审查 (`scripts/audit_reactivity.js`)
扫描源码排查常见但隐蔽的 ArkUI 架构陷阱：
- **Getter 函数纯洁性**：严禁在 `getUserProfile`、`getFoods` 等只读数据查询方法中调用 `AppStorage.setOrCreate`。这类副作用会在订阅组件监听到变化后再次调用 Getter，形成剧烈死循环并导致 CPU 跑满、界面卡死闪退。
- **@StorageLink 自循环回写拦截**：严禁在 `@Watch` 回调函数中直接给自身绑定的 `@StorageLink` 变量赋值。这会导致组件向 AppStorage 产生连锁回写。
- **监听器去重与性能**：检查同一个处理方法是否被多个 `@Watch` 重复绑定，避免单次更新被放大为多次重复查询。
- **深色模式白底白字检查**：检查所有 `TextInput` 与 `Search` 组件是否显式配置了 `.fontColor()` 与 `.placeholderColor()`。

### 2. 核心业务逻辑与无死锁自动化单元测试 (`scripts/test_logic.js`)
- **宏量供能比计算测试**：覆盖减重、增肌、痛风尿酸、控盐高血压等多种目标下的蛋白质、碳水与脂肪克数算法。
- **健康评分加权与标签联动测试**：验证在“已调高风险指标”模式及配置“高尿酸/高血压”慢病标签时，扣分更严苛、警戒阈值更紧缩的业务规则。
- **深拷贝对象隔离测试**：验证 `cloneUserProfile` 彻底切断引用共享，避免修改二级页面时无意污染全局内存对象。
- **单向数据流与防死锁仿真测试**：模拟组件监听 AppStorage 版本号变更，验证在接收到版本信号后只执行单次纯读查询，不产生二次级联回写。

### 3. DevEco 编译与 HAP 打包验证 (`scripts/verify.sh`)
- 自动定位 SDK 环境并调用 `/Applications/DevEco-Studio.app/Contents/tools/hvigor/bin/hvigorw assembleHap` 进行编译与签名打包。

## 执行方式

在工程根目录运行：
```bash
bash .agents/skills/harmony-verify/scripts/verify.sh
```
或单独运行指定审查项：
```bash
node .agents/skills/harmony-verify/scripts/audit_reactivity.js
node .agents/skills/harmony-verify/scripts/test_logic.js
```
