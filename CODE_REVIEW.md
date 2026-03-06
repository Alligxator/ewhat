# Ewhat 全面代码审查报告 v2

> 审查日期：2026-03-07（第二轮）
> 审查范围：26 个 Swift 源文件 + 1 个 JSON 数据文件 + Xcode 项目配置
> 上轮修复：6 项（1 编译阻塞 + 5 高优先级），均已验证通过

---

## 1. 项目结构完整性

### 文件清单（26/26 齐全）

| 层级 | 文件 | 状态 |
|------|------|------|
| App | `WhatToEatApp.swift` | OK |
| Models | `Food.swift`, `FoodCategory.swift`, `DailyFortune.swift`, `MealRecord.swift` | OK |
| ViewModels | `FortuneViewModel.swift`, `CardViewModel.swift`, `RecordViewModel.swift` | OK |
| Views/Home | `HomeView.swift`, `FortuneCardView.swift`, `DrawCardButton.swift` | OK |
| Views/Card | `CardFlipView.swift` (含 `CardBackView`), `CardResultView.swift`, `FoodCardView.swift` | OK |
| Views/Filter | `FilterView.swift`, `TagFlowLayout.swift` | OK |
| Views/Record | `RecordView.swift`, `StatsView.swift` | OK |
| Views/Settings | `SettingsView.swift`, `BlacklistView.swift` | OK |
| Utils | `LunarCalendar.swift`, `WeightedRandom.swift`, `HapticsManager.swift` | OK |
| Theme | `Colors.swift`, `Fonts.swift`, `Animations.swift` | OK |
| Resources | `foods.json`, `Assets.xcassets` | OK |

- ✅ 所有文件齐全，无缺失。Xcode project.pbxproj 中 26 个 Swift 文件和 2 个资源文件均正确引用。
- ✅ 目录结构清晰：App / Models / ViewModels / Views / Utils / Theme / Resources 分层合理。

---

## 2. 上轮修复验证

> commit `1d8bb87` — "fix: resolve 6 high-priority bugs from code review"

| # | 问题 | 状态 | 验证 |
|---|------|------|------|
| 1 | `CardResultView.swipeGesture` 返回 `some Gesture?` 编译错误 | ✅ 已修复 | 改为 `some Gesture`，`guard isFlipped` 移入闭包 |
| 2 | `SettingsView.pref` 计算属性副作用（重复 insert） | ✅ 已修复 | `pref` 纯读取，`ensurePreference()` 在 `.onAppear` 单次插入 |
| 3 | `HomeView` / `BlacklistView` 孤儿 UserPreference | ✅ 已修复 | 两处均添加 `ensurePreference()` |
| 4 | `CardViewModel` 未传递 `favoriteTags` | ✅ 已修复 | `drawCard()` / `rejectAndDrawNext()` 新增参数，调用链完整 |
| 5 | `matchedGeometryEffect` 跨 `fullScreenCover` 无效 | ✅ 已修复 | 改为 ZStack overlay，hero 动画在同一视图层级内 |
| 6 | `FilterView` haptics `HapticsManager.self != nil` 恒 true | ✅ 已修复 | 新增 `hapticsEnabled` 参数，由 `HomeView` 传入用户偏好 |

---

## 3. 数据流检查

### SwiftData Schema -> ViewModel -> View 绑定链路

- ✅ **MealRecord (@Model)** -> `RecordViewModel (@Observable)` -> `HomeView / RecordView` 链路完整。
- ✅ **UserPreference (@Model)** -> `@Query` 直接在 View 层获取，三处视图（`SettingsView` / `BlacklistView` / `HomeView`）均使用 `ensurePreference()` 保证对象存在。
- ✅ **Food (Codable struct)** -> `FoodDatabase.loadAll()` -> `CardViewModel` -> `CardResultView` 链路完整。
- ✅ **DailyFortune (struct)** -> `FortuneViewModel (@Observable)` -> `FortuneCardView` 链路完整。
- ✅ **favoriteTags** 从 `UserPreference.favoriteTags` -> `HomeView.startDraw()` / `onReject` -> `CardViewModel.drawCard()` -> `WeightedRandom.selectFood()` 链路已打通。
- ✅ **hapticsEnabled** 从 `UserPreference.hapticsEnabled` -> `HomeView` -> `FilterView.hapticsEnabled` 链路正确。
- ✅ 所有 ViewModel 使用 `@Observable` 宏，View 层使用 `@State` 持有（iOS 17 正确模式）。

### 遗留问题

- ⚠️ **RecordViewModel.modelContext 注入方式脆弱** (`RecordViewModel.swift:22`)
  - `var modelContext: ModelContext?` 公开可变，在 `HomeView.onAppear` 手动赋值。所有 CRUD 方法通过 `guard let` 静默忽略 nil，若未注入则操作静默丢失。
  - 建议：改为 `private(set)` 或 `init` 注入，添加断言/日志。

---

## 4. 导航流程

### 页面跳转拓扑（更新后）

```
ZStack (根视图)
├── TabView (3 tabs)
│   ├── Tab 0: 首页 (NavigationStack)
│   │   └── .sheet -> FilterView (NavigationStack)
│   ├── Tab 1: 记录 (NavigationStack)
│   │   └── NavigationLink -> StatsView (.sheet)
│   └── Tab 2: 设置 (NavigationStack)
│       ├── NavigationLink -> 偏好菜系列表
│       ├── NavigationLink -> 偏好标签列表
│       ├── NavigationLink -> BlacklistView
│       └── NavigationLink -> 菜系黑名单列表
└── if showCardResult: CardResultView (ZStack overlay, zIndex: 1)
    └── matchedGeometryEffect("cardHero") ← 与首页卡牌共享
```

- ✅ **TabView 三个 Tab 均包裹在 NavigationStack 中**，符合 iOS 17 最佳实践。
- ✅ **CardResultView 改为 ZStack overlay**，`matchedGeometryEffect` 在同一视图层级内生效。
- ✅ **FilterView 以 .sheet 呈现**，传入 `hapticsEnabled` 参数。
- ✅ **所有子页面导航正确**，dismiss 路径完整。

---

## 5. foods.json 数据完整性

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

## 6. 动画实现审查

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

### Hero 转场（修复后）
- ✅ `matchedGeometryEffect("cardHero")` 在 `mainPage` 和 `cardResultSheet` 之间通过 ZStack overlay 正确共享命名空间，hero 动画可正常触发。

### 问题

- ⚠️ **粒子特效在旧设备上可能掉帧** (`CardResultView.swift:317-357`)
  - 60 粒子 × 每帧 transform × 60-120fps。iPhone XR 等旧设备可能卡顿。
  - 建议：根据 `ProcessInfo.thermalState` 动态降至 30-40 粒子。

- ⚠️ **DispatchQueue.main.asyncAfter 动画链有状态泄漏风险** (`CardResultView.swift:228,243,272`)
  - 拒绝/确认动画使用多层嵌套 asyncAfter，若 View 在动画期间被 dismiss，闭包仍会执行。
  - 建议：改用 `Task { try await Task.sleep }` 配合 `task(id:)` 支持自动取消。

---

## 7. Light/Dark Mode 适配

### 已适配项

- ✅ `AppColors.cardBg` 使用 `Color(.systemBackground)`，自动适配。
- ✅ `AppColors.pageBg` 使用 `Color(.secondarySystemBackground)`，自动适配。
- ✅ `WhatToEatApp` 支持用户选择浅色/深色/跟随系统。
- ✅ `FoodCardView` 卡片背景使用 `.systemBackground`。
- ✅ 大量文本使用 `.primary` / `.secondary` 系统语义色。
- ✅ `CardStyle` ViewModifier 使用 `Color(.systemBackground)`。

### 问题

- ⚠️ **主色调全部硬编码 RGB，不随深色模式变化** (`Colors.swift:12-46`)
  - `warmOrange`, `warmAmber`, `warmCoral`, `warmCream`, `warmBrown` 等 15+ 颜色为固定 RGB。
  - 特别是 `warmCream (#FDF5E8)` 在深色模式下几乎不可见（接近白色背景色）。
  - 建议：在 Assets.xcassets 中定义 Light/Dark 变体，或使用条件色。

- ⚠️ **SettingsView 的 colorScheme 与 App 层级冗余** (`SettingsView.swift:140-143`)
  - `.preferredColorScheme()` 在 SettingsView 的 `List` 上设置，但 `WhatToEatApp.swift:11-14` 已在根视图设置。
  - 两处同时读取 `@AppStorage("colorSchemePreference")`，功能重叠。
  - 建议：移除 SettingsView 中的 `.preferredColorScheme`，仅保留 App 层级。

---

## 8. 代码质量

### 命名规范

- ✅ View 命名：PascalCase + View 后缀，一致清晰。
- ✅ ViewModel 命名：PascalCase + ViewModel 后缀。
- ✅ 枚举 case 使用 camelCase。
- ✅ 私有属性/方法正确使用 `private`。

### Retain Cycle 风险

- ✅ 所有 ViewModel 为 `@Observable final class`，无 delegate/closure 循环引用。
- ✅ 所有闭包均为非逃逸或 SwiftUI 内联闭包，无 retain cycle。
- ✅ `CardResultView` 是 struct（值类型），`DispatchQueue.main.asyncAfter` 闭包中捕获的 `self` 不会造成 retain cycle。

### 错误处理

- ⚠️ **FoodDatabase.loadAll() 静默吞错误** (`Food.swift:60-67`)
  - 两处 `try?` 丢弃解码错误。foods.json 格式错误时整个数据库返回 `[]`，无日志。
  - 建议：至少 `#if DEBUG print(error)` 或使用 `os_log`。

- ⚠️ **RecordViewModel CRUD 静默失败** (`RecordViewModel.swift:28,37,46,55`)
  - `guard let context = modelContext else { return }` 静默忽略。`try? modelContext?.save()` 丢弃保存错误。
  - 建议：添加 `assertionFailure` 或 `os_log`。

- ⚠️ **SwiftData 容器初始化无错误处理** (`WhatToEatApp.swift:16`)
  - `.modelContainer(for:)` 如果初始化失败（数据库损坏），应用直接崩溃。
  - 建议：`do { try } catch` 包裹，失败时重建空数据库。

### Force Unwrap 风险

全项目共有 **14 处** `!` 强制解包，集中在 Calendar 日期计算，按文件统计：

| 文件 | 行号 | 表达式 |
|------|------|--------|
| `RecordViewModel.swift` | 82 | `cal.date(byAdding: .day, value: -days, to: .now)!` |
| `RecordViewModel.swift` | 93 | `cal.date(byAdding: .day, value: 1, to: startOfDay)!` |
| `RecordViewModel.swift` | 97 | `cal.date(from: ...)!` (startOfWeek) |
| `RecordViewModel.swift` | 98 | `cal.date(byAdding: .day, value: 7, to: ...)!` |
| `RecordViewModel.swift` | 102 | `cal.date(from: ...)!` (startOfMonth) |
| `RecordViewModel.swift` | 103 | `cal.date(byAdding: .month, value: 1, to: ...)!` |
| `RecordViewModel.swift` | 189 | `cal.date(byAdding: .day, value: 1, to: start)!` |
| `RecordView.swift` | 51 | `Calendar.current.date(byAdding: .month, value: -1, ...)!` |
| `RecordView.swift` | 60 | `Calendar.current.date(byAdding: .month, value: 1, ...)!` |
| `RecordView.swift` | 182 | `cal.date(from: ...)!` (startOfWeek) |
| `RecordView.swift` | 183 | `cal.date(byAdding: .day, value: 7, ...)!` |
| `RecordView.swift` | 235 | `cal.date(from: comps)!` (firstOfMonth) |
| `RecordView.swift` | 237 | `cal.range(of:in:for:)!.count` |
| `StatsView.swift` | 16, 19 | `cal.date(from: ...)!` (startOfWeek/Month) |
| `MealRecord.swift` | 167 | `calendar.date(byAdding:)!` (todayPredicate) |

- 实际崩溃风险极低（Calendar 日期加减在标准 Locale 下不会返回 nil），但在极端系统设置下仍有理论风险。
- 建议：统一使用 `guard let ... else { return }` 模式替代。

### 线程安全

- ⚠️ **三个 ViewModel 未标记 @MainActor** (`CardViewModel`, `FortuneViewModel`, `RecordViewModel`)
  - 均操作 UI 状态，`RecordViewModel` 还访问 SwiftData `ModelContext`（非线程安全）。
  - SwiftUI 事件处理器默认在主线程，但应显式声明确保安全。
  - 建议：添加 `@MainActor` 标记。

### 死代码

- ⚠️ **FortuneViewModel.supportingElement(for:)** (`FortuneViewModel.swift:123-131`)
  - 私有方法，从未被调用。
  - 建议：删除，或在食运算法中使用五行相生逻辑。

- ⚠️ **LunarCalendar.dayName() 中 `tens` 数组** (`LunarCalendar.swift:135`)
  - `let tens = ["初", "十", "廿", "三十"]` 已声明但从未引用，代码直接使用字面量。
  - 建议：删除 `tens` 或改用 `tens[index]` 访问。

### 未使用的 Import

- ⚠️ **CardViewModel.swift:2** — `import SwiftData` 但文件中未使用任何 SwiftData 类型。

### 性能

- ⚠️ **RecordView 中 DateFormatter 频繁创建** (`RecordView.swift:220-229`)
  - `monthYearString` 和 `selectedDateString` 每次计算都创建新 `DateFormatter`。
  - `DateFormatter` 创建开销较大（Apple 文档建议缓存复用）。
  - 建议：改为 `static let` 或 `nonisolated(unsafe) static let`。

- ⚠️ **FoodDatabase.loadAll() 在多处重复调用** (`CardViewModel.init`, `BlacklistView.onAppear`, `SettingsView.body`)
  - 每次调用都重新解析 JSON。`SettingsView.body` 中的调用（line 133）在每次重绘时触发。
  - 建议：在 `FoodDatabase` 中使用 `static let` 缓存结果。

---

## 9. 编译兼容性

- ✅ **所有已知编译阻塞问题已修复**（上轮 Fix 1）。
- ✅ **`some Gesture`** 返回类型正确。
- ✅ **所有方法签名一致**：`drawCard()` / `rejectAndDrawNext()` 参数匹配调用站。
- ✅ **FilterView 初始化参数**：`hapticsEnabled` 有默认值 `= true`，向后兼容。

### 遗留类型问题

- ⚠️ **CardRarity / FiveElement 缺少 Identifiable 遵守** (`FoodCategory.swift:135,167`)
  - 其他枚举（Cuisine, FoodType, DiningScene, PriceRange）均遵守 Identifiable，但 CardRarity 和 FiveElement 未遵守。
  - 当前无 SwiftUI `ForEach` 直接迭代这两个枚举，故不影响编译。但未来使用时会报错。
  - 建议：添加 `Identifiable` 遵守和 `var id: String { rawValue }`。

---

## 10. 无障碍 (Accessibility)

- ⚠️ **所有字体使用固定 size，不支持 Dynamic Type** (`Fonts.swift`)
  - 全部使用 `Font.system(size:)` 固定尺寸。用户在系统设置中调大字体不会生效。
  - 建议：使用 `Font.system(.body, design:)` 或 `.relativeTo(.body)` 适配。

- ⚠️ **永久循环动画未检查 reduceMotion** (`Animations.swift:17,20,35`)
  - `breathe`, `fortuneFloat`, `shimmer` 使用 `.repeatForever()`，不尊重 `accessibilityReduceMotion`。
  - 建议：在使用处包裹 `@Environment(\.accessibilityReduceMotion)` 条件判断。

- ⚠️ **缺少 accessibilityLabel** — 多处交互元素无语义标签
  - `DrawCardButton`、`FortuneCardView`、`calendarDayCell` 等缺少 VoiceOver 友好标签。
  - 建议：为关键交互元素添加 `.accessibilityLabel()` 和 `.accessibilityHint()`。

---

## 总结

### 修复前 vs 修复后

| 类型 | v1 | v2（当前） | 变化 |
|------|----|----|------|
| ❌ 编译阻塞 | 1 | **0** | -1 ✅ |
| ⚠️ 高优先级 | 5 | **0** | -5 ✅ |
| ⚠️ 中优先级 | 12 | **10** | -2 |
| ⚠️ 低优先级 | 8 | **8** | 0 |
| ✅ 通过项 | 26+ | **32+** | +6 |

### 当前状态：✅ 无编译阻塞、无高优先级问题

所有影响编译和核心功能的问题均已修复。剩余为代码健壮性和规范类建议。

### ⚠️ 中优先级（建议修复）

1. **RecordViewModel.modelContext 注入方式脆弱** — 公开可变，无防护
2. **14 处 Calendar force unwrap** — 理论崩溃风险（RecordViewModel / RecordView / StatsView / MealRecord）
3. **ViewModel 未标记 @MainActor** — 线程安全缺失
4. **FoodDatabase.loadAll() 静默吞错误** — JSON 解析失败无日志
5. **RecordViewModel CRUD 静默失败** — save/fetch 错误被 `try?` 吞掉
6. **DispatchQueue.main.asyncAfter 状态泄漏** — View dismiss 后闭包仍执行
7. **主色调硬编码 RGB 不适配深色模式** — warmCream 在深色模式下几乎不可见
8. **SettingsView .preferredColorScheme 冗余** — 与 App 层级重复
9. **FoodDatabase.loadAll() 多处重复调用** — JSON 每次重新解析
10. **DateFormatter 频繁创建** — RecordView 每次计算属性都 new

### ⚠️ 低优先级（规范/无障碍/优化）

1. FortuneViewModel 死代码 `supportingElement(for:)`
2. LunarCalendar 死代码 `tens` 数组
3. CardViewModel 未使用的 `import SwiftData`
4. CardRarity / FiveElement 缺少 Identifiable
5. SwiftData 容器初始化无错误处理
6. 字体不支持 Dynamic Type
7. 永久循环动画不尊重 reduceMotion
8. 缺少 VoiceOver accessibilityLabel
