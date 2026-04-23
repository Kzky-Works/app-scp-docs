import Foundation
import Observation
import SwiftUI

@Observable
@MainActor
final class NavigationRouter {
    /// `NavigationStack` 連携用。最終要素で「閲覧中」等を判定する。
    var path: [NavigationRoute] = []

    func push(_ route: NavigationRoute) {
        path.append(route)
    }

    func pushArticle(url: URL) {
        path.append(NavigationRoute.article(url))
    }

    /// 数字のみ、または `scp-173` 形式を **scp-jp.wikidot.com** の報告書 URL に変換して遷移する。
    @discardableResult
    func pushSCPJPArticleIfPossible(query: String) -> Bool {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return false }
        if trimmed.allSatisfy(\.isNumber) {
            return pushJumpToSCPIfPossible(query: trimmed, branchBaseURL: Branch.japan.baseURL)
        }
        let lower = trimmed.lowercased()
        if lower.hasPrefix("scp-") {
            let rest = lower.dropFirst(4).filter(\.isNumber)
            guard !rest.isEmpty, let value = Int(String(rest)), value > 0 else { return false }
            return pushJumpToSCPIfPossible(query: "\(value)", branchBaseURL: Branch.japan.baseURL)
        }
        return false
    }

    /// 数字のみのクエリ（例: `173`）を現在支部の SCP 記事 URL に変換して遷移する。
    /// - Returns: ジャンプに成功したとき `true`。
    @discardableResult
    func pushJumpToSCPIfPossible(query: String, branchBaseURL: URL) -> Bool {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, trimmed.allSatisfy(\.isNumber) else { return false }
        let numericBody = String(trimmed.drop { $0 == "0" })
        let core = numericBody.isEmpty ? "0" : numericBody
        guard let value = Int(core), value > 0 else { return false }
        let slug: String
        if value < 1000 {
            slug = String(format: "scp-%03d", value)
        } else {
            slug = "scp-\(value)"
        }
        var base = branchBaseURL.absoluteString
        if base.hasSuffix("/") {
            base.removeLast()
        }
        guard let url = URL(string: "\(base)/\(slug)") else { return false }
        pushArticle(url: url)
        return true
    }

    func popToRoot() {
        path.removeAll()
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    /// 記事 Reader の最上段を差し替え（`NEXT CASE` 等で同一スタック内遷移）。
    func replaceTopArticle(with url: URL) {
        guard let last = path.last else {
            pushArticle(url: url)
            return
        }
        switch last {
        case .article:
            path[path.count - 1] = .article(url)
        default:
            pushArticle(url: url)
        }
    }
}
