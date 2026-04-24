import Foundation

/// `docs/catalog/*.json` を取得し `WikiCatalogCacheRepository` に保存する。
struct WikiCatalogSyncService: Sendable {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func syncIfNeeded(
        metadataStore: JapanSCPListMetadataStore,
        wikiCatalogCacheRepository: WikiCatalogCacheRepository
    ) async {
        let online = await MainActor.run { ConnectivityMonitor.shared.isPathSatisfied }
        guard online else { return }
        guard AppRemoteConfig.resolvedWikiCatalogBaseURL() != nil else { return }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        var didUpdate = false
        for kind in WikiCatalogKind.allCases {
            guard let url = AppRemoteConfig.resolvedWikiCatalogURL(kind: kind) else { continue }
            let localVersion = wikiCatalogCacheRepository.persistedWikiCatalogListVersion(kind: kind)
            do {
                let (data, response) = try await session.data(from: url)
                guard let http = response as? HTTPURLResponse, (200 ... 299).contains(http.statusCode) else {
                    continue
                }
                let remote = try decoder.decode(WikiCategoryCatalogPayload.self, from: data)
                guard remote.schemaVersion == AppRemoteConfig.wikiCatalogSchemaVersion else { continue }
                guard remote.listVersion > localVersion else { continue }
                try wikiCatalogCacheRepository.saveWikiCatalog(remote, kind: kind)
                didUpdate = true
            } catch {
                continue
            }
        }

        if didUpdate {
            await MainActor.run {
                metadataStore.reloadFromCache()
            }
        }
    }
}
