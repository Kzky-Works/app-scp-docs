import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// 3 系統キャッシュ由来の記事一覧（ネイティブ）。行タップで `ReaderView`（`ArticleView`）へ。
struct SCPArticleFeedListView: View {
    let kind: SCPArticleFeedKind
    let feedCache: SCPArticleFeedCacheRepository
    let personnelReadingJournal: PersonnelReadingJournal?
    @Bindable var articleRepository: ArticleRepository
    @Bindable var navigationRouter: NavigationRouter

    @Bindable private var connectivity = ConnectivityMonitor.shared
    @State private var cachedEntries: [SCPArticle] = []
    @State private var intBranchFilterID: String = "ru"

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

    /// 英語 `-en` は INT カタログでは扱わない（ホームの EN 専用一覧へ）。
    private var intCatalogEntriesExcludingEnglish: [SCPArticle] {
        guard kind == .int else { return cachedEntries }
        return cachedEntries.filter { !InternationalBranchPortalOption.SCPIntSlugLanguageTail.isEnglishBranchCatalogEntry($0) }
    }

    private var catalogListEntries: [SCPArticle] {
        guard kind == .int else { return cachedEntries }
        let base = intCatalogEntriesExcludingEnglish
        guard let filter = InternationalBranchPortalOption.option(id: intBranchFilterID) else {
            return base
        }
        return base.filter { filter.matchesCatalogEntry($0) }
    }

    private var intCatalogFilteredEmpty: Bool {
        kind == .int && !intCatalogEntriesExcludingEnglish.isEmpty && catalogListEntries.isEmpty
    }

    var body: some View {
        Group {
            if cachedEntries.isEmpty || (kind == .int && intCatalogEntriesExcludingEnglish.isEmpty) {
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
            } else if intCatalogFilteredEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Text(String(localized: String.LocalizationValue(LocalizationKey.intCatalogBranchFilterEmptyTitle)))
                        .font(AppTypography.feedListOnePointDown(.body, weight: .semibold))
                        .foregroundStyle(AppTheme.textPrimary)
                    Text(String(localized: String.LocalizationValue(LocalizationKey.intCatalogBranchFilterEmptySubtitle)))
                        .font(AppTypography.feedListOnePointDown(.subheadline, weight: .medium))
                        .foregroundStyle(AppTheme.textSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.vertical, 28)
            } else {
                List {
                    ForEach(catalogListEntries, id: \.self) { article in
                    Button {
                        Haptics.medium()
                        if let u = article.resolvedURL {
                            navigationRouter.pushArticle(url: u)
                        }
                    } label: {
                        HStack(alignment: .top, spacing: 10) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(article.t)
                                    .font(AppTypography.feedListOnePointDown(.body, weight: .semibold))
                                    .foregroundStyle(AppTheme.textPrimary)
                                Text(article.u)
                                    .font(AppTypography.feedListOnePointDown(.caption2, weight: .regular))
                                    .foregroundStyle(AppTheme.textSecondary)
                                    .lineLimit(1)
                            }
                            Spacer(minLength: 6)
                            if let u = article.resolvedURL, articleRepository.isRead(url: u) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(AppTypography.feedListOnePointDown(.body, weight: .regular))
                                    .foregroundStyle(AppTheme.textSecondary)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    }
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
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if kind == .int {
                internationalBranchPortalChrome
            }
        }
        .task(id: kind) {
            cachedEntries = feedCache.loadPersistedPayload(kind: kind)?.entries ?? []
        }
        .onAppear {
            personnelReadingJournal?.setActiveCatalogFeed(kind)
        }
    }

    @ViewBuilder
    private var internationalBranchPortalChrome: some View {
        let options = InternationalBranchPortalOption.ordered
        VStack(alignment: .leading, spacing: 6) {
            Text(String(localized: String.LocalizationValue(LocalizationKey.intCatalogBranchPickerCaption)))
                .font(AppTypography.feedListOnePointDown(.caption2, weight: .semibold))
                .foregroundStyle(AppTheme.textSecondary)
                .padding(.horizontal, 16)
                .padding(.top, 8)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(options) { option in
                        Button {
                            Haptics.light()
                            intBranchFilterID = option.id
                        } label: {
                            TagChipView(
                                label: String(localized: String.LocalizationValue(option.chipTitleLocalizationKey)),
                                isSelected: intBranchFilterID == option.id
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 4)
            }
            .accessibilityElement(children: .contain)
            .accessibilityLabel(String(localized: String.LocalizationValue(LocalizationKey.intCatalogBranchPickerCaption)))

            Button {
                Haptics.medium()
                guard let url = InternationalBranchPortalOption.option(id: intBranchFilterID)?.portalURL else { return }
                navigationRouter.pushArticle(url: url)
            } label: {
                Text(String(localized: String.LocalizationValue(LocalizationKey.intCatalogBranchPickerOpenSite)))
                    .font(AppTypography.feedListOnePointDown(.subheadline, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
            }
            .buttonStyle(.borderedProminent)
            .tint(AppTheme.brandAccent)
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.cardStandard.ignoresSafeArea(edges: .bottom))
        .overlay(alignment: .top) {
            Rectangle()
                .fill(AppTheme.terminalSilver.opacity(0.35))
                .frame(height: 1)
        }
    }
}
