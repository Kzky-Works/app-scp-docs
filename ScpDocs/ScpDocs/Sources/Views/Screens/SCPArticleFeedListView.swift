import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// SCP-JP / 本家 SCP フィードの下段: 1000 件ブロック内を「全体」または 100 件刻みで絞り込む。
private enum MainlistThousandSubband: Equatable {
    /// 選択中シリーズの 1000 件（例: 001–1000）すべて。
    case fullThousand
    /// シリーズ内の 100 件ブロック（0…9 → 先頭から 10 区間）。
    case hundred(Int)
}

/// 3 系統キャッシュ由来の記事一覧（ネイティブ）。行タップで `ReaderView`（`ArticleView`）へ。
struct SCPArticleFeedListView: View {
    let kind: SCPArticleFeedKind
    let feedCache: SCPArticleFeedCacheRepository
    let japanSCPListMetadataStore: JapanSCPListMetadataStore?
    let personnelReadingJournal: PersonnelReadingJournal?
    @Bindable var articleRepository: ArticleRepository
    @Bindable var navigationRouter: NavigationRouter

    @Bindable private var connectivity = ConnectivityMonitor.shared
    @State private var cachedEntries: [SCPArticle] = []
    @State private var intBranchFilterID: String = "all"
    /// SCP-JP / 本家 SCP フィード: 1000 件単位（シリーズ Ⅰ–Ⅴ / 1–Ⅹ）の先頭インデックス（0 始まり）。
    @State private var mainlistSeriesBandIndex: Int = 0
    @State private var mainlistThousandSubband: MainlistThousandSubband = .fullThousand

    private var screenTitle: String {
        let key = switch kind {
        case .jp: LocalizationKey.homeFeedListTitleJP
        case .en: LocalizationKey.homeFeedListTitleEN
        case .int: LocalizationKey.homeFeedListTitleINT
        case .tales: LocalizationKey.homeFeedListTitleTales
        case .gois: LocalizationKey.homeFeedListTitleGois
        case .canons: LocalizationKey.homeFeedListTitleCanons
        case .jokes: LocalizationKey.homeFeedListTitleJokes
        }
        return String(localized: String.LocalizationValue(key))
    }

    /// 英語 `-en` は INT カタログでは扱わない（ホームの EN 専用一覧へ）。
    private var intCatalogEntriesExcludingEnglish: [SCPArticle] {
        guard kind == .int else { return cachedEntries }
        return cachedEntries.filter { !InternationalBranchPortalOption.SCPIntSlugLanguageTail.isEnglishBranchCatalogEntry($0) }
    }

    private var catalogListEntries: [SCPArticle] {
        switch kind {
        case .int:
            let base = intCatalogEntriesExcludingEnglish
            guard let filter = InternationalBranchPortalOption.option(id: intBranchFilterID) else {
                return base
            }
            return base.filter { filter.matchesCatalogEntry($0) }
        case .jp, .en:
            return mainlistBandFilteredArticles(from: cachedEntries)
        case .tales, .gois, .canons, .jokes:
            return cachedEntries
        }
    }

    private var intCatalogFilteredEmpty: Bool {
        kind == .int && !intCatalogEntriesExcludingEnglish.isEmpty && catalogListEntries.isEmpty
    }

    private var mainlistBandFilteredEmpty: Bool {
        guard kind == .jp || kind == .en else { return false }
        return !cachedEntries.isEmpty && catalogListEntries.isEmpty
    }

    private var mainlistSelectedNumberRange: ClosedRange<Int> {
        let s = mainlistSeriesBandIndex
        switch mainlistThousandSubband {
        case .fullThousand:
            let lo = s * 1000 + 1
            let hi = (s + 1) * 1000
            return lo...hi
        case .hundred(let h):
            let lo = s * 1000 + h * 100 + 1
            let hi = s * 1000 + (h + 1) * 100
            return lo...hi
        }
    }

    private func mainlistBandFilteredArticles(from entries: [SCPArticle]) -> [SCPArticle] {
        entries.filter { article in
            guard let n = TrifoldReportFeedRowFormatter.catalogOrderingNumber(article: article, feedKind: kind) else {
                return false
            }
            return mainlistSelectedNumberRange.contains(n)
        }
    }

    private var mainlistSeriesBandCount: Int {
        switch kind {
        case .jp: 5
        case .en: 10
        default: 0
        }
    }

    var body: some View {
        Group {
            if cachedEntries.isEmpty || (kind == .int && intCatalogEntriesExcludingEnglish.isEmpty) {
                TacticalArchiveEmptyPanel(
                    titleLocalizationKey: connectivity.isPathSatisfied
                        ? LocalizationKey.tacticalEmptyArchiveTitle
                        : LocalizationKey.tacticalEmptyNetworkTitle,
                    subtitleLocalizationKey: connectivity.isPathSatisfied
                        ? LocalizationKey.tacticalEmptyArchiveSubtitle
                        : LocalizationKey.tacticalEmptyNetworkSubtitle,
                    usesNetworkInterruptedCopy: !connectivity.isPathSatisfied,
                    useCompactListTypography: true
                )
                .padding(.horizontal, 16)
                .frame(maxWidth: .infinity, minHeight: 220)
            } else if intCatalogFilteredEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Text(String(localized: String.LocalizationValue(LocalizationKey.intCatalogBranchFilterEmptyTitle)))
                        .font(AppTypography.feedListOnePointDown(.body, weight: .semibold))
                        .foregroundStyle(AppTheme.textPrimary)
                    Text(String(localized: String.LocalizationValue(LocalizationKey.intCatalogBranchFilterEmptySubtitle)))
                        .font(AppTypography.feedListOnePointDown(.subheadline, weight: .medium))
                        .foregroundStyle(AppTheme.textSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.vertical, 28)
            } else if mainlistBandFilteredEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Text(String(localized: String.LocalizationValue(LocalizationKey.feedTrifoldBandFilterEmptyTitle)))
                        .font(AppTypography.feedListOnePointDown(.body, weight: .semibold))
                        .foregroundStyle(AppTheme.textPrimary)
                    Text(String(localized: String.LocalizationValue(LocalizationKey.feedTrifoldBandFilterEmptySubtitle)))
                        .font(AppTypography.feedListOnePointDown(.subheadline, weight: .medium))
                        .foregroundStyle(AppTheme.textSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.vertical, 28)
            } else {
                List {
                    ForEach(catalogListEntries, id: \.self) { article in
                    Button {
                        Haptics.medium()
                        if let u = article.resolvedURL {
                            navigationRouter.pushArticle(url: u)
                        }
                    } label: {
                        HStack(alignment: .top, spacing: 10) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(TrifoldReportFeedRowFormatter.scpNumberLine(article: article, feedKind: kind))
                                    .font(AppTypography.feedListOnePointDown(.subheadline, weight: .semibold))
                                    .foregroundStyle(AppTheme.textPrimary)
                                    .monospaced()
                                    .lineLimit(1)
                                Text(article.t)
                                    .font(AppTypography.feedListOnePointDown(.body, weight: .semibold))
                                    .foregroundStyle(AppTheme.textPrimary)
                                    .lineLimit(3)
                                if let oc = trifoldListRowObjectClassDisplay(article: article) {
                                    Text(oc)
                                        .font(AppTypography.feedListOnePointDown(.caption1, weight: .semibold))
                                        .foregroundStyle(AppTheme.textSecondary)
                                        .lineLimit(1)
                                }
                            }
                            Spacer(minLength: 6)
                            if let u = article.resolvedURL, articleRepository.isRead(url: u) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(AppTypography.feedListOnePointDown(.body, weight: .regular))
                                    .foregroundStyle(AppTheme.textSecondary)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
        .background(AppTheme.mainBackground)
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(screenTitle)
                    .font(AppTypography.feedListOnePointDown(.headline, weight: .semibold))
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.8)
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            VStack(spacing: 0) {
                if kind == .jp || kind == .en {
                    mainlistTrifoldBandChrome
                }
                if kind == .int {
                    internationalBranchPortalChrome
                }
            }
        }
        .task(id: kind) {
            cachedEntries = feedCache.loadPersistedPayload(kind: kind)?.entries ?? []
            if kind == .jp || kind == .en {
                mainlistSeriesBandIndex = 0
                mainlistThousandSubband = .fullThousand
            }
        }
        .onAppear {
            personnelReadingJournal?.setActiveCatalogFeed(kind)
        }
    }

    private func listRowObjectClassLabel(wiki: String) -> String {
        if let key = SCPJPTagObjectClassCatalog.chipLocalizationKey(forWikiEqualityTitle: wiki) {
            return String(localized: String.LocalizationValue(key))
        }
        return wiki
    }

    private func trifoldListRowObjectClassDisplay(article: SCPArticle) -> String? {
        if let meta = japanSCPListMetadataStore, let oc = meta.trifoldListRowObjectClass(article: article) {
            return listRowObjectClassLabel(wiki: oc)
        }
        if let c = article.c?.trimmingCharacters(in: .whitespacesAndNewlines), !c.isEmpty {
            return listRowObjectClassLabel(wiki: c)
        }
        return nil
    }

    @ViewBuilder
    private var mainlistTrifoldBandChrome: some View {
        let seriesCount = mainlistSeriesBandCount
        VStack(alignment: .leading, spacing: 8) {
            Text(String(localized: String.LocalizationValue(LocalizationKey.feedTrifoldSeriesPickerCaption)))
                .font(AppTypography.feedListOnePointDown(.caption2, weight: .semibold))
                .foregroundStyle(AppTheme.textSecondary)
                .padding(.horizontal, 16)
                .padding(.top, 8)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(0 ..< seriesCount, id: \.self) { idx in
                        Button {
                            Haptics.light()
                            mainlistSeriesBandIndex = idx
                            mainlistThousandSubband = .fullThousand
                        } label: {
                            TagChipView(
                                label: mainlistSeriesChipTitle(seriesIndex: idx),
                                isSelected: mainlistSeriesBandIndex == idx
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 2)
            }
            .accessibilityElement(children: .contain)
            .accessibilityLabel(String(localized: String.LocalizationValue(LocalizationKey.feedTrifoldSeriesPickerCaption)))

            Text(String(localized: String.LocalizationValue(LocalizationKey.feedTrifoldHundredPickerCaption)))
                .font(AppTypography.feedListOnePointDown(.caption2, weight: .semibold))
                .foregroundStyle(AppTheme.textSecondary)
                .padding(.horizontal, 16)
                .padding(.top, 2)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    Button {
                        Haptics.light()
                        mainlistThousandSubband = .fullThousand
                    } label: {
                        TagChipView(
                            label: mainlistFullThousandRangeTitle(),
                            isSelected: mainlistThousandSubband == .fullThousand
                        )
                    }
                    .buttonStyle(.plain)

                    ForEach(0 ..< 10, id: \.self) { h in
                        Button {
                            Haptics.light()
                            mainlistThousandSubband = .hundred(h)
                        } label: {
                            TagChipView(
                                label: mainlistHundredChipTitle(hundredIndex: h),
                                isSelected: isMainlistHundredChipSelected(h)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 4)
            }
            .accessibilityElement(children: .contain)
            .accessibilityLabel(String(localized: String.LocalizationValue(LocalizationKey.feedTrifoldHundredPickerCaption)))
            .padding(.bottom, 8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.cardStandard.ignoresSafeArea(edges: .bottom))
        .overlay(alignment: .top) {
            Rectangle()
                .fill(AppTheme.terminalSilver.opacity(0.35))
                .frame(height: 1)
        }
    }

    private func mainlistSeriesChipTitle(seriesIndex: Int) -> String {
        let key: String = switch (kind, seriesIndex) {
        case (.jp, 0): LocalizationKey.feedTrifoldJpSeries1
        case (.jp, 1): LocalizationKey.feedTrifoldJpSeries2
        case (.jp, 2): LocalizationKey.feedTrifoldJpSeries3
        case (.jp, 3): LocalizationKey.feedTrifoldJpSeries4
        case (.jp, 4): LocalizationKey.feedTrifoldJpSeries5
        case (.en, 0): LocalizationKey.feedTrifoldEnSeries1
        case (.en, 1): LocalizationKey.feedTrifoldEnSeries2
        case (.en, 2): LocalizationKey.feedTrifoldEnSeries3
        case (.en, 3): LocalizationKey.feedTrifoldEnSeries4
        case (.en, 4): LocalizationKey.feedTrifoldEnSeries5
        case (.en, 5): LocalizationKey.feedTrifoldEnSeries6
        case (.en, 6): LocalizationKey.feedTrifoldEnSeries7
        case (.en, 7): LocalizationKey.feedTrifoldEnSeries8
        case (.en, 8): LocalizationKey.feedTrifoldEnSeries9
        case (.en, 9): LocalizationKey.feedTrifoldEnSeries10
        default: LocalizationKey.feedTrifoldJpSeries1
        }
        return String(localized: String.LocalizationValue(key))
    }

    private func mainlistFullThousandRangeTitle() -> String {
        let s = mainlistSeriesBandIndex
        let lo = s * 1000 + 1
        let hi = (s + 1) * 1000
        let format = String(localized: String.LocalizationValue(LocalizationKey.feedTrifoldHundredRangeFormat))
        return String(format: format, scpOrdinalListToken(lo), scpOrdinalListToken(hi))
    }

    private func mainlistHundredChipTitle(hundredIndex: Int) -> String {
        let s = mainlistSeriesBandIndex
        let lo = s * 1000 + hundredIndex * 100 + 1
        let hi = s * 1000 + (hundredIndex + 1) * 100
        let format = String(localized: String.LocalizationValue(LocalizationKey.feedTrifoldHundredRangeFormat))
        return String(format: format, scpOrdinalListToken(lo), scpOrdinalListToken(hi))
    }

    private func isMainlistHundredChipSelected(_ h: Int) -> Bool {
        if case .hundred(let x) = mainlistThousandSubband { return x == h }
        return false
    }

    private func scpOrdinalListToken(_ n: Int) -> String {
        if n < 1000 {
            return String(format: "%03d", n)
        }
        return String(n)
    }

    @ViewBuilder
    private var internationalBranchPortalChrome: some View {
        let options = InternationalBranchPortalOption.ordered
        VStack(alignment: .leading, spacing: 6) {
            Text(String(localized: String.LocalizationValue(LocalizationKey.intCatalogBranchPickerCaption)))
                .font(AppTypography.feedListOnePointDown(.caption2, weight: .semibold))
                .foregroundStyle(AppTheme.textSecondary)
                .padding(.horizontal, 16)
                .padding(.top, 8)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(options) { option in
                        Button {
                            Haptics.light()
                            intBranchFilterID = option.id
                        } label: {
                            TagChipView(
                                label: String(localized: String.LocalizationValue(option.chipTitleLocalizationKey)),
                                isSelected: intBranchFilterID == option.id
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 4)
            }
            .accessibilityElement(children: .contain)
            .accessibilityLabel(String(localized: String.LocalizationValue(LocalizationKey.intCatalogBranchPickerCaption)))
            .padding(.bottom, 8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.cardStandard.ignoresSafeArea(edges: .bottom))
        .overlay(alignment: .top) {
            Rectangle()
                .fill(AppTheme.terminalSilver.opacity(0.35))
                .frame(height: 1)
        }
    }
}
