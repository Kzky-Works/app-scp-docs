import SwiftUI

/// `goi-formats-jp` に相当する要注意団体（GoI）フォーマット索引（日本支部）。
struct GoIFormatsIndexView: View {
    @Bindable var navigationRouter: NavigationRouter

    var body: some View {
        List {
            Section {
                ForEach(GoIFormatsIndexData.portals) { link in
                    goiLinkButton(link)
                }
            } header: {
                Text(String(localized: String.LocalizationValue(LocalizationKey.goiIndexSectionPortals)))
                    .foregroundStyle(AppTheme.textSecondary)
            }
            .listRowBackground(AppTheme.mainBackground)

            Section {
                ForEach(GoIFormatsIndexData.englishFormatHubs) { link in
                    goiLinkButton(link)
                }
            } header: {
                Text(String(localized: String.LocalizationValue(LocalizationKey.goiIndexSectionEN)))
                    .foregroundStyle(AppTheme.textSecondary)
            }
            .listRowBackground(AppTheme.mainBackground)

            Section {
                ForEach(GoIFormatsIndexData.japanFormatHubs) { link in
                    goiLinkButton(link)
                }
            } header: {
                Text(String(localized: String.LocalizationValue(LocalizationKey.goiIndexSectionJP)))
                    .foregroundStyle(AppTheme.textSecondary)
            }
            .listRowBackground(AppTheme.mainBackground)
        }
        .scrollContentBackground(.hidden)
        .background(AppTheme.mainBackground)
        .navigationTitle(String(localized: String.LocalizationValue(LocalizationKey.goiIndexTitle)))
        .navigationBarTitleDisplayMode(.inline)
        .tint(AppTheme.textPrimary)
    }

    private func goiLinkButton(_ link: GoIFormatsIndexData.IndexLink) -> some View {
        Button {
            Haptics.medium()
            navigationRouter.pushArticle(url: link.url)
        } label: {
            FoundationIndexRow(
                title: String(localized: String.LocalizationValue(link.titleLocalizationKey)),
                subtitle: link.url.absoluteString,
                trailing: {
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(AppTheme.textSecondary)
                }
            )
        }
        .buttonStyle(.plain)
        .indexListRowChrome()
    }
}

#Preview {
    @Previewable @State var router = NavigationRouter()
    NavigationStack {
        GoIFormatsIndexView(navigationRouter: router)
    }
}
