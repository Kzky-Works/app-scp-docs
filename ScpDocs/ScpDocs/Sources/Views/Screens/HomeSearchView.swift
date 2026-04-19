import SwiftUI

/// ホームから開く scp-jp 報告書検索（番号・タイトル・タグ・オブジェクトクラス）。
struct HomeSearchView: View {
    @Bindable var navigationRouter: NavigationRouter
    let articleRepository: ArticleRepository
    let homeViewModel: HomeViewModel
    let japanSCPListMetadataStore: JapanSCPListMetadataStore

    @State private var query = ""
    @State private var results: [JapanSCPArchiveEntry] = []
    @State private var hasSubmitted = false

    private var trimmedQuery: String {
        query.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        IndexScreenLayout {
            List {
                Section {
                    Text(String(localized: String.LocalizationValue(LocalizationKey.homeSearchHint)))
                        .font(.footnote)
                        .foregroundStyle(AppTheme.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                }

                if hasSubmitted && results.isEmpty && !trimmedQuery.isEmpty {
                    ContentUnavailableView(
                        String(localized: String.LocalizationValue(LocalizationKey.homeSearchEmpty)),
                        systemImage: "magnifyingglass",
                        description: Text(String(localized: String.LocalizationValue(LocalizationKey.homeSearchNoIndex)))
                    )
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }

                Section {
                    ForEach(results) { entry in
                        Button {
                            Haptics.medium()
                            navigationRouter.pushArticle(url: entry.url)
                        } label: {
                            FoundationIndexRow(
                                layout: .twoLine,
                                title: formattedRowTitle(scpNumber: entry.scpNumber),
                                subtitle: resolvedSubtitle(entry),
                                tags: entry.tags,
                                showsTags: !entry.tags.isEmpty,
                                monospacedTitleDigits: true,
                                trailing: {
                                    HStack(spacing: 10) {
                                        if articleRepository.isBookmarked(url: entry.url) {
                                            Image(systemName: "bookmark.fill")
                                                .foregroundStyle(AppTheme.textPrimary)
                                                .imageScale(.medium)
                                        }
                                        if articleRepository.isRead(url: entry.url) {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundStyle(AppTheme.textPrimary)
                                                .imageScale(.medium)
                                        }
                                    }
                                }
                            )
                        }
                        .buttonStyle(.plain)
                        .indexListRowChrome()
                    }
                }
            }
            .listStyle(.plain)
            .listSectionSeparator(.hidden)
            .scrollContentBackground(.hidden)
        }
        .navigationTitle(String(localized: String.LocalizationValue(LocalizationKey.homeSearchTitle)))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .navigationBar)
        .searchable(
            text: $query,
            prompt: Text(String(localized: String.LocalizationValue(LocalizationKey.homeSearchPlaceholder)))
        )
        .onSubmit(of: .search) {
            runSearch()
        }
        .onAppear {
            homeViewModel.selectBranch(id: BranchIdentifier.scpJapan)
        }
    }

    private func runSearch() {
        hasSubmitted = true
        let q = trimmedQuery
        guard !q.isEmpty else {
            results = []
            return
        }
        if navigationRouter.pushSCPJPArticleIfPossible(query: q) {
            Haptics.medium()
            results = []
            return
        }
        results = japanSCPListMetadataStore.searchIndexedEntries(matching: q)
        Haptics.light()
    }

    private func formattedRowTitle(scpNumber: Int) -> String {
        let core = scpNumber < 1000 ? String(format: "%03d", scpNumber) : String(scpNumber)
        let format = String(localized: String.LocalizationValue(LocalizationKey.archiveEnScpRowTitleFormat))
        return String(format: format, locale: .current, core)
    }

    private func resolvedSubtitle(_ entry: JapanSCPArchiveEntry) -> String {
        if let t = entry.articleTitle, !t.isEmpty {
            return t
        }
        return String(localized: String.LocalizationValue(LocalizationKey.archiveArticleTitleUnknown))
    }
}
