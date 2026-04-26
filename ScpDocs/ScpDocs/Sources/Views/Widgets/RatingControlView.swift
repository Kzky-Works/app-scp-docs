import SwiftUI

/// 記事評価：サークル・アナリティクス調（スライダー 1.0〜5.0・0.1 刻み）。フラット・ノーシャドウ。
struct RatingControlView: View {
    @Binding var rating: Double

    @State private var isDragging = false
    @State private var dragScore: Double = 3.0
    @State private var lastTenthEmitted: Int?

    private var committed: Double {
        UserArticleData.clampedRating(rating)
    }

    private var hasCommittedScore: Bool {
        committed > UserArticleData.unrated
    }

    private var chromaActive: Bool {
        hasCommittedScore || isDragging
    }

    /// スライダー上の現在スコア（1.0…5.0）。
    private var visualScore: Double {
        if isDragging { return dragScore }
        if hasCommittedScore {
            return min(UserArticleData.maxScore, max(1.0, committed))
        }
        return 3.0
    }

    private var showsNumericChrome: Bool {
        hasCommittedScore || isDragging
    }

    private var ringProgress: CGFloat {
        guard showsNumericChrome else { return 0 }
        let v = visualScore
        return CGFloat(max(0, min(1, (v - 1.0) / 4.0)))
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

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text(String(localized: String.LocalizationValue(LocalizationKey.articleRatingCardTitle)))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppTheme.ratingAnalyticsInk)
                    .fixedSize(horizontal: false, vertical: true)
                Text(String(localized: String.LocalizationValue(LocalizationKey.articleRatingCardSubtitle)))
                    .font(.caption)
                    .foregroundStyle(AppTheme.ratingAnalyticsInk.opacity(0.55))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: 132, alignment: .leading)
            .layoutPriority(1)

            sliderBlock
                .frame(maxWidth: .infinity)

            RatingScoreRingView(
                progress: ringProgress,
                centerPrimary: formattedCenterPrimary,
                accent: accent(for: visualScore),
                chromaActive: chromaActive
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

    private var sliderBlock: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let cx = thumbCenterX(visualScore, width: width)
            let accentColor = accent(for: visualScore)
            ZStack(alignment: .topLeading) {
                if showsNumericChrome {
                    Text(String(format: "%.1f", locale: .current, visualScore))
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(Color.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(accentColor)
                        )
                        .position(x: cx, y: 14)
                }

                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: 28)
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(AppTheme.ratingAnalyticsTrack)
                            .frame(height: 4)
                            .frame(maxWidth: .infinity)

                        if chromaActive {
                            Capsule()
                                .fill(accentColor)
                                .frame(width: max(4, cx), height: 4)
                        }

                        RatingSliderTicksView(
                            width: width,
                            visualScore: visualScore,
                            chromaActive: chromaActive,
                            accent: accentColor
                        )
                        .allowsHitTesting(false)

                        Circle()
                            .fill(Color.white)
                            .frame(width: thumbDiameter, height: thumbDiameter)
                            .overlay(
                                Circle()
                                    .stroke(
                                        chromaActive ? accentColor : AppTheme.ratingAnalyticsTrack,
                                        lineWidth: 2
                                    )
                            )
                            .scaleEffect(isDragging ? 1.05 : 1)
                            .position(x: cx, y: 22)
                    }
                    .frame(height: 44)
                    .contentShape(Rectangle())
                    .gesture(sliderDragGesture(width: width))

                    trackLabelsRow(width: width)
                        .frame(height: 16)
                        .padding(.top, 4)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .frame(height: 100)
    }

    private func trackLabelsRow(width: CGFloat) -> some View {
        ZStack(alignment: .leading) {
            ForEach(1 ... 5, id: \.self) { i in
                Text(String(format: "%.1f", locale: .current, Double(i)))
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(AppTheme.ratingAnalyticsInk.opacity(0.45))
                    .position(x: thumbCenterX(Double(i), width: width), y: 8)
            }
        }
        .frame(width: width, height: 16)
    }

    private func sliderDragGesture(width: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                if !isDragging {
                    isDragging = true
                }
                let next = scoreFromThumbLocation(value.location.x, width: width)
                if next != dragScore {
                    emitStepHaptic(next)
                    dragScore = next
                }
            }
            .onEnded { _ in
                let prior = UserArticleData.clampedRating(rating)
                isDragging = false
                let next = UserArticleData.clampedRating(clampSliderScore(dragScore))
                rating = next
                if prior <= UserArticleData.unrated, next > UserArticleData.unrated {
                    Haptics.medium()
                }
            }
    }

    private func syncDraftFromCommittedIfNeeded() {
        let c = UserArticleData.clampedRating(rating)
        guard c > UserArticleData.unrated else { return }
        dragScore = min(UserArticleData.maxScore, max(1.0, c))
    }

    private func emitStepHaptic(_ value: Double) {
        let tenth = Int((value * 10).rounded())
        if tenth != lastTenthEmitted {
            Haptics.selection()
            lastTenthEmitted = tenth
        }
    }

    private func thumbCenterX(_ score: Double, width: CGFloat) -> CGFloat {
        let inset = thumbDiameter / 2
        let usable = max(1, width - thumbDiameter)
        let t = (score - 1.0) / 4.0
        return inset + CGFloat(t) * usable
    }

    private func scoreFromThumbLocation(_ x: CGFloat, width: CGFloat) -> Double {
        let inset = thumbDiameter / 2
        let usable = max(1, width - thumbDiameter)
        let clampedX = min(max(x, inset), width - inset)
        let t = Double((clampedX - inset) / usable)
        let raw = 1.0 + t * 4.0
        return clampSliderScore(raw)
    }

    private func clampSliderScore(_ raw: Double) -> Double {
        let stepped = (raw / UserArticleData.ratingStep).rounded() * UserArticleData.ratingStep
        return min(UserArticleData.maxScore, max(1.0, stepped))
    }

    private var thumbDiameter: CGFloat { 20 }
}

// MARK: - リング

private struct RatingScoreRingView: View {
    let progress: CGFloat
    let centerPrimary: String
    let accent: Color
    let chromaActive: Bool

    private let lineWidth: CGFloat = 8
    private let size: CGFloat = 92

    var body: some View {
        ZStack {
            Circle()
                .stroke(AppTheme.ratingAnalyticsTrack, lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    accent,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
            VStack(spacing: 0) {
                Text(centerPrimary)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(chromaActive ? AppTheme.ratingAnalyticsInk : AppTheme.ratingAnalyticsInk.opacity(0.35))
                Text(String(localized: String.LocalizationValue(LocalizationKey.articleRatingScaleMax)))
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(AppTheme.ratingAnalyticsInk.opacity(0.45))
            }
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}

// MARK: - 目盛り（0.1 毎のドット＋整数ノード）

private struct RatingSliderTicksView: View {
    let width: CGFloat
    let visualScore: Double
    let chromaActive: Bool
    let accent: Color

    private var inset: CGFloat { 10 }
    private var usableWidth: CGFloat { max(1, width - 20) }

    var body: some View {
        Canvas { ctx, canvasSize in
            let h = canvasSize.height
            let midY = h / 2
            for i in 0 ... 40 {
                let v = 1.0 + Double(i) / 10.0
                let isInteger = i % 10 == 0
                let active = chromaActive && v <= min(visualScore + 0.001, 5.0)
                let cx = inset + CGFloat((v - 1.0) / 4.0) * usableWidth
                if isInteger {
                    let r: CGFloat = 3.5
                    let rect = CGRect(x: cx - r, y: midY - r, width: r * 2, height: r * 2)
                    ctx.fill(
                        Path(ellipseIn: rect),
                        with: .color(active ? accent : AppTheme.ratingAnalyticsTrack)
                    )
                } else {
                    let dotR: CGFloat = 1
                    let rect = CGRect(x: cx - dotR, y: midY - dotR, width: dotR * 2, height: dotR * 2)
                    ctx.fill(
                        Path(ellipseIn: rect),
                        with: .color(active ? accent.opacity(0.65) : AppTheme.ratingAnalyticsTrack.opacity(0.85))
                    )
                }
            }
        }
        .frame(width: width, height: 44)
    }
}
