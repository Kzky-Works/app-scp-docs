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
                    .foregroundStyle(AppTheme.accentPrimary.opacity(0.85))
            }
            .listRowBackground(AppTheme.backgroundPrimary)

            Section {
                ForEach(GoIFormatsIndexData.englishFormatHubs) { link in
                    goiLinkButton(link)
                }
            } header: {
                Text(String(localized: String.LocalizationValue(LocalizationKey.goiIndexSectionEN)))
                    .foregroundStyle(AppTheme.accentPrimary.opacity(0.85))
            }
            .listRowBackground(AppTheme.backgroundPrimary)

            Section {
                ForEach(GoIFormatsIndexData.japanFormatHubs) { link in
                    goiLinkButton(link)
                }
            } header: {
                Text(String(localized: String.LocalizationValue(LocalizationKey.goiIndexSectionJP)))
                    .foregroundStyle(AppTheme.accentPrimary.opacity(0.85))
            }
            .listRowBackground(AppTheme.backgroundPrimary)
        }
        .scrollContentBackground(.hidden)
        .background(AppTheme.backgroundPrimary)
        .navigationTitle(String(localized: String.LocalizationValue(LocalizationKey.goiIndexTitle)))
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
        .tint(AppTheme.accentPrimary)
    }

    private func goiLinkButton(_ link: GoIFormatsIndexData.IndexLink) -> some View {
        Button {
            Haptics.medium()
            navigationRouter.pushArticle(url: link.url)
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(String(localized: String.LocalizationValue(link.titleLocalizationKey)))
                        .font(.body.weight(.medium))
                        .foregroundStyle(AppTheme.accentPrimary)
                        .multilineTextAlignment(.leading)
                    Text(link.url.absoluteString)
                        .font(.caption2)
                        .foregroundStyle(AppTheme.accentPrimary.opacity(0.65))
                        .lineLimit(2)
                }
                Spacer(minLength: 0)
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppTheme.accentPrimary.opacity(0.45))
            }
        }
    }
}

#Preview {
    @Previewable @State var router = NavigationRouter()
    NavigationStack {
        GoIFormatsIndexView(navigationRouter: router)
    }
}
