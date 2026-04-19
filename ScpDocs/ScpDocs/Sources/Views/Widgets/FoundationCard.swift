import SwiftUI

/// ダッシュボード共通の「フローティング」カード（極細ボーダー・控えめな影）。
enum FoundationCardStyle: Sendable {
    /// ライト: 白 / ダーク: #161616
    case standard
    /// JP アーカイヴ: チャコール地＋明るい文字。
    case inverted
    /// イベント等: レッド背景。
    case danger
    /// 報告書インデックス等の高密度グリッド: 面・線は standard と同じ、影のみ抑える。
    case indexGrid

    fileprivate var cardFill: Color {
        switch self {
        case .standard, .indexGrid: AppTheme.surfaceCard
        case .inverted: AppTheme.surfaceInverted
        case .danger: AppTheme.brandAccent
        }
    }

    fileprivate var cardStroke: Color {
        switch self {
        case .standard, .inverted, .indexGrid: AppTheme.borderSubtle
        case .danger: AppTheme.brandAccent.opacity(0.35)
        }
    }

    fileprivate var cardShadowColor: Color {
        switch self {
        case .indexGrid: .clear
        case .danger: AppTheme.shadowCard.opacity(0.12)
        case .standard, .inverted: AppTheme.shadowCard
        }
    }

    fileprivate var cardShadowRadius: CGFloat {
        self == .indexGrid ? 0 : 6
    }

    fileprivate var cardShadowY: CGFloat {
        self == .indexGrid ? 0 : 3
    }

    /// `FoundationCardModifier` と同一のカード面（`List` の `listRowBackground` 用）。
    fileprivate var indexListRowShadowRadius: CGFloat {
        switch self {
        case .indexGrid: 0
        case .danger: 4
        case .standard, .inverted: 6
        }
    }

    fileprivate var indexListRowShadowY: CGFloat {
        switch self {
        case .indexGrid: 0
        case .danger: 2
        case .standard, .inverted: 3
        }
    }
}

/// 索引 `List` 行の背後に載せる「フローティング・カード」面（`listRowBackground` 専用）。
struct IndexListFloatingCardBackground: View {
    var style: FoundationCardStyle = .standard

    var body: some View {
        RoundedRectangle(cornerRadius: AppTheme.cornerRadiusCard, style: .continuous)
            .fill(style.cardFill)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusCard, style: .continuous)
                    .stroke(style.cardStroke, lineWidth: AppTheme.borderWidthHairline)
            )
            .shadow(color: style.cardShadowColor, radius: style.indexListRowShadowRadius, y: style.indexListRowShadowY)
            .padding(.vertical, 4)
            .padding(.horizontal, 16)
    }
}

struct FoundationCardModifier: ViewModifier {
    let style: FoundationCardStyle

    func body(content: Content) -> some View {
        content
            .background(style.cardFill)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusCard, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusCard, style: .continuous)
                    .stroke(style.cardStroke, lineWidth: AppTheme.borderWidthHairline)
            )
            .shadow(color: style.cardShadowColor, radius: style.cardShadowRadius, y: style.cardShadowY)
    }

    private var cardShadowRadius: CGFloat { style.cardShadowRadius }
    private var cardShadowY: CGFloat { style.cardShadowY }
}

extension View {
    func foundationCard(style: FoundationCardStyle = .standard) -> some View {
        modifier(FoundationCardModifier(style: style))
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
