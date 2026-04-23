import Foundation
import Observation

@Observable
@MainActor
final class HomeViewModel {
    private let branchCatalog: any BranchCataloging
    private let settingsRepository: SettingsRepository
    private let articleRepository: ArticleRepository
    private let trifoldIndexStore: SCPArticleTrifoldIndexStore?
    private let personnelJournal: PersonnelReadingJournal?
    private let japanSCPListMetadataStore: JapanSCPListMetadataStore?
    private let scpArticleFeedCacheRepository: SCPArticleFeedCacheRepository?

    /// 3 系統キャッシュの件数（未取得時は 0）。
    private(set) var jpCatalogArticleCount: Int = 0
    private(set) var enCatalogArticleCount: Int = 0
    private(set) var intCatalogArticleCount: Int = 0

    /// 各フィード内で `ArticleRepository` 上まだ既読扱いでない件数。
    private(set) var jpCatalogUnreadCount: Int = 0
    private(set) var enCatalogUnreadCount: Int = 0
    private(set) var intCatalogUnreadCount: Int = 0

    private(set) var selectedBranch: Branch
    private(set) var fontSizeMultiplier: Double
    private(set) var uiLanguage: AppUILanguage
    private(set) var appearancePreference: AppAppearancePreference

    /// スクロール進捗が 95% 未満のときの再開先 URL。
    private(set) var continueReadingTargetURL: URL?
    /// `continueReadingTargetURL` 向けのホーム用表示行。
    private(set) var continueReadingRow: ContinueReadingRowDisplay?

    /// 続きから読む候補が無いときのランダム遷移先（未読優先）。
    private(set) var randomDiscoveryURL: URL?

    init(
        branchCatalog: any BranchCataloging = StaticBranchCatalog(),
        settingsRepository: SettingsRepository,
        articleRepository: ArticleRepository,
        trifoldIndexStore: SCPArticleTrifoldIndexStore? = nil,
        personnelJournal: PersonnelReadingJournal? = nil,
        japanSCPListMetadataStore: JapanSCPListMetadataStore? = nil,
        scpArticleFeedCacheRepository: SCPArticleFeedCacheRepository? = nil
    ) {
        self.branchCatalog = branchCatalog
        self.settingsRepository = settingsRepository
        self.articleRepository = articleRepository
        self.trifoldIndexStore = trifoldIndexStore
        self.personnelJournal = personnelJournal
        self.japanSCPListMetadataStore = japanSCPListMetadataStore
        self.scpArticleFeedCacheRepository = scpArticleFeedCacheRepository
        let storedId = settingsRepository.loadSelectedBranchId()
        let resolved = branchCatalog.branch(id: storedId) ?? branchCatalog.defaultBranch
        self.selectedBranch = resolved
        if branchCatalog.branch(id: storedId) == nil {
            settingsRepository.saveSelectedBranchId(resolved.id)
        }
        self.fontSizeMultiplier = settingsRepository.loadFontSizeMultiplier()
        self.uiLanguage = settingsRepository.loadUILanguage()
        self.appearancePreference = settingsRepository.loadAppearancePreference()
    }

    /// ホームの「続きから読む」およびランダム先を再計算する（同期完了後などに呼ぶ）。
    func refreshTrifoldPersonnelDashboard() {
        guard let trifoldIndexStore else {
            jpCatalogArticleCount = 0
            enCatalogArticleCount = 0
            intCatalogArticleCount = 0
            jpCatalogUnreadCount = 0
            enCatalogUnreadCount = 0
            intCatalogUnreadCount = 0
            if let personnelJournal {
                continueReadingTargetURL = try? personnelJournal.latestContinueReadingURL(incompleteBelowProgress: 0.95)
            } else {
                continueReadingTargetURL = nil
            }
            continueReadingRow = rebuildContinueReadingRow()
            recomputeRandomDiscoveryURL()
            return
        }
        trifoldIndexStore.reloadFromCache()
        jpCatalogArticleCount = trifoldIndexStore.jpTotalCount
        enCatalogArticleCount = trifoldIndexStore.enTotalCount
        intCatalogArticleCount = trifoldIndexStore.intTotalCount
        jpCatalogUnreadCount = trifoldIndexStore.unreadCount(kind: .jp, articleRepository: articleRepository)
        enCatalogUnreadCount = trifoldIndexStore.unreadCount(kind: .en, articleRepository: articleRepository)
        intCatalogUnreadCount = trifoldIndexStore.unreadCount(kind: .int, articleRepository: articleRepository)
        if let personnelJournal {
            continueReadingTargetURL = try? personnelJournal.latestContinueReadingURL(incompleteBelowProgress: 0.95)
        } else {
            continueReadingTargetURL = nil
        }
        continueReadingRow = rebuildContinueReadingRow()
        recomputeRandomDiscoveryURL()
    }

    func totalCount(for kind: SCPArticleFeedKind) -> Int {
        switch kind {
        case .jp: jpCatalogArticleCount
        case .en: enCatalogArticleCount
        case .int: intCatalogArticleCount
        case .tales, .gois, .canons, .jokes: 0
        }
    }

    func unreadCount(for kind: SCPArticleFeedKind) -> Int {
        switch kind {
        case .jp: jpCatalogUnreadCount
        case .en: enCatalogUnreadCount
        case .int: intCatalogUnreadCount
        case .tales, .gois, .canons, .jokes: 0
        }
    }

    private func rebuildContinueReadingRow() -> ContinueReadingRowDisplay? {
        guard let url = continueReadingTargetURL else { return nil }
        let key = ArticleRepository.storageKey(for: url)
        let fromRepo = articleRepository.readingScrollDepth(for: url)
        let fromPersonnel = (try? personnelJournal?.scrollProgress(forNormalizedURLKey: key)) ?? 0
        let scroll = max(fromRepo, fromPersonnel)
        let objectClassFormat: (String) -> String = { oc in
            String(format: String(localized: String.LocalizationValue(LocalizationKey.homeContinueObjectClassFormat)), oc)
        }
        return ContinueReadingSummaryBuilder.build(
            url: url,
            scrollProgress: scroll,
            cachedPageTitle: articleRepository.cachedPageTitle(for: url),
            thumbnailURL: articleRepository.cachedFirstImageURL(for: url),
            japanListHint: japanSCPListMetadataStore?.readingHint(for: url),
            listMetaTitle: catalogListMetaTitle(for: url),
            categoryLabel: { String(localized: String.LocalizationValue($0)) },
            objectClassFormat: objectClassFormat
        )
    }

    private func catalogListMetaTitle(for url: URL) -> String? {
        guard let trifoldIndexStore else { return nil }
        let key = ArticleRepository.storageKey(for: url)
        for kind in SCPArticleFeedKind.trifoldReportCases {
            for article in trifoldIndexStore.catalogEntries(for: kind) {
                guard let u = article.resolvedURL else { continue }
                if ArticleRepository.storageKey(for: u) == key { return article.t }
            }
        }
        guard let feed = scpArticleFeedCacheRepository else { return nil }
        for kind in [SCPArticleFeedKind.tales, .gois, .canons, .jokes] {
            let entries = feed.loadPersistedGeneralMultiformPayload(kind: kind)?.entries ?? []
            for row in entries {
                guard let u = row.resolvedURL else { continue }
                if ArticleRepository.storageKey(for: u) == key { return row.t }
            }
        }
        return nil
    }

    private func recomputeRandomDiscoveryURL() {
        guard let trifoldIndexStore else {
            randomDiscoveryURL = nil
            return
        }

        func allUnreadArticleURLs() -> [URL] {
            var urls: [URL] = []
            for kind in SCPArticleFeedKind.trifoldReportCases {
                for article in trifoldIndexStore.catalogEntries(for: kind) {
                    guard let u = article.resolvedURL else { continue }
                    if !articleRepository.isRead(url: u) {
                        urls.append(u)
                    }
                }
            }
            return urls
        }

        let unreadURLs = allUnreadArticleURLs()
        randomDiscoveryURL = unreadURLs.randomElement()
        if randomDiscoveryURL == nil {
            let jpPool = trifoldIndexStore.catalogEntries(for: .jp)
            randomDiscoveryURL = jpPool.randomElement()?.resolvedURL
        }
    }

    var resolvedLocale: Locale {
        switch uiLanguage {
        case .system:
            .autoupdatingCurrent
        case .japanese:
            Locale(identifier: "ja")
        case .english:
            Locale(identifier: "en")
        }
    }

    func updateFontSizeMultiplier(_ value: Double) {
        let clamped = min(max(value, 0.75), 2.0)
        guard clamped != fontSizeMultiplier else { return }
        fontSizeMultiplier = clamped
        settingsRepository.saveFontSizeMultiplier(clamped)
    }

    func updateUILanguage(_ value: AppUILanguage) {
        guard value != uiLanguage else { return }
        uiLanguage = value
        settingsRepository.saveUILanguage(value)
    }

    func updateAppearancePreference(_ value: AppAppearancePreference) {
        guard value != appearancePreference else { return }
        appearancePreference = value
        settingsRepository.saveAppearancePreference(value)
    }

    var availableBranches: [Branch] {
        branchCatalog.allBranches
    }

    func selectBranch(id: String) {
        guard let branch = branchCatalog.branch(id: id), branch.id != selectedBranch.id else { return }
        selectedBranch = branch
        settingsRepository.saveSelectedBranchId(id)
    }

    var screenTitle: String {
        String(localized: String.LocalizationValue(LocalizationKey.homeTitle))
    }

    var branchDisplayTitle: String {
        String(localized: String.LocalizationValue(selectedBranch.displayNameKey))
    }

    /// ホーム `dashboardHeaderCard` の支部名（日本支部のみ短表記「SCP財団」）。
    var homeDashboardBranchTitle: String {
        if selectedBranch.id == BranchIdentifier.scpJapan {
            String(localized: String.LocalizationValue(LocalizationKey.homeDashboardBranchShortJapan))
        } else {
            branchDisplayTitle
        }
    }

    var branchBaseURLDisplay: String {
        selectedBranch.baseURL.absoluteString
    }

    var branchURLLabel: String {
        String(localized: String.LocalizationValue(LocalizationKey.branchBaseURLLabel))
    }

    /// ホーム `LazyVGrid` 用：現在支部に応じた 6 ピラーのラベルと SF Symbol 名（名前は `systemImageName`）。
    var homeGridItems: [HomeGridItemDescriptor] {
        HomeCategory.allCases.map { $0.gridDescriptor(for: selectedBranch) }
    }

    func loadLibraryListSortMode(for category: LibraryCategory) -> LibraryListSortMode {
        settingsRepository.loadLibraryListSortMode(for: category)
    }

    func saveLibraryListSortMode(_ mode: LibraryListSortMode, for category: LibraryCategory) {
        settingsRepository.saveLibraryListSortMode(mode, for: category)
    }
}
