import Foundation

/// Tale / GoI / Canon / Joke 用の `*.json` を取得する（ネットワーク）。ユーザー状態は `ArticleRepository` 側。
struct SCPGeneralContentCatalogRepository: Sendable {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchMultiform(kind: SCPArticleFeedKind) async throws -> SCPGeneralContentListPayload {
        guard kind.isMultiformArchiveFeed else {
            throw SCPGeneralContentCatalogError.invalidKind
        }
        guard let url = AppRemoteConfig.resolvedMultiformArchiveJSONURL(kind: kind) else {
            throw SCPGeneralContentCatalogError.invalidURL
        }
        let (data, response) = try await session.data(from: url)
        guard let http = response as? HTTPURLResponse, (200 ... 299).contains(http.statusCode) else {
            throw SCPGeneralContentCatalogError.badResponse
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode(SCPGeneralContentListPayload.self, from: data)
        guard AppRemoteConfig.supportedSCPGeneralContentFeedSchemaVersions.contains(decoded.schemaVersion) else {
            throw SCPGeneralContentCatalogError.schemaMismatch
        }
        return decoded
    }

    nonisolated static func normalizedURLKey(for content: SCPGeneralContent) -> String? {
        guard let url = content.resolvedURL else { return nil }
        return ArticleRepository.storageKey(for: url)
    }
}

enum SCPGeneralContentCatalogError: Error {
    case invalidKind
    case invalidURL
    case badResponse
    case schemaMismatch
}
