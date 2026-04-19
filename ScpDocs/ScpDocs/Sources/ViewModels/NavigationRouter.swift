import Foundation
import Observation
import SwiftUI

@Observable
@MainActor
final class NavigationRouter {
    var path = NavigationPath()

    func push(_ route: NavigationRoute) {
        path.append(route)
    }

    func pushArticle(url: URL) {
        path.append(NavigationRoute.article(url))
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
        path = NavigationPath()
    }
}
