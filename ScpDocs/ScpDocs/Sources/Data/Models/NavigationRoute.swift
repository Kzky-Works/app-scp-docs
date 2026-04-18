import Foundation

/// アプリ内ナビゲーションの遷移先（`NavigationPath` に積む値）。
enum NavigationRoute: Hashable, Sendable {
    case home
    case category(URL)
    case article(URL)
}
