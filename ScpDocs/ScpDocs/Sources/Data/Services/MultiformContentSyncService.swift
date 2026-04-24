import Foundation

/// `manifest_tales.json` / `manifest_gois.json` / `canons.json` / `jokes.json` を並列取得し、マルチフォーム用キャッシュへ保存する。
struct MultiformContentSyncService: Sendable {
    private let catalogRepository: SCPGeneralContentCatalogRepository
    private let cacheRepository: SCPArticleFeedCacheRepository

    init(
        catalogRepository: SCPGeneralContentCatalogRepository = SCPGeneralContentCatalogRepository(),
        cacheRepository: SCPArticleFeedCacheRepository
    ) {
        self.catalogRepository = catalogRepository
        self.cacheRepository = cacheRepository
    }

    func syncAllMultiformFeedsIfNeeded() async {
        let online = await MainActor.run { ConnectivityMonitor.shared.isPathSatisfied }
        guard online else { return }

        await withTaskGroup(of: Void.self) { group in
            for kind in SCPArticleFeedKind.allCases where kind.isMultiformArchiveFeed {
                group.addTask { await self.syncOne(kind: kind) }
            }
        }
    }

    private func syncOne(kind: SCPArticleFeedKind) async {
        guard AppRemoteConfig.resolvedMultiformArchiveJSONURL(kind: kind) != nil else { return }
        let localVersion = cacheRepository.persistedGeneralMultiformListVersion(kind: kind)
        do {
            let remote = try await catalogRepository.fetchMultiform(kind: kind)
            guard remote.listVersion > localVersion else { return }
            let existing = cacheRepository.loadPersistedGeneralMultiformPayload(kind: kind)
            let merged = Self.merge(remote: remote, existing: existing)
            try cacheRepository.saveGeneralMultiformPayload(merged, kind: kind)
        } catch {
            return
        }
    }

    private static func merge(
        remote: SCPGeneralContentListPayload,
        existing: SCPGeneralContentListPayload?
    ) -> SCPGeneralContentListPayload {
        var byKey: [String: SCPGeneralContent] = [:]
        if let existing {
            for e in existing.entries {
                if let k = SCPGeneralContentCatalogRepository.normalizedURLKey(for: e) {
                    byKey[k] = e
                }
            }
        }
        for e in remote.entries {
            if let k = SCPGeneralContentCatalogRepository.normalizedURLKey(for: e) {
                byKey[k] = e
            }
        }
        let combined = byKey.values.sorted { a, b in
            let ka = SCPGeneralContentCatalogRepository.normalizedURLKey(for: a) ?? ""
            let kb = SCPGeneralContentCatalogRepository.normalizedURLKey(for: b) ?? ""
            return ka < kb
        }
        return SCPGeneralContentListPayload(
            listVersion: remote.listVersion,
            schemaVersion: remote.schemaVersion,
            generatedAt: remote.generatedAt,
            entries: combined
        )
    }
}
