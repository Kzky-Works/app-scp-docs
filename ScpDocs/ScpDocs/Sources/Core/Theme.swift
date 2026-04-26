import SwiftUI
#if canImport(UIKit)
import CoreText
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

    /// 職員ダッシュボード用のシルバー（境界・強調）。#C0C0C0。
    static let terminalSilver = Color(
        red: 192 / 255,
        green: 192 / 255,
        blue: 192 / 255
    )

    /// ホーム「続きから読む」進捗ゲージのフィル（#B85F14）。
    static let readingProgressGaugeFill = Color(
        red: 184 / 255,
        green: 95 / 255,
        blue: 20 / 255
    )

    /// ホーム進捗ゲージのトラック（#E6E6E6／ダークはやや下げる）。
    static let readingProgressGaugeTrack = dynamicColor(
        light: (230, 230, 230),
        dark: (58, 58, 58)
    )

    // MARK: - 記事評価（サークル・アナリティクス／ライト＋ダーク）

    /// プライマリ #F97316（ダークではやや明るめでコントラスト確保）。
    static let ratingAnalyticsPrimary = dynamicColor(
        light: (249, 115, 22),
        dark: (251, 146, 60)
    )

    /// 高評価（L≥4）でやや濃いオレンジ。
    static let ratingAnalyticsPrimaryStrong = dynamicColor(
        light: (234, 88, 12),
        dark: (249, 115, 22)
    )

    /// 低評価寄りで Soft #FDBA74 系。
    static let ratingAnalyticsPrimarySoft = dynamicColor(
        light: (253, 186, 116),
        dark: (180, 90, 40)
    )

    /// トラック／リング背景 #E5E7EB 相当。
    static let ratingAnalyticsTrack = dynamicColor(
        light: (229, 231, 235),
        dark: (55, 58, 64)
    )

    /// 見出し・数値のインク #111827 相当。
    static let ratingAnalyticsInk = dynamicColor(
        light: (17, 24, 39),
        dark: (243, 244, 246)
    )

    /// 評価カード境界（フラット。シャドウは使わない）。
    static let ratingAnalyticsBorder = dynamicColor(
        light: (229, 231, 235),
        dark: (60, 64, 72)
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
    /// 下部のシステム `TabView` タブバー。`configureWithDefaultBackground` ベースで OS 標準に近い高さ・下揃いにし、透過 alone 時の「浮き」を抑える。
    static func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundEffect = UIBlurEffect(style: .systemChromeMaterial)
        let overlay = UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor.black.withAlphaComponent(0.12)
                : UIColor.white.withAlphaComponent(0.5)
        }
        appearance.backgroundColor = overlay

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
        let titleNudge = UIOffset(horizontal: 0, vertical: 2)
        let apply: (UITabBarItemAppearance) -> Void = { item in
            item.normal.titleTextAttributes = [.foregroundColor: normal]
            item.normal.iconColor = normal
            item.selected.titleTextAttributes = [.foregroundColor: selected]
            item.selected.iconColor = selected
            item.normal.titlePositionAdjustment = titleNudge
            item.selected.titlePositionAdjustment = titleNudge
            item.focused.titlePositionAdjustment = titleNudge
            item.disabled.titlePositionAdjustment = titleNudge
        }
        apply(appearance.stackedLayoutAppearance)
        apply(appearance.inlineLayoutAppearance)
        apply(appearance.compactInlineLayoutAppearance)

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

// MARK: - Typography（バンドルするカスタムフォント）

/// ホーム上部「支部名」などで使う表示用タイポグラフィ。
enum AppTypography {
#if canImport(UIKit)
    /// `Font.custom` 用 PostScript 名（`ITC Bauhaus LT Demi.ttf` 内製は通常 `BauhausLT-Demi`）。
    private static let homeBranchTitleFontPostScriptCandidates: [String] = [
        "BauhausLT-Demi",
        "BauhausLTDemi",
        "BauhausLTDemi-Regular"
    ]

    /// バンドル内の Bauhaus LT Demi（`Resources/Fonts/ITC Bauhaus LT Demi.ttf` など）を登録する。
    static func registerBundledBauhausLTDemiIfPresent() {
        let resourceStemCandidates = [
            "ITC Bauhaus LT Demi",
            "BauhausLTDemi"
        ]
        let extensions = ["ttf", "otf"]
        let subdirectoryCandidates: [String?] = ["Fonts", nil]
        for stem in resourceStemCandidates {
            for ext in extensions {
                for subdir in subdirectoryCandidates {
                    let url: URL? = if let subdir {
                        Bundle.main.url(forResource: stem, withExtension: ext, subdirectory: subdir)
                    } else {
                        Bundle.main.url(forResource: stem, withExtension: ext)
                    }
                    guard let url else { continue }
                    if CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil) {
                        return
                    }
                }
            }
        }
    }

    /// Wikidot 系に近い人間味のサンセリフ（**SIL OFL または同等の無償商用可**）をバンドル登録する。
    static func registerBundledHomePillarOpenFonts() {
        let stems = ["Asap-VF", "OpenSans-VF", "SourceSans3-VF"]
        for stem in stems {
            guard let url = Bundle.main.url(forResource: stem, withExtension: "ttf", subdirectory: "Fonts")
                ?? Bundle.main.url(forResource: stem, withExtension: "ttf") else { continue }
            _ = CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }
    }

    /// ホーム「ランダム記事」`dice.fill` の論理ポイント（Dynamic Type 追従）。
    static func randomPanelDiceIconPointSize() -> CGFloat {
        max(26, UIFont.preferredFont(forTextStyle: .title1).pointSize + 4)
    }

    /// `largeTitle` 比で 5pt 小さい支部名の論理ポイント（2pt+3pt 縮小。Dynamic Type 追従の基準）。
    private static var homeBranchTitlePointSize: CGFloat {
        let base = UIFont.preferredFont(forTextStyle: .largeTitle).pointSize
        return max(10, base - 5)
    }

    /// ホーム支部名行の最小高さ（実フォント行ボックスに合わせ、中央可視域の確保のため取りすぎない）。
    static var homeBranchTitleRowReservedHeight: CGFloat {
        let ps = homeBranchTitlePointSize
        for name in homeBranchTitleFontPostScriptCandidates {
            if let f = UIFont(name: name, size: ps) {
                return ceil(f.lineHeight)
            }
        }
        return ceil(UIFont.systemFont(ofSize: ps, weight: .bold).lineHeight)
    }

    /// 左の財団マーク画像高さ。支部名文字ボックスに合わせる。
    static func homeBranchMarkImageHeight() -> CGFloat {
        let ps = homeBranchTitlePointSize
        for name in homeBranchTitleFontPostScriptCandidates {
            if let f = UIFont(name: name, size: ps) {
                return ceil(f.lineHeight * 0.94)
            }
        }
        let f = UIFont.systemFont(ofSize: ps, weight: .bold)
        return ceil(f.lineHeight * 0.94)
    }

    /// ホーム `dashboardHeaderCard` の支部名。`largeTitle` 比で 5pt 小さく、未バンドル時はシステム太字。
    static func homeBranchTitleFont() -> Font {
        let size = homeBranchTitlePointSize
        for name in homeBranchTitleFontPostScriptCandidates {
            if UIFont(name: name, size: size) != nil {
                return Font.custom(name, size: size, relativeTo: .largeTitle)
            }
        }
        return Font.system(size: size, weight: .bold)
    }

    /// ホーム各パネル主タイトル。公式サイトの `Trebuchet MS → …` に**雰囲気を寄せた**バンドル無償フォントを、**先頭から最初に登録済みの1ファミリ**だけ使う（CSS の font-family と同じ考え方）。
    /// 優先順: Asap（Trebuchet 系に近い）→ Open Sans → Source Sans 3。いずれも Google Fonts 由来・商用利用可（`Resources/Fonts` の OFL 文書参照）。
    static func homePillarTitleFont() -> Font {
        let baseSize = UIFont.preferredFont(forTextStyle: .title2).pointSize + 5
        let metrics = UIFontMetrics(forTextStyle: .title2)
        let bundledFamiliesInOrder = ["Asap", "Open Sans", "Source Sans 3"]
        for family in bundledFamiliesInOrder {
            let faces = UIFont.fontNames(forFamilyName: family).sorted()
            guard !faces.isEmpty else { continue }
            let postScript = faces.first(where: { name in
                let n = name.lowercased()
                return n.contains("semibold") || n.contains("600") || n.contains("bold") || n.contains("700")
            }) ?? faces[0]
            guard let ui = UIFont(name: postScript, size: baseSize) else { continue }
            return Font(metrics.scaledFont(for: ui))
        }
        let fallbackSize = UIFont.preferredFont(forTextStyle: .title2).pointSize + 5
        return Font.system(size: fallbackSize, weight: .semibold)
    }

    /// 記事一覧（ネイティブリスト）: 同じ `TextStyle` の**現在**のポイントを 1 下げる（Content Size の範囲で追従。長いナビタイトル対策）。
    static func feedListOnePointDown(_ textStyle: UIFont.TextStyle, weight: Font.Weight) -> Font {
        let base = UIFont.preferredFont(forTextStyle: textStyle)
        let size = max(6, base.pointSize - 1)
        return Font.system(size: size, weight: weight, design: .default)
    }
#else
    static var homeBranchTitleRowReservedHeight: CGFloat { 34 }

    static func homeBranchTitleFont() -> Font {
        .largeTitle.weight(.bold)
    }

    static func homePillarTitleFont() -> Font {
        .title.weight(.semibold)
    }

    static func randomPanelDiceIconPointSize() -> CGFloat { 32 }
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
