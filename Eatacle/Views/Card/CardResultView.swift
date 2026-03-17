import SwiftUI

/// 抽卡结果页 — 翻牌 + 滑动手势 + 粒子庆祝
struct CardResultView: View {
    let food: Food
    let drawCount: Int
    @Binding var isFlipped: Bool
    var hapticsEnabled: Bool
    let onConfirm: () -> Void
    let onReject: () -> Void
    let onDismiss: () -> Void

    // 拖拽
    @State private var dragOffset: CGSize = .zero
    @State private var cardRotation: Double = 0

    // 进入/退出动画
    @State private var cardEnterOffset: CGFloat = 0    // 新卡从右滑入用
    @State private var cardScale: CGFloat = 1.0
    @State private var showButtons = false

    // 庆祝
    @State private var showParticles = false
    @State private var particleSeed = UInt64(0)

    private let swipeThreshold: CGFloat = 120

    var body: some View {
        VStack(spacing: 0) {
            // ── 顶部栏 ──
            topBar
                .padding(.top, 16)

            Spacer()

            // ── 卡牌 + 方向指示 ──
            ZStack {
                if isFlipped {
                    swipeIndicators
                }

                CardFlipView(food: food, isFlipped: $isFlipped, hapticsEnabled: hapticsEnabled)
                    .padding(.horizontal, AppLayout.pagePadding)
                    .offset(x: cardEnterOffset + dragOffset.width, y: dragOffset.height * 0.3)
                    .rotationEffect(.degrees(cardRotation))
                    .scaleEffect(cardScale)
                    .gesture(swipeGesture)
                    .animation(.interactiveSpring(response: 0.3, dampingFraction: 0.7), value: dragOffset)
            }

            Spacer()

            // ── 底部按钮 ──
            if showButtons {
                bottomButtons
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .overlay {
            if showParticles {
                ParticleCanvasView(
                    themeColor: AppColors.cuisineColor(food.cuisine),
                    seed: particleSeed
                )
                .ignoresSafeArea()
                .allowsHitTesting(false)
            }
        }
        .onChange(of: isFlipped) { _, flipped in
            if flipped {
                withAnimation(AppAnimations.cardEnter.delay(0.3)) {
                    showButtons = true
                }
            }
        }
    }

    // MARK: - Top bar

    private var topBar: some View {
        HStack {
            Button { onDismiss() } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            // 翻牌次数计数器
            Text("第 \(drawCount) 次翻牌")
                .font(AppFonts.captionBold)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 5)
                .background(Capsule().fill(.ultraThinMaterial))
            Spacer()
            Color.clear.frame(width: 28, height: 28)
        }
        .padding(.horizontal, AppLayout.pagePadding)
    }

    // MARK: - Swipe indicators

    private var swipeIndicators: some View {
        HStack {
            // 左：拒绝
            VStack(spacing: 4) {
                Image(systemName: "hand.thumbsdown.fill")
                    .font(.system(size: 36))
                Text("换一个")
                    .font(AppFonts.tiny)
            }
            .foregroundStyle(AppColors.reject.opacity(rejectOpacity))
            .scaleEffect(1.0 + rejectOpacity * 0.15)
            .padding(.leading, 24)
            .accessibilityLabel("向左滑动换一个")

            Spacer()

            // 右：确认
            VStack(spacing: 4) {
                Image(systemName: "hand.thumbsup.fill")
                    .font(.system(size: 36))
                Text("就这个")
                    .font(AppFonts.tiny)
            }
            .foregroundStyle(AppColors.confirm.opacity(confirmOpacity))
            .scaleEffect(1.0 + confirmOpacity * 0.15)
            .padding(.trailing, 24)
            .accessibilityLabel("向右滑动确认选择")
        }
    }

    // MARK: - Swipe gesture

    private var swipeGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                guard isFlipped else { return }
                dragOffset = value.translation
                cardRotation = Double(value.translation.width / 20)
                // 缩放跟随拖拽距离
                let distance = abs(value.translation.width)
                cardScale = max(0.92, 1.0 - distance / 1500)
            }
            .onEnded { value in
                guard isFlipped else { return }
                handleSwipeEnd(value.translation, velocity: value.predictedEndTranslation)
            }
    }

    // MARK: - Bottom buttons

    private var bottomButtons: some View {
        HStack(spacing: 14) {
            // 拒绝
            Button { rejectWithAnimation() } label: {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.left")
                    Text("换一个")
                }
                .font(AppFonts.bodyMedium)
                .foregroundStyle(AppColors.reject)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: AppLayout.smallCorner, style: .continuous)
                        .stroke(AppColors.reject.opacity(0.4), lineWidth: 1.5)
                )
            }

            // 确认
            Button { confirmWithParticles() } label: {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark")
                    Text("就吃这个！")
                }
                .font(AppFonts.bodyMedium)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: AppLayout.smallCorner, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [AppColors.confirm, AppColors.jadeGreen],
                                startPoint: .leading, endPoint: .trailing
                            )
                        )
                )
            }
        }
        .padding(.horizontal, AppLayout.pagePadding)
        .padding(.bottom, 32)
    }

    // MARK: - Swipe handling

    private func handleSwipeEnd(_ translation: CGSize, velocity: CGSize) {
        // 使用速度加成：快速滑动降低阈值
        let effectiveThreshold = abs(velocity.width) > 500 ? swipeThreshold * 0.6 : swipeThreshold

        if translation.width > effectiveThreshold {
            confirmWithParticles()
        } else if translation.width < -effectiveThreshold {
            rejectWithAnimation()
        } else {
            // 回弹
            withAnimation(AppAnimations.bouncy) {
                dragOffset = .zero
                cardRotation = 0
                cardScale = 1.0
            }
        }
    }

    // MARK: - Reject animation

    private func rejectWithAnimation() {
        if hapticsEnabled { HapticsManager.cardDismiss() }
        showButtons = false

        // 1) 卡牌向左飞出 + 旋转 + 缩小
        withAnimation(AppAnimations.cardDismiss) {
            dragOffset = CGSize(width: -500, height: -40)
            cardRotation = -18
            cardScale = 0.7
        }

        // 2) 重置状态 → 抽下一张
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            dragOffset = .zero
            cardRotation = 0
            cardScale = 1.0
            isFlipped = false

            // 新卡从右侧弹入
            cardEnterOffset = 400
            onReject()

            withAnimation(AppAnimations.cardEnter) {
                cardEnterOffset = 0
            }

            // 新卡到位后自动翻转
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                if hapticsEnabled { HapticsManager.cardFlip() }
                isFlipped = true
            }

            // 新卡滑入触觉
            if hapticsEnabled { HapticsManager.cardEnter() }
        }
    }

    // MARK: - Confirm animation

    private func confirmWithParticles() {
        if hapticsEnabled { HapticsManager.celebrationBurst() }
        showButtons = false

        // 触发粒子爆炸
        particleSeed = UInt64.random(in: 0...UInt64.max)
        showParticles = true

        // 卡牌轻微放大
        withAnimation(.spring(duration: 0.3, bounce: 0.4)) {
            cardScale = 1.08
        }
        withAnimation(.spring(duration: 0.3, bounce: 0.2).delay(0.3)) {
            cardScale = 1.0
        }

        // 延迟后确认
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
            onConfirm()
        }
    }

    // MARK: - Indicator opacities

    private var rejectOpacity: Double {
        min(max(Double(-dragOffset.width / swipeThreshold), 0), 1)
    }

    private var confirmOpacity: Double {
        min(max(Double(dragOffset.width / swipeThreshold), 0), 1)
    }
}

// MARK: - Canvas 粒子爆炸效果

struct ParticleCanvasView: View {
    let themeColor: Color
    let seed: UInt64

    @State private var particles: [Particle] = []
    @State private var elapsedTime: TimeInterval = 0

    private let particleCount = 60
    private let duration: TimeInterval = 1.5

    struct Particle {
        let startX: CGFloat
        let startY: CGFloat
        let velocityX: CGFloat
        let velocityY: CGFloat
        let color: Color
        let size: CGFloat
        let rotation: Double
        let rotationSpeed: Double
        let shape: ParticleShape

        enum ParticleShape: CaseIterable {
            case circle, square, star, diamond
        }
    }

    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let now = timeline.date.timeIntervalSinceReferenceDate
                let t = min((now - startTime) / duration, 1.0)
                let gravity: CGFloat = 600

                for p in particles {
                    let progress = t
                    let x = size.width / 2 + p.startX + p.velocityX * CGFloat(progress)
                    let y = size.height / 2 + p.startY + p.velocityY * CGFloat(progress) + gravity * CGFloat(progress * progress)
                    let alpha = max(0, 1.0 - progress * 1.2)
                    let scale = max(0.2, 1.0 - progress * 0.5)
                    let angle = Angle.degrees(p.rotation + p.rotationSpeed * progress * 360)

                    guard alpha > 0 else { continue }

                    context.opacity = alpha
                    let transform = CGAffineTransform.identity
                        .translatedBy(x: x, y: y)
                        .rotated(by: angle.radians)
                        .scaledBy(x: scale, y: scale)

                    let rect = CGRect(x: -p.size / 2, y: -p.size / 2, width: p.size, height: p.size)

                    switch p.shape {
                    case .circle:
                        let path = Path(ellipseIn: rect)
                        context.fill(path.applying(transform), with: .color(p.color))
                    case .square:
                        let path = Path(rect)
                        context.fill(path.applying(transform), with: .color(p.color))
                    case .star:
                        let path = starPath(in: rect)
                        context.fill(path.applying(transform), with: .color(p.color))
                    case .diamond:
                        let path = diamondPath(in: rect)
                        context.fill(path.applying(transform), with: .color(p.color))
                    }
                }
            }
        }
        .onAppear { generateParticles() }
    }

    @State private var startTime: TimeInterval = Date().timeIntervalSinceReferenceDate

    private func generateParticles() {
        startTime = Date().timeIntervalSinceReferenceDate

        let colors: [Color] = [
            themeColor,
            themeColor.opacity(0.8),
            AppColors.warmOrange,
            AppColors.warmAmber,
            AppColors.warmCoral,
            .yellow,
            .white,
        ]

        particles = (0..<particleCount).map { _ in
            let angle = CGFloat.random(in: 0...(2 * .pi))
            let speed = CGFloat.random(in: 200...600)
            return Particle(
                startX: CGFloat.random(in: -20...20),
                startY: CGFloat.random(in: -20...20),
                velocityX: cos(angle) * speed,
                velocityY: sin(angle) * speed - 300, // upward bias
                color: colors.randomElement()!,
                size: CGFloat.random(in: 4...12),
                rotation: Double.random(in: 0...360),
                rotationSpeed: Double.random(in: -2...2),
                shape: Particle.ParticleShape.allCases.randomElement()!
            )
        }
    }

    private func starPath(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let r = rect.width / 2
        for i in 0..<5 {
            let angle = CGFloat(i) * .pi * 2 / 5 - .pi / 2
            let point = CGPoint(x: center.x + r * cos(angle), y: center.y + r * sin(angle))
            let innerAngle = angle + .pi / 5
            let innerPoint = CGPoint(x: center.x + r * 0.4 * cos(innerAngle), y: center.y + r * 0.4 * sin(innerAngle))
            if i == 0 { path.move(to: point) }
            else { path.addLine(to: point) }
            path.addLine(to: innerPoint)
        }
        path.closeSubpath()
        return path
    }

    private func diamondPath(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
        path.closeSubpath()
        return path
    }
}
