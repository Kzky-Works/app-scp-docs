import Foundation
import Observation

/// Phase 14–16: アーカイヴ一覧のオブジェクトクラス・タグ・レーティングによる絞り込み／並べ替え。
@Observable
final class ArchiveArticleViewModel {
    /// 選択中のオブジェクトクラス（Wiki 表記、例: `Keter`）。`nil` は指定なし。
    var selectedObjectClass: String?
    /// AND 条件で適用するタグ（完全一致）。
    var selectedTags: Set<String> = []
    /// タグチップ一覧の絞り込み用クエリ（`score:>4.0` 形式のスコア句を含み得る）。
    var tagSearchQuery: String = ""

    /// 「お気に入り」相当: レーティング 4.0 以上のみ（内部マッピング）。
    var filterHighRatingOnly: Bool = false

    /// 一覧の並べ替え（既定: レーティング降順）。
    var sortMode: ArchiveListSortMode

    init(defaults: UserDefaults = .standard) {
        self.sortMode = ArchiveListSortMode.load(from: defaults)
    }

    func persistSortMode(to defaults: UserDefaults = .standard) {
        sortMode.save(to: defaults)
    }

    /// セグメント切替時などに呼び、迷子フィルタを防ぐ。
    func clearFilters() {
        selectedObjectClass = nil
        selectedTags = []
        tagSearchQuery = ""
        filterHighRatingOnly = false
    }

    var hasActiveFilters: Bool {
        selectedObjectClass != nil || !selectedTags.isEmpty || filterHighRatingOnly || parsedScorePredicate != nil
    }

    /// チップ検索に使う文字列（`score:` 句を除いた残り）。
    var effectiveTagSearchQueryForChips: String {
        Self.stripScoreCommands(from: tagSearchQuery)
    }

    func filteredAndSortedEntries(
        from entries: [JapanSCPArchiveEntry],
        ratingScore: (URL) -> Double
    ) -> [JapanSCPArchiveEntry] {
        var list = entries.filter { matchesFilters($0, ratingScore: ratingScore) }
        switch sortMode {
        case .ratingHighToLow:
            list.sort { a, b in
                let ra = ratingScore(a.url)
                let rb = ratingScore(b.url)
                if ra != rb { return ra > rb }
                return a.scpNumber < b.scpNumber
            }
        case .scpNumberAscending:
            list.sort { $0.scpNumber < $1.scpNumber }
        }
        return list
    }

    private func matchesFilters(_ entry: JapanSCPArchiveEntry, ratingScore: (URL) -> Double) -> Bool {
        if let oc = selectedObjectClass {
            guard SCPJPTagObjectClassCatalog.objectClassFilterMatches(
                entryObjectClass: entry.objectClass,
                entryTags: entry.tags,
                selectedWikiTitle: oc
            ) else { return false }
        }
        for t in selectedTags {
            guard entry.tags.contains(t) else { return false }
        }

        let r = ratingScore(entry.url)

        if filterHighRatingOnly, r < Self.highRatingThreshold {
            return false
        }

        if let predicate = parsedScorePredicate, !predicate(r) {
            return false
        }

        return true
    }

    /// アーカイヴ「高評価」フィルタおよび旧「お気に入り」意味合いの境界。
    static let highRatingThreshold: Double = 4.0

    private var parsedScorePredicate: ((Double) -> Bool)? {
        Self.parseScorePredicate(from: tagSearchQuery)
    }

    func toggleObjectClass(_ canonical: String) {
        if selectedObjectClass?.caseInsensitiveCompare(canonical) == .orderedSame {
            selectedObjectClass = nil
        } else {
            selectedObjectClass = canonical
        }
    }

    func toggleTag(_ tag: String) {
        if selectedTags.contains(tag) {
            selectedTags.remove(tag)
        } else {
            selectedTags.insert(tag)
        }
    }

    func toggleHighRatingFilter() {
        filterHighRatingOnly.toggle()
    }

    /// 現在セグメントに現れるタグを優先シード順＋五十音／英字順で並べ、検索クエリで絞る。
    func visibleTagChips(for segmentEntries: [JapanSCPArchiveEntry]) -> [String] {
        var present = Set<String>()
        for e in segmentEntries {
            present.formUnion(e.tags)
        }
        let ordered = Self.orderTags(present: present)
        let q = effectiveTagSearchQueryForChips.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return ordered }
        return ordered.filter { $0.localizedStandardContains(q) }
    }

    /// 財団でよく参照されるタグを先頭に（当該セグメントに存在するもののみ）。
    private static let prioritizedTagSeeds: [String] = [
        "人型", "空間異常", "認識災害", "精神影響", "生物", "自律", "彫刻", "電気", "液体",
    ]

    private static func orderTags(present: Set<String>) -> [String] {
        var head: [String] = []
        for s in prioritizedTagSeeds where present.contains(s) {
            head.append(s)
        }
        var rest: [String] = []
        for t in present where !head.contains(t) {
            rest.append(t)
        }
        rest.sort { $0.localizedStandardCompare($1) == .orderedAscending }
        return head + rest
    }

    // MARK: - score: コマンド（将来のタグ検索バー拡張）

    /// `score:>4` / `score:>=4.0` 等を解析し、述語を返す。複数条件は先頭の 1 件のみ（将来拡張用に集約）。
    static func parseScorePredicate(from raw: String) -> ((Double) -> Bool)? {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        let pattern = #"score\s*:\s*(>=|<=|>|<|=)?\s*([\d.]+)"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else { return nil }
        let range = NSRange(trimmed.startIndex ..< trimmed.endIndex, in: trimmed)
        guard let match = regex.firstMatch(in: trimmed, options: [], range: range) else { return nil }

        guard let thresholdRange = Range(match.range(at: 2), in: trimmed),
              let threshold = Double(String(trimmed[thresholdRange]))
        else { return nil }

        let opRange = match.range(at: 1)
        let op: String
        if opRange.location != NSNotFound, let r = Range(opRange, in: trimmed) {
            op = String(trimmed[r])
        } else {
            op = ">="
        }

        switch op {
        case ">":
            return { $0 > threshold }
        case ">=":
            return { $0 >= threshold }
        case "<":
            return { $0 < threshold }
        case "<=":
            return { $0 <= threshold }
        case "=":
            return { abs($0 - threshold) < 0.001 }
        default:
            return { $0 >= threshold }
        }
    }

    /// `score:` で始まるサブストリングを除去し、タグ検索の残りを返す。
    static func stripScoreCommands(from raw: String) -> String {
        let pattern = #"score\s*:\s*(>=|<=|>|<|=)?\s*[\d.]+\s*"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else { return raw }
        let range = NSRange(raw.startIndex ..< raw.endIndex, in: raw)
        let out = regex.stringByReplacingMatches(in: raw, options: [], range: range, withTemplate: "")
        return out.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
