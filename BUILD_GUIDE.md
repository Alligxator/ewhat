# 🛠️ 构建指南 — 给执行 Agent 的完整指令

## 前置信息

- **项目目录：** `~/Projects/what-to-eat-today/`（已 git init）
- **需求文档：** 同目录下 `PRD.md`（务必先完整阅读）
- **产品名：** Ewhat
- **工具：** Claude Code (`claude`) 已由用户提前启动，通过 tmux 控制
- **目标：** iOS App，SwiftUI，纯本地无后端

---

## 第一步：确认 tmux 会话

用户已提前打开好 Claude Code 环境。你需要：

```bash
# 列出所有 tmux 会话，找到用户已开好的那个
tmux list-sessions

# 查看各会话内容，确认哪个窗口里跑着 Claude Code
tmux capture-pane -t <session-name> -p -S -20
```

确认好目标 tmux 会话名后，后续所有 `tmux send-keys` 都用该会话名。实际使用 **会话 0**。

## 第三步：分阶段发送任务

### ⚠️ 重要原则
- **每次只发一个阶段的任务**，等完成后再发下一个
- 通过 `tmux capture-pane -t whattoeat -p -S -100` 查看输出判断是否完成
- Claude Code 完成当前任务后会回到输入等待状态（出现 `>` 提示符）
- 如果卡住或报错，先查看日志分析原因再决定是否重试

---

### 阶段 1：项目初始化 + 数据层

```bash
tmux send-keys -t 0 "读取当前目录下的 PRD.md，这是完整的产品需求文档。现在开始第一阶段：

1. 用 Xcode 项目结构创建 SwiftUI iOS App（项目名 Ewhat，最低 iOS 17）
2. 按 PRD 中的项目结构创建所有目录和文件骨架
3. 实现 Models 层：Food.swift / FoodCategory.swift / DailyFortune.swift / MealRecord.swift
4. 创建 foods.json 食物数据库，至少包含 200 个食物条目，覆盖：
   - 中餐各菜系（川/粤/湘/东北/江浙/西北各15-20个）
   - 日料/韩餐/东南亚/西餐/快餐各10-15个
   - 每个条目包含：name/cuisine/category/tags/scene/priceRange/emoji/funText
5. 实现 LunarCalendar.swift 农历计算工具
6. 实现 WeightedRandom.swift 加权随机算法
7. 实现 SwiftData 持久化 schema

完成后 git commit。" Enter
```

### 阶段 2：核心 ViewModel + 食运算法

```bash
tmux send-keys -t 0 "继续第二阶段，在现有代码基础上：

1. 实现 FortuneViewModel：
   - 根据农历日期 + 节气 + 星期生成今日食运
   - 食运签文要有趣（准备30+条不同签文模板）
   - 属性系统：火/水/木/金/土 对应不同食物类型
   - 同一天同一配置产生相同食运（确定性伪随机）
2. 实现 CardViewModel：
   - 抽卡逻辑：根据筛选条件 + 食运加成 + 偏好权重 + 近期去重
   - 管理抽卡状态（当前卡牌/翻牌次数/确认/拒绝）
   - 拒绝后自动抽下一张
3. 实现 RecordViewModel：
   - CRUD 饮食记录
   - 统计：菜系分布/最爱Top5/本周本月数据
4. 实现偏好管理：黑名单/临时排除/偏好加权

确保所有 ViewModel 用 @Observable 宏。完成后 git commit。" Enter
```

### 阶段 3：UI 主体页面

```bash
tmux send-keys -t 0 "继续第三阶段，实现所有 UI 页面：

1. Theme 层：
   - 定义新中式暖色调配色方案（支持 light/dark mode）
   - 自定义字体样式
   - 统一的圆角/阴影/间距规范
2. HomeView：
   - 顶部今日食运卡片（农历日期 + 签文 + 推荐属性），带缓慢浮动呼吸效果
   - 中间大抽卡按钮/卡牌区域
   - 底部 TabBar（首页/记录/设置）
3. FilterView（模式选择页）：
   - 标签流布局展示菜系/类别/场景/预算
   - 支持多选组合
   - 选中态动画
4. FoodCardView + CardFlipView + CardResultView：
   - 卡牌正面：食物名 + emoji + 趣味文案 + 菜系标签 + 稀有度标识
   - 卡牌背面：统一的精美背面图案
   - 3D翻转动画（rotation3DEffect，0.6s，弹性回弹）
5. CardResultView：
   - 「就吃这个！」按钮 → 确认
   - 「朕不喜欢 👎」按钮 → 拒绝
   - 左滑拒绝/右滑确认手势（DragGesture）
6. RecordView：日历视图 + 简单统计图表
7. SettingsView：偏好/黑名单/食运开关/深浅模式

注意：UI 要精致细致，参考高质量 iOS App 的设计水准。圆角卡片、柔和阴影、舒适间距。完成后 git commit。" Enter
```

### 阶段 4：动画 + 特效 + 触觉反馈

```bash
tmux send-keys -t 0 "继续第四阶段，打磨动画和交互体验：

1. 抽卡翻转动画：
   - 3D翻转 + 卡牌周围光晕扩散效果
   - 时长0.6s，带弹性 spring 回弹
2. 拒绝动画：
   - 卡牌向左飞出 + 旋转 + 缩小消失
   - 新卡从右侧弹性滑入
   - 显示当前翻牌次数（如'第3次翻牌'）
3. 确认动画：
   - Canvas API 实现彩色粒子爆炸/撒花效果
   - 粒子颜色与食物主题色匹配
4. 食运卡片呼吸效果：
   - 缓慢上下浮动 + 透明度微变
5. 页面转场：
   - matchedGeometryEffect 实现卡牌到详情的流畅过渡
6. HapticsManager：
   - 翻牌：.medium impact
   - 确认：.success notification
   - 拒绝：.light impact
   - 筛选切换：.selection
7. 卡牌背面待抽取状态的呼吸光效

所有动画要流畅自然，不卡顿。完成后 git commit。" Enter
```

### 阶段 5：代码审查 + 审查报告

```bash
tmux send-keys -t whattoeat "最后阶段，对整个项目进行全面代码审查。**不要修改任何代码**，只输出审查报告：

1. 项目结构完整性：所有 Models/ViewModels/Views 是否齐全，文件是否缺失
2. 数据流检查：SwiftData schema → ViewModel (@Observable) → View 绑定链路是否完整
3. 导航流程：所有页面间跳转是否闭环，TabBar/Sheet/NavigationStack 是否正确
4. foods.json 数据完整性：条目数量、字段完整度、菜系覆盖度
5. 动画实现审查：翻牌/拒绝/确认/粒子特效的性能和流畅度
6. light/dark mode 适配是否完整
7. 代码质量：命名规范、retain cycle 风险、错误处理、Swift 最佳实践
8. 潜在编译问题：类型不匹配、缺少 import、iOS 17 API 兼容性

将审查报告写入项目根目录 CODE_REVIEW.md，格式：
- ✅ 通过项：简要说明
- ⚠️ 警告项：问题描述 + 所在文件 + 建议修复方式
- ❌ 严重问题：必须修复的阻塞项

另外编写 README.md：项目介绍、技术栈、功能列表、如何用 Xcode 打开运行。

完成后 git commit，然后运行: openclaw system event --text '✅ Ewhat 代码审查完成！5个阶段已提交，CODE_REVIEW.md 已生成，等待用户验收。' --mode now" Enter
```

---

## 定时检查 + 推进的 Cron 指令

在 agent 的对话中执行以下命令设置自动推进：

```
/cron add "*/8 * * * *" "检查 tmux 会话 0 的状态：
1. 运行 tmux capture-pane -t 0 -p -S -50 查看最近输出
2. 如果 Claude Code 已完成当前阶段（回到 > 提示符等待输入），发送下一阶段的任务
3. 如果正在执行中，不干预，报告进度
4. 如果报错或卡住，分析原因并尝试修复（发送修复指令给 Claude Code）
5. 如果所有5个阶段都已完成，报告最终状态并停止

阶段进度跟踪：读取 ~/Projects/what-to-eat-today/BUILD_PROGRESS.md 确认当前阶段，完成一个阶段后更新该文件。

各阶段的具体任务内容见 ~/Projects/what-to-eat-today/BUILD_GUIDE.md 中的'阶段1-5'。"
```

---

## Agent 执行流程总结

```
确认用户已开好的 tmux 会话
    ↓
发送阶段1任务 → 等待完成 → git commit
    ↓
发送阶段2任务 → 等待完成 → git commit
    ↓
发送阶段3任务 → 等待完成 → git commit
    ↓
发送阶段4任务 → 等待完成 → git commit
    ↓
发送阶段5任务 → 等待完成 → git commit
    ↓
发送完成通知 → 结束
```

## 进度追踪文件

Agent 应在项目目录维护 `BUILD_PROGRESS.md`：

```markdown
# 构建进度

- [x] 阶段1：项目初始化 + 数据层（完成时间：xxx）
- [ ] 阶段2：核心 ViewModel + 食运算法
- [ ] 阶段3：UI 主体页面
- [ ] 阶段4：动画 + 特效 + 触觉反馈
- [ ] 阶段5：整合测试 + 修复
```

---

## 注意事项

1. **不要同时发多个阶段** — 一个一个来，确认完成再发下一个
2. **每个阶段完成后必须 git commit** — 方便回滚
3. **如果 Claude Code 退出了** — 在 tmux 中重新启动 `claude`（确保 cwd 在项目目录），发送"继续上次未完成的工作"
4. **如果编译报错** — 让 Claude Code 自己修复，不要跳过
5. **项目目录：** `~/Projects/what-to-eat-today/`，不要在其他地方操作
6. **PRD.md 是需求真相** — 所有功能细节以 PRD.md 为准
