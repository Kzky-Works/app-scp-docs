import CryptoKit
import Foundation
import Network
import Observation

/// ネットワーク到達性（`WebViewModel` のロード分岐と UI バッジ用）。
@Observable
@MainActor
final class ConnectivityMonitor {
    static let shared = ConnectivityMonitor()

    private(set) var isPathSatisfied = true

    private let monitor = NWPathMonitor()

    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor in
                self?.isPathSatisfied = path.status == .satisfied
            }
        }
        monitor.start(queue: .main)
    }
}

/// お気に入り記事の HTML スナップショットを Application Support に保存する。
final class OfflineStore: @unchecked Sendable {
    static let shared = OfflineStore()

    private let subdirectoryName = "OfflineSnapshots"

    private init() {}

    private func snapshotsDirectory() throws -> URL {
        let base = try FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        let dir = base.appendingPathComponent(subdirectoryName, isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    private func fileURL(forCanonicalKey key: String) throws -> URL {
        let hash = Self.sha256Hex(key)
        return try snapshotsDirectory().appendingPathComponent("\(hash).html", isDirectory: false)
    }

    private static func sha256Hex(_ string: String) -> String {
        let digest = SHA256.hash(data: Data(string.utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    /// `ArticleRepository` と同一の正規化キーでパスを決定する。
    private static func canonicalKey(for url: URL) -> String {
        ArticleRepository.storageKey(for: url)
    }

    private static func baseHrefValue(for url: URL) -> String {
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            return escapeForHtmlAttribute(url.absoluteString)
        }
        components.fragment = nil
        if components.path.isEmpty {
            components.path = "/"
        }
        return escapeForHtmlAttribute(components.string ?? url.absoluteString)
    }

    private static func escapeForHtmlAttribute(_ raw: String) -> String {
        raw
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "\"", with: "&quot;")
    }

    /// `<head>` 直後に `<base href="...">` を挿入する（既存の先頭 `<base` は削除しないで追記のみでもよいが、二重を避ける）。
    static func htmlByInsertingBaseTag(_ html: String, pageURL: URL) -> String {
        if html.range(of: "<base", options: .caseInsensitive) != nil {
            return html
        }
        let baseTag = "<base href=\"\(baseHrefValue(for: pageURL))\">"
        guard let headRange = html.range(of: "<head", options: .caseInsensitive) else {
            return "<head>\(baseTag)</head>" + html
        }
        let afterHead = html[headRange.upperBound...]
        guard let close = afterHead.firstIndex(of: ">") else {
            return "<head>\(baseTag)</head>" + html
        }
        let insertIndex = html.index(after: close)
        var result = html
        result.insert(contentsOf: baseTag, at: insertIndex)
        return result
    }

    func saveHTML(_ html: String, for url: URL) throws {
        let key = Self.canonicalKey(for: url)
        let processed = Self.htmlByInsertingBaseTag(html, pageURL: url)
        let dest = try fileURL(forCanonicalKey: key)
        try processed.write(to: dest, atomically: true, encoding: .utf8)
    }

    func loadHTML(for url: URL) -> URL? {
        let key = Self.canonicalKey(for: url)
        guard let dest = try? fileURL(forCanonicalKey: key) else { return nil }
        return FileManager.default.fileExists(atPath: dest.path) ? dest : nil
    }

    func deleteHTML(for url: URL) {
        let key = Self.canonicalKey(for: url)
        guard let dest = try? fileURL(forCanonicalKey: key) else { return }
        try? FileManager.default.removeItem(at: dest)
    }

    func deleteAllSnapshots() {
        guard let dir = try? snapshotsDirectory() else { return }
        guard let items = try? FileManager.default.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil) else {
            return
        }
        for url in items {
            try? FileManager.default.removeItem(at: url)
        }
    }
}
