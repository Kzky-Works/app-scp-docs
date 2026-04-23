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

    private(set) var selectedBranch: Branch
    private(set) var fontSizeMultiplier: Double
    private(set) var uiLanguage: AppUILanguage
    private(set) var appearancePreference: AppAppearancePreference

    /// 3 系統キャッシュの件数（未取得時は 0）。
    private(set) var jpCatalogArticleCount: Int = 0
    private(set) var enCatalogArticleCount: Int = 0
    private(set) var intCatalogArticleCount: Int = 0

    /// 各フィード内で `ArticleRepository` 上まだ既読扱いでない件数。
    private(set) var jpCatalogUnreadCount: Int = 0
    private(set) var enCatalogUnreadCount: Int = 0
    private(set) var intCatalogUnreadCount: Int = 0

    /// `PersonnelRecord` ベースの「続きから読む」候補（読了率 85% 未満・最新アクセス）。
    private(set) var continueReadingFromPersonnelURL: URL?

    /// 「Daily Assignment」: キャッシュ済み JP フィードからのおすすめ（未読優先）。
    private(set) var dailyAssignmentURL: URL?
    private(set) var dailyAssignmentTitle: String = ""
    private(set) var dailyAssignmentIdentifier: String = ""

    /// `continueReadingFromPersonnelURL` が無いときの「Random Discovery」先（未読からランダム）。
    private(set) var randomDiscoveryURL: URL?

    init(
        branchCatalog: any BranchCataloging = StaticBranchCatalog(),
        settingsRepository: SettingsRepository,
        articleRepository: ArticleRepository,
        trifoldIndexStore: SCPArticleTrifoldIndexStore? = nil,
        personnelJournal: PersonnelReadingJournal? = nil
    ) {
        self.branchCatalog = branchCatalog
        self.settingsRepository = settingsRepository
        self.articleRepository = articleRepository
        self.trifoldIndexStore = trifoldIndexStore
        self.personnelJournal = personnelJournal
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

    /// ホームの非対称グリッド用メトリクスを再計算する（同期完了後などに呼ぶ）。
    func refreshTrifoldPersonnelDashboard() {
        guard let trifoldIndexStore else {
            jpCatalogArticleCount = 0
            enCatalogArticleCount = 0
            intCatalogArticleCount = 0
            jpCatalogUnreadCount = 0
            enCatalogUnreadCount = 0
            intCatalogUnreadCount = 0
            continueReadingFromPersonnelURL = nil
            recomputeDashboardAssignments()
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
            continueReadingFromPersonnelURL = try? personnelJournal.latestContinueReadingURL()
        } else {
            continueReadingFromPersonnelURL = nil
        }
        recomputeDashboardAssignments()
    }

    var resumeMissionTitle: String {
        guard let url = continueReadingFromPersonnelURL else { return "" }
        let trimmed = articleRepository.cachedPageTitle(for: url)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if trimmed.isEmpty { return url.lastPathComponent }
        return trimmed
    }

    var resumeMissionIdentifier: String {
        continueReadingFromPersonnelURL?.lastPathComponent ?? ""
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

    private func recomputeDashboardAssignments() {
        guard let trifoldIndexStore else {
            dailyAssignmentURL = nil
            dailyAssignmentTitle = ""
            dailyAssignmentIdentifier = ""
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

        let jpArticles = trifoldIndexStore.catalogEntries(for: .jp)
        if let pick = jpArticles.first(where: { article in
            guard let u = article.resolvedURL else { return false }
            return !articleRepository.isRead(url: u)
        }), let url = pick.resolvedURL {
            dailyAssignmentURL = url
            dailyAssignmentTitle = pick.t
            dailyAssignmentIdentifier = pick.i
        } else if let first = jpArticles.first, let url = first.resolvedURL {
            dailyAssignmentURL = url
            dailyAssignmentTitle = first.t
            dailyAssignmentIdentifier = first.i
        } else {
            dailyAssignmentURL = nil
            dailyAssignmentTitle = ""
            dailyAssignmentIdentifier = ""
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
