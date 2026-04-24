import Foundation

/// 3 系統分割配信の JSON を取得するリポジトリ（ネットワーク）。
///
/// ユーザー状態の `ArticleRepository`（`UserDefaults`）とは役割を分離している。
struct SCPArticleCatalogRepository: Sendable {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchJP() async throws -> SCPArticleListPayload {
        try await fetch(kind: .jp)
    }

    func fetchEN() async throws -> SCPArticleListPayload {
        try await fetch(kind: .en)
    }

    func fetchINT() async throws -> SCPArticleListPayload {
        try await fetch(kind: .int)
    }

    private func fetch(kind: SCPArticleFeedKind) async throws -> SCPArticleListPayload {
        guard let url = AppRemoteConfig.resolvedSCPArticleFeedURL(kind: kind) else {
            throw SCPArticleCatalogError.invalidURL
        }
        let (data, response) = try await session.data(from: url)
        guard let http = response as? HTTPURLResponse, (200 ... 299).contains(http.statusCode) else {
            throw SCPArticleCatalogError.badResponse
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode(SCPArticleListPayload.self, from: data)
        guard AppRemoteConfig.supportedSCPArticleFeedSchemaVersions.contains(decoded.schemaVersion) else {
            throw SCPArticleCatalogError.schemaMismatch
        }
        return decoded
    }

    /// `PersonnelRecord` / `ArticleRepository` と突き合わせる正規化 URL キー。
    nonisolated static func normalizedURLKey(for article: SCPArticle) -> String? {
        guard let url = article.resolvedURL else { return nil }
        return ArticleRepository.storageKey(for: url)
    }
}

enum SCPArticleCatalogError: Error {
    case invalidURL
    case badResponse
    case schemaMismatch
}
