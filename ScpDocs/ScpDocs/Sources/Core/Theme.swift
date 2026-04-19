import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

// MARK: - WebView 用（CleanUI.js と同一の hex を Swift から注入）

struct WebContentPalette: Equatable, Sendable {
    let backgroundHex: String
    let textHex: String
    let linkHex: String
    let linkHoverHex: String
    let containerHex: String
}

/// 画像ベースの「モダン・ブルータリズム」パレット（ライト／ダーク）。
/// 画面側は `Color`、UIKit／WebView は対応する動的 `UIColor` と hex を共有する。
enum AppTheme {
    static let cornerRadiusCard: CGFloat = 10
    static let borderWidthHairline: CGFloat = 0.5

    /// 要注意・ナビ選択・イベント等の差し色（財団レッド系）。
    static let brandAccent = Color(
        red: 220 / 255,
        green: 38 / 255,
        blue: 38 / 255
    )

    // MARK: SwiftUI — システム外観に追従

    static let backgroundPrimary = dynamicColor(
        light: (242, 242, 247),
        dark: (10, 10, 10)
    )

    /// 索引・一覧画面の下地（`backgroundPrimary` と同一）。
    static var mainBackground: Color { backgroundPrimary }

    /// 通常カード面（ライト白／ダーク #161616）。
    static let surfaceCard = dynamicColor(
        light: (255, 255, 255),
        dark: (22, 22, 22)
    )

    /// 索引行のカード面（`surfaceCard` と同一）。
    static var cardBackground: Color { surfaceCard }

    /// JP アーカイヴ等の反転タイル（ライトではチャコール、ダークではやや深い面）。
    static let surfaceInverted = dynamicColor(
        light: (22, 22, 22),
        dark: (18, 18, 18)
    )

    static let borderSubtle = dynamicColor(
        light: (229, 229, 234),
        dark: (44, 44, 46)
    )

    /// 本文・見出しの主色（ライト #3A3A3C／ダーク #C0C0C0）。
    static let textPrimary = dynamicColor(
        light: (58, 58, 60),
        dark: (192, 192, 192)
    )

    static let textSecondary = dynamicColor(
        light: (110, 110, 115),
        dark: (142, 142, 147)
    )

    /// 旧コード互換: 主にアイコン・ラベルに使っていた「アクセント」＝ `textPrimary` と同系。
    static let accentPrimary = textPrimary

    /// 反転タイル上の文字色。
    static let textOnInverted = dynamicColor(
        light: (242, 242, 247),
        dark: (192, 192, 192)
    )

    static let shadowCard = Color.black.opacity(0.06)

    /// AdMob 標準バナー（`GADAdSizeBanner`）に合わせた帯の高さ。ルート `safeAreaInset` 用。
    static let adBannerStripeHeight: CGFloat = 50

    // MARK: UIKit（WKWebView 等）

#if canImport(UIKit)
    static let backgroundPrimaryUIKit = dynamicUIColor(
        light: (242, 242, 247),
        dark: (10, 10, 10)
    )

    static let accentPrimaryUIKit = dynamicUIColor(
        light: (58, 58, 60),
        dark: (192, 192, 192)
    )

    static let brandAccentUIKit = UIColor(brandAccent)
#endif

    // MARK: Web

    static func webContentPalette(isDark: Bool) -> WebContentPalette {
        if isDark {
            WebContentPalette(
                backgroundHex: "#0A0A0A",
                textHex: "#C0C0C0",
                linkHex: "#C0C0C0",
                linkHoverHex: "#E0E0E0",
                containerHex: "#0A0A0A"
            )
        } else {
            WebContentPalette(
                backgroundHex: "#F2F2F7",
                textHex: "#3A3A3C",
                linkHex: "#3A3A3C",
                linkHoverHex: "#1C1C1E",
                containerHex: "#F2F2F7"
            )
        }
    }

    // MARK: Tab bar

#if canImport(UIKit)
    /// 下部のシステム `TabView` タブバー: やや透過のブラー。周囲はコンテンツが透けて見える（記事 WebView など）。
    static func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        appearance.backgroundColor = UIColor.black.withAlphaComponent(0.12)

        let line = UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(white: 1, alpha: 0.12)
                : UIColor(white: 0, alpha: 0.08)
        }
        appearance.shadowColor = line
        appearance.shadowImage = UIImage()

        let normal = UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(white: 0.55, alpha: 1)
                : UIColor(white: 0.45, alpha: 1)
        }
        let selected = brandAccentUIKit
        let stacked = appearance.stackedLayoutAppearance
        stacked.normal.titleTextAttributes = [.foregroundColor: normal]
        stacked.normal.iconColor = normal
        stacked.selected.titleTextAttributes = [.foregroundColor: selected]
        stacked.selected.iconColor = selected

        let tabBar = UITabBar.appearance()
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        tabBar.isTranslucent = true
    }
#endif

    private static func dynamicColor(light: (CGFloat, CGFloat, CGFloat), dark: (CGFloat, CGFloat, CGFloat)) -> Color {
        Color(UIColor { trait in
            let c = trait.userInterfaceStyle == .dark ? dark : light
            return UIColor(red: c.0 / 255, green: c.1 / 255, blue: c.2 / 255, alpha: 1)
        })
    }

#if canImport(UIKit)
    private static func dynamicUIColor(light: (CGFloat, CGFloat, CGFloat), dark: (CGFloat, CGFloat, CGFloat)) -> UIColor {
        UIColor { trait in
            let c = trait.userInterfaceStyle == .dark ? dark : light
            return UIColor(red: c.0 / 255, green: c.1 / 255, blue: c.2 / 255, alpha: 1)
        }
    }
#endif
}
