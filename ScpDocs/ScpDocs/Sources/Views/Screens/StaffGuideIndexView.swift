import SwiftUI

/// SCP-JP の新人職員向けガイド・規約ページへのネイティブ索引。
struct StaffGuideIndexView: View {
    @Bindable var navigationRouter: NavigationRouter

    var body: some View {
        List {
            ForEach(StaffGuideIndexCatalog.entries) { entry in
                Button {
                    Haptics.medium()
                    navigationRouter.push(.article(entry.url))
                } label: {
                    FoundationIndexRow(
                        layout: .compact,
                        title: String(localized: String.LocalizationValue(entry.titleLocalizationKey)),
                        subtitle: nil,
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
        .navigationTitle(String(localized: String.LocalizationValue(LocalizationKey.homeSectionGuideTitle)))
        .navigationBarTitleDisplayMode(.inline)
        .tint(AppTheme.textPrimary)
    }
}

private enum StaffGuideIndexCatalog {
    struct Entry: Identifiable {
        let id: String
        let url: URL
        let titleLocalizationKey: String
    }

    static let entries: [Entry] = [
        Entry(
            id: "about-the-scp-foundation",
            url: URL(string: "http://scp-jp.wikidot.com/about-the-scp-foundation")!,
            titleLocalizationKey: LocalizationKey.guideIndexItemAboutFoundation
        ),
        Entry(
            id: "faq-jp",
            url: URL(string: "http://scp-jp.wikidot.com/faq-jp")!,
            titleLocalizationKey: LocalizationKey.guideIndexItemFAQ
        ),
        Entry(
            id: "contact-staff",
            url: URL(string: "http://scp-jp.wikidot.com/contact-staff")!,
            titleLocalizationKey: LocalizationKey.guideIndexItemContact
        ),
        Entry(
            id: "site-rules",
            url: URL(string: "http://scp-jp.wikidot.com/site-rules")!,
            titleLocalizationKey: LocalizationKey.guideIndexItemSiteRules
        ),
        Entry(
            id: "licensing-guide",
            url: URL(string: "http://scp-jp.wikidot.com/licensing-guide")!,
            titleLocalizationKey: LocalizationKey.guideIndexItemLicensing
        ),
        Entry(
            id: "guide-for-newbies",
            url: URL(string: "http://scp-jp.wikidot.com/guide-for-newbies")!,
            titleLocalizationKey: LocalizationKey.guideIndexItemJoinSite
        ),
    ]
}

#Preview {
    @Previewable @State var router = NavigationRouter()
    NavigationStack {
        StaffGuideIndexView(navigationRouter: router)
    }
}
