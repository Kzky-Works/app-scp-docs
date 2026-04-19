import SwiftUI

/// SCP-JP：Level 1 — シリーズ JP-I 〜 JP-V の選択。
struct ArchiveSeriesListView: View {
    @Bindable var navigationRouter: NavigationRouter

    var body: some View {
        List {
            ForEach(SCPJPSeries.allCases) { series in
                Button {
                    Haptics.medium()
                    navigationRouter.push(.scpJapanArchiveArticles(seriesOrdinal: series.rawValue))
                } label: {
                    HStack(alignment: .center, spacing: 12) {
                        Image(systemName: "list.number")
                            .foregroundStyle(AppTheme.accentPrimary)
                            .frame(width: 28, alignment: .center)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(String(localized: String.LocalizationValue(series.titleLocalizationKey)))
                                .font(.body.weight(.semibold))
                                .foregroundStyle(AppTheme.accentPrimary)
                            Text(series.rangeSubtitle)
                                .font(.caption.weight(.medium))
                                .foregroundStyle(AppTheme.accentPrimary.opacity(0.75))
                        }
                        Spacer(minLength: 0)
                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(AppTheme.accentPrimary.opacity(0.55))
                    }
                    .padding(.vertical, 4)
                }
                .buttonStyle(.plain)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(AppTheme.backgroundPrimary)
        .navigationTitle(String(localized: String.LocalizationValue(LocalizationKey.archiveJpSeriesListTitle)))
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
        .tint(AppTheme.accentPrimary)
    }
}

private extension SCPJPSeries {
    var rangeSubtitle: String {
        let template = String(localized: String.LocalizationValue(LocalizationKey.archiveSegmentLabelTemplate))
        let lo = scpNumberRange.lowerBound
        let hi = scpNumberRange.upperBound
        let ls: String
        let le: String
        if hi < 1000 {
            ls = String(format: "%03d", lo)
            le = String(format: "%03d", hi)
        } else {
            ls = String(lo)
            le = String(hi)
        }
        return String(format: template, locale: .current, ls, le)
    }
}

#Preview {
    @Previewable @State var router = NavigationRouter()
    NavigationStack {
        ArchiveSeriesListView(navigationRouter: router)
    }
}
