import SwiftUI

// MARK: - カード内テキスト（背景に応じた主／従の自動切替）

private struct FoundationCardTextPrimaryKey: EnvironmentKey {
    static let defaultValue: Color = AppTheme.textPrimary
}

private struct FoundationCardTextSecondaryKey: EnvironmentKey {
    static let defaultValue: Color = AppTheme.textSecondary
}

extension EnvironmentValues {
    /// `foundationCard` が付いたコンテンツ内の主テキスト色（SCP-JP ライト反転時は白へ）。
    var foundationCardTextPrimary: Color {
        get { self[FoundationCardTextPrimaryKey.self] }
        set { self[FoundationCardTextPrimaryKey.self] = newValue }
    }

    /// `foundationCard` が付いたコンテンツ内の補助テキスト色。
    var foundationCardTextSecondary: Color {
        get { self[FoundationCardTextSecondaryKey.self] }
        set { self[FoundationCardTextSecondaryKey.self] = newValue }
    }
}

/// ダッシュボード共通カード（極細ボーダー・角丸・シャドウなしのフラット面）。
enum FoundationCardStyle: Sendable {
    /// 標準カード（`cardStandard` + `cardBorder`）。
    case standard
    /// SCP-JP（01）: ライトは #1A1A1A 地＋白字。ダークは #1E1E1E 地＋通常字（斜線は `specialCardChrome`）。
    case inverted
    /// イベント等向け。見た目は標準パネルと同一（赤背景は使わない）。
    case danger
    /// 報告書インデックス等: 面・線は standard と同じ。
    case indexGrid

    fileprivate func cardFill(colorScheme: ColorScheme) -> Color {
        switch self {
        case .standard, .indexGrid, .danger:
            AppTheme.cardStandard
        case .inverted:
            AppTheme.scpJapanPanelFill
        }
    }

    fileprivate func cardStroke(colorScheme: ColorScheme) -> Color {
        switch self {
        case .standard, .indexGrid, .danger:
            AppTheme.cardBorder
        case .inverted:
            colorScheme == .dark ? AppTheme.cardBorder : Color.white.opacity(0.18)
        }
    }

    fileprivate func resolvedTextPrimary(colorScheme: ColorScheme) -> Color {
        switch self {
        case .standard, .indexGrid, .danger:
            AppTheme.textPrimary
        case .inverted:
            colorScheme == .dark ? AppTheme.textPrimary : AppTheme.textOnSCPJapanLight
        }
    }

    fileprivate func resolvedTextSecondary(colorScheme: ColorScheme) -> Color {
        switch self {
        case .standard, .indexGrid, .danger:
            AppTheme.textSecondary
        case .inverted:
            colorScheme == .dark ? AppTheme.textSecondary : AppTheme.textOnSCPJapanLight.opacity(0.78)
        }
    }
}

/// 索引 `List` 行の背後に載せるフラット・カード面（`listRowBackground` 専用）。
struct IndexListFloatingCardBackground: View {
    var style: FoundationCardStyle = .standard

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        RoundedRectangle(cornerRadius: AppTheme.cornerRadiusCard, style: .continuous)
            .fill(style.cardFill(colorScheme: colorScheme))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusCard, style: .continuous)
                    .stroke(style.cardStroke(colorScheme: colorScheme), lineWidth: AppTheme.borderWidthHairline)
            )
            .padding(.vertical, 4)
            .padding(.horizontal, 16)
    }
}

struct FoundationCardModifier: ViewModifier {
    let style: FoundationCardStyle

    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content
            .environment(\.foundationCardTextPrimary, style.resolvedTextPrimary(colorScheme: colorScheme))
            .environment(\.foundationCardTextSecondary, style.resolvedTextSecondary(colorScheme: colorScheme))
            .background(style.cardFill(colorScheme: colorScheme))
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusCard, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusCard, style: .continuous)
                    .stroke(style.cardStroke(colorScheme: colorScheme), lineWidth: AppTheme.borderWidthHairline)
            )
    }
}

// MARK: - SCP-JP ダーク: 斜線テクスチャ（機密面の強調）

private struct ConfidentialDiagonalStripes: View {
    var body: some View {
        Canvas { context, size in
            let step: CGFloat = 6
            var x: CGFloat = -size.height
            while x < size.width + size.height {
                var path = Path()
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x + size.height * 1.05, y: size.height))
                context.stroke(path, with: .color(Color.white.opacity(0.065)), lineWidth: 0.75)
                x += step
            }
        }
        .allowsHitTesting(false)
    }
}

private struct SpecialCardChromeModifier: ViewModifier {
    let isActive: Bool

    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content.overlay {
            if isActive, colorScheme == .dark {
                ConfidentialDiagonalStripes()
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusCard, style: .continuous))
            }
        }
    }
}

extension View {
    func foundationCard(style: FoundationCardStyle = .standard) -> some View {
        modifier(FoundationCardModifier(style: style))
    }

    /// SCP-JP（01）向け。ダークモード時のみ 45° 相当の細斜線をカード上に重ねる（`foundationCard` 後に適用）。
    func specialCardChrome(isActive: Bool = true) -> some View {
        modifier(SpecialCardChromeModifier(isActive: isActive))
    }
}

/// タイル押下時のわずかなスケール＋既定で触覚（呼び出し側で `Haptics.medium()` と併用）。
struct DashboardPressButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeOut(duration: 0.14), value: configuration.isPressed)
    }
}
