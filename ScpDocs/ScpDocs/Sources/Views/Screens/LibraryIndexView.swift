import SwiftUI

/// SCP ライブラリのネイティブインデックス（物語 / カノン / 連作）。
struct LibraryIndexView: View {
    @Bindable var navigationRouter: NavigationRouter
    let branch: Branch

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(LibraryCategory.scpLibraryPortalCategories) { category in
                    Button {
                        Haptics.medium()
                        navigationRouter.push(.libraryList(category))
                    } label: {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(String(localized: String.LocalizationValue(category.titleLocalizationKey)))
                                .font(.headline.weight(.semibold))
                                .foregroundStyle(AppTheme.accentPrimary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text(String(localized: String.LocalizationValue(category.subtitleLocalizationKey)))
                                .font(.caption.weight(.medium))
                                .foregroundStyle(AppTheme.accentPrimary.opacity(0.78))
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(16)
                        .background(AppTheme.backgroundPrimary)
                        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .stroke(AppTheme.accentPrimary.opacity(0.5), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(AppTheme.backgroundPrimary)
        .navigationTitle(String(localized: String.LocalizationValue(LocalizationKey.libraryIndexTitle)))
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
        .tint(AppTheme.accentPrimary)
    }
}

#Preview {
    @Previewable @State var router = NavigationRouter()
    NavigationStack {
        LibraryIndexView(
            navigationRouter: router,
            branch: .japan
        )
    }
}
