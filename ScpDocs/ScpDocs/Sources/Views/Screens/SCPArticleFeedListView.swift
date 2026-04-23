import SwiftUI

/// 3 系統キャッシュ由来の記事一覧（ネイティブ）。行タップで `ReaderView`（`ArticleView`）へ。
struct SCPArticleFeedListView: View {
    let kind: SCPArticleFeedKind
    let feedCache: SCPArticleFeedCacheRepository
    let personnelReadingJournal: PersonnelReadingJournal?
    @Bindable var articleRepository: ArticleRepository
    @Bindable var navigationRouter: NavigationRouter

    @Bindable private var connectivity = ConnectivityMonitor.shared
    @State private var cachedEntries: [SCPArticle] = []

    private var screenTitle: String {
        let key = switch kind {
        case .jp: LocalizationKey.homeFeedListTitleJP
        case .en: LocalizationKey.homeFeedListTitleEN
        case .int: LocalizationKey.homeFeedListTitleINT
        case .tales: LocalizationKey.homeFeedListTitleTales
        case .gois: LocalizationKey.homeFeedListTitleGois
        case .canons: LocalizationKey.homeFeedListTitleCanons
        case .jokes: LocalizationKey.homeFeedListTitleJokes
        }
        return String(localized: String.LocalizationValue(key))
    }

    var body: some View {
        Group {
            if cachedEntries.isEmpty {
                TacticalArchiveEmptyPanel(
                    titleLocalizationKey: connectivity.isPathSatisfied
                        ? LocalizationKey.tacticalEmptyArchiveTitle
                        : LocalizationKey.tacticalEmptyNetworkTitle,
                    subtitleLocalizationKey: connectivity.isPathSatisfied
                        ? LocalizationKey.tacticalEmptyArchiveSubtitle
                        : LocalizationKey.tacticalEmptyNetworkSubtitle,
                    usesNetworkInterruptedCopy: !connectivity.isPathSatisfied
                )
                .padding(.horizontal, 16)
                .frame(maxWidth: .infinity, minHeight: 220)
            } else {
                List(Array(cachedEntries.enumerated()), id: \.offset) { _, article in
                    Button {
                        Haptics.medium()
                        if let u = article.resolvedURL {
                            navigationRouter.pushArticle(url: u)
                        }
                    } label: {
                        HStack(alignment: .top, spacing: 10) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(article.t)
                                    .font(.body.weight(.semibold))
                                    .foregroundStyle(AppTheme.textPrimary)
                                Text(article.u)
                                    .font(.caption2)
                                    .foregroundStyle(AppTheme.textSecondary)
                                    .lineLimit(1)
                            }
                            Spacer(minLength: 6)
                            if let u = article.resolvedURL, articleRepository.isRead(url: u) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(AppTheme.textSecondary)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
        .background(AppTheme.mainBackground)
        .navigationTitle(screenTitle)
        .navigationBarTitleDisplayMode(.inline)
        .task(id: kind) {
            cachedEntries = feedCache.loadPersistedPayload(kind: kind)?.entries ?? []
        }
        .onAppear {
            personnelReadingJournal?.setActiveCatalogFeed(kind)
        }
    }
}
