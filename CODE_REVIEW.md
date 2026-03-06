# Ewhat 全面代码审查报告

> 审查日期：2026-03-07
> 审查范围：26 个 Swift 源文件 + 1 个 JSON 数据文件 + Xcode 项目配置

---

## 1. 项目结构完整性

### 文件清单（26/26 齐全）

| 层级 | 文件 | 状态 |
|------|------|------|
| App | `WhatToEatApp.swift` | OK |
| Models | `Food.swift`, `FoodCategory.swift`, `DailyFortune.swift`, `MealRecord.swift` | OK |
| ViewModels | `FortuneViewModel.swift`, `CardViewModel.swift`, `RecordViewModel.swift` | OK |
| Views/Home | `HomeView.swift`, `FortuneCardView.swift`, `DrawCardButton.swift` | OK |
| Views/Card | `CardFlipView.swift`, `CardResultView.swift`, `FoodCardView.swift` | OK |
| Views/Filter | `FilterView.swift`, `TagFlowLayout.swift` | OK |
| Views/Record | `RecordView.swift`, `StatsView.swift` | OK |
| Views/Settings | `SettingsView.swift`, `BlacklistView.swift` | OK |
| Utils | `LunarCalendar.swift`, `WeightedRandom.swift`, `HapticsManager.swift` | OK |
| Theme | `Colors.swift`, `Fonts.swift`, `Animations.swift` | OK |
| Resources | `foods.json`, `Assets.xcassets` | OK |

- ✅ **所有文件齐全**，无缺失。Xcode project.pbxproj 中 26 个 Swift 文件和 2 个资源文件均正确引用，无孤立文件。
- ✅ **目录结构清晰**：App / Models / ViewModels / Views / Utils / Theme / Resources 分层合理。

---

## 2. 数据流检查

### SwiftData Schema -> ViewModel -> View 绑定链路

- ✅ **MealRecord (@Model)** -> `RecordViewModel (@Observable)` -> `HomeView / RecordView` 链路完整。`RecordViewModel` 通过 `modelContext` 执行 CRUD，View 通过 `@State` 持有 ViewModel。
- ✅ **UserPreference (@Model)** -> `@Query` 直接在 View 层获取，`SettingsView` / `BlacklistView` / `HomeView` 均使用 `@Query private var preferences`。
- ✅ **Food (Codable struct)** -> `FoodDatabase.loadAll()` -> `CardViewModel` -> `CardResultView` 链路完整。
- ✅ **DailyFortune (struct)** -> `FortuneViewModel (@Observable)` -> `FortuneCardView` 链路完整。
- ✅ 所有 ViewModel 使用 `@Observable` 宏，View 层使用 `@State` 持有（iOS 17 正确模式）。

### 问题

- ⚠️ **RecordViewModel.modelContext 注入方式脆弱** (`RecordViewModel.swift`)
  - `var modelContext: ModelContext?` 是公开可变的，在 `HomeView.onAppear` 中手动赋值。所有 CRUD 方法通过 `guard let` 静默忽略 nil 的情况，若 modelContext 未注入则操作静默丢失。
  - 建议：改为 `private(set)` 或通过 `init` 注入，添加日志警告。

- ⚠️ **CardViewModel 未传递 favoriteTags 给 WeightedRandom** (`CardViewModel.swift:102-108`)
  - `WeightedRandom.selectFood()` 有 `favoriteTags` 参数（默认空数组），但 `CardViewModel` 从未传递用户配置的偏好标签，导致用户设置的标签偏好对推荐结果**完全无效**。
  - 建议：在 `drawCard()` 中增加 `favoriteTags` 参数并传递。

---

## 3. 导航流程

### 页面跳转拓扑

```
TabView (3 tabs)
├── Tab 0: 首页 (NavigationStack)
│   ├── .sheet -> FilterView (NavigationStack)
│   └── .fullScreenCover -> CardResultView
├── Tab 1: 记录 (NavigationStack)
│   └── NavigationLink -> StatsView
└── Tab 2: 设置 (NavigationStack)
    └── NavigationLink -> BlacklistView
```

- ✅ **TabView 三个 Tab 均包裹在 NavigationStack 中**，符合 iOS 17 最佳实践。
- ✅ **FilterView 以 .sheet 呈现**，有 dismiss 回调。
- ✅ **CardResultView 以 .fullScreenCover 呈现**，有 onDismiss 关闭路径。
- ✅ **StatsView / BlacklistView 通过 NavigationLink 正确推入栈**。

### 问题

- ⚠️ **matchedGeometryEffect 跨 fullScreenCover 无效** (`HomeView.swift:107,241`)
  - `@Namespace` 的 `matchedGeometryEffect` 在 `mainPage` (line 107) 和 `cardResultSheet` (line 241) 之间使用，但 `.fullScreenCover` 使用独立的 window 层级，hero 动画不会触发。
  - 建议：改用 ZStack overlay 替代 fullScreenCover，或移除 matchedGeometryEffect 改为普通转场。

---

## 4. foods.json 数据完整性

- ✅ **201 个食物条目**，超过 200 的最低要求。
- ✅ **所有条目字段完整**：id / name / cuisine / category / tags / scene / priceRange / emoji / funText / rarity 均有值。
- ✅ **ID 格式正确**：全部为小写 UUID，无重复。
- ✅ **枚举值与 Swift 代码完全匹配**：

| 字段 | JSON 值 | Swift 枚举 | 匹配 |
|------|---------|-----------|------|
| cuisine | 川菜/粤菜/湘菜/东北菜/江浙菜/西北菜/日料/韩餐/东南亚/西餐/快餐 | `Cuisine` | ✅ |
| category | 热菜/主食/小吃/汤品/火锅/甜品/烧烤/快餐/凉菜/套餐 | `FoodType` | ✅ |
| scene | 午餐/晚餐/聚餐/夜宵/下午茶/早餐 | `DiningScene` | ✅ |
| priceRange | budget/mid/high/luxury | `PriceRange` | ✅ |
| rarity | common/rare/legendary | `CardRarity` | ✅ |

### 菜系分布

| 菜系 | 数量 | 占比 |
|------|------|------|
| 川菜 | 22 | 10.9% |
| 快餐 | 22 | 10.9% |
| 粤菜 | 21 | 10.4% |
| 东北菜 | 20 | 10.0% |
| 江浙菜 | 20 | 10.0% |
| 湘菜 | 18 | 9.0% |
| 西北菜 | 18 | 9.0% |
| 日料/韩餐/东南亚/西餐 | 各15 | 各7.5% |

### 稀有度分布

| 稀有度 | 数量 | 占比 |
|--------|------|------|
| common | 157 | 78.1% |
| rare | 34 | 16.9% |
| legendary | 10 | 5.0% |

- ✅ 分布合理，legendary 5% 配合权重算法约 1% 实际出现率，符合抽卡体验设计。

### 问题

- ⚠️ **凉菜和套餐类别仅 4 条** — 若用户单独筛选这两个类别，可选范围极为有限。建议后续扩充。

---

## 5. 动画实现审查

### 翻牌动画
- ✅ `CardFlipView` 使用 `rotation3DEffect` Y 轴 0.5 透视，`spring(0.6s, bounce: 0.2)` 手感优秀。
- ✅ 翻转瞬间光晕爆发 (`triggerGlowBurst`)：模糊半径 0→30 + 渐隐，视觉表现丰富。

### 拒绝动画
- ✅ 卡牌向左飞出 offset(-500, -40) + 旋转 -18° + 缩放 0.7，时序 0.3s 合理。
- ✅ 新卡从右侧弹入 offset(400→0) + spring(0.45s)，0.25s 后自动翻转，连贯流畅。

### 确认动画 (Canvas 粒子特效)
- ✅ 60 个粒子，4 种形状（圆/方/星/菱），物理模拟含重力 600pt/s² 和向上偏移。
- ✅ 使用 `Canvas` + `TimelineView(.animation)` 实现，GPU 加速渲染。

### 食运卡片
- ✅ 呼吸浮动 ±5pt (3s 周期) + 光晕边框 0.2→0.55 (2s 周期) + 阴影 6→12pt 脉动。

### 卡牌背面
- ✅ 外光晕呼吸 + 内边框透明度脉动 + 光泽扫过 (120pt 条带，2.5s 周期)。

### 问题

- ⚠️ **粒子特效在旧设备上可能掉帧** (`CardResultView.swift:317-357`)
  - 60 个粒子 × 每帧 transform 计算 × 60-120fps。iPhone XR 等旧设备可能出现卡顿。
  - 建议：减少粒子数至 30-40，或根据设备性能动态调整。

- ⚠️ **DispatchQueue.main.asyncAfter 动画链有状态泄漏风险** (`CardResultView.swift:228,243,272`)
  - 拒绝/确认动画使用多层嵌套 asyncAfter，若 View 在动画期间被 dismiss，闭包仍会执行，可能操作已失效的状态。
  - 建议：使用 `Task { try await Task.sleep }` 替代，支持取消。

---

## 6. Light/Dark Mode 适配

### 已适配项

- ✅ `AppColors.cardBg` 使用 `Color(.systemBackground)`，自动适配。
- ✅ `AppColors.pageBg` 使用 `Color(.secondarySystemBackground)`，自动适配。
- ✅ `WhatToEatApp` 支持用户选择浅色/深色/跟随系统。
- ✅ `FoodCardView` 卡片背景使用 `.systemBackground`。
- ✅ 大量文本使用 `.primary` / `.secondary` 系统语义色。

### 问题

- ⚠️ **主色调全部硬编码 RGB，不随深色模式变化** (`Colors.swift:12-45`)
  - `warmOrange`, `warmAmber`, `warmCoral`, `warmCream`, `warmBrown` 等 15+ 颜色为固定 RGB。
  - 特别是 `warmCream (#FDF5E8)` 在深色模式下几乎不可见（接近白色背景色）。
  - 建议：在 Assets.xcassets 中定义 Light/Dark 变体，或使用 `Color(light:dark:)` 适配器。

- ⚠️ **FilterView / CardBackView 中的 `.white` 硬编码** — 深色模式下白色文字/边框在深色背景上可见性取决于具体层叠关系，但在浅色模式下 `.white.opacity(0.65)` 在白色背景上将不可见。`CardBackView` 的卡牌本身有深色渐变背景，所以其内部白色文字是合适的。

- ⚠️ **SettingsView 的 colorScheme 仅应用于自身** (`SettingsView.swift:142-145`)
  - `.preferredColorScheme()` 在 SettingsView 的 `List` 上设置，但 `WhatToEatApp.swift` 已在根视图设置。两处冗余，且 SettingsView 中的设置范围仅限该页面。
  - 建议：移除 SettingsView 中的 `.preferredColorScheme`，仅保留 App 层级的。

---

## 7. 代码质量

### 命名规范

- ✅ View 命名：`HomeView`, `FilterView`, `CardResultView` 等均使用 PascalCase + View 后缀。
- ✅ ViewModel 命名：`CardViewModel`, `FortuneViewModel`, `RecordViewModel` 清晰一致。
- ✅ 枚举 case 使用 camelCase (`budget`, `mid`, `sichuan`)。
- ✅ 私有属性/方法正确使用 `private`。

### Retain Cycle 风险

- ✅ 所有 ViewModel 为 `@Observable final class`，无 delegate/closure 循环引用。
- ✅ 所有闭包均为非逃逸（`.filter`, `.map` 等）或 SwiftUI 内联闭包，无 retain cycle。

### 错误处理

- ⚠️ **FoodDatabase.loadAll() 静默吞错误** (`Food.swift:60-68`)
  - 两个 `try?` 表达式完全丢弃解码错误。如果 foods.json 有单个格式错误，整个数据库返回 `[]`，无任何日志。
  - 建议：至少添加 `#if DEBUG` 打印错误信息。

- ⚠️ **RecordViewModel CRUD 静默失败** (`RecordViewModel.swift:28,37,46`)
  - `guard let context = modelContext else { return }` 在 modelContext 为 nil 时静默忽略。`try? modelContext?.save()` 静默丢弃保存错误。
  - 建议：添加断言或日志。

- ⚠️ **SwiftData 容器初始化无错误处理** (`WhatToEatApp.swift:16`)
  - `.modelContainer(for:)` 如果初始化失败（数据库损坏、迁移失败），应用直接崩溃。
  - 建议：使用 `do { try } catch` 包裹，失败时提供重置选项。

### Swift 最佳实践

- ⚠️ **未使用 @MainActor** — 三个 ViewModel 均操作 UI 状态且 `RecordViewModel` 访问 SwiftData ModelContext（非线程安全），但均未标记 `@MainActor`。虽然 SwiftUI 事件处理器默认在主线程，但应显式声明。

- ⚠️ **FortuneViewModel 中存在死代码** (`FortuneViewModel.swift:123-131`)
  - `supportingElement(for:)` 私有方法从未被调用。

- ⚠️ **LunarCalendar 中存在死代码** (`LunarCalendar.swift:135`)
  - `dayName(_:)` 中声明了 `tens` 数组但从未使用。

- ⚠️ **CardViewModel 有未使用的 import** (`CardViewModel.swift:2`)
  - `import SwiftData` 但文件中未使用任何 SwiftData 类型。

---

## 8. 潜在编译问题

- ❌ **CardResultView.swipeGesture 返回 Optional Gesture** (`CardResultView.swift:134`)
  ```swift
  private var swipeGesture: some Gesture? {
      guard isFlipped else { return nil }
      return DragGesture()...
  }
  ```
  `some Gesture?` 作为返回类型在 `.gesture()` 修饰符中不合法。SwiftUI 的 `.gesture()` 要求非 Optional 的具体 `Gesture` 类型。**这将导致编译错误。**
  - 修复方案：始终返回 DragGesture，在 `onChanged` / `onEnded` 内部 `guard isFlipped` 提前返回。

- ⚠️ **SettingsView.pref 计算属性在 body 中有副作用** (`SettingsView.swift:10-15`)
  ```swift
  private var pref: UserPreference {
      if let existing = preferences.first { return existing }
      let newPref = UserPreference()
      modelContext.insert(newPref)
      return newPref
  }
  ```
  SwiftUI 可能在单帧内多次求值 `body`，每次调用都会 insert 新的 UserPreference，造成重复数据。
  - 建议：移至 `onAppear` 或使用 `@State` 标志确保只插入一次。

- ⚠️ **HomeView / BlacklistView 的 UserPreference 孤儿对象** (`HomeView.swift:17`, `BlacklistView.swift:11-13`)
  ```swift
  private var pref: UserPreference { preferences.first ?? UserPreference() }
  ```
  当 `preferences` 为空时创建的 `UserPreference()` 未插入 modelContext，对其的任何修改都会丢失。
  - 建议：统一使用与 SettingsView 相同的插入逻辑，或抽取共享初始化方法。

- ⚠️ **FilterView 中 HapticsManager.self != nil 永远为 true** (`FilterView.swift:150`)
  - `HapticsManager.self` 是元类型，永远不为 nil。应检查 `pref.hapticsEnabled`，但 FilterView 无法访问 UserPreference。
  - 建议：将 `hapticsEnabled` 作为参数传入 FilterView。

- ⚠️ **RecordView 中多处 Force Unwrap** (`RecordView.swift:51,60,182-183,235-236`)
  - `Calendar.date(byAdding:...)!` 和 `Calendar.date(from:...)!` 虽然实际极少返回 nil，但 force unwrap 在极端 locale 设置下有崩溃风险。

- ⚠️ **FoodCategory.swift: CardRarity / FiveElement 缺少 Identifiable** (`FoodCategory.swift:135,167`)
  - 其他枚举（Cuisine, FoodType, DiningScene, PriceRange）均遵守 Identifiable，但 CardRarity 和 FiveElement 未遵守。如在 SwiftUI ForEach 中使用将编译报错。

- ⚠️ **RecordView 中 DateFormatter 频繁创建** (`RecordView.swift:220-229`)
  - `monthYearString` 和 `selectedDateString` 每次访问都创建新 DateFormatter 实例。DateFormatter 创建开销大。
  - 建议：改为 `static let`。

---

## 无障碍 (Accessibility)

- ⚠️ **所有字体使用固定 size，不支持 Dynamic Type** (`Fonts.swift`)
  - 用户在系统设置中调大字体不会生效。建议使用 `Font.system(.body, design:)` 或 `.relativeTo()` 适配。

- ⚠️ **永久循环动画未检查 reduceMotion** (`Animations.swift:17,20,35`)
  - `breathe`, `fortuneFloat`, `shimmer` 均使用 `.repeatForever()`，不尊重 `accessibilityReduceMotion` 设置。
  - 建议：包裹 `@Environment(\.accessibilityReduceMotion)` 条件判断。

- ⚠️ **CardResultView 滑动手势与 VoiceOver 冲突** (`CardResultView.swift:134-147`)
  - 自定义 DragGesture 会与 VoiceOver 导航手势冲突。底部按钮可作为替代输入方式。

---

## 总结

| 类型 | 数量 |
|------|------|
| ❌ 严重问题（编译阻塞） | 1 |
| ⚠️ 高优先级（功能/数据缺陷） | 5 |
| ⚠️ 中优先级（代码质量/性能） | 12 |
| ⚠️ 低优先级（规范/无障碍） | 8 |
| ✅ 通过项 | 26+ |

### ❌ 严重问题（必须修复）

1. **`CardResultView.swipeGesture` 返回 `some Gesture?` — 编译错误** — 需改为非 Optional 返回类型并在闭包内部 guard。

### ⚠️ 高优先级建议修复

2. **SettingsView.pref 计算属性副作用** — body 多次求值会创建重复 UserPreference。
3. **HomeView / BlacklistView 孤儿 UserPreference** — 新建对象未持久化，修改丢失。
4. **CardViewModel 未传递 favoriteTags** — 用户标签偏好完全无效。
5. **matchedGeometryEffect 跨 fullScreenCover 无效** — hero 转场不会执行。
6. **FilterView haptics 检查逻辑错误** — 永远触发震动，无视用户设置。
