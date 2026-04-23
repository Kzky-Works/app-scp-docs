import SwiftUI

/// Step 4: Tale / GoI / Canon / Joke のネイティブ一覧（`SCPGeneralContent`）。
struct SCPGeneralContentListView: View {
    let kind: SCPArticleFeedKind
    let feedCache: SCPArticleFeedCacheRepository
    let personnelReadingJournal: PersonnelReadingJournal?
    @Bindable var articleRepository: ArticleRepository
    @Bindable var navigationRouter: NavigationRouter

    @Bindable private var connectivity = ConnectivityMonitor.shared
    @State private var cachedEntries: [SCPGeneralContent] = []

    private var screenTitle: String {
        let key = switch kind {
        case .tales: LocalizationKey.homeFeedListTitleTales
        case .gois: LocalizationKey.homeFeedListTitleGois
        case .canons: LocalizationKey.homeFeedListTitleCanons
        case .jokes: LocalizationKey.homeFeedListTitleJokes
        case .jp, .en, .int: LocalizationKey.homeFeedListTitleJP
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
                List(Array(cachedEntries.enumerated()), id: \.offset) { _, row in
                    Button {
                        Haptics.medium()
                        if let u = row.resolvedURL {
                            navigationRouter.pushArticle(url: u)
                        }
                    } label: {
                        HStack(alignment: .top, spacing: 10) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(row.t)
                                    .font(.headline.weight(.heavy))
                                    .foregroundStyle(AppTheme.textPrimary)
                                    .multilineTextAlignment(.leading)
                                    .lineLimit(2)
                                    .fixedSize(horizontal: false, vertical: true)
                                if let author = row.trimmedAuthor {
                                    Text(author)
                                        .font(.caption.weight(.medium))
                                        .foregroundStyle(AppTheme.textSecondary)
                                        .lineLimit(2)
                                } else {
                                    Text(String(localized: String.LocalizationValue(LocalizationKey.multiformAuthorUnknown)))
                                        .font(.caption.weight(.heavy))
                                        .foregroundStyle(AppTheme.brandAccent)
                                        .lineLimit(1)
                                }
                            }
                            Spacer(minLength: 8)
                            if let u = row.resolvedURL, articleRepository.isRead(url: u) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.body.weight(.medium))
                                    .foregroundStyle(AppTheme.textSecondary)
                            }
                        }
                        .padding(.vertical, 6)
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
            cachedEntries = feedCache.loadPersistedGeneralMultiformPayload(kind: kind)?.entries ?? []
        }
        .onAppear {
            personnelReadingJournal?.setActiveCatalogFeed(kind)
        }
    }
}
