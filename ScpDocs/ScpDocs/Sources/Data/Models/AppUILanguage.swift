import Foundation

/// アプリ UI の表示言語（システム設定とは独立して保存する）。
enum AppUILanguage: String, CaseIterable, Identifiable {
    case system
    case japanese
    case english

    var id: String { rawValue }
}
