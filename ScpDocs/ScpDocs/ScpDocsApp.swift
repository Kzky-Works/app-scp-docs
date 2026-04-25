import GoogleMobileAds
import SwiftData
import SwiftUI

@main
struct ScpDocsApp: App {
    private static let personnelModelContainer: ModelContainer = {
        do {
            return try ModelContainer(for: PersonnelRecord.self)
        } catch {
            fatalError("SwiftData ModelContainer failed: \(error)")
        }
    }()

    @State private var homeViewModel: HomeViewModel
    @State private var wikiCatalogCacheRepository: WikiCatalogCacheRepository
    @State private var japanSCPListMetadataStore: JapanSCPListMetadataStore
    private let scpArticleFeedCacheRepository: SCPArticleFeedCacheRepository
    private let personnelReadingJournal: PersonnelReadingJournal

    init() {
#if canImport(UIKit)
        AppTypography.registerBundledBauhausLTDemiIfPresent()
        AppTypography.registerBundledHomePillarOpenFonts()
        AppTypography.registerFontAwesome6SolidIfPresent()
#endif
        let settingsRepository = SettingsRepository()
        let wikiCatalogCache = WikiCatalogCacheRepository()
        let articleRepo = ArticleRepository()
        let feedCache = SCPArticleFeedCacheRepository()
        let trifoldIndex = SCPArticleTrifoldIndexStore(feedCache: feedCache)
        let personnelJournal = PersonnelReadingJournal(container: Self.personnelModelContainer)

        self.scpArticleFeedCacheRepository = feedCache
        self.personnelReadingJournal = personnelJournal

        let japanMeta = JapanSCPListMetadataStore(wikiCatalogCacheRepository: wikiCatalogCache, articleFeedCache: feedCache)
        let homeVM = HomeViewModel(
            settingsRepository: settingsRepository,
            articleRepository: articleRepo,
            trifoldIndexStore: trifoldIndex,
            personnelJournal: personnelJournal,
            japanSCPListMetadataStore: japanMeta,
            scpArticleFeedCacheRepository: feedCache
        )

        /// 起動 `init` はメインスレッド・ウォッチドッグ対象。巨大 JSON の多重デコードや SwiftData 整列は初回描画後に回す。
        Task { @MainActor in
            try? personnelJournal.reconcile(from: articleRepo)
            japanMeta.reloadFromCache()
            homeVM.refreshTrifoldPersonnelDashboard()
        }

        _articleRepository = State(wrappedValue: articleRepo)
        _homeViewModel = State(wrappedValue: homeVM)
        _wikiCatalogCacheRepository = State(wrappedValue: wikiCatalogCache)
        _japanSCPListMetadataStore = State(wrappedValue: japanMeta)

        AppTheme.configureTabBarAppearance()
        GADMobileAds.sharedInstance().start(completionHandler: nil)
    }

    @State private var homeNavigationRouter = NavigationRouter()
    @State private var libraryNavigationRouter = NavigationRouter()
    @State private var settingsNavigationRouter = NavigationRouter()
    @State private var articleRepository: ArticleRepository
    @State private var purchaseRepository = PurchaseRepository()
    @State private var rootTab: AppRootTab = .home

    var body: some Scene {
        WindowGroup {
            MainView(
                homeViewModel: homeViewModel,
                homeNavigationRouter: homeNavigationRouter,
                libraryNavigationRouter: libraryNavigationRouter,
                settingsNavigationRouter: settingsNavigationRouter,
                articleRepository: articleRepository,
                purchaseRepository: purchaseRepository,
                japanSCPListMetadataStore: japanSCPListMetadataStore,
                wikiCatalogCacheRepository: wikiCatalogCacheRepository,
                scpArticleFeedCacheRepository: scpArticleFeedCacheRepository,
                personnelReadingJournal: personnelReadingJournal,
                selectedTab: $rootTab
            )
            .modelContainer(Self.personnelModelContainer)
        }
    }
}
