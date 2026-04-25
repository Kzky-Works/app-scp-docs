import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

// MARK: - ジョーク報告書: `scp-N-j`（本家）と `scp-N-jp-j`（日本支部）の区別

private enum JokeReportCatalogOrigin: String, CaseIterable, Identifiable {
    case jpBranch
    case mainWiki
    var id: String { rawValue }
    var titleLocalizationKey: String {
        switch self {
        case .jpBranch: return LocalizationKey.jokeCatalogOriginJP
        case .mainWiki: return LocalizationKey.jokeCatalogOriginMain
        }
    }
}

/// `i` または URL 末 slug が `scp-数字-j` か `scp-数字-jp-j` かで分類（マニフェストと整合）。
private enum JokeReportCatalogLineage {
    case jpBranch
    case mainWiki

    private static let mainJSeriesRegex: NSRegularExpression? = {
        try? NSRegularExpression(pattern: "^scp-[0-9]+-j$", options: .caseInsensitive)
    }()

    static func of(_ content: SCPGeneralContent) -> JokeReportCatalogLineage? {
        let slug = resolvedSlug(for: content)
        let lower = slug.lowercased()
        if lower.hasSuffix("-jp-j") { return .jpBranch }
        let len = (lower as NSString).length
        let range = NSRange(location: 0, length: len)
        guard let re = mainJSeriesRegex, re.firstMatch(in: lower, options: [], range: range) != nil else { return nil }
        return .mainWiki
    }

    private static func resolvedSlug(for content: SCPGeneralContent) -> String {
        if let i = content.i, !i.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return i
        }
        return slugFromURLString(content.u)
    }

    private static func slugFromURLString(_ raw: String) -> String {
        let t = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty, let url = URL(string: t) else { return "" }
        let p = url.path
        if let last = p.split(separator: "/").filter({ !$0.isEmpty }).last {
            return String(last)
        }
        return ""
    }
}

/// Step 4: Tale / GoI / Canon / Joke のネイティブ一覧（`SCPGeneralContent`）。
struct SCPGeneralContentListView: View {
    let kind: SCPArticleFeedKind
    let feedCache: SCPArticleFeedCacheRepository
    let personnelReadingJournal: PersonnelReadingJournal?
    @Bindable var articleRepository: ArticleRepository
    @Bindable var navigationRouter: NavigationRouter

    @Bindable private var connectivity = ConnectivityMonitor.shared
    @State private var cachedEntries: [SCPGeneralContent] = []
    @State private var jokeReportOrigin: JokeReportCatalogOrigin = .jpBranch

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

    private var listEntries: [SCPGeneralContent] {
        guard kind == .jokes else { return cachedEntries }
        return cachedEntries.filter { entry in
            switch jokeReportOrigin {
            case .jpBranch: return JokeReportCatalogLineage.of(entry) == .jpBranch
            case .mainWiki: return JokeReportCatalogLineage.of(entry) == .mainWiki
            }
        }
    }

    private var jokeFilterEmpty: Bool {
        kind == .jokes && !cachedEntries.isEmpty && listEntries.isEmpty
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
            } else if jokeFilterEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Text(String(localized: String.LocalizationValue(LocalizationKey.jokeCatalogFilterEmptyTitle)))
                        .font(AppTypography.feedListOnePointDown(.body, weight: .semibold))
                        .foregroundStyle(AppTheme.textPrimary)
                    Text(String(localized: String.LocalizationValue(LocalizationKey.jokeCatalogFilterEmptySubtitle)))
                        .font(AppTypography.feedListOnePointDown(.subheadline, weight: .medium))
                        .foregroundStyle(AppTheme.textSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.vertical, 28)
            } else {
                List(Array(listEntries.enumerated()), id: \.offset) { _, row in
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
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if kind == .jokes, !cachedEntries.isEmpty {
                jokeReportOriginPickerChrome
            }
        }
        .task(id: kind) {
            reloadCachedEntriesFromDisk()
        }
        .onReceive(NotificationCenter.default.publisher(for: .scpMultiformManifestsDidSync)) { _ in
            reloadCachedEntriesFromDisk()
        }
        .onAppear {
            personnelReadingJournal?.setActiveCatalogFeed(kind)
            reloadCachedEntriesFromDisk()
        }
    }

    @ViewBuilder
    private var jokeReportOriginPickerChrome: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(JokeReportCatalogOrigin.allCases) { origin in
                        Button {
                            Haptics.selection()
                            jokeReportOrigin = origin
                        } label: {
                            TagChipView(
                                label: String(localized: String.LocalizationValue(origin.titleLocalizationKey)),
                                isSelected: jokeReportOrigin == origin
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
            }
            .accessibilityElement(children: .contain)
            .accessibilityLabel(String(localized: String.LocalizationValue(LocalizationKey.jokeCatalogOriginPickerAccessibility)))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.cardStandard.ignoresSafeArea(edges: .bottom))
        .overlay(alignment: .top) {
            Rectangle()
                .fill(AppTheme.terminalSilver.opacity(0.35))
                .frame(height: 1)
        }
    }

    private func reloadCachedEntriesFromDisk() {
        cachedEntries = feedCache.loadPersistedGeneralMultiformPayload(kind: kind)?.entries ?? []
    }
}
