import SwiftUI

/// ライブラリの静的リスト（支部に応じた URL、検索、既読・お気に入り表示）。
struct LibraryListView: View {
    @Bindable var navigationRouter: NavigationRouter
    let category: LibraryCategory
    let branch: Branch
    let articleRepository: ArticleRepository
    private let homeViewModel: HomeViewModel
    @Bindable var purchaseRepository: PurchaseRepository

    @State private var searchText = ""
    @State private var sortMode: LibraryListSortMode

    init(
        navigationRouter: NavigationRouter,
        category: LibraryCategory,
        branch: Branch,
        articleRepository: ArticleRepository,
        homeViewModel: HomeViewModel,
        purchaseRepository: PurchaseRepository
    ) {
        self.navigationRouter = navigationRouter
        self.category = category
        self.branch = branch
        self.articleRepository = articleRepository
        self.homeViewModel = homeViewModel
        self._purchaseRepository = Bindable(purchaseRepository)
        _sortMode = State(initialValue: homeViewModel.loadLibraryListSortMode(for: category))
    }

    private var allItems: [LibraryItem] {
        LibraryStaticData.items(category: category, branch: branch)
    }

    private func localizedTitle(_ item: LibraryItem) -> String {
        if let injected = item.title, !injected.isEmpty {
            return injected
        }
        return String(localized: String.LocalizationValue(item.titleLocalizationKey))
    }

    private var filteredItems: [LibraryItem] {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        let base: [LibraryItem]
        if trimmed.isEmpty {
            base = allItems
        } else {
            let query = trimmed.lowercased()
            base = allItems.filter { item in
                localizedTitle(item).lowercased().contains(query)
                    || item.id.lowercased().contains(query)
            }
        }
        return base.sortedLibraryItems(
            mode: sortMode,
            titleKey: localizedTitle,
            locale: homeViewModel.resolvedLocale
        )
    }

    var body: some View {
        VStack(spacing: 0) {
            List {
                ForEach(filteredItems) { item in
                    Button {
                        Haptics.medium()
                        navigationRouter.pushArticle(url: item.url)
                    } label: {
                        HStack(alignment: .center, spacing: 12) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(localizedTitle(item))
                                    .font(.body.weight(.medium))
                                    .foregroundStyle(AppTheme.accentPrimary)
                                    .multilineTextAlignment(.leading)
                                Text(item.url.absoluteString)
                                    .font(.caption2)
                                    .foregroundStyle(AppTheme.accentPrimary.opacity(0.65))
                                    .lineLimit(2)
                            }
                            Spacer(minLength: 0)
                            if articleRepository.isBookmarked(url: item.url) {
                                Image(systemName: "bookmark.fill")
                                    .foregroundStyle(AppTheme.accentPrimary)
                                    .imageScale(.medium)
                            }
                            if articleRepository.isRead(url: item.url) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(AppTheme.accentPrimary)
                                    .imageScale(.medium)
                            }
                        }
                    }
                    .listRowBackground(AppTheme.backgroundPrimary)
                }
            }
            .scrollContentBackground(.hidden)
            .background(AppTheme.backgroundPrimary)

            if !purchaseRepository.isAdRemovalActive {
                AdBannerView()
                    .frame(height: 50)
                    .frame(maxWidth: .infinity)
            }
        }
        .background(AppTheme.backgroundPrimary)
        .navigationTitle(String(localized: String.LocalizationValue(category.titleLocalizationKey)))
        .navigationBarTitleDisplayMode(.inline)
        .searchable(
            text: $searchText,
            prompt: String(localized: String.LocalizationValue(LocalizationKey.libraryListSearchPrompt))
        )
        .toolbar {
            Menu {
                ForEach(LibraryListSortMode.allCases) { mode in
                    Button {
                        Haptics.light()
                        sortMode = mode
                        homeViewModel.saveLibraryListSortMode(mode, for: category)
                    } label: {
                        HStack {
                            Text(String(localized: String.LocalizationValue(mode.localizationKey)))
                            if sortMode == mode {
                                Spacer(minLength: 8)
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                Image(systemName: "arrow.up.arrow.down.circle")
            }
            .accessibilityLabel(String(localized: String.LocalizationValue(LocalizationKey.librarySortToolbarAccessibility)))
        }
        .preferredColorScheme(.dark)
        .tint(AppTheme.accentPrimary)
    }
}

#Preview {
    @Previewable @State var router = NavigationRouter()
    @Previewable @State var repo = ArticleRepository()
    @Previewable @State var vm = HomeViewModel(settingsRepository: SettingsRepository())
    @Previewable @State var purchases = PurchaseRepository()
    NavigationStack {
        LibraryListView(
            navigationRouter: router,
            category: .canons,
            branch: .japan,
            articleRepository: repo,
            homeViewModel: vm,
            purchaseRepository: purchases
        )
    }
}
