import SwiftUI

struct MainView: View {
    let homeViewModel: HomeViewModel
    @Bindable var homeNavigationRouter: NavigationRouter
    @Bindable var libraryNavigationRouter: NavigationRouter
    @Bindable var articleRepository: ArticleRepository
    @Bindable var purchaseRepository: PurchaseRepository
    @Binding var selectedTab: AppRootTab

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack(path: $homeNavigationRouter.path) {
                HomeView(
                    navigationRouter: homeNavigationRouter,
                    homeViewModel: homeViewModel,
                    purchaseRepository: purchaseRepository
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
            .tag(AppRootTab.home)

            NavigationStack(path: $libraryNavigationRouter.path) {
                LibraryView(
                    navigationRouter: libraryNavigationRouter,
                    articleRepository: articleRepository,
                    homeViewModel: homeViewModel
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
            .tag(AppRootTab.library)

            NavigationStack {
                SettingsView(
                    homeViewModel: homeViewModel,
                    articleRepository: articleRepository,
                    purchaseRepository: purchaseRepository
                )
            }
            .tabItem {
                Label(
                    String(localized: String.LocalizationValue(LocalizationKey.tabSettings)),
                    systemImage: "gearshape"
                )
            }
            .tag(AppRootTab.settings)
        }
        .environment(\.locale, homeViewModel.resolvedLocale)
        .preferredColorScheme(.dark)
        .tint(AppTheme.accentPrimary)
    }

    @ViewBuilder
    private func articleDestination(for route: NavigationRoute, navigationRouter: NavigationRouter) -> some View {
        switch route {
        case .home:
            EmptyView()
        case .archiveIndex(let branchId):
            ArchiveIndexView(
                navigationRouter: navigationRouter,
                branch: Branch.branchForArchiveIndex(id: branchId)
            )
        case .libraryIndex:
            LibraryIndexView(
                navigationRouter: navigationRouter,
                branch: homeViewModel.selectedBranch
            )
        case .libraryList(let category):
            LibraryListView(
                navigationRouter: navigationRouter,
                category: category,
                branch: homeViewModel.selectedBranch,
                articleRepository: articleRepository,
                homeViewModel: homeViewModel,
                purchaseRepository: purchaseRepository
            )
        case .goiFormatsIndex:
            GoIFormatsIndexView(navigationRouter: navigationRouter)
        case .goiPortal:
            GoIPortalView(
                navigationRouter: navigationRouter,
                branch: homeViewModel.selectedBranch
            )
        case .category(let url), .article(let url):
            ArticleView(
                entryURL: url,
                fontSizeMultiplier: homeViewModel.fontSizeMultiplier,
                navigationRouter: navigationRouter,
                articleRepository: articleRepository
            )
        }
    }
}
