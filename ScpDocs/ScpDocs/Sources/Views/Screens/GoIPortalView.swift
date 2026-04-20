import SwiftUI

/// 要注意団体（ネイティブ一覧）と人事ファイルへの入口。
struct GoIPortalView: View {
    let navigationRouter: NavigationRouter
    let branch: Branch

    var body: some View {
        List {
            Button {
                Haptics.medium()
                navigationRouter.push(.libraryList(.goi))
            } label: {
                FoundationIndexRow(
                    title: String(localized: String.LocalizationValue(LocalizationKey.goiPortalNativeListTitle)),
                    subtitle: String(localized: String.LocalizationValue(LocalizationKey.goiPortalNativeListSubtitle)),
                    leadingSystemImage: "person.3.fill",
                    trailing: {
                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                )
            }
            .buttonStyle(DashboardPressButtonStyle())
            .indexListRowChrome()

            Button {
                Haptics.medium()
                navigationRouter.push(.category(branch.personnelDossierHubURL()))
            } label: {
                FoundationIndexRow(
                    title: String(localized: String.LocalizationValue(LocalizationKey.goiPortalPersonnelTitle)),
                    subtitle: String(localized: String.LocalizationValue(LocalizationKey.goiPortalPersonnelSubtitle)),
                    leadingSystemImage: "person.text.rectangle",
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
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(AppTheme.mainBackground)
        .navigationTitle(String(localized: String.LocalizationValue(LocalizationKey.goiPortalTitle)))
        .navigationBarTitleDisplayMode(.inline)
        .tint(AppTheme.textPrimary)
    }
}

#Preview {
    @Previewable @State var router = NavigationRouter()
    NavigationStack {
        GoIPortalView(navigationRouter: router, branch: .japan)
    }
}
