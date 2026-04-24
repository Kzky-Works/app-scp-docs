import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// 空アーカイヴ・オフライン等の「警告スタイル」パネル（Daily Assignment 空状態と整合）。
struct TacticalArchiveEmptyPanel: View {
    let titleLocalizationKey: String
    let subtitleLocalizationKey: String
    var usesNetworkInterruptedCopy: Bool
    /// 記事一覧上と同じく各文字を 1pt 小さくする（長い画面タイトルと行の密度に合わせる）。
    var useCompactListTypography: Bool = false

    var body: some View {
        let subtitleKey = usesNetworkInterruptedCopy
            ? LocalizationKey.tacticalEmptyNetworkSubtitle
            : subtitleLocalizationKey

        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(String(localized: String.LocalizationValue(LocalizationKey.tacticalEmptyEyebrow)))
                    .font(scpEyebrowFont)
                    .foregroundStyle(AppTheme.terminalSilver)
                    .tracking(1.1)
                Text(String(localized: String.LocalizationValue(titleLocalizationKey)))
                    .font(scpEmptyTitleFont)
                    .foregroundStyle(AppTheme.brandAccent)
                    .tracking(0.5)
                    .lineLimit(4)
                    .minimumScaleFactor(0.78)
                Text(String(localized: String.LocalizationValue(subtitleKey)))
                    .font(scpEmptySubtitleFont)
                    .foregroundStyle(AppTheme.textSecondary)
                    .lineLimit(6)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            Image(systemName: usesNetworkInterruptedCopy ? "wifi.slash" : "exclamationmark.triangle")
                .font(scpEmptyIconFont)
                .foregroundStyle(AppTheme.brandAccent.opacity(0.92))
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(AppTheme.cardStandard)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(AppTheme.terminalSilver.opacity(0.9), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
    }

#if canImport(UIKit)
    private var scpEyebrowFont: Font {
        useCompactListTypography
            ? AppTypography.feedListOnePointDown(.caption2, weight: .heavy)
            : .caption2.weight(.heavy)
    }

    private var scpEmptyTitleFont: Font {
        useCompactListTypography
            ? AppTypography.feedListOnePointDown(.subheadline, weight: .heavy)
            : .subheadline.weight(.heavy)
    }

    private var scpEmptySubtitleFont: Font {
        useCompactListTypography
            ? AppTypography.feedListOnePointDown(.caption1, weight: .medium)
            : .caption.weight(.medium)
    }

    private var scpEmptyIconFont: Font {
        useCompactListTypography
            ? AppTypography.feedListOnePointDown(.title3, weight: .semibold)
            : .title3.weight(.semibold)
    }
#endif
}
