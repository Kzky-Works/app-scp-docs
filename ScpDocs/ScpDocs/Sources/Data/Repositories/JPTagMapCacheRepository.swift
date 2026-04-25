import Foundation

/// 巨大な `list/jp/jp_tag.json` を **UserDefaults ではなく** Application Support ファイルに保持する。
final class JPTagMapCacheRepository: @unchecked Sendable {
    private let fileURL: URL
    private let lock = NSLock()
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    init(fileManager: FileManager = .default) {
        let base = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? fileManager.temporaryDirectory
        let dir = base.appendingPathComponent("ScpDocs", isDirectory: true)
        try? fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
        self.fileURL = dir.appendingPathComponent("jp_tag_map.json", isDirectory: false)
        let dec = JSONDecoder()
        self.decoder = dec
        let enc = JSONEncoder()
        enc.outputFormatting = [] // コンパクト
        self.encoder = enc
    }

    /// キャッシュが無い・デコード失敗のとき `nil`。
    func loadPayload() -> JPTagMapPayload? {
        lock.lock()
        defer { lock.unlock() }
        guard let data = try? Data(contentsOf: fileURL), !data.isEmpty else { return nil }
        return try? decoder.decode(JPTagMapPayload.self, from: data)
    }

    func savePayload(_ payload: JPTagMapPayload) throws {
        let data = try encoder.encode(payload)
        lock.lock()
        defer { lock.unlock() }
        try data.write(to: fileURL, options: .atomic)
    }
}
