import Foundation

/// `list/jp/scp-jp.json` 等（`AppRemoteConfig` 解決 URL）を非同期に並列取得し、キャッシュへ保存する。
struct SCPArticleTrifoldSyncService: Sendable {
    private let catalogRepository: SCPArticleCatalogRepository
    private let cacheRepository: SCPArticleFeedCacheRepository

    init(
        catalogRepository: SCPArticleCatalogRepository = SCPArticleCatalogRepository(),
        cacheRepository: SCPArticleFeedCacheRepository
    ) {
        self.catalogRepository = catalogRepository
        self.cacheRepository = cacheRepository
    }

    /// オフライン時は何もしない。各フィードは独立して成功分のみ保存する。
    func syncAllFeedsIfNeeded() async {
        let online = await MainActor.run { ConnectivityMonitor.shared.isPathSatisfied }
        guard online else { return }

        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.syncOne(kind: .jp) }
            group.addTask { await self.syncOne(kind: .en) }
            group.addTask { await self.syncOne(kind: .int) }
        }
    }

    private func syncOne(kind: SCPArticleFeedKind) async {
        guard kind.isTrifoldSCPReportFeed else { return }
        guard AppRemoteConfig.resolvedSCPArticleFeedURL(kind: kind) != nil else { return }
        let localVersion = cacheRepository.persistedListVersion(kind: kind)
        do {
            let remote: SCPArticleListPayload
            switch kind {
            case .jp:
                remote = try await catalogRepository.fetchJP()
            case .en:
                remote = try await catalogRepository.fetchEN()
            case .int:
                remote = try await catalogRepository.fetchINT()
            case .tales, .gois, .canons, .jokes:
                return
            }
            guard remote.listVersion > localVersion else { return }
            let existing = cacheRepository.loadPersistedPayload(kind: kind)
            let merged = Self.merge(remote: remote, existing: existing)
            try cacheRepository.savePayload(merged, kind: kind)
        } catch {
            return
        }
    }

    private static func merge(remote: SCPArticleListPayload, existing: SCPArticleListPayload?) -> SCPArticleListPayload {
        var byKey: [String: SCPArticle] = [:]
        if let existing {
            for e in existing.entries {
                if let k = SCPArticleCatalogRepository.normalizedURLKey(for: e) {
                    byKey[k] = e
                }
            }
        }
        for e in remote.entries {
            if let k = SCPArticleCatalogRepository.normalizedURLKey(for: e) {
                byKey[k] = e
            }
        }
        let combined = byKey.values.sorted { a, b in
            let ka = SCPArticleCatalogRepository.normalizedURLKey(for: a) ?? ""
            let kb = SCPArticleCatalogRepository.normalizedURLKey(for: b) ?? ""
            return ka < kb
        }
        return SCPArticleListPayload(
            listVersion: remote.listVersion,
            schemaVersion: remote.schemaVersion,
            generatedAt: remote.generatedAt,
            entries: combined
        )
    }
}
