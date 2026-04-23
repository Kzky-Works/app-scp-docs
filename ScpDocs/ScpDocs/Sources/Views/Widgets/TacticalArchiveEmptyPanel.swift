import SwiftUI

/// 空アーカイヴ・オフライン等の「警告スタイル」パネル（Daily Assignment 空状態と整合）。
struct TacticalArchiveEmptyPanel: View {
    let titleLocalizationKey: String
    let subtitleLocalizationKey: String
    var usesNetworkInterruptedCopy: Bool

    var body: some View {
        let subtitleKey = usesNetworkInterruptedCopy
            ? LocalizationKey.tacticalEmptyNetworkSubtitle
            : subtitleLocalizationKey

        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(String(localized: String.LocalizationValue(LocalizationKey.tacticalEmptyEyebrow)))
                    .font(.caption2.weight(.heavy))
                    .foregroundStyle(AppTheme.terminalSilver)
                    .tracking(1.1)
                Text(String(localized: String.LocalizationValue(titleLocalizationKey)))
                    .font(.subheadline.weight(.heavy))
                    .foregroundStyle(AppTheme.brandAccent)
                    .tracking(0.5)
                    .lineLimit(4)
                    .minimumScaleFactor(0.78)
                Text(String(localized: String.LocalizationValue(subtitleKey)))
                    .font(.caption.weight(.medium))
                    .foregroundStyle(AppTheme.textSecondary)
                    .lineLimit(6)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            Image(systemName: usesNetworkInterruptedCopy ? "wifi.slash" : "exclamationmark.triangle")
                .font(.title3.weight(.semibold))
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
}
