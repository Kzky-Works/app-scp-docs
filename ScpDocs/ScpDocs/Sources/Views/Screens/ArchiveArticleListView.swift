import SwiftUI

/// SCP-JP：Level 2 — シリーズ内の報告書一覧と 100 件セグメントピッカー。
struct ArchiveArticleListView: View {
    @Bindable var navigationRouter: NavigationRouter
    let series: SCPJPSeries

    @State private var selectedSegmentStart: Int

    init(navigationRouter: NavigationRouter, series: SCPJPSeries) {
        self.navigationRouter = navigationRouter
        self.series = series
        _selectedSegmentStart = State(initialValue: series.segmentStarts.first ?? series.scpNumberRange.lowerBound)
    }

    private var entries: [JapanSCPArchiveEntry] {
        LibraryStaticData.japanSCPArchiveEntries(series: series, segmentStart: selectedSegmentStart)
    }

    var body: some View {
        VStack(spacing: 0) {
            segmentPicker
            List {
                ForEach(entries) { entry in
                    Button {
                        Haptics.medium()
                        navigationRouter.pushArticle(url: entry.url)
                    } label: {
                        Text(formattedRowTitle(scpNumber: entry.scpNumber))
                            .font(.body.weight(.medium))
                            .foregroundStyle(AppTheme.accentPrimary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .buttonStyle(.plain)
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
        .background(AppTheme.backgroundPrimary)
        .navigationTitle(String(localized: String.LocalizationValue(series.titleLocalizationKey)))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    Haptics.medium()
                    navigationRouter.push(.category(series.wikidotSeriesIndexURL))
                } label: {
                    Image(systemName: "safari")
                }
                .accessibilityLabel(String(localized: String.LocalizationValue(LocalizationKey.archiveJpOpenWikiIndex)))
            }
        }
        .preferredColorScheme(.dark)
        .tint(AppTheme.accentPrimary)
    }

    private var segmentPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(series.segmentStarts, id: \.self) { start in
                    let isSelected = start == selectedSegmentStart
                    Button {
                        guard start != selectedSegmentStart else { return }
                        Haptics.medium()
                        selectedSegmentStart = start
                    } label: {
                        Text(segmentPickerLabel(start))
                            .font(.caption.weight(.semibold).monospacedDigit())
                            .foregroundStyle(AppTheme.accentPrimary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(isSelected ? AppTheme.accentPrimary.opacity(0.22) : AppTheme.backgroundPrimary)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .stroke(
                                        AppTheme.accentPrimary.opacity(isSelected ? 0.85 : 0.45),
                                        lineWidth: 1
                                    )
                            )
                    }
                    .buttonStyle(.plain)
                    .accessibilityAddTraits(isSelected ? [.isSelected] : [])
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
        .background(AppTheme.backgroundPrimary.opacity(0.98))
        .accessibilityElement(children: .contain)
        .accessibilityLabel(String(localized: String.LocalizationValue(LocalizationKey.archiveJpSegmentPickerAccessibility)))
    }

    private func segmentPickerLabel(_ start: Int) -> String {
        if start < 1000 {
            return String(format: "%03d", start)
        }
        return String(start)
    }

    private func formattedRowTitle(scpNumber: Int) -> String {
        let core = scpNumber < 1000 ? String(format: "%03d", scpNumber) : String(scpNumber)
        let format = String(localized: String.LocalizationValue(LocalizationKey.archiveJpScpRowTitleFormat))
        return String(format: format, locale: .current, core)
    }
}

#Preview {
    @Previewable @State var router = NavigationRouter()
    NavigationStack {
        ArchiveArticleListView(navigationRouter: router, series: .series5)
    }
}
