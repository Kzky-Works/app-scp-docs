import Foundation
import Observation

/// 財団 Tales-JP 著者別一覧の読み込みとセグメント別フィルタ。
@Observable
@MainActor
final class FoundationTalesJPIndexViewModel {
    enum Phase: Equatable {
        case idle
        case loading
        case ready
        case failed(String)
    }

    private(set) var phase: Phase = .idle
    private(set) var allAuthors: [FoundationTalesJPAuthor] = []

    /// 既定は「A」（Wiki のアルファベット順セクションと揃える）。
    var selectedSegment: TalesJPAlphabetSegment = .letter("A")

    private let repository: FoundationTalesJPRepository

    init(repository: FoundationTalesJPRepository = .shared) {
        self.repository = repository
    }

    func load(forceRefresh: Bool = false) async {
        phase = .loading
        do {
            let authors = try await repository.authors(forceRefresh: forceRefresh)
            allAuthors = authors
            phase = .ready
        } catch {
            phase = .failed(error.localizedDescription)
        }
    }

    func authors(for segment: TalesJPAlphabetSegment, locale: Locale) -> [FoundationTalesJPAuthor] {
        let filtered = allAuthors.filter { TalesJPAlphabetSegment.bucket(forAuthorDisplayName: $0.displayName) == segment }
        return filtered.sorted { a, b in
            let cmp = a.displayName.compare(b.displayName, options: [.caseInsensitive, .widthInsensitive], locale: locale)
            if cmp == .orderedSame { return a.id < b.id }
            return cmp == .orderedAscending
        }
    }

    func wikiHubURL() -> URL {
        FoundationTalesJPWikiSite.foundationTalesJPPage
    }
}
