import SwiftUI

struct MainView: View {
    let homeViewModel: HomeViewModel
    @Bindable var homeNavigationRouter: NavigationRouter
    @Bindable var libraryNavigationRouter: NavigationRouter
    @Bindable var settingsNavigationRouter: NavigationRouter
    @Bindable var articleRepository: ArticleRepository
    @Bindable var purchaseRepository: PurchaseRepository
    let japanSCPListMetadataStore: JapanSCPListMetadataStore
    let scpListCacheRepository: SCPListCacheRepository
    @Binding var selectedTab: AppRootTab

    private let scpListSyncService = SCPListSyncService()

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack(path: $homeNavigationRouter.path) {
                HomeView(
                    navigationRouter: homeNavigationRouter,
                    homeViewModel: homeViewModel,
                    japanSCPListMetadataStore: japanSCPListMetadataStore
                )
                .navigationDestination(for: NavigationRoute.self) { route in
                    articleDestination(for: route, navigationRouter: homeNavigationRouter)
                }
            }
            .tabRootAdBannerLayout(isAdRemovalActive: purchaseRepository.isAdRemovalActive)
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
            .tabRootAdBannerLayout(isAdRemovalActive: purchaseRepository.isAdRemovalActive)
            .tabItem {
                Label(
                    String(localized: String.LocalizationValue(LocalizationKey.tabLibrary)),
                    systemImage: "books.vertical.fill"
                )
            }
            .tag(AppRootTab.library)

            NavigationStack(path: $settingsNavigationRouter.path) {
                SettingsView(
                    homeViewModel: homeViewModel,
                    articleRepository: articleRepository,
                    purchaseRepository: purchaseRepository,
                    navigationRouter: settingsNavigationRouter
                )
                .navigationDestination(for: NavigationRoute.self) { route in
                    articleDestination(for: route, navigationRouter: settingsNavigationRouter)
                }
            }
            .tabRootAdBannerLayout(isAdRemovalActive: purchaseRepository.isAdRemovalActive)
            .tabItem {
                Label(
                    String(localized: String.LocalizationValue(LocalizationKey.tabSettings)),
                    systemImage: "gearshape"
                )
            }
            .tag(AppRootTab.settings)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .preferredColorScheme(homeViewModel.appearancePreference == .dark ? .dark : .light)
        .environment(\.locale, homeViewModel.resolvedLocale)
        .tint(AppTheme.brandAccent)
        .task {
            await scpListSyncService.syncIfNeeded(
                metadataStore: japanSCPListMetadataStore,
                cacheRepository: scpListCacheRepository
            )
        }
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
        case .scpJapanArchive(let initialTagFilters):
            ArchiveArticleListView(
                navigationRouter: navigationRouter,
                articleRepository: articleRepository,
                kind: .japan,
                japanSCPListMetadataStore: japanSCPListMetadataStore,
                initialTagFilters: initialTagFilters
            )
        case .scpEnglishArchive(let initialTagFilters):
            ArchiveArticleListView(
                navigationRouter: navigationRouter,
                articleRepository: articleRepository,
                kind: .english,
                japanSCPListMetadataStore: japanSCPListMetadataStore,
                initialTagFilters: initialTagFilters
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
                homeViewModel: homeViewModel
            )
        case .goiFormatsIndex:
            GoIFormatsIndexView(navigationRouter: navigationRouter)
        case .goiPortal:
            GoIPortalView(
                navigationRouter: navigationRouter,
                branch: homeViewModel.selectedBranch
            )
        case .staffGuideIndex:
            StaffGuideIndexView(navigationRouter: navigationRouter)
        case .homeScpSearch:
            HomeSearchView(
                navigationRouter: navigationRouter,
                articleRepository: articleRepository,
                homeViewModel: homeViewModel,
                japanSCPListMetadataStore: japanSCPListMetadataStore
            )
        case .category(let url), .article(let url):
            ArticleView(
                entryURL: url,
                homeViewModel: homeViewModel,
                navigationRouter: navigationRouter,
                articleRepository: articleRepository
            )
        }
    }
}

private extension View {
    /// 広告を `NavigationStack` の **兄弟**として `VStack` 最下段に固定し、`safeAreaInset` 由来の重なり・ヒットテストずれを避ける。
    @ViewBuilder
    func tabRootAdBannerLayout(isAdRemovalActive: Bool) -> some View {
        if isAdRemovalActive {
            self
        } else {
            VStack(spacing: 0) {
                self
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                AdBannerStripeContainer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
