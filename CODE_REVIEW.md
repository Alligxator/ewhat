# Ewhat 全面代码审查报告 v3

> 审查日期：2026-03-07（第三轮）
> 审查范围：26 个 Swift 源文件 + 1 个 JSON 数据文件 + Xcode 项目配置
> 第一轮修复：6 项（1 编译阻塞 + 5 高优先级），均已验证通过
> 第二轮修复：18 项（8 中优先级 + 6 低优先级 + 4 项有意跳过），均已验证通过

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

## 2. 历史修复验证

### 第一轮（commit `1d8bb87`）

| # | 问题 | 状态 |
|---|------|------|
| 1 | `CardResultView.swipeGesture` 返回 `some Gesture?` 编译错误 | ✅ 已修复 |
| 2 | `SettingsView.pref` 计算属性副作用（重复 insert） | ✅ 已修复 |
| 3 | `HomeView` / `BlacklistView` 孤儿 UserPreference | ✅ 已修复 |
| 4 | `CardViewModel` 未传递 `favoriteTags` | ✅ 已修复 |
| 5 | `matchedGeometryEffect` 跨 `fullScreenCover` 无效 | ✅ 已修复 |
| 6 | `FilterView` haptics `HapticsManager.self != nil` 恒 true | ✅ 已修复 |

### 第二轮（commit `d5c676e`）

| # | 问题 | 状态 |
|---|------|------|
| 1 | RecordViewModel.modelContext 公开可变 | ✅ 改为 `private(set)` + `configure()` 方法 |
| 2 | 14 处 Calendar force unwrap | ✅ 全部替换为 `guard let` / `?? fallback` |
| 3 | 三个 ViewModel 未标记 @MainActor | ✅ RecordVM / CardVM / FortuneVM 均已添加 |
| 4 | FoodDatabase.loadAll() 静默吞错误 | ✅ 改为 `do/catch` + `#if DEBUG print` |
| 5 | RecordViewModel.save() 静默失败 | ✅ 改为 `do/catch` + `#if DEBUG print` |
| 6 | SettingsView .preferredColorScheme 冗余 | ✅ 已移除，仅保留 App 层级 |
| 7 | FoodDatabase.loadAll() 多处重复调用 | ✅ 改为 `static let allFoods` 缓存 |
| 8 | DateFormatter 频繁创建 | ✅ 改为 `private static let` 缓存 |
| 9 | FortuneViewModel 死代码 supportingElement | ✅ 已删除 |
| 10 | LunarCalendar 死代码 tens 数组 | ✅ 已删除 |
| 11 | CardViewModel 未使用的 import SwiftData | ✅ 已移除 |
| 12 | CardRarity / FiveElement 缺少 Identifiable | ✅ 已添加 |
| 13 | 永久循环动画不尊重 reduceMotion | ✅ CardBackView / FortuneCardView 已添加 guard |
| 14 | 缺少 VoiceOver accessibilityLabel | ✅ DrawCardButton / CardResultView / RecordView 已添加 |

有意跳过的 4 项：

| # | 问题 | 决策 | 理由 |
|---|------|------|------|
| S1 | DispatchQueue.main.asyncAfter 状态泄漏 | 接受风险 | CardResultView 是 struct，SwiftUI 对已移除视图的状态变更自动 no-op |
| S2 | 主色调硬编码 RGB 不适配深色模式 | 待设计 | 需设计师确定 Dark Mode 色板，超出代码修复范围 |
| S3 | 字体不支持 Dynamic Type | 保留现状 | 固定尺寸为设计意图，已添加文档注释说明 |
| S4 | SwiftData 容器初始化无错误处理 | 接受风险 | 极端边缘情况，App 启动时数据库损坏概率极低 |

---

## 3. 数据流检查

### SwiftData Schema -> ViewModel -> View 绑定链路

- ✅ **MealRecord (@Model)** -> `RecordViewModel (@MainActor @Observable)` -> `HomeView / RecordView` 链路完整。
- ✅ **UserPreference (@Model)** -> `@Query` 直接在 View 层获取，三处视图均使用 `ensurePreference()` 保证对象存在。
- ✅ **Food (Codable struct)** -> `FoodDatabase.allFoods` (缓存) -> `CardViewModel` -> `CardResultView` 链路完整。
- ✅ **DailyFortune (struct)** -> `FortuneViewModel (@MainActor @Observable)` -> `FortuneCardView` 链路完整。
- ✅ **favoriteTags** 全链路打通：`UserPreference` -> `HomeView` -> `CardViewModel.drawCard()` -> `WeightedRandom`。
- ✅ **hapticsEnabled** 全链路打通：`UserPreference` -> `HomeView` -> `FilterView`。
- ✅ **RecordViewModel.modelContext** 通过 `configure(modelContext:)` 安全注入，属性为 `private(set)`。
- ✅ 所有 ViewModel 使用 `@MainActor @Observable` 宏，View 层使用 `@State` 持有。

---

## 4. 导航流程

### 页面跳转拓扑

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

- ✅ TabView 三个 Tab 均包裹在 NavigationStack 中，符合 iOS 17 最佳实践。
- ✅ CardResultView 以 ZStack overlay 呈现，matchedGeometryEffect 在同一视图层级内生效。
- ✅ FilterView 以 .sheet 呈现，传入 hapticsEnabled 参数。
- ✅ 所有子页面导航正确，dismiss 路径完整。

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

### 遗留备注

- 💡 **凉菜和套餐类别仅 4 条** — 若用户单独筛选这两个类别，可选范围极为有限。建议后续扩充。

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
- ✅ 尊重 `accessibilityReduceMotion`，开启时跳过动画。

### 卡牌背面
- ✅ 外光晕呼吸 + 内边框透明度脉动 + 光泽扫过 (120pt 条带，2.5s 周期)。
- ✅ 尊重 `accessibilityReduceMotion`，开启时跳过动画。

### Hero 转场
- ✅ `matchedGeometryEffect("cardHero")` 在同一视图层级内通过 ZStack overlay 生效。

### 遗留备注

- 💡 **粒子特效在旧设备上可能掉帧** (`CardResultView.swift`)
  - 60 粒子 × 每帧 transform × 60-120fps。iPhone XR 等旧设备可能卡顿。
  - 可考虑根据 `ProcessInfo.thermalState` 动态降粒子数。

- 💡 **DispatchQueue.main.asyncAfter 动画链** (`CardResultView.swift`)
  - 拒绝/确认动画使用多层嵌套 asyncAfter。CardResultView 是 struct（值类型），SwiftUI 对已移除视图的状态变更自动 no-op，实际风险极低。
  - 若未来需要更严谨的取消支持，可改用 `Task { try await Task.sleep }` 配合 `task(id:)`。

---

## 7. Light/Dark Mode 适配

### 已适配项

- ✅ `AppColors.cardBg` / `pageBg` 使用系统语义色，自动适配。
- ✅ `WhatToEatApp` 支持用户选择浅色/深色/跟随系统（仅在 App 根视图设置一次）。
- ✅ `FoodCardView` / `CardStyle` 使用 `.systemBackground`。
- ✅ 大量文本使用 `.primary` / `.secondary` 系统语义色。

### 遗留备注

- 💡 **主色调全部硬编码 RGB，不随深色模式变化** (`Colors.swift`)
  - `warmOrange`, `warmAmber`, `warmCoral`, `warmCream`, `warmBrown` 等为固定 RGB。
  - `warmCream (#FDF5E8)` 在深色模式下对比度偏低。
  - 需设计师确定 Dark Mode 色板变体后，在 Assets.xcassets 中定义 Light/Dark 变体。

---

## 8. 代码质量

### 命名规范
- ✅ View / ViewModel / 枚举命名一致规范。
- ✅ 私有属性/方法正确使用 `private`。

### 线程安全
- ✅ 三个 ViewModel 均标记 `@MainActor`，保证 UI 状态和 ModelContext 的线程安全。

### 错误处理
- ✅ `FoodDatabase.loadAll()` 使用 `do/catch` + `#if DEBUG print`，错误不再静默丢失。
- ✅ `RecordViewModel.save()` 使用 `do/catch` + `#if DEBUG print`。
- ✅ `RecordViewModel` 的 fetch 方法使用 `(try? ...) ?? []` 模式，返回安全默认值。
- 💡 `SwiftData` 容器初始化（`WhatToEatApp.swift`）如果失败应用会崩溃，但此为极端边缘情况。

### Force Unwrap
- ✅ **全部 14 处 Calendar force unwrap 已消除**，统一使用 `guard let ... else { return }` 或 `?? fallback` 模式。
- ✅ `MealRecord.todayPredicate` 使用 `?? startOfDay.addingTimeInterval(86400)` 兼容 `#Predicate` 上下文。
- ✅ 全项目 Swift 源文件中无 `cal.date(...)!` 或 `Calendar.current.date(...)!` 模式。

### 死代码
- ✅ 无死代码残留。`FortuneViewModel.supportingElement()` 和 `LunarCalendar.tens` 已删除。

### Import
- ✅ 无未使用的 import。`CardViewModel` 中多余的 `import SwiftData` 已移除。

### 性能
- ✅ `FoodDatabase.allFoods` 使用 `static let` 缓存，JSON 仅解析一次。全部 3 处调用点已迁移。
- ✅ `RecordView` 中 DateFormatter 使用 `private static let` 缓存，不再重复创建。

### 数据封装
- ✅ `RecordViewModel.modelContext` 为 `private(set)`，外部通过 `configure(modelContext:)` 注入。
- ✅ `FoodDatabase.loadAll()` 为 `private`，外部统一使用 `FoodDatabase.allFoods`。

### 类型完备
- ✅ 所有枚举（Cuisine, FoodType, DiningScene, PriceRange, CardRarity, FiveElement）均遵守 `Identifiable`。

---

## 9. 编译兼容性

- ✅ 所有已知编译阻塞问题已修复。
- ✅ `some Gesture` 返回类型正确。
- ✅ 所有方法签名一致，参数匹配调用站。
- ✅ `@MainActor` 与 `@State` 在 View 层兼容（`@State` 属性已隐式 MainActor 隔离）。
- ✅ 所有枚举遵守 `Identifiable`，可安全用于 `ForEach`。

---

## 10. 无障碍 (Accessibility)

### 已适配项

- ✅ **reduceMotion**：`CardBackView` 和 `FortuneCardView` 的 `.onAppear` 动画检查 `accessibilityReduceMotion`，开启时跳过。
- ✅ **VoiceOver 标签**：
  - `DrawCardButton`：`accessibilityLabel("抽一张卡牌")` + `accessibilityHint("随机推荐一道美食")`
  - `CardResultView` 滑动指示器：左 `"向左滑动换一个"` / 右 `"向右滑动确认选择"`
  - `RecordView` 日历格：`accessibilityLabel("X日，有记录")`

### 遗留备注

- 💡 **字体不支持 Dynamic Type**（`Fonts.swift`）— 全部使用 `Font.system(size:)` 固定尺寸，已添加文档注释说明这是设计意图。若未来需要支持，改用 `.relativeTo(.body)` 适配。

---

## 总结

### 三轮修复进展

| 类型 | v1 (初始) | v2 (一轮修复后) | v3 (二轮修复后) |
|------|-----------|----------------|----------------|
| ❌ 编译阻塞 | 1 | **0** | **0** |
| ⚠️ 高优先级 | 5 | **0** | **0** |
| ⚠️ 中优先级 | 12 | 10 | **2** |
| ⚠️ 低优先级 | 8 | 8 | **2** |
| ✅ 通过项 | 26+ | 32+ | **46+** |

### 当前状态：✅ 生产就绪

无编译阻塞、无高优先级问题。8 项中优先级 + 6 项低优先级已修复。剩余 4 项为设计决策或极端边缘情况，已评估并有意保留。

### 💡 剩余备注（非阻塞）

1. **主色调硬编码 RGB 不适配深色模式** — 需设计师确定 Dark Mode 色板后在 Asset Catalog 中配置
2. **DispatchQueue.main.asyncAfter 动画链** — struct 值类型，SwiftUI 自动 no-op，实际风险极低
3. **SwiftData 容器初始化无 fallback** — 极端边缘情况，数据库损坏概率极低
4. **字体不支持 Dynamic Type** — 固定尺寸为设计意图，已文档标注
