import Foundation

/// `manifest_gois` の `g` タグから、同梱の `GoIFormatsIndexData` / `GoILibraryHierarchyData` に照らし合わせた団体ハブ URL を返す。未一致時は scp-jp のタグ一覧へ。
enum GoIManifestTagHubResolver: Sendable {
    private static let fallbackTagPortal = URL(string: "https://scp-jp.wikidot.com/groups-of-interest-jp")!

    private static let pathSlugToURL: [String: URL] = {
        var out: [String: URL] = [:]
        func take(_ u: URL) {
            let k = u.lastPathComponent.lowercased()
            if k.isEmpty { return }
            if out[k] == nil { out[k] = u }
        }
        for group in GoILibraryHierarchyData.japanGoIFormatGroups {
            if let u = group.hubURL { take(u) }
        }
        for link in GoIFormatsIndexData.englishFormatHubs {
            take(link.url)
        }
        for link in GoIFormatsIndexData.japanFormatHubs {
            take(link.url)
        }
        return out
    }()

    static func hubURL(forManifestTag tag: String) -> URL {
        let t = tag.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty else { return fallbackTagPortal }
        let key = t.lowercased()

        if let u = pathSlugToURL[key] {
            return u
        }
        for g in GoILibraryHierarchyData.japanGoIFormatGroups {
            if g.hubTitle == t, let u = g.hubURL { return u }
        }
        for link in GoIFormatsIndexData.englishFormatHubs {
            if link.id.lowercased() == key { return link.url }
            if link.id.split(separator: "#").first.map(String.init)?.lowercased() == key { return link.url }
        }
        for link in GoIFormatsIndexData.japanFormatHubs {
            if link.id.lowercased() == key { return link.url }
            if let hash = link.id.split(separator: "#").last, String(hash).lowercased() == key {
                return link.url
            }
        }
        if let u = wikidotJPTagListURL(tag: t) { return u }
        return fallbackTagPortal
    }

    private static func wikidotJPTagListURL(tag: String) -> URL? {
        let enc = tag.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? tag
        return URL(string: "https://scp-jp.wikidot.com/system:page-tags/tag/\(enc)")
    }
}
