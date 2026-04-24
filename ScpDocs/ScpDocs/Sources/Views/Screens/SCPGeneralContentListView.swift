import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

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
                    usesNetworkInterruptedCopy: !connectivity.isPathSatisfied,
                    useCompactListTypography: true
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
                                    .font(AppTypography.feedListOnePointDown(.headline, weight: .heavy))
                                    .foregroundStyle(AppTheme.textPrimary)
                                    .multilineTextAlignment(.leading)
                                    .lineLimit(2)
                                    .fixedSize(horizontal: false, vertical: true)
                                if let author = row.trimmedAuthor {
                                    Text(author)
                                        .font(AppTypography.feedListOnePointDown(.caption1, weight: .medium))
                                        .foregroundStyle(AppTheme.textSecondary)
                                        .lineLimit(2)
                                } else {
                                    Text(String(localized: String.LocalizationValue(LocalizationKey.multiformAuthorUnknown)))
                                        .font(AppTypography.feedListOnePointDown(.caption1, weight: .heavy))
                                        .foregroundStyle(AppTheme.brandAccent)
                                        .lineLimit(1)
                                }
                            }
                            Spacer(minLength: 8)
                            if let u = row.resolvedURL, articleRepository.isRead(url: u) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(AppTypography.feedListOnePointDown(.body, weight: .medium))
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
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(screenTitle)
                    .font(AppTypography.feedListOnePointDown(.headline, weight: .semibold))
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.8)
            }
        }
        .task(id: kind) {
            cachedEntries = feedCache.loadPersistedGeneralMultiformPayload(kind: kind)?.entries ?? []
        }
        .onAppear {
            personnelReadingJournal?.setActiveCatalogFeed(kind)
        }
    }
}
