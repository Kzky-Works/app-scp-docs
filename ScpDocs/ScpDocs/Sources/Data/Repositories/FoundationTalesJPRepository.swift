import Foundation

/// `foundation-tales-jp` を取得してパースし、セッション内キャッシュする。
actor FoundationTalesJPRepository {
    static let shared = FoundationTalesJPRepository()

    private let pageURL = FoundationTalesJPWikiSite.foundationTalesJPPage
    private let session: URLSession

    private var cachedAuthors: [FoundationTalesJPAuthor]?

    init(session: URLSession = .shared) {
        self.session = session
    }

    func authors(forceRefresh: Bool) async throws -> [FoundationTalesJPAuthor] {
        if !forceRefresh, let cachedAuthors {
            return cachedAuthors
        }
        let html = try await fetchHTML()
        let parsed = FoundationTalesJPPageParser.parseAuthors(html: html)
        cachedAuthors = parsed
        return parsed
    }

    private func fetchHTML() async throws -> String {
        var request = URLRequest(url: pageURL)
        request.setValue(
            "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile",
            forHTTPHeaderField: "User-Agent"
        )
        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw FoundationTalesJPRepositoryError.invalidResponse
        }
        guard (200 ... 299).contains(http.statusCode) else {
            throw FoundationTalesJPRepositoryError.httpStatus(http.statusCode)
        }
        guard let html = String(data: data, encoding: .utf8) else {
            throw FoundationTalesJPRepositoryError.encoding
        }
        return html
    }
}

enum FoundationTalesJPRepositoryError: Error, LocalizedError {
    case invalidResponse
    case httpStatus(Int)
    case encoding

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            "invalid_response"
        case .httpStatus(let code):
            "http_\(code)"
        case .encoding:
            "encoding"
        }
    }
}
