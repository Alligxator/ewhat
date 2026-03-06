# Ewhat — 今天吃什么？

> 用抽卡 + 玄学的方式，帮你解决"今天吃什么"的终极难题。

Ewhat 是一款为选择困难症而生的美食随机推荐 iOS App。通过卡牌翻转、食运系统和智能筛选，让每一顿饭的选择都充满仪式感和趣味。

## 功能亮点

- **抽卡推荐** — 翻转卡牌揭晓今日美食，支持滑动确认/拒绝，带 3D 翻转动画和粒子庆祝特效
- **今日食运** — 基于农历日期、节气、五行生成每日食运签文，影响推荐权重
- **智能筛选** — 按菜系、食物类型、用餐场景、价格区间多维筛选
- **饮食记录** — 日历视图查看历史记录，统计菜系分布和用餐偏好
- **卡牌等级** — 普通 / 稀有 / 传说三档稀有度，增加抽卡惊喜感
- **偏好管理** — 收藏菜系、黑名单食物、快速排除标签（辣/油炸/甜/生冷）
- **上瘾警告** — 连续多次选择同一菜系或食物时温馨提示

## 技术栈

| 技术 | 说明 |
|------|------|
| **SwiftUI** | 声明式 UI 框架，iOS 17+ |
| **SwiftData** | Apple 原生持久化框架，管理用餐记录和用户偏好 |
| **@Observable** | iOS 17 Observation 框架，替代 ObservableObject |
| **Canvas API** | 高性能粒子特效渲染（确认选择时的烟花爆炸） |
| **matchedGeometryEffect** | 页面间 hero 转场动画 |
| **Calendar (Chinese)** | 农历日期计算和二十四节气推算 |
| **UIFeedbackGenerator** | 丰富的触觉反馈（翻牌/确认/拒绝/庆祝） |

## 项目架构

```
Ewhat/
├── App/
│   └── WhatToEatApp.swift          # App 入口
├── Models/
│   ├── Food.swift                   # 食物数据模型 + JSON 加载
│   ├── FoodCategory.swift           # 枚举定义（菜系/类别/场景/价格/稀有度/五行）
│   ├── DailyFortune.swift           # 食运模型 + 152 条签文模板
│   └── MealRecord.swift             # SwiftData 持久化模型
├── ViewModels/
│   ├── FortuneViewModel.swift       # 确定性食运生成（FNV-1a 哈希种子）
│   ├── CardViewModel.swift          # 抽卡核心逻辑（筛选→去重→加权随机）
│   └── RecordViewModel.swift        # 记录 CRUD + 统计分析
├── Views/
│   ├── Home/                        # 首页（食运卡片 + 抽卡区 + 今日记录）
│   ├── Card/                        # 卡牌（3D 翻转 + 结果页 + 食物卡面）
│   ├── Filter/                      # 筛选（FlowLayout 标签 + 快速排除）
│   ├── Record/                      # 记录（日历 + 统计图表）
│   └── Settings/                    # 设置（偏好/黑名单/主题）
├── Theme/
│   ├── Colors.swift                 # 新中式暖色调色板
│   ├── Fonts.swift                  # 统一字体定义
│   └── Animations.swift             # 动画预设 + ViewModifier
├── Utils/
│   ├── LunarCalendar.swift          # 农历计算 + 节气 + 五行
│   ├── WeightedRandom.swift         # 多因子加权随机选择算法
│   └── HapticsManager.swift         # 触觉反馈管理器
└── Resources/
    ├── foods.json                   # 201 种食物数据库（11 菜系）
    └── Assets.xcassets              # 图片资源
```

## 食物数据库

201 种食物，覆盖 11 大菜系：

| 菜系 | 数量 | | 菜系 | 数量 |
|------|------|-|------|------|
| 川菜 | 22 | | 日料 | 15 |
| 快餐 | 22 | | 韩餐 | 15 |
| 粤菜 | 21 | | 东南亚 | 15 |
| 东北菜 | 20 | | 西餐 | 15 |
| 江浙菜 | 20 | | | |
| 湘菜 | 18 | | | |
| 西北菜 | 18 | | | |

稀有度分布：普通 78% / 稀有 17% / 传说 5%

## 系统要求

- iOS 17.0+
- Xcode 16.0+
- Swift 5.0+

## 如何运行

1. 克隆项目：
   ```bash
   git clone <repository-url>
   cd what-to-eat-today
   ```

2. 用 Xcode 打开项目：
   ```bash
   open Ewhat.xcodeproj
   ```

3. 选择目标设备（iPhone 模拟器或真机），点击 Run (Cmd+R)。

> 项目无第三方依赖，无需安装 CocoaPods 或 SPM 包。

## 设计理念

**新中式暖色调** — 以 `#F58D33` 暖橙为主色，搭配琥珀、珊瑚、米白，营造温暖食欲感。融入水墨黑、翡翠绿、朱砂红等中式点缀色。

**趣味 > 工具** — 抽卡机制借鉴手游体验，3D 翻牌、粒子庆祝、食运签文让选餐过程充满仪式感。

**仪式感 > 效率** — 不是最快告诉你吃什么，而是让"选择吃什么"本身成为一个有趣的小游戏。
