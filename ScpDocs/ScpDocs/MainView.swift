import SwiftUI

struct MainView: View {
    let homeViewModel: HomeViewModel
    @Bindable var homeNavigationRouter: NavigationRouter
    @Bindable var libraryNavigationRouter: NavigationRouter
    @Bindable var settingsNavigationRouter: NavigationRouter
    @Bindable var articleRepository: ArticleRepository
    @Bindable var purchaseRepository: PurchaseRepository
    let japanSCPListMetadataStore: JapanSCPListMetadataStore
    let jpTagMapCacheRepository: JPTagMapCacheRepository
    let scpArticleFeedCacheRepository: SCPArticleFeedCacheRepository
    let personnelReadingJournal: PersonnelReadingJournal
    @Binding var selectedTab: AppRootTab

    private let jpTagMapSyncService = JPTagMapSyncService()

    private var scpArticleTrifoldSyncService: SCPArticleTrifoldSyncService {
        SCPArticleTrifoldSyncService(cacheRepository: scpArticleFeedCacheRepository)
    }

    private var multiformContentSyncService: MultiformContentSyncService {
        MultiformContentSyncService(cacheRepository: scpArticleFeedCacheRepository)
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack(path: $homeNavigationRouter.path) {
                HomeView(
                    navigationRouter: homeNavigationRouter,
                    homeViewModel: homeViewModel,
                    articleRepository: articleRepository,
                    onOpenSettings: { selectedTab = .settings }
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
            await Task.yield()
            await jpTagMapSyncService.syncIfNeeded(
                metadataStore: japanSCPListMetadataStore,
                cacheRepository: jpTagMapCacheRepository
            )
            await scpArticleTrifoldSyncService.syncAllFeedsIfNeeded()
            await multiformContentSyncService.syncAllMultiformFeedsIfNeeded()
            await MainActor.run {
                japanSCPListMetadataStore.reloadFromCache()
            }
            try? personnelReadingJournal.reconcile(from: articleRepository)
            homeViewModel.refreshTrifoldPersonnelDashboard()
            Haptics.light()
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
        case .scpJapanArchive(let seed):
            ArchiveArticleListView(
                navigationRouter: navigationRouter,
                articleRepository: articleRepository,
                kind: .japan,
                japanSCPListMetadataStore: japanSCPListMetadataStore,
                archiveSeed: seed
            )
        case .scpEnglishArchive(let seed):
            ArchiveArticleListView(
                navigationRouter: navigationRouter,
                articleRepository: articleRepository,
                kind: .english,
                japanSCPListMetadataStore: japanSCPListMetadataStore,
                archiveSeed: seed
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
                japanSCPListMetadataStore: japanSCPListMetadataStore,
                feedCache: scpArticleFeedCacheRepository
            )
        case .foundationTalesJPAuthorIndex:
            FoundationTalesJPIndexView(
                navigationRouter: navigationRouter,
                articleRepository: articleRepository,
                homeViewModel: homeViewModel
            )
        case .scpArticleCatalogFeed(let kind):
            if kind.isMultiformArchiveFeed {
                SCPGeneralContentListView(
                    kind: kind,
                    feedCache: scpArticleFeedCacheRepository,
                    japanSCPListMetadataStore: japanSCPListMetadataStore,
                    personnelReadingJournal: personnelReadingJournal,
                    articleRepository: articleRepository,
                    navigationRouter: navigationRouter
                )
            } else {
                SCPArticleFeedListView(
                    kind: kind,
                    feedCache: scpArticleFeedCacheRepository,
                    japanSCPListMetadataStore: japanSCPListMetadataStore,
                    personnelReadingJournal: personnelReadingJournal,
                    articleRepository: articleRepository,
                    navigationRouter: navigationRouter
                )
            }
        case .category(let url), .article(let url):
            ArticleView(
                entryURL: url,
                homeViewModel: homeViewModel,
                navigationRouter: navigationRouter,
                articleRepository: articleRepository,
                personnelReadingJournal: personnelReadingJournal,
                scpArticleFeedCacheRepository: scpArticleFeedCacheRepository,
                japanSCPListMetadataStore: japanSCPListMetadataStore
            )
            .id(ArticleRepository.storageKey(for: url))
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
