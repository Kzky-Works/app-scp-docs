import SwiftUI

/// ライブラリの静的リスト（支部に応じた URL、検索、レーティング表示）。
struct LibraryListView: View {
    @Bindable var navigationRouter: NavigationRouter
    let category: LibraryCategory
    let branch: Branch
    let articleRepository: ArticleRepository
    private let homeViewModel: HomeViewModel

    @State private var searchText = ""
    @State private var sortMode: LibraryListSortMode

    init(
        navigationRouter: NavigationRouter,
        category: LibraryCategory,
        branch: Branch,
        articleRepository: ArticleRepository,
        homeViewModel: HomeViewModel
    ) {
        self.navigationRouter = navigationRouter
        self.category = category
        self.branch = branch
        self.articleRepository = articleRepository
        self.homeViewModel = homeViewModel
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

    /// 日本支部の要注意団体（`goi-formats-jp`）：団体ハブと子の GoI フォーマット記事を階層表示する。
    private var showsJapanGoIHierarchy: Bool {
        category == .goi && branch.id == BranchIdentifier.scpJapan
    }

    private var filteredJapanGoIGroups: [GoILibraryHierarchyData.Group] {
        let base = GoILibraryHierarchyData.japanGoIFormatGroups
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return base }
        let query = trimmed.lowercased()
        return base.compactMap { group in
            if group.hubTitle.lowercased().contains(query) { return group }
            let articles = group.articles.filter { $0.title.lowercased().contains(query) }
            if articles.isEmpty { return nil }
            return GoILibraryHierarchyData.Group(
                id: group.id,
                hubTitle: group.hubTitle,
                hubURL: group.hubURL,
                articles: articles
            )
        }
    }

    @ViewBuilder
    private func goiOrganizationBlock(_ group: GoILibraryHierarchyData.Group) -> some View {
        if let hubURL = group.hubURL {
            Button {
                Haptics.medium()
                navigationRouter.pushArticle(url: hubURL)
            } label: {
                FoundationIndexRow(
                    title: group.hubTitle,
                    subtitle: hubURL.absoluteString,
                    leadingSystemImage: "person.3.fill",
                    trailing: {
                        HStack(spacing: 10) {
                            ArticleRatingMeterView(ratingScore: articleRepository.ratingScore(for: hubURL))
                            Image(systemName: "chevron.right")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(AppTheme.textSecondary)
                        }
                    }
                )
            }
            .buttonStyle(.plain)
            .indexListRowChrome()
        } else {
            FoundationIndexRow(
                title: group.hubTitle,
                subtitle: nil,
                leadingSystemImage: "person.3.fill",
                trailing: { EmptyView() }
            )
            .indexListRowChrome()
        }

        ForEach(group.articles) { article in
            Button {
                Haptics.medium()
                navigationRouter.pushArticle(url: article.url)
            } label: {
                FoundationIndexRow(
                    title: article.title,
                    subtitle: article.url.absoluteString,
                    trailing: {
                        ArticleRatingMeterView(ratingScore: articleRepository.ratingScore(for: article.url))
                    }
                )
            }
            .buttonStyle(.plain)
            .indexListRowChromeIndented()
        }
    }

    var body: some View {
        IndexScreenLayout {
            List {
                if showsJapanGoIHierarchy {
                    Section {
                        ForEach(GoIFormatsIndexData.portals) { link in
                            Button {
                                Haptics.medium()
                                navigationRouter.pushArticle(url: link.url)
                            } label: {
                                FoundationIndexRow(
                                    title: String(localized: String.LocalizationValue(link.titleLocalizationKey)),
                                    subtitle: link.url.absoluteString,
                                    trailing: {
                                        Image(systemName: "chevron.right")
                                            .font(.caption.weight(.semibold))
                                            .foregroundStyle(AppTheme.textSecondary)
                                    }
                                )
                            }
                            .buttonStyle(.plain)
                            .indexListRowChrome()
                        }
                    } header: {
                        Text(String(localized: String.LocalizationValue(LocalizationKey.goiIndexSectionPortals)))
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                    .listRowBackground(AppTheme.mainBackground)

                    ForEach(filteredJapanGoIGroups) { group in
                        goiOrganizationBlock(group)
                    }
                } else {
                    ForEach(filteredItems) { item in
                        Button {
                            Haptics.medium()
                            navigationRouter.pushArticle(url: item.url)
                        } label: {
                            FoundationIndexRow(
                                title: localizedTitle(item),
                                subtitle: item.url.absoluteString,
                                trailing: {
                                    ArticleRatingMeterView(ratingScore: articleRepository.ratingScore(for: item.url))
                                }
                            )
                        }
                        .buttonStyle(.plain)
                        .indexListRowChrome()
                    }
                }
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle(String(localized: String.LocalizationValue(category.titleLocalizationKey)))
        .navigationBarTitleDisplayMode(.inline)
        .searchable(
            text: $searchText,
            prompt: String(localized: String.LocalizationValue(LocalizationKey.libraryListSearchPrompt))
        )
        .toolbar {
            if !showsJapanGoIHierarchy {
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
        }
        .tint(AppTheme.textPrimary)
    }
}

#Preview {
    @Previewable @State var router = NavigationRouter()
    @Previewable @State var repo = ArticleRepository()
    @Previewable @State var vm = HomeViewModel(settingsRepository: SettingsRepository())
    NavigationStack {
        LibraryListView(
            navigationRouter: router,
            category: .canons,
            branch: .japan,
            articleRepository: repo,
            homeViewModel: vm
        )
    }
}
