import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// Semantic colors for the SCP docs visual system (avoid raw hex in views).
enum AppTheme {
    /// Matte black `#121212`.
    static let backgroundPrimary = Color(
        red: 18 / 255,
        green: 18 / 255,
        blue: 18 / 255
    )

    /// Satin silver `#C0C0C0`.
    static let accentPrimary = Color(
        red: 192 / 255,
        green: 192 / 255,
        blue: 192 / 255
    )

    #if canImport(UIKit)
    /// Matte black for `WKWebView` / UIKit surfaces (`#121212`).
    static let backgroundPrimaryUIKit = UIColor(
        red: 18 / 255,
        green: 18 / 255,
        blue: 18 / 255,
        alpha: 1
    )

    /// Satin silver for default text on dark surfaces (`#C0C0C0`).
    static let accentPrimaryUIKit = UIColor(
        red: 192 / 255,
        green: 192 / 255,
        blue: 192 / 255,
        alpha: 1
    )
    #endif
}
