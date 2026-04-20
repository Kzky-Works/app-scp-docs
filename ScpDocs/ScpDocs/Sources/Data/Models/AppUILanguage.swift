import Foundation

/// アプリ UI の表示言語（システム設定とは独立して保存する）。
enum AppUILanguage: String, CaseIterable, Identifiable {
    case system
    case japanese
    case english

    var id: String { rawValue }
}

/// アプリ全体の配色（設定のトグルでライト／ダークを切替）。
enum AppAppearancePreference: String, CaseIterable, Identifiable {
    case light
    case dark

    var id: String { rawValue }
}
