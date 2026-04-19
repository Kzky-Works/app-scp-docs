import SwiftUI

/// Phase 14: モダン・ブルータリズム風のタグチップ。
struct TagChipView: View {
    let label: String
    let isSelected: Bool

    var body: some View {
        Text(label)
            .font(.caption2.weight(.semibold))
            .foregroundStyle(AppTheme.textPrimary)
            .lineLimit(1)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(isSelected ? AppTheme.brandAccent.opacity(0.18) : AppTheme.cardBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .stroke(
                        isSelected ? AppTheme.brandAccent : AppTheme.borderSubtle,
                        lineWidth: isSelected ? 1.25 : AppTheme.borderWidthHairline
                    )
            )
    }
}
