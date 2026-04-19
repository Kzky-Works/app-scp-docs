import SwiftUI

struct SettingsView: View {
    @Bindable var homeViewModel: HomeViewModel
    @Bindable var articleRepository: ArticleRepository
    @Bindable var purchaseRepository: PurchaseRepository

    @State private var dataAction: DataManagementAction?
    @State private var cacheClearDone = false
    @State private var networkProbeResult: String?
    @State private var networkProbeRunning = false

    @AppStorage(WebViewDiagnostics.minimalConfigurationDefaultsKey) private var webViewMinimalConfiguration = false

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
                    Picker(
                        String(localized: String.LocalizationValue(LocalizationKey.settingsUILanguagePicker)),
                        selection: Binding(
                            get: { homeViewModel.uiLanguage },
                            set: { homeViewModel.updateUILanguage($0) }
                        )
                    ) {
                        Text(String(localized: String.LocalizationValue(LocalizationKey.settingsUILanguageSystem)))
                            .tag(AppUILanguage.system)
                        Text(String(localized: String.LocalizationValue(LocalizationKey.settingsUILanguageJapanese)))
                            .tag(AppUILanguage.japanese)
                        Text(String(localized: String.LocalizationValue(LocalizationKey.settingsUILanguageEnglish)))
                            .tag(AppUILanguage.english)
                    }
                    .pickerStyle(.navigationLink)

                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(String(localized: String.LocalizationValue(LocalizationKey.settingsReaderFontSize)))
                            Spacer()
                            Text("\(Int((homeViewModel.fontSizeMultiplier * 100).rounded()))%")
                                .font(.body.monospacedDigit())
                                .foregroundStyle(.secondary)
                        }
                        Slider(
                            value: Binding(
                                get: { homeViewModel.fontSizeMultiplier },
                                set: { homeViewModel.updateFontSizeMultiplier($0) }
                            ),
                            in: 0.75 ... 2.0,
                            step: 0.05
                        )
                        .tint(AppTheme.accentPrimary)
                    }
                } header: {
                    Text(String(localized: String.LocalizationValue(LocalizationKey.settingsSectionLocaleReader)))
                } footer: {
                    Text(String(localized: String.LocalizationValue(LocalizationKey.settingsReaderFontSizeFooter)))
                }

                Section {
                    if purchaseRepository.isAdRemovalActive {
                        Label(
                            String(localized: String.LocalizationValue(LocalizationKey.settingsPurchaseAdFreeActive)),
                            systemImage: "checkmark.seal.fill"
                        )
                        .foregroundStyle(AppTheme.accentPrimary)
                    } else {
                        Button {
                            Task { await purchaseRepository.purchaseAdRemoval() }
                        } label: {
                            HStack {
                                Text(String(localized: String.LocalizationValue(LocalizationKey.settingsPurchaseRemoveAds)))
                                Spacer(minLength: 8)
                                if purchaseRepository.isPurchaseInProgress {
                                    ProgressView()
                                }
                            }
                        }
                        .disabled(purchaseRepository.isPurchaseInProgress)

                        Button {
                            Task { await purchaseRepository.restorePurchases() }
                        } label: {
                            HStack {
                                Text(String(localized: String.LocalizationValue(LocalizationKey.settingsPurchaseRestore)))
                                Spacer(minLength: 8)
                                if purchaseRepository.isPurchaseInProgress {
                                    ProgressView()
                                }
                            }
                        }
                        .disabled(purchaseRepository.isPurchaseInProgress)
                    }

                    if let err = purchaseRepository.lastErrorDescription {
                        Text(err)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .textSelection(.enabled)
                    }
                } header: {
                    Text(String(localized: String.LocalizationValue(LocalizationKey.settingsSectionMonetization)))
                }

                Section {
                    Toggle(
                        String(localized: String.LocalizationValue(LocalizationKey.settingsWebViewMinimalToggle)),
                        isOn: $webViewMinimalConfiguration
                    )
                    Button {
                        Task {
                            networkProbeRunning = true
                            networkProbeResult = nil
                            let line = await WebViewDiagnostics.NetworkProbe.fetchStatusLine(
                                for: WebViewDiagnostics.NetworkProbe.defaultProbeURL
                            )
                            networkProbeResult = line
                            networkProbeRunning = false
                        }
                    } label: {
                        HStack {
                            Text(String(localized: String.LocalizationValue(LocalizationKey.settingsWebViewProbe)))
                            if networkProbeRunning {
                                Spacer(minLength: 8)
                                ProgressView()
                            }
                        }
                    }
                    .disabled(networkProbeRunning)
                } header: {
                    Text(String(localized: String.LocalizationValue(LocalizationKey.settingsSectionWebViewDebug)))
                } footer: {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(String(localized: String.LocalizationValue(LocalizationKey.settingsWebViewMinimalFooter)))
                        Text(String(localized: String.LocalizationValue(LocalizationKey.settingsWebViewProbeFooter)))
                        if let networkProbeResult {
                            Text(networkProbeResult)
                                .font(.caption.monospaced())
                                .foregroundStyle(.secondary)
                                .textSelection(.enabled)
                        }
                    }
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
    @Previewable @State var purchaseRepository = PurchaseRepository()
    SettingsView(homeViewModel: homeViewModel, articleRepository: articleRepository, purchaseRepository: purchaseRepository)
}
