import Foundation
import Observation

/// Phase 14: アーカイヴ一覧のオブジェクトクラス・タグによる絞り込み。
@Observable
final class ArchiveArticleViewModel {
    /// 選択中のオブジェクトクラス（Wiki 表記、例: `Keter`）。`nil` は指定なし。
    var selectedObjectClass: String?
    /// AND 条件で適用するタグ（完全一致）。
    var selectedTags: Set<String> = []
    /// タグチップ一覧の絞り込み用クエリ。
    var tagSearchQuery: String = ""

    /// セグメント切替時などに呼び、迷子フィルタを防ぐ。
    func clearFilters() {
        selectedObjectClass = nil
        selectedTags = []
        tagSearchQuery = ""
    }

    var hasActiveFilters: Bool {
        selectedObjectClass != nil || !selectedTags.isEmpty
    }

    func filteredEntries(from entries: [JapanSCPArchiveEntry]) -> [JapanSCPArchiveEntry] {
        entries.filter { matchesFilters($0) }
    }

    private func matchesFilters(_ entry: JapanSCPArchiveEntry) -> Bool {
        if let oc = selectedObjectClass {
            guard let eoc = entry.objectClass else { return false }
            guard eoc.caseInsensitiveCompare(oc) == .orderedSame else { return false }
        }
        for t in selectedTags {
            guard entry.tags.contains(t) else { return false }
        }
        return true
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

    /// 現在セグメントに現れるタグを優先シード順＋五十音／英字順で並べ、検索クエリで絞る。
    func visibleTagChips(for segmentEntries: [JapanSCPArchiveEntry]) -> [String] {
        var present = Set<String>()
        for e in segmentEntries {
            present.formUnion(e.tags)
        }
        let ordered = Self.orderTags(present: present)
        let q = tagSearchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
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
}
