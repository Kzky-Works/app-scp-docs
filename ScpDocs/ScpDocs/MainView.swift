import SwiftUI

struct MainView: View {
    let homeViewModel: HomeViewModel
    @Bindable var homeNavigationRouter: NavigationRouter
    @Bindable var libraryNavigationRouter: NavigationRouter
    @Bindable var articleRepository: ArticleRepository

    var body: some View {
        TabView {
            NavigationStack(path: $homeNavigationRouter.path) {
                HomeView(
                    navigationRouter: homeNavigationRouter,
                    articleRepository: articleRepository,
                    homeViewModel: homeViewModel
                )
                .navigationDestination(for: NavigationRoute.self) { route in
                    articleDestination(for: route, navigationRouter: homeNavigationRouter)
                }
            }
            .tabItem {
                Label(
                    String(localized: String.LocalizationValue(LocalizationKey.tabHome)),
                    systemImage: "house.fill"
                )
            }

            NavigationStack(path: $libraryNavigationRouter.path) {
                LibraryView(
                    navigationRouter: libraryNavigationRouter,
                    articleRepository: articleRepository
                )
                .navigationDestination(for: NavigationRoute.self) { route in
                    articleDestination(for: route, navigationRouter: libraryNavigationRouter)
                }
            }
            .tabItem {
                Label(
                    String(localized: String.LocalizationValue(LocalizationKey.tabLibrary)),
                    systemImage: "books.vertical.fill"
                )
            }

            NavigationStack {
                SettingsView(
                    homeViewModel: homeViewModel,
                    articleRepository: articleRepository
                )
            }
            .tabItem {
                Label(
                    String(localized: String.LocalizationValue(LocalizationKey.tabSettings)),
                    systemImage: "gearshape"
                )
            }
        }
        .preferredColorScheme(.dark)
        .tint(AppTheme.accentPrimary)
    }

    @ViewBuilder
    private func articleDestination(for route: NavigationRoute, navigationRouter: NavigationRouter) -> some View {
        switch route {
        case .home:
            EmptyView()
        case .category(let url), .article(let url):
            ArticleView(
                entryURL: url,
                navigationRouter: navigationRouter,
                articleRepository: articleRepository
            )
        }
    }
}
