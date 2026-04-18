import SwiftUI

@main
struct ScpDocsApp: App {
    @State private var homeViewModel: HomeViewModel

    init() {
        let settingsRepository = SettingsRepository()
        _homeViewModel = State(wrappedValue: HomeViewModel(settingsRepository: settingsRepository))
    }
    @State private var homeNavigationRouter = NavigationRouter()
    @State private var libraryNavigationRouter = NavigationRouter()
    @State private var articleRepository = ArticleRepository()

    var body: some Scene {
        WindowGroup {
            MainView(
                homeViewModel: homeViewModel,
                homeNavigationRouter: homeNavigationRouter,
                libraryNavigationRouter: libraryNavigationRouter,
                articleRepository: articleRepository
            )
        }
    }
}
