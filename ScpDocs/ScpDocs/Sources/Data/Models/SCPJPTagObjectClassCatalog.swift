import Foundation

/// SCP-JP Wikidot のタグ（`safe` 等）とオブジェクトクラス表示の対応。`objectClass` 文字列が空のときタグから補完する。
enum SCPJPTagObjectClassCatalog: Sendable {
    private struct Row: Sendable {
        let slug: String
        /// 一覧・フィルタで比較する正規 Wiki 表記（英字クラス名など）。
        let wikiEqualityTitle: String
    }

    private static let rows: [Row] = [
        Row(slug: "safe", wikiEqualityTitle: "Safe"),
        Row(slug: "euclid", wikiEqualityTitle: "Euclid"),
        Row(slug: "keter", wikiEqualityTitle: "Keter"),
        Row(slug: "thaumiel", wikiEqualityTitle: "Thaumiel"),
        Row(slug: "apollyon", wikiEqualityTitle: "Apollyon"),
        Row(slug: "archon", wikiEqualityTitle: "Archon"),
        Row(slug: "cernunnos", wikiEqualityTitle: "Cernunnos"),
        Row(slug: "ticonderoga", wikiEqualityTitle: "Ticonderoga"),
        Row(slug: "neutralized", wikiEqualityTitle: "Neutralized"),
        Row(slug: "decommissioned", wikiEqualityTitle: "Decommissioned"),
        Row(slug: "pending", wikiEqualityTitle: "Pending"),
        Row(slug: "esoteric-class", wikiEqualityTitle: "Esoteric")
    ]

    /// クイックフィルタ用チップ（`wikiEqualityTitle` の表示は `LocalizationKey.archiveObjectClassChipPrefix` + キー）。
    static var orderedFilterWikiTitles: [String] {
        rows.map(\.wikiEqualityTitle)
    }

    /// チップ表示用 `LocalizationKey` の値（未登録 Wiki 表記は `nil`）。
    static func chipLocalizationKey(forWikiEqualityTitle wiki: String) -> String? {
        switch wiki {
        case "Safe": LocalizationKey.archiveOcSafe
        case "Euclid": LocalizationKey.archiveOcEuclid
        case "Keter": LocalizationKey.archiveOcKeter
        case "Thaumiel": LocalizationKey.archiveOcThaumiel
        case "Apollyon": LocalizationKey.archiveOcApollyon
        case "Archon": LocalizationKey.archiveOcArchon
        case "Cernunnos": LocalizationKey.archiveOcCernunnos
        case "Ticonderoga": LocalizationKey.archiveOcTiconderoga
        case "Neutralized": LocalizationKey.archiveOcNeutralized
        case "Decommissioned": LocalizationKey.archiveOcDecommissioned
        case "Pending": LocalizationKey.archiveOcPending
        case "Esoteric": LocalizationKey.archiveOcEsoteric
        default: nil
        }
    }

    /// チップの色分け用インデックス（`TagFilterView`）。
    static func filterTintIndex(forWikiEqualityTitle wiki: String) -> Int {
        guard let idx = rows.firstIndex(where: { $0.wikiEqualityTitle == wiki }) else { return 0 }
        return idx
    }

    /// カタログまたはフィード由来の `objectClass` を優先し、無ければタグから推定。
    static func resolvedWikiObjectClass(catalogOrFeedClass: String?, tags: [String]) -> String? {
        if let c = catalogOrFeedClass?.trimmingCharacters(in: .whitespacesAndNewlines), !c.isEmpty {
            return normalizeIncomingClass(c)
        }
        return inferredWikiTitle(fromTags: tags)
    }

    /// タグ列からオブジェクトクラスを推定（先頭一致の 1 件）。
    static func inferredWikiTitle(fromTags tags: [String]) -> String? {
        for row in rows {
            if tags.contains(where: { tagMatchesRow($0, row: row) }) {
                return row.wikiEqualityTitle
            }
        }
        return nil
    }

    /// オブジェクトクラス由来とみなすタグを一覧チップから外す（重複表示の抑止）。
    static func tagsStrippingObjectClassMarkers(_ tags: [String]) -> [String] {
        var out: [String] = []
        var seen = Set<String>()
        for raw in tags {
            let t = raw.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !t.isEmpty else { continue }
            if rows.contains(where: { tagMatchesRow(t, row: $0) }) { continue }
            if seen.contains(t) { continue }
            seen.insert(t)
            out.append(t)
        }
        return out
    }

    /// オブジェクトクラス・フィルタ一致（`selected` は Wiki 表記想定。タグに `safe` があれば Safe とみなす）。
    static func objectClassFilterMatches(entryObjectClass: String?, entryTags: [String], selectedWikiTitle: String) -> Bool {
        let sel = selectedWikiTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !sel.isEmpty else { return false }
        if let eoc = entryObjectClass?.trimmingCharacters(in: .whitespacesAndNewlines), !eoc.isEmpty {
            if wikiTitlesSemanticallyEqual(eoc, sel) { return true }
        }
        guard let wantRow = rows.first(where: { $0.wikiEqualityTitle.caseInsensitiveCompare(sel) == .orderedSame }) else {
            return entryTags.contains { $0.trimmingCharacters(in: .whitespacesAndNewlines).caseInsensitiveCompare(sel) == .orderedSame }
        }
        return entryTags.contains { tagMatchesRow($0, row: wantRow) }
    }

    // MARK: - Private

    /// フィード／Wiki 由来の表記を行定義の Wiki 表記へ寄せる（`wikiTitlesSemanticallyEqual` とは相互再帰しない）。
    private static func normalizeIncomingClass(_ raw: String) -> String {
        let t = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        let tLower = t.lowercased()
        let tSlugish = tLower.replacingOccurrences(of: " ", with: "-")
        for row in rows {
            if t.caseInsensitiveCompare(row.wikiEqualityTitle) == .orderedSame { return row.wikiEqualityTitle }
            if tLower == row.slug { return row.wikiEqualityTitle }
            if tSlugish == row.slug { return row.wikiEqualityTitle }
        }
        return t
    }

    private static func wikiTitlesSemanticallyEqual(_ a: String, _ b: String) -> Bool {
        if a.caseInsensitiveCompare(b) == .orderedSame { return true }
        let na = normalizeIncomingClass(a)
        let nb = normalizeIncomingClass(b)
        return na.caseInsensitiveCompare(nb) == .orderedSame
    }

    private static func tagMatchesRow(_ tag: String, row: Row) -> Bool {
        let trimmed = tag.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return false }
        if trimmed.caseInsensitiveCompare(row.wikiEqualityTitle) == .orderedSame { return true }
        if trimmed.lowercased() == row.slug { return true }
        if trimmed.lowercased().replacingOccurrences(of: " ", with: "-") == row.slug { return true }
        return false
    }
}
