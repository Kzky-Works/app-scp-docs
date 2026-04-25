import Foundation

/// `list/jp/jp_tag.json` を取得し `JPTagMapCacheRepository` に保存する。
struct JPTagMapSyncService: Sendable {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func syncIfNeeded(
        metadataStore: JapanSCPListMetadataStore,
        cacheRepository: JPTagMapCacheRepository
    ) async {
        let online = await MainActor.run { ConnectivityMonitor.shared.isPathSatisfied }
        guard online else { return }
        guard let url = AppRemoteConfig.resolvedJPTagMapURL() else { return }
        do {
            let (data, response) = try await session.data(from: url)
            guard let http = response as? HTTPURLResponse, (200 ... 299).contains(http.statusCode) else { return }
            let remote = try JSONDecoder().decode(JPTagMapPayload.self, from: data)
            let prior = cacheRepository.loadPayload()
            if let p = prior, p.articles == remote.articles, p.tagPageRange == remote.tagPageRange, p.source == remote.source {
                return
            }
            try cacheRepository.savePayload(remote)
            await MainActor.run {
                metadataStore.reloadFromCache()
            }
        } catch {
            return
        }
    }
}
