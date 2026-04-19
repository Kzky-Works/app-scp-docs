import SwiftUI

/// 要注意団体（ネイティブ一覧）と人事ファイルへの入口。
struct GoIPortalView: View {
    let navigationRouter: NavigationRouter
    let branch: Branch

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                Button {
                    Haptics.medium()
                    navigationRouter.push(.libraryList(.goi))
                } label: {
                    portalRow(
                        titleKey: LocalizationKey.goiPortalNativeListTitle,
                        subtitleKey: LocalizationKey.goiPortalNativeListSubtitle,
                        systemImage: "person.3.fill"
                    )
                }
                .buttonStyle(.plain)

                Button {
                    Haptics.medium()
                    navigationRouter.push(.category(branch.personnelDossierHubURL()))
                } label: {
                    portalRow(
                        titleKey: LocalizationKey.goiPortalPersonnelTitle,
                        subtitleKey: LocalizationKey.goiPortalPersonnelSubtitle,
                        systemImage: "person.text.rectangle"
                    )
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(AppTheme.backgroundPrimary)
        .navigationTitle(String(localized: String.LocalizationValue(LocalizationKey.goiPortalTitle)))
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
        .tint(AppTheme.accentPrimary)
    }

    private func portalRow(titleKey: String, subtitleKey: String, systemImage: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: systemImage)
                .font(.title2.weight(.semibold))
                .foregroundStyle(AppTheme.accentPrimary)
                .frame(width: 28, alignment: .center)
            VStack(alignment: .leading, spacing: 6) {
                Text(String(localized: String.LocalizationValue(titleKey)))
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(AppTheme.accentPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(String(localized: String.LocalizationValue(subtitleKey)))
                    .font(.caption.weight(.medium))
                    .foregroundStyle(AppTheme.accentPrimary.opacity(0.78))
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(AppTheme.accentPrimary.opacity(0.45))
        }
        .padding(16)
        .background(AppTheme.backgroundPrimary)
        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .stroke(AppTheme.accentPrimary.opacity(0.5), lineWidth: 1)
        )
    }
}

#Preview {
    @Previewable @State var router = NavigationRouter()
    NavigationStack {
        GoIPortalView(navigationRouter: router, branch: .japan)
    }
}
