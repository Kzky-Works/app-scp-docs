import GoogleMobileAds
import SwiftUI

@main
struct ScpDocsApp: App {
    @State private var homeViewModel: HomeViewModel

    init() {
        let settingsRepository = SettingsRepository()
        _homeViewModel = State(wrappedValue: HomeViewModel(settingsRepository: settingsRepository))
        GADMobileAds.sharedInstance().start(completionHandler: nil)
    }
    @State private var homeNavigationRouter = NavigationRouter()
    @State private var libraryNavigationRouter = NavigationRouter()
    @State private var articleRepository = ArticleRepository()
    @State private var purchaseRepository = PurchaseRepository()
    @State private var rootTab: AppRootTab = .home

    var body: some Scene {
        WindowGroup {
            MainView(
                homeViewModel: homeViewModel,
                homeNavigationRouter: homeNavigationRouter,
                libraryNavigationRouter: libraryNavigationRouter,
                articleRepository: articleRepository,
                purchaseRepository: purchaseRepository,
                selectedTab: $rootTab
            )
        }
    }
}
