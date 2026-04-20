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

/// Phase 12.2: モダン・ブルータリズム配色（ライト確定案／ダーク新案）。
/// 画面側は `Color`、UIKit／WebView は対応する動的 `UIColor` と hex を共有する。
enum AppTheme {
    /// ホーム・カード類の角丸（12〜16pt のレンジ内で統一）。
    static let cornerRadiusCard: CGFloat = 14
    /// 極細ボーダー（0.5pt / 1.0pt のレンジ。フラット面の区切りに 0.5pt）。
    static let borderWidthHairline: CGFloat = 0.5

    /// 要注意・ナビ選択等の差し色（イベントパネル本体には使わない）。
    static let brandAccent = Color(
        red: 220 / 255,
        green: 38 / 255,
        blue: 38 / 255
    )

    // MARK: SwiftUI — システム外観に追従

    /// メイン下地: ライト #F7F6F0／ダーク #121212。
    static let mainBackground = dynamicColor(
        light: (247, 246, 240),
        dark: (18, 18, 18)
    )

    /// 画面全体の背景（`mainBackground` と同一。旧名互換）。
    static var backgroundPrimary: Color { mainBackground }

    /// 標準カード面: ライト #FFFFFF／ダーク #1E1E1E。
    static let cardStandard = dynamicColor(
        light: (255, 255, 255),
        dark: (30, 30, 30)
    )

    /// 索引行のカード面・旧名互換。
    static var surfaceCard: Color { cardStandard }

    /// 索引行のカード面（`cardStandard` と同一）。
    static var cardBackground: Color { cardStandard }

    /// カード境界線: ライト #E2E0D6／ダーク #2C2C2C。
    static let cardBorder = dynamicColor(
        light: (226, 224, 214),
        dark: (44, 44, 44)
    )

    /// 旧名互換（`cardBorder` と同一）。
    static var borderSubtle: Color { cardBorder }

    /// SCP-JP（01）ライト: 背景 #1A1A1A。ダーク: 他パネルと同じ #1E1E1E（斜線は `specialCardChrome`）。
    static let scpJapanPanelFill = dynamicColor(
        light: (26, 26, 26),
        dark: (30, 30, 30)
    )

    /// 旧コード互換（SCP-JP パネル面）。
    static var surfaceInverted: Color { scpJapanPanelFill }

    /// 本文・見出し: ライト #1A1A1A／ダーク #E2E0D6。
    static let textPrimary = dynamicColor(
        light: (26, 26, 26),
        dark: (226, 224, 214)
    )

    /// 補助テキスト: ライト #8C8A82／ダーク #75736C。
    static let textSecondary = dynamicColor(
        light: (140, 138, 130),
        dark: (117, 115, 108)
    )

    /// 旧コード互換: 主にアイコン・ラベルに使っていた「アクセント」＝ `textPrimary` と同系。
    static let accentPrimary = textPrimary

    /// SCP-JP ライト反転面の主文字（#FFFFFF）。
    static let textOnSCPJapanLight = Color.white

    /// 反転タイル上の文字色（ライト: 白／ダーク: 通常主色＝パネルが標準面のため）。
    static let textOnInverted = dynamicColor(
        light: (255, 255, 255),
        dark: (226, 224, 214)
    )

    /// `GADAdSizeBanner` の論理高さ（50pt）。
    static let adBannerContentHeight: CGFloat = 50
    /// 広告帯コンテナの総高さ（バナー＋クリップ余白）。
    static let adBannerStripeHeight: CGFloat = 54

    // MARK: UIKit（WKWebView 等）

#if canImport(UIKit)
    static let backgroundPrimaryUIKit = dynamicUIColor(
        light: (247, 246, 240),
        dark: (18, 18, 18)
    )

    static let accentPrimaryUIKit = dynamicUIColor(
        light: (26, 26, 26),
        dark: (226, 224, 214)
    )

    static let brandAccentUIKit = UIColor(brandAccent)
#endif

    // MARK: Web

    static func webContentPalette(isDark: Bool) -> WebContentPalette {
        if isDark {
            WebContentPalette(
                backgroundHex: "#121212",
                textHex: "#E2E0D6",
                linkHex: "#E2E0D6",
                linkHoverHex: "#FFFFFF",
                containerHex: "#121212"
            )
        } else {
            WebContentPalette(
                backgroundHex: "#F7F6F0",
                textHex: "#1A1A1A",
                linkHex: "#1A1A1A",
                linkHoverHex: "#000000",
                containerHex: "#F7F6F0"
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

// MARK: - Home tab（広告帯とタイルのレイアウト）

private struct HomeAdBottomReserveKey: EnvironmentKey {
    static let defaultValue: CGFloat = 0
}

extension EnvironmentValues {
    /// ホームのタイル列の下に追加する余白（主に旧レイアウト用。既定は `0`）。
    var scpHomeAdBottomReserve: CGFloat {
        get { self[HomeAdBottomReserveKey.self] }
        set { self[HomeAdBottomReserveKey.self] = newValue }
    }
}
