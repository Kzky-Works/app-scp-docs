import SwiftUI

/// `TagFilterView` の載せ方（`List` ヘッダーでは背景をリストに馴染ませる）。
enum TagFilterListChrome: Sendable {
    /// `List` と並べて配置（やや不透明な帯）。
    case standalone
    /// `List` の `Section` ヘッダー内。
    case listSectionHeader
}

/// Phase 14: オブジェクトクラス・クイックフィルターとタグチップバー。
struct TagFilterView: View {
    @Bindable var model: ArchiveArticleViewModel
    let segmentEntries: [JapanSCPArchiveEntry]
    var listChrome: TagFilterListChrome = .standalone

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(String(localized: String.LocalizationValue(LocalizationKey.archiveFilterTagsSection)))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppTheme.textSecondary)
                Spacer(minLength: 8)
                if model.hasActiveFilters {
                    Button {
                        Haptics.light()
                        model.clearFilters()
                    } label: {
                        Text(String(localized: String.LocalizationValue(LocalizationKey.archiveFilterClear)))
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(AppTheme.brandAccent)
                    }
                    .buttonStyle(.plain)
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(ArchiveObjectClassFilter.allCases, id: \.self) { oc in
                        objectClassCard(oc)
                    }
                }
            }
            .accessibilityElement(children: .contain)
            .accessibilityLabel(String(localized: String.LocalizationValue(LocalizationKey.archiveFilterObjectClassAccessibility)))

            Button {
                Haptics.medium()
                model.toggleHighRatingFilter()
            } label: {
                Text(String(localized: String.LocalizationValue(LocalizationKey.archiveFilterHighRatingChip)))
                    .font(.caption2.weight(.bold))
                    .monospacedDigit()
                    .foregroundStyle(AppTheme.textPrimary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(model.filterHighRatingOnly ? AppTheme.brandAccent.opacity(0.22) : AppTheme.cardBackground)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(
                                model.filterHighRatingOnly ? AppTheme.brandAccent : AppTheme.borderSubtle,
                                lineWidth: model.filterHighRatingOnly ? 1.25 : AppTheme.borderWidthHairline
                            )
                    )
            }
            .buttonStyle(.plain)
            .accessibilityLabel(String(localized: String.LocalizationValue(LocalizationKey.archiveFilterHighRatingAccessibility)))
            .accessibilityAddTraits(model.filterHighRatingOnly ? [.isSelected] : [])

            TextField(
                String(localized: String.LocalizationValue(LocalizationKey.archiveFilterTagSearchPlaceholder)),
                text: $model.tagSearchQuery
            )
            .textFieldStyle(.plain)
            .font(.caption)
            .foregroundStyle(AppTheme.textPrimary)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(AppTheme.cardBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(AppTheme.borderSubtle, lineWidth: AppTheme.borderWidthHairline)
            )

            let chips = model.visibleTagChips(for: segmentEntries)
            if chips.isEmpty {
                Text(String(localized: String.LocalizationValue(LocalizationKey.archiveFilterNoTagsInSegment)))
                    .font(.caption2)
                    .foregroundStyle(AppTheme.textSecondary)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(chips, id: \.self) { tag in
                            Button {
                                Haptics.light()
                                model.toggleTag(tag)
                            } label: {
                                TagChipView(label: tag, isSelected: model.selectedTags.contains(tag))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, listChrome == .listSectionHeader ? 6 : 10)
        .padding(.bottom, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(headerBackground)
    }

    private var headerBackground: Color {
        switch listChrome {
        case .standalone:
            AppTheme.mainBackground.opacity(0.98)
        case .listSectionHeader:
            AppTheme.mainBackground
        }
    }

    private func objectClassCard(_ oc: ArchiveObjectClassFilter) -> some View {
        let isOn = model.selectedObjectClass?.caseInsensitiveCompare(oc.wikiName) == .orderedSame
        return Button {
            Haptics.medium()
            model.toggleObjectClass(oc.wikiName)
        } label: {
            Text(oc.wikiName)
                .font(.caption2.weight(.bold))
                .foregroundStyle(AppTheme.textPrimary)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(isOn ? oc.tint.opacity(0.22) : AppTheme.cardBackground)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(isOn ? oc.tint : AppTheme.borderSubtle, lineWidth: isOn ? 1.25 : AppTheme.borderWidthHairline)
                )
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isOn ? [.isSelected] : [])
    }
}

private enum ArchiveObjectClassFilter: CaseIterable {
    case safe
    case euclid
    case keter
    case thaumiel

    var wikiName: String {
        switch self {
        case .safe: "Safe"
        case .euclid: "Euclid"
        case .keter: "Keter"
        case .thaumiel: "Thaumiel"
        }
    }

    var tint: Color {
        switch self {
        case .safe:
            Color(red: 34 / 255, green: 197 / 255, blue: 94 / 255)
        case .euclid:
            Color(red: 234 / 255, green: 179 / 255, blue: 8 / 255)
        case .keter:
            Color(red: 220 / 255, green: 38 / 255, blue: 38 / 255)
        case .thaumiel:
            Color(red: 59 / 255, green: 130 / 255, blue: 246 / 255)
        }
    }
}
