import SwiftUI

/// SCP-JP / SCP（英語）共通：001–4999 を一覧し、1000 刻み・100 刻みの 2 段ピッカーで移動。
struct ArchiveArticleListView: View {
    enum Kind: Hashable, Sendable {
        case japan
        case english
    }

    @Bindable var navigationRouter: NavigationRouter
    let kind: Kind
    let articleRepository: ArticleRepository
    private let japanSCPListMetadataStore: JapanSCPListMetadataStore?

    @State private var selectedSeries: SCPJPSeries
    @State private var selectedSegmentStart: Int

    init(
        navigationRouter: NavigationRouter,
        articleRepository: ArticleRepository,
        japanSCPListMetadataStore: JapanSCPListMetadataStore
    ) {
        self.navigationRouter = navigationRouter
        self.kind = .japan
        self.articleRepository = articleRepository
        self.japanSCPListMetadataStore = japanSCPListMetadataStore
        let initialSeries = SCPJPSeries.series1
        self._selectedSeries = State(initialValue: initialSeries)
        self._selectedSegmentStart = State(initialValue: initialSeries.segmentStarts.first ?? 1)
    }

    init(
        navigationRouter: NavigationRouter,
        articleRepository: ArticleRepository
    ) {
        self.navigationRouter = navigationRouter
        self.kind = .english
        self.articleRepository = articleRepository
        self.japanSCPListMetadataStore = nil
        let initialSeries = SCPJPSeries.series1
        self._selectedSeries = State(initialValue: initialSeries)
        self._selectedSegmentStart = State(initialValue: initialSeries.segmentStarts.first ?? 1)
    }

    private var entries: [JapanSCPArchiveEntry] {
        switch kind {
        case .japan:
            guard let store = japanSCPListMetadataStore else { return [] }
            return store.japanSCPArchiveEntries(series: selectedSeries, segmentStart: selectedSegmentStart)
        case .english:
            return Self.englishEntries(series: selectedSeries, segmentStart: selectedSegmentStart)
        }
    }

    private var archiveNavigationTitle: String {
        switch kind {
        case .japan:
            String(localized: String.LocalizationValue(LocalizationKey.archiveTitleJP))
        case .english:
            String(localized: String.LocalizationValue(LocalizationKey.archiveTitleEN))
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            List {
                ForEach(entries) { entry in
                    Button {
                        Haptics.medium()
                        navigationRouter.pushArticle(url: entry.url)
                    } label: {
                        HStack(alignment: .top, spacing: 12) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(formattedRowTitle(scpNumber: entry.scpNumber))
                                    .font(.body.weight(.semibold))
                                    .foregroundStyle(AppTheme.accentPrimary)
                                    .multilineTextAlignment(.leading)
                                Text(resolvedSubtitle(entry))
                                    .font(.caption)
                                    .foregroundStyle(AppTheme.accentPrimary.opacity(0.78))
                                    .multilineTextAlignment(.leading)
                                    .lineLimit(3)
                            }
                            Spacer(minLength: 0)
                            if articleRepository.isBookmarked(url: entry.url) {
                                Image(systemName: "bookmark.fill")
                                    .foregroundStyle(AppTheme.accentPrimary)
                                    .imageScale(.medium)
                            }
                            if articleRepository.isRead(url: entry.url) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(AppTheme.accentPrimary)
                                    .imageScale(.medium)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .buttonStyle(.plain)
                    .listRowBackground(AppTheme.backgroundPrimary)
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)

            seriesPicker
            segmentPicker
        }
        .background(AppTheme.backgroundPrimary)
        .navigationTitle(archiveNavigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    Haptics.medium()
                    navigationRouter.push(.category(wikidotIndexURLForToolbar))
                } label: {
                    Image(systemName: "safari")
                }
                .accessibilityLabel(String(localized: String.LocalizationValue(openWikiIndexLocalizationKey)))
            }
        }
        .onChange(of: selectedSeries) { _, newSeries in
            let starts = newSeries.segmentStarts
            guard !starts.isEmpty else { return }
            if !starts.contains(selectedSegmentStart) {
                selectedSegmentStart = starts[0]
            }
        }
        .preferredColorScheme(.dark)
        .tint(AppTheme.accentPrimary)
    }

    private var wikidotIndexURLForToolbar: URL {
        switch kind {
        case .japan:
            selectedSeries.wikidotSeriesIndexURL
        case .english:
            selectedSeries.englishWikidotSeriesIndexURL
        }
    }

    private var openWikiIndexLocalizationKey: String {
        switch kind {
        case .japan:
            LocalizationKey.archiveJpOpenWikiIndex
        case .english:
            LocalizationKey.archiveEnOpenWikiIndex
        }
    }

    private var seriesPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(SCPJPSeries.allCases) { series in
                    let isSelected = series == selectedSeries
                    Button {
                        guard series != selectedSeries else { return }
                        Haptics.medium()
                        selectedSeries = series
                    } label: {
                        Text(seriesPickerLabel(series))
                            .font(.caption.weight(.semibold))
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
            .padding(.vertical, 8)
        }
        .background(AppTheme.backgroundPrimary.opacity(0.98))
        .accessibilityElement(children: .contain)
        .accessibilityLabel(String(localized: String.LocalizationValue(seriesPickerAccessibilityKey)))
    }

    private var segmentPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(selectedSeries.segmentStarts, id: \.self) { start in
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
        .accessibilityLabel(String(localized: String.LocalizationValue(segmentPickerAccessibilityKey)))
    }

    private var seriesPickerAccessibilityKey: String {
        switch kind {
        case .japan:
            LocalizationKey.archiveJpSeriesPickerAccessibility
        case .english:
            LocalizationKey.archiveEnSeriesPickerAccessibility
        }
    }

    private var segmentPickerAccessibilityKey: String {
        switch kind {
        case .japan:
            LocalizationKey.archiveJpSegmentPickerAccessibility
        case .english:
            LocalizationKey.archiveEnSegmentPickerAccessibility
        }
    }

    private func seriesPickerLabel(_ series: SCPJPSeries) -> String {
        switch kind {
        case .japan:
            String(localized: String.LocalizationValue(series.titleLocalizationKey))
        case .english:
            String(localized: String.LocalizationValue(series.englishThousandBlockLocalizationKey))
        }
    }


    private func segmentPickerLabel(_ start: Int) -> String {
        if start < 1000 {
            return String(format: "%03d", start)
        }
        return String(start)
    }

    private func formattedRowTitle(scpNumber: Int) -> String {
        let core = scpNumber < 1000 ? String(format: "%03d", scpNumber) : String(scpNumber)
        let formatKey = switch kind {
        case .japan:
            LocalizationKey.archiveJpScpRowTitleFormat
        case .english:
            LocalizationKey.archiveEnScpRowTitleFormat
        }
        let format = String(localized: String.LocalizationValue(formatKey))
        return String(format: format, locale: .current, core)
    }

    private func resolvedSubtitle(_ entry: JapanSCPArchiveEntry) -> String {
        if let t = entry.articleTitle, !t.isEmpty {
            return t
        }
        return String(localized: String.LocalizationValue(LocalizationKey.archiveArticleTitleUnknown))
    }

    private static func englishEntries(series: SCPJPSeries, segmentStart: Int) -> [JapanSCPArchiveEntry] {
        series.numbersInSegment(segmentStart: segmentStart).map { n in
            let url = SCPJPSeries.englishArticleURL(scpNumber: n)
            let slug: String
            if n < 1000 {
                slug = String(format: "scp-%03d", n)
            } else {
                slug = "scp-\(n)"
            }
            return JapanSCPArchiveEntry(id: slug, scpNumber: n, url: url, articleTitle: nil)
        }
    }
}

#Preview("JP") {
    @Previewable @State var router = NavigationRouter()
    @Previewable @State var repo = ArticleRepository()
    let meta = JapanSCPListMetadataStore(cacheRepository: SCPListCacheRepository())
    NavigationStack {
        ArchiveArticleListView(
            navigationRouter: router,
            articleRepository: repo,
            japanSCPListMetadataStore: meta
        )
    }
}

#Preview("EN") {
    @Previewable @State var router = NavigationRouter()
    @Previewable @State var repo = ArticleRepository()
    NavigationStack {
        ArchiveArticleListView(
            navigationRouter: router,
            articleRepository: repo
        )
    }
}
