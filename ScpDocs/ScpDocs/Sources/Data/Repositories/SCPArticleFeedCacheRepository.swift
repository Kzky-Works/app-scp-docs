import Foundation

/// 3 系統 `SCPArticleListPayload` のローカルキャッシュ（`UserDefaults`）。
final class SCPArticleFeedCacheRepository: @unchecked Sendable {
    private enum StorageKey {
        static func payloadJSON(_ kind: SCPArticleFeedKind) -> String {
            "scp_article_feed.cache.\(kind.rawValue).payload_json"
        }

        static func appliedListVersion(_ kind: SCPArticleFeedKind) -> String {
            "scp_article_feed.cache.\(kind.rawValue).applied_list_version"
        }

        /// Step 4: Tale / GoI / Canon / Joke（`SCPGeneralContentListPayload`）。
        static func generalMultiformPayloadJSON(_ kind: SCPArticleFeedKind) -> String {
            "scp_multiform_feed.cache.\(kind.rawValue).payload_json"
        }

        static func generalMultiformAppliedListVersion(_ kind: SCPArticleFeedKind) -> String {
            "scp_multiform_feed.cache.\(kind.rawValue).applied_list_version"
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

    func persistedListVersion(kind: SCPArticleFeedKind) -> Int {
        max(0, defaults.integer(forKey: StorageKey.appliedListVersion(kind)))
    }

    func loadPersistedPayload(kind: SCPArticleFeedKind) -> SCPArticleListPayload? {
        guard let data = defaults.data(forKey: StorageKey.payloadJSON(kind)), !data.isEmpty else {
            return nil
        }
        return try? decoder.decode(SCPArticleListPayload.self, from: data)
    }

    func savePayload(_ payload: SCPArticleListPayload, kind: SCPArticleFeedKind) throws {
        let data = try encoder.encode(payload)
        defaults.set(data, forKey: StorageKey.payloadJSON(kind))
        defaults.set(payload.listVersion, forKey: StorageKey.appliedListVersion(kind))
    }

    // MARK: - Step 4（マルチフォーム）

    func persistedGeneralMultiformListVersion(kind: SCPArticleFeedKind) -> Int {
        guard kind.isMultiformArchiveFeed else { return 0 }
        return max(0, defaults.integer(forKey: StorageKey.generalMultiformAppliedListVersion(kind)))
    }

    func loadPersistedGeneralMultiformPayload(kind: SCPArticleFeedKind) -> SCPGeneralContentListPayload? {
        guard kind.isMultiformArchiveFeed else { return nil }
        guard let data = defaults.data(forKey: StorageKey.generalMultiformPayloadJSON(kind)), !data.isEmpty else {
            return nil
        }
        return try? decoder.decode(SCPGeneralContentListPayload.self, from: data)
    }

    func saveGeneralMultiformPayload(_ payload: SCPGeneralContentListPayload, kind: SCPArticleFeedKind) throws {
        precondition(kind.isMultiformArchiveFeed, "saveGeneralMultiformPayload expects a multiform feed kind")
        let data = try encoder.encode(payload)
        defaults.set(data, forKey: StorageKey.generalMultiformPayloadJSON(kind))
        defaults.set(payload.listVersion, forKey: StorageKey.generalMultiformAppliedListVersion(kind))
    }
}
