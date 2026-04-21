import SwiftUI

/// Filmarks 風の細いレーティングバー（目盛り＋等幅数字、星なし）。
struct RatingControlView: View {
    @Binding var rating: Double

    @State private var lastTenthEmitted: Int?
    @State private var lastHalfEmitted: Int?

    private var displayValue: Double {
        UserArticleData.clampedRating(rating)
    }

    private var largeNumberColor: Color {
        let v = displayValue
        if v >= 4.0 {
            return AppTheme.brandAccent
        }
        if v >= 3.0 {
            return AppTheme.textPrimary
        }
        return AppTheme.textSecondary
    }

    private var formattedLarge: String {
        let v = displayValue
        if v <= 0 {
            return String(localized: String.LocalizationValue(LocalizationKey.articleRatingUnsetShort))
        }
        return String(format: "%.1f", locale: .current, v)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(formattedLarge)
                    .font(.system(size: 28, weight: .semibold, design: .monospaced))
                    .foregroundStyle(largeNumberColor)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                Spacer(minLength: 0)
                Text(String(localized: String.LocalizationValue(LocalizationKey.articleRatingScaleMax)))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppTheme.textSecondary)
            }

            GeometryReader { geo in
                let width = geo.size.width
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(AppTheme.textSecondary.opacity(0.12))
                        .frame(height: 10)
                        .overlay(
                            Rectangle()
                                .stroke(AppTheme.borderSubtle.opacity(0.9), lineWidth: AppTheme.borderWidthHairline)
                        )

                    SegmentedRatingTicksCanvas(
                        segmentCount: 50,
                        emphasisEvery: 5
                    )
                    .frame(width: width, height: 22)
                    .allowsHitTesting(false)

                    Rectangle()
                        .fill(AppTheme.textPrimary.opacity(0.32))
                        .frame(width: max(0, width * (displayValue / UserArticleData.maxScore)), height: 10)

                    Slider(
                        value: $rating,
                        in: UserArticleData.minScore ... UserArticleData.maxScore,
                        step: UserArticleData.ratingStep
                    )
                    .tint(largeNumberColor)
                    .onChange(of: rating) { _, newValue in
                        emitHaptics(for: UserArticleData.clampedRating(newValue))
                    }
                }
                .frame(height: 28)
            }
            .frame(height: 28)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(AppTheme.cardBackground.opacity(0.94))
        .overlay(
            Rectangle()
                .stroke(AppTheme.borderSubtle.opacity(0.55), lineWidth: AppTheme.borderWidthHairline)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(String(localized: String.LocalizationValue(LocalizationKey.articleRatingAccessibility)))
        .accessibilityValue(formattedLarge)
    }

    private func emitHaptics(for value: Double) {
        let tenth = Int((value * 10).rounded())
        if tenth != lastTenthEmitted {
            Haptics.selection()
            lastTenthEmitted = tenth
        }
        let half = Int((value * 2).rounded())
        if half != lastHalfEmitted {
            Haptics.selectionAccent()
            lastHalfEmitted = half
        }
    }
}

private struct SegmentedRatingTicksCanvas: View {
    let segmentCount: Int
    let emphasisEvery: Int

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = geo.size.height
            Canvas { ctx, size in
                guard segmentCount > 0 else { return }
                let step = width / CGFloat(segmentCount)
                for i in 0 ... segmentCount {
                    let x = CGFloat(i) * step
                    let major = i % emphasisEvery == 0
                    let tickHeight: CGFloat = major ? 8 : 4
                    let y1 = (height - tickHeight) / 2
                    let y2 = y1 + tickHeight
                    var path = Path()
                    path.move(to: CGPoint(x: x, y: y1))
                    path.addLine(to: CGPoint(x: x, y: y2))
                    let opacity = major ? 0.55 : 0.28
                    ctx.stroke(
                        path,
                        with: .color(AppTheme.textSecondary.opacity(opacity)),
                        lineWidth: major ? 1 : AppTheme.borderWidthHairline
                    )
                }
            }
        }
    }
}
