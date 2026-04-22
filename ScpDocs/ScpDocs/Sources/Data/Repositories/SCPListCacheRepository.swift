import Foundation

/// Phase 13: 取得済み `scp_list` の `UserDefaults` 永続化。
final class SCPListCacheRepository: @unchecked Sendable {
    private enum StorageKey {
        static let payloadJSON = "scp_list.cache.payload_json"
        static let appliedListVersion = "scp_list.cache.applied_list_version"

        static func wikiCatalogJSON(_ kind: WikiCatalogKind) -> String {
            "wiki_catalog.cache.\(kind.rawValue).payload_json"
        }

        static func wikiCatalogListVersion(_ kind: WikiCatalogKind) -> String {
            "wiki_catalog.cache.\(kind.rawValue).list_version"
        }
    }

    private let defaults: UserDefaults
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        let enc = JSONEncoder()
        enc.dateEncodingStrategy = .iso8601
        self.encoder = enc
        let dec = JSONDecoder()
        dec.dateDecodingStrategy = .iso8601
        self.decoder = dec
    }

    /// 最後に適用したリモート `listVersion`（未同期は `0`）。
    func persistedListVersion() -> Int {
        let v = defaults.integer(forKey: StorageKey.appliedListVersion)
        return max(0, v)
    }

    func loadPersistedPayload() -> SCPListRemotePayload? {
        guard let data = defaults.data(forKey: StorageKey.payloadJSON), !data.isEmpty else {
            return nil
        }
        return try? decoder.decode(SCPListRemotePayload.self, from: data)
    }

    func saveMergedPayload(_ payload: SCPListRemotePayload) throws {
        let data = try encoder.encode(payload)
        defaults.set(data, forKey: StorageKey.payloadJSON)
        defaults.set(payload.listVersion, forKey: StorageKey.appliedListVersion)
    }

    /// 未取得は `0`。
    func persistedWikiCatalogListVersion(kind: WikiCatalogKind) -> Int {
        max(0, defaults.integer(forKey: StorageKey.wikiCatalogListVersion(kind)))
    }

    func loadWikiCatalog(kind: WikiCatalogKind) -> WikiCategoryCatalogPayload? {
        guard let data = defaults.data(forKey: StorageKey.wikiCatalogJSON(kind)), !data.isEmpty else {
            return nil
        }
        return try? decoder.decode(WikiCategoryCatalogPayload.self, from: data)
    }

    func saveWikiCatalog(_ payload: WikiCategoryCatalogPayload, kind: WikiCatalogKind) throws {
        let data = try encoder.encode(payload)
        defaults.set(data, forKey: StorageKey.wikiCatalogJSON(kind))
        defaults.set(payload.listVersion, forKey: StorageKey.wikiCatalogListVersion(kind))
    }
}
