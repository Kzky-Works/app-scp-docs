import SwiftUI

/// SCP ライブラリのネイティブインデックス（物語 / カノン / 連作）。
struct LibraryIndexView: View {
    @Bindable var navigationRouter: NavigationRouter
    let branch: Branch

    var body: some View {
        List {
            ForEach(LibraryCategory.scpLibraryPortalCategories) { category in
                Button {
                    Haptics.medium()
                    if branch.id == BranchIdentifier.scpJapan, category == .tales {
                        navigationRouter.push(.foundationTalesJPAuthorIndex)
                    } else {
                        navigationRouter.push(.libraryList(category))
                    }
                } label: {
                    FoundationIndexRow(
                        title: String(localized: String.LocalizationValue(category.titleLocalizationKey)),
                        subtitle: String(localized: String.LocalizationValue(category.subtitleLocalizationKey)),
                        trailing: {
                            Image(systemName: "chevron.right")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(AppTheme.textSecondary)
                        }
                    )
                }
                .buttonStyle(DashboardPressButtonStyle())
                .indexListRowChrome()
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(AppTheme.mainBackground)
        .navigationTitle(String(localized: String.LocalizationValue(LocalizationKey.libraryIndexTitle)))
        .navigationBarTitleDisplayMode(.inline)
        .tint(AppTheme.textPrimary)
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
