import SwiftUI

/// 記事評価：参考レイアウト（左：見出し＋スライダー／右：円）。未評価時はアクセント（オレンジ）を使わない。フラット・ノーシャドウ。
struct RatingControlView: View {
    @Binding var rating: Double

    @State private var isDragging = false
    @State private var dragScore: Double = 3.0
    @State private var lastTenthEmitted: Int?

    private let sliderMin = 1.0
    private let sliderMax = 5.0
    private let sliderStep = UserArticleData.ratingStep

    private var committed: Double {
        UserArticleData.clampedRating(rating)
    }

    private var hasCommittedScore: Bool {
        committed > UserArticleData.unrated
    }

    /// 保存済みの評価があるときのみオレンジ系アクセントを使う。
    private var chromaActive: Bool {
        hasCommittedScore
    }

    private var visualScore: Double {
        if isDragging { return dragScore }
        if hasCommittedScore {
            return min(UserArticleData.maxScore, max(sliderMin, committed))
        }
        return 3.0
    }

    private var showsNumericChrome: Bool {
        hasCommittedScore || isDragging
    }

    private var ringProgress: CGFloat {
        guard showsNumericChrome else { return 0 }
        let v = visualScore
        return CGFloat(max(0, min(1, (v - sliderMin) / (sliderMax - sliderMin))))
    }

    private func accent(for value: Double) -> Color {
        if value >= 4.0 {
            return AppTheme.ratingAnalyticsPrimaryStrong
        }
        if value < 2.0 {
            return AppTheme.ratingAnalyticsPrimarySoft
        }
        return AppTheme.ratingAnalyticsPrimary
    }

    /// 未評価時のトラック左側のフィル（グレー）。
    private var neutralFillColor: Color {
        AppTheme.ratingAnalyticsInk.opacity(0.18)
    }

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            VStack(alignment: .leading, spacing: 16) {
                Text(String(localized: String.LocalizationValue(LocalizationKey.articleRatingCardTitle)))
                    .font(.headline)
                    .foregroundStyle(AppTheme.ratingAnalyticsInk)
                    .fixedSize(horizontal: false, vertical: true)

                Text(String(localized: String.LocalizationValue(LocalizationKey.articleRatingCardSubtitle)))
                    .font(.caption)
                    .foregroundStyle(AppTheme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                VStack(alignment: .leading, spacing: 6) {
                    ReferenceStyleTickedSlider(
                        value: visualScore,
                        chromaActive: chromaActive,
                        showBubble: showsNumericChrome,
                        accentColor: accent(for: visualScore),
                        neutralFillColor: neutralFillColor,
                        minValue: sliderMin,
                        maxValue: sliderMax,
                        step: sliderStep,
                        onDragBegan: {
                            if !isDragging { isDragging = true }
                        },
                        onValueChange: { newValue in
                            if newValue != dragScore {
                                emitStepHaptic(newValue)
                                dragScore = newValue
                            }
                        },
                        onDragEnded: {
                            let prior = UserArticleData.clampedRating(rating)
                            isDragging = false
                            let next = UserArticleData.clampedRating(clampSliderScore(dragScore))
                            rating = next
                            if prior <= UserArticleData.unrated, next > UserArticleData.unrated {
                                Haptics.medium()
                            }
                        }
                    )
                    .frame(height: 40)
                    .padding(.top, 18)

                    trackLabelsRow
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            RatingScoreRingView(
                progress: ringProgress,
                centerPrimary: formattedCenterPrimary,
                arcColor: chromaActive ? accent(for: visualScore) : AppTheme.ratingAnalyticsInk.opacity(0.28),
                centerStrong: showsNumericChrome
            )
            .animation(.easeOut(duration: 0.2), value: ringProgress)
            .animation(.easeOut(duration: 0.2), value: visualScore)
        }
        .padding(16)
        .background(AppTheme.cardStandard)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(AppTheme.ratingAnalyticsBorder, lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(String(localized: String.LocalizationValue(LocalizationKey.articleRatingAccessibility)))
        .accessibilityValue(accessibilityValueText)
        .onAppear {
            syncDraftFromCommittedIfNeeded()
        }
        .onChange(of: rating) { _, _ in
            guard !isDragging else { return }
            syncDraftFromCommittedIfNeeded()
        }
    }

    private var trackLabelsRow: some View {
        GeometryReader { geo in
            let w = geo.size.width
            ZStack(alignment: .leading) {
                ForEach(1 ... 5, id: \.self) { i in
                    Text(String(format: "%.1f", locale: .current, Double(i)))
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(AppTheme.ratingAnalyticsInk.opacity(0.45))
                        .position(x: knobCenterX(score: Double(i), width: w), y: 8)
                }
            }
            .frame(width: w, height: 16)
        }
        .frame(height: 16)
    }

    private func knobCenterX(score: Double, width: CGFloat) -> CGFloat {
        let t = (score - sliderMin) / (sliderMax - sliderMin)
        return width * CGFloat(t)
    }

    private var accessibilityValueText: String {
        if !showsNumericChrome {
            return String(localized: String.LocalizationValue(LocalizationKey.articleRatingUnsetShort))
        }
        return String(format: "%.1f", locale: .current, visualScore)
    }

    private var formattedCenterPrimary: String {
        if !showsNumericChrome {
            return String(localized: String.LocalizationValue(LocalizationKey.articleRatingUnsetShort))
        }
        return String(format: "%.1f", locale: .current, visualScore)
    }

    private func syncDraftFromCommittedIfNeeded() {
        let c = UserArticleData.clampedRating(rating)
        guard c > UserArticleData.unrated else { return }
        dragScore = min(UserArticleData.maxScore, max(sliderMin, c))
    }

    private func emitStepHaptic(_ value: Double) {
        let tenth = Int((value * 10).rounded())
        if tenth != lastTenthEmitted {
            Haptics.selection()
            lastTenthEmitted = tenth
        }
    }

    private func clampSliderScore(_ raw: Double) -> Double {
        let stepped = (raw / sliderStep).rounded() * sliderStep
        return min(UserArticleData.maxScore, max(sliderMin, stepped))
    }
}

// MARK: - 参考コード寄せスライダー（全幅 0…width・@GestureState でノブサイズ）

private struct ReferenceStyleTickedSlider: View {
    let value: Double
    let chromaActive: Bool
    let showBubble: Bool
    let accentColor: Color
    let neutralFillColor: Color
    let minValue: Double
    let maxValue: Double
    let step: Double
    let onDragBegan: () -> Void
    let onValueChange: (Double) -> Void
    let onDragEnded: () -> Void

    @GestureState private var knobDragging = false

    private var totalSteps: Int {
        Int((maxValue - minValue) / step)
    }

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let knobX = knobCenterX(width: width)
            let fillWidth = max(4, knobX)
            let activeTint = chromaActive ? accentColor : neutralFillColor
            let knobStroke = chromaActive ? accentColor : AppTheme.ratingAnalyticsTrack
            let knobSize: CGFloat = knobDragging ? 24 : 20

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(AppTheme.ratingAnalyticsTrack.opacity(0.65))
                    .frame(height: 4)

                Capsule()
                    .fill(activeTint)
                    .frame(width: fillWidth, height: 4)

                ForEach(0 ... totalSteps, id: \.self) { i in
                    let x = width * CGFloat(Double(i) / Double(totalSteps))
                    let major = i % 10 == 0
                    Circle()
                        .fill(major ? AppTheme.ratingAnalyticsInk.opacity(0.35) : AppTheme.ratingAnalyticsInk.opacity(0.22))
                        .frame(width: major ? 4 : 2, height: major ? 4 : 2)
                        .position(x: x, y: 2)
                }

                Circle()
                    .fill(Color.white)
                    .frame(width: knobSize, height: knobSize)
                    .overlay(
                        Circle()
                            .stroke(knobStroke, lineWidth: 2)
                    )
                    .position(x: knobX, y: 2)

                if showBubble {
                    let bubbleFill = chromaActive ? accentColor : AppTheme.ratingAnalyticsInk.opacity(0.42)
                    Text(String(format: "%.1f", locale: .current, value))
                        .font(.caption.weight(.bold))
                        .monospacedDigit()
                        .foregroundStyle(Color.white)
                        .padding(6)
                        .background(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(bubbleFill)
                        )
                        .position(x: knobX, y: -20)
                }
            }
            .frame(height: 40)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .updating($knobDragging) { _, state, _ in
                        state = true
                    }
                    .onChanged { gesture in
                        onDragBegan()
                        let x = min(max(0, gesture.location.x), width)
                        let percent = width > 0 ? Double(x / width) : 0
                        let raw = percent * (maxValue - minValue) + minValue
                        let snapped = (raw / step).rounded() * step
                        let clamped = min(max(snapped, minValue), maxValue)
                        onValueChange(clamped)
                    }
                    .onEnded { _ in
                        onDragEnded()
                    }
            )
        }
    }

    private func knobCenterX(width: CGFloat) -> CGFloat {
        let percent = (value - minValue) / (maxValue - minValue)
        return width * CGFloat(percent)
    }
}

// MARK: - リング

private struct RatingScoreRingView: View {
    let progress: CGFloat
    let centerPrimary: String
    let arcColor: Color
    let centerStrong: Bool

    private let lineWidth: CGFloat = 8
    private let size: CGFloat = 90

    var body: some View {
        ZStack {
            Circle()
                .stroke(AppTheme.ratingAnalyticsTrack.opacity(0.65), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    arcColor,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
            VStack(spacing: 2) {
                Text(centerPrimary)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(centerStrong ? AppTheme.ratingAnalyticsInk : AppTheme.ratingAnalyticsInk.opacity(0.35))
                Text(String(localized: String.LocalizationValue(LocalizationKey.articleRatingScaleMax)))
                    .font(.caption)
                    .foregroundStyle(AppTheme.ratingAnalyticsInk.opacity(0.45))
            }
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}
