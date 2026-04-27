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
    case seriesJp
    var id: String { rawValue }
    var titleLocalizationKey: String {
        switch self {
        case .jp: return LocalizationKey.goiCatalogSourceTabJP
        case .en: return LocalizationKey.goiCatalogSourceTabEN
        case .seriesJp: return LocalizationKey.canonCatalogSourceTabSeriesJP
        }
    }
}

// MARK: - カノンフィードリスト行（報告書フィード等と同様の区切り線のみ）

private struct CanonHubFeedListRowContent: View {
    let line: GoIFormatArticleLine
    let contentBranch: Branch

    @Environment(\.colorScheme) private var colorScheme

    private var descriptionForeground: Color {
        switch colorScheme {
        case .dark:
            AppTheme.textPrimary.opacity(0.88)
        default:
            AppTheme.textPrimary.opacity(0.66)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center, spacing: 8) {
                if let chip = seriesTagChipText {
                    Text(chip)
                        .font(AppTypography.feedListOnePointDown(.caption1, weight: .semibold))
                        .foregroundStyle(AppTheme.brandAccent)
                        .lineLimit(1)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .overlay(
                            RoundedRectangle(cornerRadius: 3, style: .continuous)
                                .stroke(AppTheme.brandAccent, lineWidth: max(0.5, AppTheme.borderWidthHairline))
                        )
                }
                Spacer(minLength: 8)
                if let updated = lastUpdatedLabel {
                    Text(updated)
                        .font(AppTypography.feedListOnePointDown(.caption1, weight: .medium))
                        .foregroundStyle(AppTheme.textSecondary)
                        .multilineTextAlignment(.trailing)
                        .lineLimit(2)
                        .monospacedDigit()
                }
            }
            Text(line.t)
                .font(AppTypography.feedListCanonHubTitle(weight: .bold))
                .foregroundStyle(AppTheme.textPrimary)
                .multilineTextAlignment(.leading)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 8)
            Text(slugDisplay)
                .font(AppTypography.feedListOnePointDown(.subheadline, weight: .medium))
                .foregroundStyle(AppTheme.brandAccent)
                .lineLimit(1)
                .padding(.top, 4)
            Text((line.ds ?? "").trimmingCharacters(in: .whitespacesAndNewlines))
                .font(AppTypography.feedListOnePointDown(.subheadline, weight: .regular))
                .foregroundStyle(descriptionForeground)
                .multilineTextAlignment(.leading)
                .lineLimit(2)
                .truncationMode(.tail)
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .contentShape(Rectangle())
    }

    private var seriesTagChipText: String? {
        guard let raw = line.ct?.trimmingCharacters(in: .whitespacesAndNewlines), !raw.isEmpty else { return nil }
        return raw
    }

    private var slugDisplay: String {
        let slug = line.i.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !slug.isEmpty else { return "" }
        return "/" + slug
    }

    private var lastUpdatedLabel: String? {
        guard let lu = line.lu else { return nil }
        let tz = contentBranch.catalogListingsTimeZone
        let date = Date(timeIntervalSince1970: TimeInterval(lu))
        let fmt = DateFormatter()
        fmt.calendar = Calendar(identifier: .gregorian)
        fmt.timeZone = tz
        fmt.locale = Locale.current
        fmt.dateFormat = "yyyy/MM/dd"
        let dateStr = fmt.string(from: date)
        let format = String(localized: String.LocalizationValue(LocalizationKey.canonCardLastUpdatedFormat))
        return String(format: format, locale: .current, dateStr)
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

// MARK: - Tales: 著者別ミニマルリスト（カードなし）

private struct MultiformTalesAuthorGroup: Identifiable {
    static let unknownAuthorID = "multiform_tales_author_unknown"
    let id: String
    let displayName: String
    let entries: [SCPGeneralContent]
}

private struct TalesMinimalListRowPressStyle: ButtonStyle {
    @Environment(\.colorScheme) private var colorScheme

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                (colorScheme == .dark ? Color.white : Color.black)
                    .opacity(configuration.isPressed ? 0.05 : 0)
            )
    }
}

private struct TaleAuthorRow: View {
    let displayName: String
    let countLabel: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(alignment: .center, spacing: 0) {
                Text(displayName)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(AppTheme.textPrimary)
                    .lineLimit(1)
                    .truncationMode(.tail)
                Spacer(minLength: 12)
                Text(countLabel)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(AppTheme.textSecondary)
                    .monospacedDigit()
                    .lineLimit(1)
            }
            .padding(.vertical, 14)
            .contentShape(Rectangle())
        }
        .buttonStyle(TalesMinimalListRowPressStyle())
    }
}

/// Step 4: Tale / GoI / Canon / Joke のネイティブ一覧（`SCPGeneralContent`）。
struct SCPGeneralContentListView: View {
    let kind: SCPArticleFeedKind
    /// 設定のコンテンツ支部（カノンカードの日付タイムゾーン等）。
    let contentBranch: Branch
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

    /// `manifest_gois` schema 3: タブに応じた団体行（団体名 → ハブ `u` のみ。`u` 空は除外）
    private var goiV3TabGroups: [GoIFormatGroupPayload] {
        guard let r = goisManifest?.goiRegions else { return [] }
        let raw: [GoIFormatGroupPayload] = switch goiSourceTab {
        case .jp: r.jp
        case .en: r.en
        case .other: r.other
        }
        return raw.filter { !$0.u.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    }

    /// マニフェストの `canonRegions`、または `entries[].r`（jp / en / series_jp）から組み立て。
    private var resolvedCanonRegions: CanonRegionsLayoutPayload? {
        if let cr = canonsManifest?.canonRegions,
           !cr.jp.isEmpty || !cr.en.isEmpty || !cr.seriesJp.isEmpty
        {
            return cr
        }
        var jp: [GoIFormatArticleLine] = []
        var en: [GoIFormatArticleLine] = []
        var seriesJp: [GoIFormatArticleLine] = []
        for e in cachedEntries {
            guard let line = goIFormatArticleLine(from: e) else { continue }
            switch canonHubLineageTab(e) {
            case .en: en.append(line)
            case .seriesJp: seriesJp.append(line)
            case .jp: jp.append(line)
            }
        }
        if jp.isEmpty && en.isEmpty && seriesJp.isEmpty { return nil }
        return CanonRegionsLayoutPayload(jp: jp, en: en, seriesJp: seriesJp)
    }

    /// `manifest_canons` のカノンハブ行（タブで JP / EN / 連作-JP を切替）。
    private var canonV3TabHubLines: [GoIFormatArticleLine] {
        guard let r = resolvedCanonRegions else { return [] }
        switch canonHubSourceTab {
        case .jp: return r.jp
        case .en: return r.en
        case .seriesJp: return r.seriesJp
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
            if let cr = resolvedCanonRegions {
                let anyHub = !cr.jp.isEmpty || !cr.en.isEmpty || !cr.seriesJp.isEmpty
                return !anyHub && cachedEntries.isEmpty
            }
            return cachedEntries.isEmpty
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
                        goiV3GroupHubRow(group: group)
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
            } else if kind == .canons, resolvedCanonRegions != nil {
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
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        ForEach(multiformTalesAuthorGroups) { group in
                            VStack(alignment: .leading, spacing: 0) {
                                let expanded = expandedMultiformTalesAuthorKeys.contains(group.id)
                                let countText = String(
                                    format: String(localized: String.LocalizationValue(LocalizationKey.talesJpTaleCountFormat)),
                                    locale: .current,
                                    group.entries.count
                                )
                                TaleAuthorRow(
                                    displayName: group.displayName,
                                    countLabel: countText
                                ) {
                                    withAnimation(.easeInOut(duration: 0.15)) {
                                        if expanded {
                                            expandedMultiformTalesAuthorKeys.remove(group.id)
                                        } else {
                                            Haptics.selection()
                                            expandedMultiformTalesAuthorKeys.insert(group.id)
                                        }
                                    }
                                }
                                if expanded {
                                    ForEach(group.entries, id: \.self) { row in
                                        multiformTalesArticleMinimalRow(row: row)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
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
                                if kind == .jokes {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(TrifoldReportFeedRowFormatter.jokeScpNumberLine(entry: row))
                                            .font(AppTypography.feedListOnePointDown(.subheadline, weight: .semibold))
                                            .foregroundStyle(AppTheme.textPrimary)
                                            .monospaced()
                                            .lineLimit(1)
                                        Text(row.t)
                                            .font(AppTypography.feedListOnePointDown(.body, weight: .semibold))
                                            .foregroundStyle(AppTheme.textPrimary)
                                            .multilineTextAlignment(.leading)
                                            .lineLimit(3)
                                            .fixedSize(horizontal: false, vertical: true)
                                        if let oc = jokeListRowObjectClassDisplay(entry: row) {
                                            Text(oc)
                                                .font(AppTypography.feedListOnePointDown(.caption1, weight: .semibold))
                                                .foregroundStyle(AppTheme.textSecondary)
                                                .lineLimit(1)
                                        }
                                    }
                                } else {
                                    Text(row.t)
                                        .font(AppTypography.feedListOnePointDown(.headline, weight: .heavy))
                                        .foregroundStyle(AppTheme.textPrimary)
                                        .multilineTextAlignment(.leading)
                                        .lineLimit(2)
                                        .fixedSize(horizontal: false, vertical: true)
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
                            }
                            Spacer(minLength: 8)
                            if let u = row.resolvedURL, articleRepository.isRead(url: u) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(AppTypography.feedListOnePointDown(.body, weight: .medium))
                                    .foregroundStyle(AppTheme.textSecondary)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
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
            } else if kind == .canons, resolvedCanonRegions != nil {
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
    private func goiV3GroupHubRow(group: GoIFormatGroupPayload) -> some View {
        Button {
            Haptics.medium()
            if let url = URL(string: group.u.trimmingCharacters(in: .whitespacesAndNewlines)) {
                navigationRouter.pushArticle(url: url)
            }
        } label: {
            HStack(alignment: .top, spacing: 10) {
                Text(group.t)
                    .font(AppTypography.feedListOnePointDown(.headline, weight: .heavy))
                    .foregroundStyle(AppTheme.textPrimary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 8)
                if let url = URL(string: group.u.trimmingCharacters(in: .whitespacesAndNewlines)),
                   articleRepository.isRead(url: url)
                {
                    Image(systemName: "checkmark.circle.fill")
                        .font(AppTypography.feedListOnePointDown(.body, weight: .medium))
                        .foregroundStyle(AppTheme.textSecondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .padding(.vertical, 6)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func canonHubLineRow(line: GoIFormatArticleLine) -> some View {
        Button {
            Haptics.medium()
            if let url = URL(string: line.u.trimmingCharacters(in: .whitespacesAndNewlines)) {
                navigationRouter.pushArticle(url: url)
            }
        } label: {
            CanonHubFeedListRowContent(line: line, contentBranch: contentBranch)
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
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .padding(.vertical, 6)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func multiformTalesArticleMinimalRow(row: SCPGeneralContent) -> some View {
        Button {
            Haptics.medium()
            if let u = row.resolvedURL {
                navigationRouter.pushArticle(url: u)
            }
        } label: {
            Text(row.t)
                .font(.system(size: 15, weight: .regular))
                .foregroundStyle(AppTheme.textPrimary)
                .multilineTextAlignment(.leading)
                .lineLimit(2)
                .truncationMode(.tail)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 10)
                .padding(.leading, 2)
                .contentShape(Rectangle())
        }
        .buttonStyle(TalesMinimalListRowPressStyle())
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

    /// マニフェストの軽量行と同一形（カノンハブ一覧用）。
    private func goIFormatArticleLine(from entry: SCPGeneralContent) -> GoIFormatArticleLine? {
        let u = entry.u.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !u.isEmpty else { return nil }
        let id: String
        if let i = entry.i, !i.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            id = i.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        } else if let url = URL(string: u),
                  let last = url.path.split(separator: "/").filter({ !$0.isEmpty }).last
        {
            id = String(last).lowercased()
        } else {
            return nil
        }
        return GoIFormatArticleLine(u: u, i: id, t: entry.t)
    }

    /// `metadata.r` 由来のカノン出典（jp / en / series_jp）。欠損時は JP タブへまとめる。
    private func canonHubLineageTab(_ entry: SCPGeneralContent) -> CanonHubCatalogTab {
        guard let raw = entry.r?.trimmingCharacters(in: .whitespacesAndNewlines), !raw.isEmpty else {
            return .jp
        }
        let lower = raw.lowercased()
        switch lower {
        case "en", "english", "enwiki", "us", "scp-wiki", "scpen", "main":
            return .en
        case "series_jp", "series-jp", "seriesjp", "連作-jp":
            return .seriesJp
        default:
            return .jp
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

    private func jokeListRowObjectClassDisplay(entry: SCPGeneralContent) -> String? {
        guard let meta = japanSCPListMetadataStore, let oc = meta.jokeMultiformListRowObjectClass(entry: entry) else {
            return nil
        }
        return jokeListObjectClassLabel(wiki: oc)
    }
}
