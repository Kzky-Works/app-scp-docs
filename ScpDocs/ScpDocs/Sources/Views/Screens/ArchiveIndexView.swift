import SwiftUI

/// 報告書を 100 番単位で開くための中間階層（000–099 … 8900–8999）。
struct ArchiveIndexView: View {
    @Bindable var navigationRouter: NavigationRouter
    let branch: Branch

    private let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]

    private var segments: [SCPArchiveSegment] {
        SCPArchiveSegmentBuilder.segments(for: branch)
    }

    private var archiveNavigationTitle: String {
        switch branch.id {
        case BranchIdentifier.scpJapan:
            String(localized: String.LocalizationValue(LocalizationKey.archiveTitleJP))
        case BranchIdentifier.scpWikiEN:
            String(localized: String.LocalizationValue(LocalizationKey.archiveTitleEN))
        default:
            String(localized: String.LocalizationValue(LocalizationKey.archiveTitle))
        }
    }

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(segments) { segment in
                    Button {
                        Haptics.medium()
                        navigationRouter.push(.category(segment.url))
                    } label: {
                        Text(segment.label)
                            .font(.caption.weight(.semibold).monospacedDigit())
                            .foregroundStyle(AppTheme.accentPrimary)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 4)
                            .background(AppTheme.backgroundPrimary)
                            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 6, style: .continuous)
                                    .stroke(AppTheme.accentPrimary.opacity(0.55), lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(AppTheme.backgroundPrimary)
        .navigationTitle(archiveNavigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
        .tint(AppTheme.accentPrimary)
    }
}

// MARK: - Segment model

struct SCPArchiveSegment: Identifiable, Sendable {
    let id: Int
    let label: String
    let url: URL
}

enum SCPArchiveSegmentBuilder {
    /// 000–099 … 8900–8999 の 90 ブロック。
    static func segments(for branch: Branch) -> [SCPArchiveSegment] {
        (0 ..< 90).map { index in
            let blockStart = index * 100
            let end = blockStart + 99
            let label = rangeLabel(start: blockStart, end: end)
            let url = url(for: branch, blockStart: blockStart)
            return SCPArchiveSegment(id: index, label: label, url: url)
        }
    }

    private static func rangeLabel(start: Int, end: Int) -> String {
        let width = max(start, end) >= 1000 ? 4 : 3
        let ls = String(format: "%0\(width)d", start)
        let le = String(format: "%0\(width)d", end)
        let template = String(localized: String.LocalizationValue(LocalizationKey.archiveSegmentLabelTemplate))
        return String(format: template, locale: .current, ls, le)
    }

    private static func url(for branch: Branch, blockStart: Int) -> URL {
        switch branch.id {
        case BranchIdentifier.scpJapan:
            return japanListURL(blockStart: blockStart)
        case BranchIdentifier.scpInternational:
            return englishMainListURL(blockStart: blockStart)
        default:
            return englishMainListURL(blockStart: blockStart)
        }
    }

    private static func englishMainListURL(blockStart: Int) -> URL {
        let (path, fragment) = englishSeriesPathAndFragment(blockStart: blockStart)
        let base = URL(string: "https://scp-wiki.wikidot.com/\(path)")!
        return urlWithFragment(base, fragment: fragment)
    }

    private static func japanListURL(blockStart: Int) -> URL {
        let (path, fragment) = japanSeriesPathAndFragment(blockStart: blockStart)
        let base = URL(string: "https://scp-jp.wikidot.com/\(path)")!
        return urlWithFragment(base, fragment: fragment)
    }

    private static func englishSeriesPathAndFragment(blockStart: Int) -> (path: String, fragment: String) {
        let anchor = max(blockStart, 1)
        let path: String
        switch anchor {
        case 1 ..< 1000:
            path = "scp-series"
        case 1000 ..< 2000:
            path = "scp-series-2"
        case 2000 ..< 3000:
            path = "scp-series-3"
        case 3000 ..< 4000:
            path = "scp-series-4"
        case 4000 ..< 5000:
            path = "scp-series-4"
        case 5000 ..< 6000:
            path = "scp-series-5"
        case 6000 ..< 7000:
            path = "scp-series-6"
        case 7000 ..< 8000:
            path = "scp-series-7"
        case 8000 ..< 9000:
            path = "scp-series-8"
        default:
            path = "scp-series"
        }
        let fragment: String
        if blockStart == 0 {
            fragment = "001"
        } else if blockStart >= 1000 {
            fragment = String(format: "%04d", blockStart)
        } else {
            fragment = String(format: "%03d", blockStart)
        }
        return (path, fragment)
    }

    private static func japanSeriesPathAndFragment(blockStart: Int) -> (path: String, fragment: String) {
        let anchor = max(blockStart, 1)
        let path: String
        switch anchor {
        case 1 ..< 1000:
            path = "scp-series-jp"
        case 1000 ..< 2000:
            path = "scp-series-jp-2"
        case 2000 ..< 3000:
            path = "scp-series-jp-3"
        case 3000 ..< 4000:
            path = "scp-series-jp-4"
        case 4000 ..< 9000:
            path = "scp-series-jp-5"
        default:
            path = "scp-series-jp"
        }
        let fragment: String
        if blockStart == 0 {
            fragment = "001"
        } else if blockStart >= 1000 {
            fragment = String(format: "%04d", blockStart)
        } else {
            fragment = String(format: "%03d", blockStart)
        }
        return (path, fragment)
    }

    private static func urlWithFragment(_ base: URL, fragment: String) -> URL {
        var components = URLComponents(url: base, resolvingAgainstBaseURL: false)
        components?.fragment = fragment
        return components?.url ?? base
    }
}
