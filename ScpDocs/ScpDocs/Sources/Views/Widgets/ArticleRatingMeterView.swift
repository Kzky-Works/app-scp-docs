import SwiftUI

/// 索引行右端のデジタル・メーター（レーティング表示）。
struct ArticleRatingMeterView: View {
    let ratingScore: Double

    private var accent: Color {
        if ratingScore >= 4.0 {
            AppTheme.brandAccent
        } else if ratingScore > UserArticleData.unrated {
            AppTheme.textPrimary
        } else {
            AppTheme.textSecondary.opacity(0.65)
        }
    }

    var body: some View {
        Group {
            if ratingScore <= UserArticleData.unrated {
                Circle()
                    .fill(accent)
                    .frame(width: 6, height: 6)
            } else {
                Text(formattedScore)
                    .font(.caption.weight(.bold).monospacedDigit())
                    .foregroundStyle(accent)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .stroke(AppTheme.borderSubtle.opacity(0.85), lineWidth: AppTheme.borderWidthHairline)
                    )
            }
        }
        .accessibilityLabel(accessibilityLabelText)
    }

    private var accessibilityLabelText: String {
        if ratingScore <= UserArticleData.unrated {
            String(localized: String.LocalizationValue(LocalizationKey.archiveRatingMeterUnreadAccessibility))
        } else {
            String(
                format: String(localized: String.LocalizationValue(LocalizationKey.archiveRatingMeterScoreAccessibilityFormat)),
                locale: .current,
                formattedScore
            )
        }
    }

    private var formattedScore: String {
        let v = UserArticleData.clampedRating(ratingScore)
        if v.truncatingRemainder(dividingBy: 1) < 0.05 {
            return String(format: "%.0f", locale: .current, v)
        }
        return String(format: "%.1f", locale: .current, v)
    }

}
