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
    private let japanSCPListMetadataStore: JapanSCPListMetadataStore
    private let initialTagFilters: Set<String>?

    @State private var selectedSeries: SCPJPSeries
    @State private var selectedSegmentStart: Int
    @State private var filterModel: ArchiveArticleViewModel
    /// 一覧行にタグチップを常時表示（フィルタ／タグ検索入力時は自動で表示）。
    @State private var showDetailRowTags = false

    init(
        navigationRouter: NavigationRouter,
        articleRepository: ArticleRepository,
        kind: Kind,
        japanSCPListMetadataStore: JapanSCPListMetadataStore,
        initialTagFilters: Set<String>? = nil
    ) {
        self.navigationRouter = navigationRouter
        self.kind = kind
        self.articleRepository = articleRepository
        self.japanSCPListMetadataStore = japanSCPListMetadataStore
        self.initialTagFilters = initialTagFilters
        let initialSeries = SCPJPSeries.series1
        self._selectedSeries = State(initialValue: initialSeries)
        self._selectedSegmentStart = State(initialValue: initialSeries.segmentStarts.first ?? 1)
        let model = ArchiveArticleViewModel()
        if let initialTagFilters {
            model.selectedTags = initialTagFilters
        }
        self._filterModel = State(initialValue: model)
    }

    private var entries: [JapanSCPArchiveEntry] {
        switch kind {
        case .japan:
            japanSCPListMetadataStore.japanSCPArchiveEntries(series: selectedSeries, segmentStart: selectedSegmentStart)
        case .english:
            japanSCPListMetadataStore.englishMainlistTranslationArchiveEntries(series: selectedSeries, segmentStart: selectedSegmentStart)
        }
    }

    private var displayedEntries: [JapanSCPArchiveEntry] {
        filterModel.filteredAndSortedEntries(from: entries) { articleRepository.ratingScore(for: $0) }
    }

    private var archiveRowTagVisibilityActive: Bool {
        showDetailRowTags
            || filterModel.hasActiveFilters
            || !filterModel.tagSearchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var archiveNavigationTitle: String {
        switch kind {
        case .japan:
            String(localized: String.LocalizationValue(LocalizationKey.archiveTitleJP))
        case .english:
            String(localized: String.LocalizationValue(LocalizationKey.archiveTitleEN))
        }
    }

    @ViewBuilder
    private func archiveRowRatingMeter(for entry: JapanSCPArchiveEntry) -> some View {
        ArticleRatingMeterView(ratingScore: articleRepository.ratingScore(for: entry.url))
    }

    @ViewBuilder
    private func archiveSortModeMenuRowLabel(for mode: ArchiveListSortMode) -> some View {
        HStack {
            Text(String(localized: String.LocalizationValue(mode.localizationKey)))
            if filterModel.sortMode == mode {
                Spacer(minLength: 8)
                Image(systemName: "checkmark")
            }
        }
    }

    private var archiveSortMenu: some View {
        Menu {
            ForEach(ArchiveListSortMode.allCases) { mode in
                Button {
                    Haptics.light()
                    filterModel.sortMode = mode
                    filterModel.persistSortMode()
                } label: {
                    archiveSortModeMenuRowLabel(for: mode)
                }
            }
        } label: {
            Image(systemName: "arrow.up.arrow.down.circle")
        }
        .accessibilityLabel(String(localized: String.LocalizationValue(LocalizationKey.archiveSortToolbarAccessibility)))
    }

    private var archiveRowTagsToggleButton: some View {
        Button {
            Haptics.light()
            showDetailRowTags.toggle()
        } label: {
            Image(systemName: showDetailRowTags ? "tag.fill" : "tag")
                .foregroundStyle(showDetailRowTags ? AppTheme.brandAccent : AppTheme.textPrimary)
        }
        .accessibilityLabel(String(localized: String.LocalizationValue(LocalizationKey.archiveListRowTagsToggleAccessibility)))
    }

    private var archiveOpenWikiIndexButton: some View {
        Button {
            Haptics.medium()
            navigationRouter.push(.category(wikidotIndexURLForToolbar))
        } label: {
            Image(systemName: "safari")
        }
        .accessibilityLabel(String(localized: String.LocalizationValue(openWikiIndexLocalizationKey)))
    }

    var body: some View {
        IndexScreenLayout {
            List {
                Section {
                    if displayedEntries.isEmpty {
                        ContentUnavailableView(
                            String(localized: String.LocalizationValue(LocalizationKey.archiveFilterNoResults)),
                            systemImage: "line.3.horizontal.decrease.circle",
                            description: Text(String(localized: String.LocalizationValue(LocalizationKey.archiveFilterNoResultsHint)))
                        )
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 20, trailing: 16))
                    } else {
                        ForEach(displayedEntries) { entry in
                            Button {
                                Haptics.medium()
                                navigationRouter.pushArticle(url: entry.url)
                            } label: {
                                FoundationIndexRow(
                                    layout: .twoLine,
                                    title: formattedRowTitle(scpNumber: entry.scpNumber),
                                    subtitle: resolvedSubtitle(entry),
                                    tags: entry.tags,
                                    showsTags: archiveRowTagVisibilityActive,
                                    monospacedTitleDigits: true,
                                    trailing: {
                                        archiveRowRatingMeter(for: entry)
                                    }
                                )
                            }
                            .buttonStyle(.plain)
                            .indexListRowChrome()
                        }
                    }
                } header: {
                    TagFilterView(model: filterModel, segmentEntries: entries, listChrome: .listSectionHeader)
                }
            }
            .listStyle(.plain)
            .listSectionSeparator(.hidden)
            .scrollContentBackground(.hidden)
        } bottomAccessory: {
            VStack(spacing: 0) {
                seriesPicker
                segmentPicker
            }
        }
        .navigationTitle(archiveNavigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                archiveSortMenu
                archiveRowTagsToggleButton
                archiveOpenWikiIndexButton
            }
        }
        .onChange(of: selectedSeries) { _, newSeries in
            filterModel.clearFilters()
            if let initialTagFilters {
                filterModel.selectedTags = initialTagFilters
            }
            let starts = newSeries.segmentStarts
            guard !starts.isEmpty else { return }
            if !starts.contains(selectedSegmentStart) {
                selectedSegmentStart = starts[0]
            }
        }
        .onChange(of: selectedSegmentStart) { _, _ in
            filterModel.clearFilters()
            if let initialTagFilters {
                filterModel.selectedTags = initialTagFilters
            }
        }
        .tint(AppTheme.textPrimary)
    }

    private var wikidotIndexURLForToolbar: URL {
        switch kind {
        case .japan:
            selectedSeries.wikidotSeriesIndexURL
        case .english:
            selectedSeries.wikidotEnglishMainlistTranslationSeriesIndexURL
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
                            .foregroundStyle(AppTheme.textPrimary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(isSelected ? AppTheme.textPrimary.opacity(0.14) : AppTheme.mainBackground)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .stroke(
                                        AppTheme.borderSubtle.opacity(isSelected ? 1.0 : 0.6),
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
        .background(AppTheme.mainBackground.opacity(0.98))
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
                            .foregroundStyle(AppTheme.textPrimary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(isSelected ? AppTheme.textPrimary.opacity(0.14) : AppTheme.mainBackground)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .stroke(
                                        AppTheme.borderSubtle.opacity(isSelected ? 1.0 : 0.6),
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
        .background(AppTheme.mainBackground.opacity(0.98))
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
}

#Preview("JP") {
    @Previewable @State var router = NavigationRouter()
    @Previewable @State var repo = ArticleRepository()
    let meta = JapanSCPListMetadataStore(cacheRepository: SCPListCacheRepository())
    NavigationStack {
        ArchiveArticleListView(
            navigationRouter: router,
            articleRepository: repo,
            kind: .japan,
            japanSCPListMetadataStore: meta
        )
    }
}

#Preview("EN") {
    @Previewable @State var router = NavigationRouter()
    @Previewable @State var repo = ArticleRepository()
    let meta = JapanSCPListMetadataStore(cacheRepository: SCPListCacheRepository())
    NavigationStack {
        ArchiveArticleListView(
            navigationRouter: router,
            articleRepository: repo,
            kind: .english,
            japanSCPListMetadataStore: meta
        )
    }
}
