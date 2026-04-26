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

// MARK: - 要注意団体: manifest の `g` ＝団体名、`metadata.r` ＝出典分類（将来のハーベスト用）

private enum GoICatalogSourceTab: String, CaseIterable, Identifiable {
    case jp
    case en
    case other
    var id: String { rawValue }
    var titleLocalizationKey: String {
        switch self {
        case .jp: return LocalizationKey.goiCatalogSourceTabJP
        case .en: return LocalizationKey.goiCatalogSourceTabEN
        case .other: return LocalizationKey.goiCatalogSourceTabOther
        }
    }
}

// MARK: - カノンハブ: `canon-hub-jp` / `canon-hub`

private enum CanonHubCatalogTab: String, CaseIterable, Identifiable {
    case jp
    case en
    var id: String { rawValue }
    var titleLocalizationKey: String {
        switch self {
        case .jp: return LocalizationKey.goiCatalogSourceTabJP
        case .en: return LocalizationKey.goiCatalogSourceTabEN
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

// MARK: - Tales: 著者別アコーディオン

private struct MultiformTalesAuthorGroup: Identifiable {
    static let unknownAuthorID = "multiform_tales_author_unknown"
    let id: String
    let displayName: String
    let entries: [SCPGeneralContent]
}

/// Step 4: Tale / GoI / Canon / Joke のネイティブ一覧（`SCPGeneralContent`）。
struct SCPGeneralContentListView: View {
    let kind: SCPArticleFeedKind
    let feedCache: SCPArticleFeedCacheRepository
    let japanSCPListMetadataStore: JapanSCPListMetadataStore?
    let personnelReadingJournal: PersonnelReadingJournal?
    @Bindable var articleRepository: ArticleRepository
    @Bindable var navigationRouter: NavigationRouter

    @Bindable private var connectivity = ConnectivityMonitor.shared
    @State private var cachedEntries: [SCPGeneralContent] = []
    @State private var goisManifest: SCPGeneralContentListPayload?
    @State private var canonsManifest: SCPGeneralContentListPayload?
    @State private var jokeReportOrigin: JokeReportCatalogOrigin = .jpBranch
    @State private var goiSourceTab: GoICatalogSourceTab = .jp
    @State private var canonHubSourceTab: CanonHubCatalogTab = .jp
    @State private var expandedMultiformTalesAuthorKeys: Set<String> = []

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

    /// マルチフォーム Tales 専用: 著者（欠損は「著者不明」1 バケツにまとめて末尾へ）。
    private var multiformTalesAuthorGroups: [MultiformTalesAuthorGroup] {
        guard kind == .tales else { return [] }
        var buckets: [String: [SCPGeneralContent]] = [:]
        for entry in listEntries {
            let bucketID: String
            if let name = entry.trimmedAuthor, !name.isEmpty {
                bucketID = name
            } else {
                bucketID = MultiformTalesAuthorGroup.unknownAuthorID
            }
            buckets[bucketID, default: []].append(entry)
        }
        let unknownLabel = String(localized: String.LocalizationValue(LocalizationKey.multiformAuthorUnknown))
        var groups: [MultiformTalesAuthorGroup] = []
        for (key, var items) in buckets {
            items.sort { $0.t.localizedStandardCompare($1.t) == .orderedAscending }
            if key == MultiformTalesAuthorGroup.unknownAuthorID {
                groups.append(MultiformTalesAuthorGroup(id: key, displayName: unknownLabel, entries: items))
            } else {
                groups.append(MultiformTalesAuthorGroup(id: key, displayName: key, entries: items))
            }
        }
        groups.sort { a, b in
            let aU = a.id == MultiformTalesAuthorGroup.unknownAuthorID
            let bU = b.id == MultiformTalesAuthorGroup.unknownAuthorID
            if aU != bU { return !aU }
            return a.displayName.localizedStandardCompare(b.displayName) == .orderedAscending
        }
        return groups
    }

    private var jokeFilterEmpty: Bool {
        kind == .jokes && !cachedEntries.isEmpty && listEntries.isEmpty
    }

    private var goiFilteredEntries: [SCPGeneralContent] {
        guard kind == .gois else { return [] }
        return cachedEntries.filter { goiEntryMatchesSourceTab($0) }
    }

    /// `manifest_gois` schema 3: タブに応じた団体配列
    private var goiV3TabGroups: [GoIFormatGroupPayload] {
        guard let r = goisManifest?.goiRegions else { return [] }
        switch goiSourceTab {
        case .jp: return r.jp
        case .en: return r.en
        case .other: return r.other
        }
    }

    /// `manifest_canons` のカノンハブ行（タブで JP / EN を切替）。
    private var canonV3TabHubLines: [GoIFormatArticleLine] {
        guard let r = canonsManifest?.canonRegions else { return [] }
        switch canonHubSourceTab {
        case .jp: return r.jp
        case .en: return r.en
        }
    }

    private var goiDistinctGroupTags: [String] {
        var seen = Set<String>()
        var out: [String] = []
        for entry in goiFilteredEntries {
            for tag in entry.g {
                let t = tag.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !t.isEmpty, !seen.contains(t) else { continue }
                seen.insert(t)
                out.append(t)
            }
        }
        return out.sorted { $0.localizedStandardCompare($1) == .orderedAscending }
    }

    private var goiFilterEmpty: Bool {
        guard kind == .gois, !cachedEntries.isEmpty || goisManifest?.goiRegions != nil else { return false }
        if goisManifest?.goiRegions != nil {
            return goiV3TabGroups.isEmpty
        }
        return !cachedEntries.isEmpty && goiFilteredEntries.isEmpty
    }

    private var goiNoGroupTagsInFilter: Bool {
        kind == .gois
            && goisManifest?.goiRegions == nil
            && !goiFilteredEntries.isEmpty
            && goiDistinctGroupTags.isEmpty
    }

    /// GoI schema 3 / Canon `canonRegions` では構造化データのみで表示できるため、entries が空でも一覧を出す。
    private var shouldShowTacticalEmptyPanel: Bool {
        if kind == .gois, goisManifest?.goiRegions != nil {
            return false
        }
        if kind == .canons {
            if let cr = canonsManifest?.canonRegions {
                let anyHub = !cr.jp.isEmpty || !cr.en.isEmpty
                return !anyHub && cachedEntries.isEmpty
            }
        }
        return cachedEntries.isEmpty
    }

    var body: some View {
        Group {
            if shouldShowTacticalEmptyPanel {
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
            } else if goiFilterEmpty {
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
            } else if goiNoGroupTagsInFilter {
                Text(String(localized: String.LocalizationValue(LocalizationKey.goiFeedEmptyNoGroupTags)))
                    .font(AppTypography.feedListOnePointDown(.subheadline, weight: .medium))
                    .foregroundStyle(AppTheme.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 28)
            } else if kind == .gois, goisManifest?.goiRegions != nil {
                List {
                    ForEach(goiV3TabGroups) { group in
                        Section {
                            ForEach(group.entries) { line in
                                Button {
                                    Haptics.medium()
                                    if let url = URL(string: line.u) {
                                        navigationRouter.pushArticle(url: url)
                                    }
                                } label: {
                                    HStack(alignment: .top, spacing: 10) {
                                        Text(line.t)
                                            .font(AppTypography.feedListOnePointDown(.headline, weight: .semibold))
                                            .foregroundStyle(AppTheme.textPrimary)
                                            .multilineTextAlignment(.leading)
                                            .lineLimit(3)
                                            .fixedSize(horizontal: false, vertical: true)
                                        Spacer(minLength: 8)
                                        if let url = URL(string: line.u), articleRepository.isRead(url: url) {
                                            Image(systemName: "checkmark.circle.fill")
                                                .font(AppTypography.feedListOnePointDown(.body, weight: .medium))
                                                .foregroundStyle(AppTheme.textSecondary)
                                        }
                                    }
                                    .padding(.vertical, 4)
                                }
                                .buttonStyle(.plain)
                            }
                        } header: {
                            goiV3GroupHeader(group: group)
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            } else if kind == .gois {
                List {
                    ForEach(goiDistinctGroupTags, id: \.self) { tag in
                        goiGroupTagRow(tag: tag)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            } else if kind == .canons, canonsManifest?.canonRegions != nil {
                if canonV3TabHubLines.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(String(localized: String.LocalizationValue(LocalizationKey.canonHubFeedTabEmptyTitle)))
                            .font(AppTypography.feedListOnePointDown(.body, weight: .semibold))
                            .foregroundStyle(AppTheme.textPrimary)
                        Text(String(localized: String.LocalizationValue(LocalizationKey.canonHubFeedTabEmptySubtitle)))
                            .font(AppTypography.feedListOnePointDown(.subheadline, weight: .medium))
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 28)
                } else {
                    List {
                        ForEach(canonV3TabHubLines) { line in
                            canonHubLineRow(line: line)
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            } else if kind == .tales, !listEntries.isEmpty {
                List {
                    ForEach(multiformTalesAuthorGroups) { group in
                        DisclosureGroup(
                            isExpanded: Binding(
                                get: { expandedMultiformTalesAuthorKeys.contains(group.id) },
                                set: { newValue in
                                    if newValue {
                                        Haptics.selection()
                                        expandedMultiformTalesAuthorKeys.insert(group.id)
                                    } else {
                                        expandedMultiformTalesAuthorKeys.remove(group.id)
                                    }
                                }
                            )
                        ) {
                            ForEach(group.entries, id: \.self) { row in
                                multiformTalesArticleRow(row: row)
                            }
                        } label: {
                            multiformTalesAuthorDisclosureLabel(group: group)
                        }
                        .indexListRowChrome()
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
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
                                if kind == .jokes, let meta = japanSCPListMetadataStore, let oc = meta.jokeMultiformListRowObjectClass(entry: row) {
                                    Text(jokeListObjectClassLabel(wiki: oc))
                                        .font(AppTypography.feedListOnePointDown(.caption1, weight: .semibold))
                                        .foregroundStyle(AppTheme.textSecondary)
                                        .lineLimit(1)
                                }
                                if kind != .canons {
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
            } else if kind == .gois, !cachedEntries.isEmpty || goisManifest?.goiRegions != nil {
                goiSourceTabPickerChrome
            } else if kind == .canons, canonsManifest?.canonRegions != nil {
                canonHubSourceTabPickerChrome
            }
        }
        .task(id: kind) {
            expandedMultiformTalesAuthorKeys = []
            canonHubSourceTab = .jp
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
    private func goiV3GroupHeader(group: GoIFormatGroupPayload) -> some View {
        let rawU = group.u?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if !rawU.isEmpty, let hubURL = URL(string: rawU) {
            Button {
                Haptics.medium()
                navigationRouter.pushArticle(url: hubURL)
            } label: {
                HStack(alignment: .top, spacing: 8) {
                    Text(group.t)
                        .font(AppTypography.feedListOnePointDown(.headline, weight: .heavy))
                        .foregroundStyle(AppTheme.textPrimary)
                        .multilineTextAlignment(.leading)
                    Spacer(minLength: 0)
                    if articleRepository.isRead(url: hubURL) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(AppTypography.feedListOnePointDown(.body, weight: .medium))
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                }
                .padding(.vertical, 4)
            }
            .buttonStyle(.plain)
        } else {
            Text(group.t)
                .font(AppTypography.feedListOnePointDown(.headline, weight: .heavy))
                .foregroundStyle(AppTheme.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 4)
        }
    }

    @ViewBuilder
    private func canonHubLineRow(line: GoIFormatArticleLine) -> some View {
        Button {
            Haptics.medium()
            if let url = URL(string: line.u) {
                navigationRouter.pushArticle(url: url)
            }
        } label: {
            HStack(alignment: .top, spacing: 10) {
                Text(line.t)
                    .font(AppTypography.feedListOnePointDown(.headline, weight: .semibold))
                    .foregroundStyle(AppTheme.textPrimary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 8)
                if let url = URL(string: line.u), articleRepository.isRead(url: url) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(AppTypography.feedListOnePointDown(.body, weight: .medium))
                        .foregroundStyle(AppTheme.textSecondary)
                }
            }
            .padding(.vertical, 6)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func goiGroupTagRow(tag: String) -> some View {
        let hub = GoIManifestTagHubResolver.hubURL(forManifestTag: tag)
        Button {
            Haptics.medium()
            navigationRouter.pushArticle(url: hub)
        } label: {
            HStack(alignment: .top, spacing: 10) {
                Text(tag)
                    .font(AppTypography.feedListOnePointDown(.headline, weight: .heavy))
                    .foregroundStyle(AppTheme.textPrimary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 8)
                if articleRepository.isRead(url: hub) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(AppTypography.feedListOnePointDown(.body, weight: .medium))
                        .foregroundStyle(AppTheme.textSecondary)
                }
            }
            .padding(.vertical, 6)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func multiformTalesAuthorDisclosureLabel(group: MultiformTalesAuthorGroup) -> some View {
        HStack(alignment: .center, spacing: 10) {
            Image(systemName: "person.fill")
                .font(AppTypography.feedListOnePointDown(.body, weight: .semibold))
                .foregroundStyle(AppTheme.brandAccent)
                .frame(width: 22, alignment: .center)
            Text(group.displayName)
                .font(AppTypography.feedListOnePointDown(.headline, weight: .semibold))
                .foregroundStyle(AppTheme.textPrimary)
                .multilineTextAlignment(.leading)
            Spacer(minLength: 0)
            Text(
                String(
                    format: String(localized: String.LocalizationValue(LocalizationKey.talesJpTaleCountFormat)),
                    locale: .current,
                    group.entries.count
                )
            )
            .font(AppTypography.feedListOnePointDown(.caption1, weight: .semibold))
            .foregroundStyle(AppTheme.textSecondary)
            .monospacedDigit()
        }
        .padding(.vertical, 2)
    }

    @ViewBuilder
    private func multiformTalesArticleRow(row: SCPGeneralContent) -> some View {
        Button {
            Haptics.medium()
            if let u = row.resolvedURL {
                navigationRouter.pushArticle(url: u)
            }
        } label: {
            HStack(alignment: .top, spacing: 10) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(row.t)
                        .font(AppTypography.feedListOnePointDown(.headline, weight: .heavy))
                        .foregroundStyle(AppTheme.textPrimary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
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
        .indexListRowChromeIndented()
    }

    @ViewBuilder
    private var canonHubSourceTabPickerChrome: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(CanonHubCatalogTab.allCases) { tab in
                        Button {
                            Haptics.selection()
                            canonHubSourceTab = tab
                        } label: {
                            TagChipView(
                                label: String(localized: String.LocalizationValue(tab.titleLocalizationKey)),
                                isSelected: canonHubSourceTab == tab
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
            .accessibilityLabel(String(localized: String.LocalizationValue(LocalizationKey.canonHubSourcePickerAccessibility)))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.cardStandard.ignoresSafeArea(edges: .bottom))
        .overlay(alignment: .top) {
            Rectangle()
                .fill(AppTheme.terminalSilver.opacity(0.35))
                .frame(height: 1)
        }
    }

    @ViewBuilder
    private var goiSourceTabPickerChrome: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(GoICatalogSourceTab.allCases) { tab in
                        Button {
                            Haptics.selection()
                            goiSourceTab = tab
                        } label: {
                            TagChipView(
                                label: String(localized: String.LocalizationValue(tab.titleLocalizationKey)),
                                isSelected: goiSourceTab == tab
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
            .accessibilityLabel(String(localized: String.LocalizationValue(LocalizationKey.goiCatalogSourcePickerAccessibility)))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.cardStandard.ignoresSafeArea(edges: .bottom))
        .overlay(alignment: .top) {
            Rectangle()
                .fill(AppTheme.terminalSilver.opacity(0.35))
                .frame(height: 1)
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
        if kind == .gois {
            let p = feedCache.loadPersistedGeneralMultiformPayload(kind: .gois)
            goisManifest = p
            canonsManifest = nil
            cachedEntries = p?.entries ?? []
        } else if kind == .canons {
            let p = feedCache.loadPersistedGeneralMultiformPayload(kind: .canons)
            canonsManifest = p
            goisManifest = nil
            cachedEntries = p?.entries ?? []
        } else {
            goisManifest = nil
            canonsManifest = nil
            cachedEntries = feedCache.loadPersistedGeneralMultiformPayload(kind: kind)?.entries ?? []
        }
    }

    private func goiEntryMatchesSourceTab(_ entry: SCPGeneralContent) -> Bool {
        guard let raw = entry.r?.trimmingCharacters(in: .whitespacesAndNewlines), !raw.isEmpty else {
            return true
        }
        let lower = raw.lowercased()
        guard let tab = goiLineageKey(lower) else {
            return true
        }
        return tab == goiSourceTab
    }

    private func goiLineageKey(_ lowercased: String) -> GoICatalogSourceTab? {
        switch lowercased {
        case "jp", "japan", "scp-jp", "ja":
            return .jp
        case "en", "english", "enwiki", "us", "scp-wiki", "scpen", "main":
            return .en
        case "other", "intl", "international", "int", "other-goi", "jp-intl":
            return .other
        default:
            return nil
        }
    }

    private func jokeListObjectClassLabel(wiki: String) -> String {
        if let key = SCPJPTagObjectClassCatalog.chipLocalizationKey(forWikiEqualityTitle: wiki) {
            return String(localized: String.LocalizationValue(key))
        }
        return wiki
    }
}
