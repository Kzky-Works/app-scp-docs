import Foundation
import SwiftData

/// `PersonnelRecord` への読み取りアクセスと、`ArticleRepository` からの整合同期。
@MainActor
final class PersonnelReadingJournal {
    private enum SessionDefaultsKey {
        static let activeCatalogFeed = "personnel.reading.active_catalog_feed"
    }

    private let container: ModelContainer
    private let sessionDefaults: UserDefaults

    init(container: ModelContainer, sessionDefaults: UserDefaults = .standard) {
        self.container = container
        self.sessionDefaults = sessionDefaults
    }

    /// カタログ一覧から Reader に入ったときの系統（`NEXT` / `RANDOM` 用）。
    func setActiveCatalogFeed(_ kind: SCPArticleFeedKind?) {
        if let kind {
            sessionDefaults.set(kind.rawValue, forKey: SessionDefaultsKey.activeCatalogFeed)
        } else {
            sessionDefaults.removeObject(forKey: SessionDefaultsKey.activeCatalogFeed)
        }
    }

    func activeCatalogFeedKind() -> SCPArticleFeedKind? {
        guard let raw = sessionDefaults.string(forKey: SessionDefaultsKey.activeCatalogFeed) else { return nil }
        return SCPArticleFeedKind(rawValue: raw)
    }

    /// 明示コンテキストが無いときだけ URL から推定して保存する。
    func ensureActiveCatalogFeedIfNeeded(for url: URL) {
        guard activeCatalogFeedKind() == nil else { return }
        if let inferred = CatalogFeedNavigator.inferCatalogFeed(for: url) {
            setActiveCatalogFeed(inferred)
        }
    }

    /// 閲覧終了時にスクロール・滞在時間を SwiftData に反映する。
    func persistVisitEnd(normalizedURLKey: String, scrollProgress: Double, addedReadingSeconds: TimeInterval) throws {
        let context = container.mainContext
        let clampedScroll = min(1, max(0, scrollProgress))
        let add = max(0, addedReadingSeconds)
        let key = normalizedURLKey
        var descriptor = FetchDescriptor<PersonnelRecord>(
            predicate: #Predicate<PersonnelRecord> { $0.normalizedURLKey == key }
        )
        descriptor.fetchLimit = 1
        if let existing = try context.fetch(descriptor).first {
            existing.lastAccessedAt = Date()
            existing.scrollProgress = clampedScroll
            existing.totalReadingTimeSeconds += add
        } else {
            context.insert(
                PersonnelRecord(
                    normalizedURLKey: normalizedURLKey,
                    lastAccessedAt: Date(),
                    scrollProgress: clampedScroll,
                    totalReadingTimeSeconds: add
                )
            )
        }
        try context.save()
    }

    /// `ArticleRepository` の履歴・スクロール進捗を `PersonnelRecord` に反映する（履歴順＝新しいほど先頭）。
    func reconcile(from articleRepository: ArticleRepository) throws {
        let context = container.mainContext
        let existing = try context.fetch(FetchDescriptor<PersonnelRecord>())
        for r in existing {
            context.delete(r)
        }
        let history = articleRepository.allHistory()
        let base = Date()
        for (idx, url) in history.enumerated() {
            let key = ArticleRepository.storageKey(for: url)
            let scroll = articleRepository.readingScrollDepth(for: url)
            let stamp = base.addingTimeInterval(-TimeInterval(idx))
            let clamped = min(1, max(0, scroll))
            context.insert(
                PersonnelRecord(
                    normalizedURLKey: key,
                    lastAccessedAt: stamp,
                    scrollProgress: clamped,
                    totalReadingTimeSeconds: 0
                )
            )
        }
        try context.save()
    }

    /// 読了率が `incompleteBelowProgress` 未満で、最後にアクセスした 1 件（既定は 95% 未満を「途中」）。
    func latestContinueReadingURL(incompleteBelowProgress: Double = 0.95) throws -> URL? {
        let context = container.mainContext
        var descriptor = FetchDescriptor<PersonnelRecord>(
            sortBy: [SortDescriptor(\.lastAccessedAt, order: .reverse)]
        )
        descriptor.fetchLimit = 50
        let batch = try context.fetch(descriptor)
        for record in batch where record.scrollProgress + 0.000_001 < incompleteBelowProgress {
            return URL(string: record.normalizedURLKey)
        }
        return nil
    }
}
