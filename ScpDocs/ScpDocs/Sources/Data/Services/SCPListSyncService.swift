import Foundation

/// Phase 13: 起動時などに `scp_list.json` を取得し、ローカルキャッシュへマージする。
struct SCPListSyncService: Sendable {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    /// オフライン・URL 未設定・HTTP 失敗・デコード失敗時は何もせず、既存キャッシュ＋埋め込みデータにフォールバック。
    func syncIfNeeded(
        metadataStore: JapanSCPListMetadataStore,
        cacheRepository: SCPListCacheRepository
    ) async {
        let online = await MainActor.run { ConnectivityMonitor.shared.isPathSatisfied }
        guard online else { return }

        guard let url = AppRemoteConfig.resolvedSCPListJSONURL() else { return }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        do {
            let (data, response) = try await session.data(from: url)
            guard let http = response as? HTTPURLResponse, (200 ... 299).contains(http.statusCode) else {
                return
            }
            let remote = try decoder.decode(SCPListRemotePayload.self, from: data)
            guard remote.schemaVersion == AppRemoteConfig.scpListSchemaVersion else { return }

            let localVersion = cacheRepository.persistedListVersion()
            guard remote.listVersion > localVersion else { return }

            let existing = cacheRepository.loadPersistedPayload()
            let merged = Self.merge(remote: remote, existing: existing)

            try cacheRepository.saveMergedPayload(merged)
            await MainActor.run {
                metadataStore.reloadFromCache()
            }
        } catch {
            return
        }
    }

    private static func merge(remote: SCPListRemotePayload, existing: SCPListRemotePayload?) -> SCPListRemotePayload {
        var byKey: [String: SCPListRemoteEntry] = [:]
        if let existing {
            for e in existing.entries {
                byKey[e.mergeKey] = e
            }
        }
        for e in remote.entries {
            byKey[e.mergeKey] = e
        }
        let combined = byKey.values.sorted {
            if $0.series != $1.series { return $0.series < $1.series }
            return $0.scpNumber < $1.scpNumber
        }
        var hubPaths = Set<String>()
        if let existing {
            hubPaths.formUnion(existing.hubLinkedPaths)
        }
        hubPaths.formUnion(remote.hubLinkedPaths)
        return SCPListRemotePayload(
            listVersion: remote.listVersion,
            schemaVersion: remote.schemaVersion,
            generatedAt: remote.generatedAt,
            entries: combined,
            hubLinkedPaths: hubPaths.sorted()
        )
    }
}
