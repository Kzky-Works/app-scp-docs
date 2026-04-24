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
                    ForEach(SCPJPTagObjectClassCatalog.orderedFilterWikiTitles, id: \.self) { wiki in
                        objectClassChip(wikiTitle: wiki, tintIndex: SCPJPTagObjectClassCatalog.filterTintIndex(forWikiEqualityTitle: wiki))
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

    private func objectClassChipLabel(wikiTitle: String) -> String {
        if let key = SCPJPTagObjectClassCatalog.chipLocalizationKey(forWikiEqualityTitle: wikiTitle) {
            return String(localized: String.LocalizationValue(key))
        }
        return wikiTitle
    }

    private func objectClassChip(wikiTitle: String, tintIndex: Int) -> some View {
        let tint = Self.objectClassTintPalette[tintIndex % Self.objectClassTintPalette.count]
        let isOn = model.selectedObjectClass?.caseInsensitiveCompare(wikiTitle) == .orderedSame
        return Button {
            Haptics.medium()
            model.toggleObjectClass(wikiTitle)
        } label: {
            Text(objectClassChipLabel(wikiTitle: wikiTitle))
                .font(.caption2.weight(.bold))
                .foregroundStyle(AppTheme.textPrimary)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(isOn ? tint.opacity(0.22) : AppTheme.cardBackground)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(isOn ? tint : AppTheme.borderSubtle, lineWidth: isOn ? 1.25 : AppTheme.borderWidthHairline)
                )
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isOn ? [.isSelected] : [])
    }

    private static let objectClassTintPalette: [Color] = [
        Color(red: 34 / 255, green: 197 / 255, blue: 94 / 255),
        Color(red: 234 / 255, green: 179 / 255, blue: 8 / 255),
        Color(red: 220 / 255, green: 38 / 255, blue: 38 / 255),
        Color(red: 59 / 255, green: 130 / 255, blue: 246 / 255),
        Color(red: 168 / 255, green: 85 / 255, blue: 247 / 255),
        Color(red: 244 / 255, green: 114 / 255, blue: 182 / 255),
        Color(red: 20 / 255, green: 184 / 255, blue: 166 / 255),
        Color(red: 251 / 255, green: 146 / 255, blue: 60 / 255),
        Color(red: 148 / 255, green: 163 / 255, blue: 184 / 255),
        Color(red: 100 / 255, green: 116 / 255, blue: 139 / 255),
        Color(red: 129 / 255, green: 140 / 255, blue: 248 / 255),
        Color(red: 45 / 255, green: 212 / 255, blue: 191 / 255)
    ]
}
