import Foundation

/// Wikidot カタログ JSON（`docs/catalog/*.json`）の `UserDefaults` 永続化。
final class WikiCatalogCacheRepository: @unchecked Sendable {
    private enum StorageKey {
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
