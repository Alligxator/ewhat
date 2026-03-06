import SwiftUI

/// 抽卡结果页 — 翻牌 + 左滑拒绝 / 右滑确认 手势
struct CardResultView: View {
    let food: Food
    let drawCount: Int
    @Binding var isFlipped: Bool
    var hapticsEnabled: Bool
    let onConfirm: () -> Void
    let onReject: () -> Void
    let onDismiss: () -> Void

    @State private var dragOffset: CGSize = .zero
    @State private var cardRotation: Double = 0
    @State private var showConfetti = false

    /// 拖拽阈值
    private let swipeThreshold: CGFloat = 120

    var body: some View {
        VStack(spacing: 0) {
            // ── 顶部栏 ──
            HStack {
                Button { onDismiss() } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if drawCount > 1 {
                    Text("第 \(drawCount) 次翻牌")
                        .font(AppFonts.captionBold)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 5)
                        .background(Capsule().fill(.ultraThinMaterial))
                }
                Spacer()
                // placeholder for symmetry
                Color.clear.frame(width: 28, height: 28)
            }
            .padding(.horizontal, AppLayout.pagePadding)
            .padding(.top, 16)

            Spacer()

            // ── 卡牌 ──
            ZStack {
                // 滑动方向指示
                if isFlipped {
                    HStack {
                        // 左：拒绝
                        Image(systemName: "hand.thumbsdown.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(AppColors.reject.opacity(rejectIndicatorOpacity))
                            .padding(.leading, 30)
                        Spacer()
                        // 右：确认
                        Image(systemName: "hand.thumbsup.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(AppColors.confirm.opacity(confirmIndicatorOpacity))
                            .padding(.trailing, 30)
                    }
                }

                CardFlipView(food: food, isFlipped: $isFlipped, hapticsEnabled: hapticsEnabled)
                    .padding(.horizontal, AppLayout.pagePadding)
                    .offset(dragOffset)
                    .rotationEffect(.degrees(cardRotation))
                    .gesture(
                        isFlipped
                        ? DragGesture()
                            .onChanged { value in
                                dragOffset = value.translation
                                cardRotation = Double(value.translation.width / 25)
                            }
                            .onEnded { value in
                                handleSwipeEnd(value.translation)
                            }
                        : nil
                    )
                    .animation(.interactiveSpring, value: dragOffset)
            }

            Spacer()

            // ── 底部按钮（翻牌后显示） ──
            if isFlipped {
                HStack(spacing: 14) {
                    // 拒绝
                    Button {
                        dismissCard(direction: .left)
                    } label: {
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
                    Button {
                        confirmWithCelebration()
                    } label: {
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
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .overlay {
            if showConfetti {
                ConfettiView()
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }
        }
    }

    // MARK: - Swipe

    private func handleSwipeEnd(_ translation: CGSize) {
        if translation.width > swipeThreshold {
            // 右滑 → 确认
            confirmWithCelebration()
        } else if translation.width < -swipeThreshold {
            // 左滑 → 拒绝
            dismissCard(direction: .left)
        } else {
            // 回弹
            withAnimation(AppAnimations.bouncy) {
                dragOffset = .zero
                cardRotation = 0
            }
        }
    }

    private func dismissCard(direction: SwipeDirection) {
        let offscreen: CGFloat = direction == .left ? -500 : 500
        withAnimation(AppAnimations.cardDismiss) {
            dragOffset = CGSize(width: offscreen, height: 0)
            cardRotation = direction == .left ? -15 : 15
        }

        // 短暂延迟后重置并抽下一张
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            dragOffset = .zero
            cardRotation = 0
            isFlipped = false
            onReject()
            // 新卡进入后自动翻转
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                if hapticsEnabled { HapticsManager.cardFlip() }
                isFlipped = true
            }
        }
    }

    private func confirmWithCelebration() {
        showConfetti = true
        if hapticsEnabled { HapticsManager.confirmSelection() }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            onConfirm()
        }
    }

    private enum SwipeDirection { case left, right }

    private var rejectIndicatorOpacity: Double {
        let x = -dragOffset.width
        return min(max(Double(x / swipeThreshold), 0), 1)
    }

    private var confirmIndicatorOpacity: Double {
        let x = dragOffset.width
        return min(max(Double(x / swipeThreshold), 0), 1)
    }
}

// MARK: - 简易撒花效果

struct ConfettiView: View {
    @State private var particles: [(id: Int, x: CGFloat, y: CGFloat, color: Color, size: CGFloat)] = []
    @State private var animate = false

    private let emojis = ["🎉", "🎊", "✨", "🌟", "🎈", "🥳"]

    var body: some View {
        ZStack {
            ForEach(0..<20, id: \.self) { i in
                Text(emojis[i % emojis.count])
                    .font(.system(size: CGFloat.random(in: 16...32)))
                    .offset(
                        x: animate ? CGFloat.random(in: -180...180) : 0,
                        y: animate ? CGFloat.random(in: -400...400) : 0
                    )
                    .opacity(animate ? 0 : 1)
                    .scaleEffect(animate ? 0.3 : 1.0)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.5)) {
                animate = true
            }
        }
    }
}
