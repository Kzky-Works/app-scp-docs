import SwiftUI

/// 財団 Tales-JP（`foundation-tales-jp`）の著者別アコーディオン一覧と A–Z / 0–9 / その他 ピッカー。
struct FoundationTalesJPIndexView: View {
    @Bindable var navigationRouter: NavigationRouter
    let articleRepository: ArticleRepository
    let homeViewModel: HomeViewModel

    @State private var model = FoundationTalesJPIndexViewModel()
    /// 開いている著者セクション（複数開くことを許容）。
    @State private var expandedAuthorIDs: Set<String> = []

    private let siteRoot = FoundationTalesJPWikiSite.root

    private var displayedAuthors: [FoundationTalesJPAuthor] {
        model.authors(for: model.selectedSegment, locale: homeViewModel.resolvedLocale)
    }

    var body: some View {
        IndexScreenLayout {
            Group {
                switch model.phase {
                case .idle, .loading:
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                case .failed:
                    VStack(spacing: 16) {
                        ContentUnavailableView(
                            String(localized: String.LocalizationValue(LocalizationKey.talesJpLoadFailed)),
                            systemImage: "wifi.exclamationmark",
                            description: Text(String(localized: String.LocalizationValue(LocalizationKey.talesJpLoadFailedHint)))
                        )
                        Button(String(localized: String.LocalizationValue(LocalizationKey.talesJpRetry))) {
                            Haptics.medium()
                            Task { await model.load(forceRefresh: true) }
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(AppTheme.brandAccent)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
                case .ready:
                    if model.allAuthors.isEmpty {
                        ContentUnavailableView(
                            String(localized: String.LocalizationValue(LocalizationKey.talesJpEmpty)),
                            systemImage: "book.closed",
                            description: Text(String(localized: String.LocalizationValue(LocalizationKey.talesJpEmptyHint)))
                        )
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        List {
                            if displayedAuthors.isEmpty {
                                ContentUnavailableView(
                                    String(localized: String.LocalizationValue(LocalizationKey.talesJpEmptySegment)),
                                    systemImage: "character.book.closed",
                                    description: Text(verbatim: "")
                                )
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 24)
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                            }
                            ForEach(displayedAuthors) { author in
                                DisclosureGroup(
                                    isExpanded: Binding(
                                        get: { expandedAuthorIDs.contains(author.id) },
                                        set: { newValue in
                                            if newValue {
                                                expandedAuthorIDs.insert(author.id)
                                            } else {
                                                expandedAuthorIDs.remove(author.id)
                                            }
                                        }
                                    )
                                ) {
                                    if author.tales.isEmpty {
                                        Text(String(localized: String.LocalizationValue(LocalizationKey.talesJpNoTalesUnderAuthor)))
                                            .font(.footnote.weight(.medium))
                                            .foregroundStyle(AppTheme.textSecondary)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.vertical, 6)
                                            .listRowBackground(Color.clear)
                                    } else {
                                        ForEach(author.tales) { tale in
                                            taleLinkRow(author: author, tale: tale)
                                        }
                                    }
                                } label: {
                                    HStack(alignment: .center, spacing: 10) {
                                        Image(systemName: "person.fill")
                                            .font(.body.weight(.semibold))
                                            .foregroundStyle(AppTheme.brandAccent)
                                            .frame(width: 22, alignment: .center)
                                        Text(author.displayName)
                                            .font(.body.weight(.semibold))
                                            .foregroundStyle(AppTheme.textPrimary)
                                            .multilineTextAlignment(.leading)
                                        Spacer(minLength: 0)
                                        if author.tales.isEmpty == false {
                                            Text(
                                                String(
                                                    format: String(localized: String.LocalizationValue(LocalizationKey.talesJpTaleCountFormat)),
                                                    locale: .current,
                                                    author.tales.count
                                                )
                                            )
                                                .font(.caption.weight(.semibold))
                                                .foregroundStyle(AppTheme.textSecondary)
                                                .monospacedDigit()
                                        }
                                    }
                                    .padding(.vertical, 2)
                                }
                                .indexListRowChrome()
                            }
                        }
                        .scrollContentBackground(.hidden)
                    }
                }
            }
        } bottomAccessory: {
            alphabetPicker
        }
        .navigationTitle(String(localized: String.LocalizationValue(LocalizationKey.talesJpAuthorIndexTitle)))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Button {
                    Haptics.medium()
                    navigationRouter.push(.category(model.wikiHubURL()))
                } label: {
                    Image(systemName: "safari")
                }
                .accessibilityLabel(String(localized: String.LocalizationValue(LocalizationKey.talesJpOpenWikiHubAccessibility)))
                Button {
                    Haptics.light()
                    Task { await model.load(forceRefresh: true) }
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .accessibilityLabel(String(localized: String.LocalizationValue(LocalizationKey.talesJpRefreshAccessibility)))
                .disabled(model.phase == .loading)
            }
        }
        .tint(AppTheme.textPrimary)
        .task {
            await model.load()
        }
        .onChange(of: model.selectedSegment) { _, _ in
            expandedAuthorIDs.removeAll()
        }
    }

    private var alphabetPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(TalesJPAlphabetSegment.orderedPickerSegments, id: \.self) { segment in
                    let isSelected = segment == model.selectedSegment
                    Button {
                        guard segment != model.selectedSegment else { return }
                        Haptics.medium()
                        model.selectedSegment = segment
                    } label: {
                        Text(pickerTitle(for: segment))
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(AppTheme.textPrimary)
                            .padding(.horizontal, segment == .misc ? 10 : 8)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(isSelected ? AppTheme.textPrimary.opacity(0.14) : AppTheme.mainBackground)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .stroke(
                                        AppTheme.borderSubtle.opacity(isSelected ? 1.0 : 0.6),
                                        lineWidth: 1
                                    )
                            )
                    }
                    .buttonStyle(.plain)
                    .accessibilityAddTraits(isSelected ? [.isSelected] : [])
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
        .background(AppTheme.mainBackground.opacity(0.98))
        .accessibilityElement(children: .contain)
        .accessibilityLabel(String(localized: String.LocalizationValue(LocalizationKey.talesJpAlphabetPickerAccessibility)))
    }

    private func pickerTitle(for segment: TalesJPAlphabetSegment) -> String {
        switch segment {
        case .letter(let ch):
            String(ch)
        case .digits:
            String(localized: String.LocalizationValue(LocalizationKey.talesJpSegmentDigits))
        case .misc:
            String(localized: String.LocalizationValue(LocalizationKey.talesJpSegmentMisc))
        }
    }

    @ViewBuilder
    private func taleLinkRow(author: FoundationTalesJPAuthor, tale: FoundationTalesJPTaleLink) -> some View {
        if let url = tale.resolvedURL(siteRoot: siteRoot) {
            Button {
                Haptics.medium()
                navigationRouter.pushArticle(url: url)
            } label: {
                FoundationIndexRow(
                    title: tale.title,
                    subtitle: url.absoluteString,
                    leadingSystemImage: "doc.text.fill",
                    trailing: {
                        ArticleRatingMeterView(ratingScore: articleRepository.ratingScore(for: url))
                    }
                )
            }
            .buttonStyle(.plain)
            .indexListRowChromeIndented()
        }
    }
}

#if DEBUG
#Preview {
    @Previewable @State var router = NavigationRouter()
    @Previewable @State var repo = ArticleRepository()
    @Previewable @State var vm = HomeViewModel(
        settingsRepository: SettingsRepository(),
        articleRepository: ArticleRepository()
    )
    NavigationStack {
        FoundationTalesJPIndexView(
            navigationRouter: router,
            articleRepository: repo,
            homeViewModel: vm
        )
    }
}
#endif
