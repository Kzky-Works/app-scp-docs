import SwiftUI

/// ホームから開く横断検索（SCP 3 系統・Tale/GoI/Canon/Joke・フィード索引）。
struct HomeSearchView: View {
    @Bindable var navigationRouter: NavigationRouter
    let articleRepository: ArticleRepository
    let homeViewModel: HomeViewModel
    let japanSCPListMetadataStore: JapanSCPListMetadataStore
    let feedCache: SCPArticleFeedCacheRepository

    @Bindable private var connectivity = ConnectivityMonitor.shared

    @State private var query = ""
    @State private var unifiedHits: [CatalogSearchHit] = []
    @State private var hasSubmitted = false
    @State private var isSearching = false
    @State private var debouncedSearchTask: Task<Void, Never>?

    private var trimmedQuery: String {
        query.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        IndexScreenLayout {
            ZStack {
                List {
                    Section {
                        Text(String(localized: String.LocalizationValue(LocalizationKey.homeSearchHint)))
                            .font(.footnote)
                            .foregroundStyle(AppTheme.textSecondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                    }

                    if hasSubmitted && !trimmedQuery.isEmpty && !isSearching {
                        if unifiedHits.isEmpty {
                            TacticalArchiveEmptyPanel(
                                titleLocalizationKey: connectivity.isPathSatisfied
                                    ? LocalizationKey.tacticalEmptyArchiveTitle
                                    : LocalizationKey.tacticalEmptyNetworkTitle,
                                subtitleLocalizationKey: connectivity.isPathSatisfied
                                    ? LocalizationKey.tacticalEmptyArchiveSubtitle
                                    : LocalizationKey.tacticalEmptyNetworkSubtitle,
                                usesNetworkInterruptedCopy: !connectivity.isPathSatisfied
                            )
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                        } else {
                            Section {
                                ForEach(unifiedHits) { hit in
                                    Button {
                                        Haptics.medium()
                                        navigationRouter.pushArticle(url: hit.url)
                                    } label: {
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text(String(localized: String.LocalizationValue(hit.badge.localizationKey)))
                                                .font(.caption2.weight(.heavy))
                                                .foregroundStyle(AppTheme.brandAccent)
                                                .tracking(0.6)
                                            Text(hit.title)
                                                .font(.body.weight(.semibold))
                                                .foregroundStyle(AppTheme.textPrimary)
                                                .lineLimit(2)
                                            if !hit.subtitle.isEmpty {
                                                Text(hit.subtitle)
                                                    .font(.caption.weight(.medium))
                                                    .foregroundStyle(AppTheme.textSecondary)
                                                    .lineLimit(3)
                                            }
                                            if !hit.tags.isEmpty {
                                                HStack(spacing: 6) {
                                                    ForEach(Array(hit.tags.prefix(5)), id: \.self) { tag in
                                                        TagChipView(label: tag, isSelected: false)
                                                    }
                                                }
                                            }
                                            HStack {
                                                Spacer(minLength: 0)
                                                ArticleRatingMeterView(ratingScore: articleRepository.ratingScore(for: hit.url))
                                            }
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .contentShape(Rectangle())
                                    }
                                    .buttonStyle(.plain)
                                    .indexListRowChrome()
                                }
                            }
                            .animation(.easeOut(duration: 0.18), value: unifiedHits.count)
                        }
                    }
                }
                .listStyle(.plain)
                .listSectionSeparator(.hidden)
                .scrollContentBackground(.hidden)

                if isSearching {
                    ProgressView(String(localized: String.LocalizationValue(LocalizationKey.homeSearchScanning)))
                        .tint(AppTheme.brandAccent)
                        .padding(24)
                        .background(.ultraThinMaterial.opacity(0.88))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
            }
        }
        .navigationTitle(String(localized: String.LocalizationValue(LocalizationKey.homeSearchTitle)))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .navigationBar)
        .searchable(
            text: $query,
            prompt: Text(String(localized: String.LocalizationValue(LocalizationKey.homeSearchPlaceholder)))
        )
        .onSubmit(of: .search) {
            Task { await runGlobalSearch(submitted: true) }
        }
        .onChange(of: query) { _, _ in
            debouncedSearchTask?.cancel()
            let q = trimmedQuery
            guard q.count >= 2 else {
                if q.isEmpty {
                    unifiedHits = []
                    hasSubmitted = false
                }
                return
            }
            debouncedSearchTask = Task {
                try? await Task.sleep(for: .milliseconds(420))
                guard !Task.isCancelled else { return }
                await runGlobalSearch(submitted: false)
            }
        }
        .onDisappear {
            debouncedSearchTask?.cancel()
        }
    }

    @MainActor
    private func runGlobalSearch(submitted: Bool) async {
        if submitted {
            hasSubmitted = true
        }
        let q = trimmedQuery
        if q.count >= 2 {
            hasSubmitted = true
        }
        guard !q.isEmpty else {
            unifiedHits = []
            isSearching = false
            return
        }

        if navigationRouter.pushSCPJPArticleIfPossible(query: q) {
            Haptics.medium()
            unifiedHits = []
            isSearching = false
            return
        }

        isSearching = true
        let listMatches = japanSCPListMetadataStore.searchIndexedEntries(matching: q, limit: 120)
        let snapshot = CatalogSearchSnapshotBuilder.build(
            feedCache: feedCache,
            indexedMatches: listMatches
        )

        let drafts = await Task.detached(priority: .userInitiated) {
            GlobalCatalogSearchEngine.search(query: q, snapshot: snapshot, maxTotal: 220)
        }.value

        let unknownSubtitle = String(localized: String.LocalizationValue(LocalizationKey.archiveArticleTitleUnknown))
        unifiedHits = drafts.map { d in
            CatalogSearchHit(
                id: ArticleRepository.storageKey(for: d.url) + "|" + d.badge.rawValue,
                url: d.url,
                badge: d.badge,
                title: d.title,
                subtitle: d.subtitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? unknownSubtitle : d.subtitle,
                tags: d.tags
            )
        }
        isSearching = false
        Haptics.light()
    }
}
