import Foundation
import Observation
import WebKit

@Observable
@MainActor
final class WebViewModel {
    private(set) var currentURL: URL?
    private(set) var isLoading = false
    private(set) var canGoBack = false
    private(set) var pageTitle: String?
    weak var webView: WKWebView?

    private let offlineStore: OfflineStore

    private enum PendingCommand: Equatable {
        case none
        case load(URL)
        case loadFile(URL)
        case goBack
    }

    private var pendingCommand: PendingCommand = .none

    /// `updateUIView` が短時間に複数回走ると `load` が重複し、先のリクエストが NSURLErrorCancelled (-999) になる。
    private var lastFlushedLoadKey: String?
    private var lastIssuedLoadAt: Date?

    init(offlineStore: OfflineStore = .shared) {
        self.offlineStore = offlineStore
    }

    func load(url: URL) {
        currentURL = url
        pageTitle = nil

        let snapshotFile = offlineStore.loadHTML(for: url)
        let offline = snapshotFile != nil && !ConnectivityMonitor.shared.isPathSatisfied

        if offline, let fileURL = snapshotFile {
            pendingCommand = .loadFile(fileURL)
        } else {
            pendingCommand = .load(url)
        }
    }

    func goBack() {
        pendingCommand = .goBack
    }

    private static func flushKey(forNetwork url: URL) -> String {
        ArticleRepository.storageKey(for: url)
    }

    private static func flushKey(forFile url: URL) -> String {
        "file:\(url.path)"
    }

    /// 現在表示中の DOM をスナップショットして保存する（お気に入り追加時など）。
    func captureSnapshot(for url: URL) {
        guard let webView else { return }
        webView.evaluateJavaScript("document.documentElement.outerHTML") { [weak self] result, error in
            Task { @MainActor in
                guard error == nil, let html = result as? String, let self else { return }
                try? self.offlineStore.saveHTML(html, for: url)
            }
        }
    }

    /// `UIViewRepresentable.updateUIView` から呼び出し、保留中のナビゲーションを適用する。
    func flushPendingCommands(into webView: WKWebView) {
        switch pendingCommand {
        case .none:
            break
        case .load(let url):
            pendingCommand = .none
            let key = Self.flushKey(forNetwork: url)
            let now = Date()
            if lastFlushedLoadKey == key {
                let recentDuplicate = lastIssuedLoadAt.map { now.timeIntervalSince($0) < 0.35 } ?? false
                if webView.isLoading || recentDuplicate {
                    return
                }
            }
            lastFlushedLoadKey = key
            lastIssuedLoadAt = now
            webView.load(URLRequest(url: url))
        case .loadFile(let fileURL):
            pendingCommand = .none
            let key = Self.flushKey(forFile: fileURL)
            let now = Date()
            if lastFlushedLoadKey == key {
                let recentDuplicate = lastIssuedLoadAt.map { now.timeIntervalSince($0) < 0.35 } ?? false
                if webView.isLoading || recentDuplicate {
                    return
                }
            }
            lastFlushedLoadKey = key
            lastIssuedLoadAt = now
            let directory = fileURL.deletingLastPathComponent()
            webView.loadFileURL(fileURL, allowingReadAccessTo: directory)
        case .goBack:
            pendingCommand = .none
            lastFlushedLoadKey = nil
            lastIssuedLoadAt = nil
            if webView.canGoBack {
                webView.goBack()
            }
        }
    }

    func updateStateFromWebView(_ webView: WKWebView) {
        canGoBack = webView.canGoBack
        currentURL = webView.url ?? currentURL
        if let title = webView.title, !title.isEmpty {
            pageTitle = title
        }
    }

    func setLoading(_ value: Bool) {
        if value {
            pageTitle = nil
        }
        isLoading = value
    }
}
