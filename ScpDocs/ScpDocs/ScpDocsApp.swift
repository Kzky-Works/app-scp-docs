import GoogleMobileAds
import SwiftUI

@main
struct ScpDocsApp: App {
    @State private var homeViewModel: HomeViewModel
    @State private var scpListCacheRepository: SCPListCacheRepository
    @State private var japanSCPListMetadataStore: JapanSCPListMetadataStore

    init() {
        let settingsRepository = SettingsRepository()
        _homeViewModel = State(wrappedValue: HomeViewModel(settingsRepository: settingsRepository))
        let scpCache = SCPListCacheRepository()
        _scpListCacheRepository = State(wrappedValue: scpCache)
        _japanSCPListMetadataStore = State(wrappedValue: JapanSCPListMetadataStore(cacheRepository: scpCache))
        AppTheme.configureTabBarAppearance()
        GADMobileAds.sharedInstance().start(completionHandler: nil)
    }
    @State private var homeNavigationRouter = NavigationRouter()
    @State private var libraryNavigationRouter = NavigationRouter()
    @State private var settingsNavigationRouter = NavigationRouter()
    @State private var articleRepository = ArticleRepository()
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
                scpListCacheRepository: scpListCacheRepository,
                selectedTab: $rootTab
            )
        }
    }
}
