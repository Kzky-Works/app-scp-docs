import Foundation

/// `manifest_tales.json` / `manifest_gois.json` / `manifest_canons.json` / `manifest_jokes.json` を並列取得し、マルチフォーム用キャッシュへ保存する。
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
        await MainActor.run {
            NotificationCenter.default.post(name: .scpMultiformManifestsDidSync, object: nil)
        }
    }

    private func syncOne(kind: SCPArticleFeedKind) async {
        guard AppRemoteConfig.resolvedMultiformArchiveJSONURL(kind: kind) != nil else { return }
        do {
            let remote = try await catalogRepository.fetchMultiform(kind: kind)
            let remoteUsable = !remote.entries.isEmpty || remote.goiRegions != nil || remote.canonRegions != nil
            guard remoteUsable else { return }

            let localVersion = cacheRepository.persistedGeneralMultiformListVersion(kind: kind)
            let existing = cacheRepository.loadPersistedGeneralMultiformPayload(kind: kind)
            let localIsEmpty = existing?.entries.isEmpty ?? true

            let merged: SCPGeneralContentListPayload
            if remote.listVersion > localVersion {
                merged = Self.merge(remote: remote, existing: existing)
            } else if remote.listVersion < localVersion {
                // 旧 JSON のタイムスタンプ等でローカル版だけが大きいとき、新 manifest が永遠に弾かれないようにする。
                merged = Self.merge(remote: remote, existing: nil)
            } else if localIsEmpty {
                merged = Self.merge(remote: remote, existing: existing)
            } else {
                return
            }
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
            entries: combined,
            goiRegions: remote.goiRegions ?? existing?.goiRegions,
            canonRegions: remote.canonRegions ?? existing?.canonRegions
        )
    }
}
