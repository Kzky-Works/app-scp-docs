import SwiftUI

struct SettingsView: View {
    @Bindable var homeViewModel: HomeViewModel
    @Bindable var articleRepository: ArticleRepository

    @State private var dataAction: DataManagementAction?
    @State private var cacheClearDone = false

    private var appVersionLabel: String {
        func trimmedNonEmpty(_ raw: String?) -> String? {
            guard let t = raw?.trimmingCharacters(in: .whitespacesAndNewlines), !t.isEmpty else { return nil }
            return t
        }
        let s = trimmedNonEmpty(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String)
        let b = trimmedNonEmpty(Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String)
        switch (s, b) {
        case let (v?, b?):
            return "\(v) (\(b))"
        case let (v?, nil):
            return v
        case let (nil, b?):
            return b
        case (nil, nil):
            return "—"
        }
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Picker(
                        String(localized: String.LocalizationValue(LocalizationKey.settingsBranchPicker)),
                        selection: Binding(
                            get: { homeViewModel.selectedBranch.id },
                            set: { homeViewModel.selectBranch(id: $0) }
                        )
                    ) {
                        ForEach(homeViewModel.availableBranches) { branch in
                            Text(String(localized: String.LocalizationValue(branch.displayNameKey)))
                                .tag(branch.id)
                        }
                    }
                    .pickerStyle(.navigationLink)
                } header: {
                    Text(String(localized: String.LocalizationValue(LocalizationKey.settingsSectionBranch)))
                }

                Section {
                    Button(role: .destructive) {
                        dataAction = .clearHistory
                    } label: {
                        Label(
                            String(localized: String.LocalizationValue(LocalizationKey.settingsClearHistory)),
                            systemImage: "clock.arrow.circlepath"
                        )
                    }

                    Button(role: .destructive) {
                        dataAction = .clearBookmarks
                    } label: {
                        Label(
                            String(localized: String.LocalizationValue(LocalizationKey.settingsClearBookmarks)),
                            systemImage: "bookmark.slash"
                        )
                    }

                    Button {
                        Task {
                            cacheClearDone = false
                            await WebViewService.clearWebsiteData()
                            cacheClearDone = true
                        }
                    } label: {
                        Label(
                            String(localized: String.LocalizationValue(LocalizationKey.settingsClearWebCache)),
                            systemImage: "trash"
                        )
                    }
                } header: {
                    Text(String(localized: String.LocalizationValue(LocalizationKey.settingsSectionData)))
                } footer: {
                    if cacheClearDone {
                        Text(String(localized: String.LocalizationValue(LocalizationKey.settingsWebCacheCleared)))
                    }
                }

                Section {
                    LabeledContent(
                        String(localized: String.LocalizationValue(LocalizationKey.settingsAppVersion)),
                        value: appVersionLabel
                    )

                    VStack(alignment: .leading, spacing: 8) {
                        Text(String(localized: String.LocalizationValue(LocalizationKey.settingsLicenseCreditTitle)))
                            .font(.subheadline.weight(.semibold))

                        Text(String(localized: String.LocalizationValue(LocalizationKey.settingsLicenseCreditBody)))
                            .font(.footnote)
                            .foregroundStyle(.secondary)

                        Link(
                            String(localized: String.LocalizationValue(LocalizationKey.settingsLicenseLinkTitle)),
                            destination: URL(string: "https://creativecommons.org/licenses/by-sa/3.0/")!
                        )
                        .font(.footnote)
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text(String(localized: String.LocalizationValue(LocalizationKey.settingsSectionAbout)))
                }
            }
            .navigationTitle(String(localized: String.LocalizationValue(LocalizationKey.settingsTitle)))
            .confirmationDialog(
                String(localized: String.LocalizationValue(LocalizationKey.settingsConfirmTitle)),
                isPresented: Binding(
                    get: { dataAction != nil },
                    set: { if !$0 { dataAction = nil } }
                ),
                titleVisibility: .visible
            ) {
                Button(String(localized: String.LocalizationValue(LocalizationKey.settingsConfirmDelete)), role: .destructive) {
                    switch dataAction {
                    case .clearHistory:
                        articleRepository.clearAllHistory()
                    case .clearBookmarks:
                        articleRepository.clearAllBookmarks()
                    case .none:
                        break
                    }
                    dataAction = nil
                }
                Button(String(localized: String.LocalizationValue(LocalizationKey.settingsConfirmCancel)), role: .cancel) {
                    dataAction = nil
                }
            } message: {
                switch dataAction {
                case .clearHistory:
                    Text(String(localized: String.LocalizationValue(LocalizationKey.settingsConfirmHistoryMessage)))
                case .clearBookmarks:
                    Text(String(localized: String.LocalizationValue(LocalizationKey.settingsConfirmBookmarksMessage)))
                case .none:
                    EmptyView()
                }
            }
        }
        .preferredColorScheme(.dark)
        .tint(AppTheme.accentPrimary)
    }

    private enum DataManagementAction {
        case clearHistory
        case clearBookmarks
    }
}

#Preview {
    @Previewable @State var homeViewModel = HomeViewModel(settingsRepository: SettingsRepository())
    @Previewable @State var articleRepository = ArticleRepository()
    SettingsView(homeViewModel: homeViewModel, articleRepository: articleRepository)
}
