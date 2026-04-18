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
    /// 読み込み失敗時に表示するユーザー向けメッセージ（成功・再読込開始で消える）。
    private(set) var loadFailureMessage: String?
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
    /// 同一キーで「すでに読み込み中」のときだけ二重 `load` を抑止する（時間だけで弾くと、再試行の `load` を落とす）。
    private var lastFlushedLoadKey: String?

    init(offlineStore: OfflineStore = .shared) {
        self.offlineStore = offlineStore
    }

    func load(url: URL) {
        currentURL = url
        pageTitle = nil
        loadFailureMessage = nil

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

    /// Wikidot は応答が遅いことがある。既定 60 秒だと -1001 になりやすいので延ばす。
    private static let articleRequestTimeout: TimeInterval = 120

    private static func urlRequest(forArticle url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.timeoutInterval = articleRequestTimeout
        return request
    }

    func clearLoadFailure() {
        loadFailureMessage = nil
    }

    func recordNavigationFailure(_ error: Error) {
        let ns = error as NSError
        if ns.domain == NSURLErrorDomain && ns.code == NSURLErrorCancelled {
            return
        }
        if ns.domain == NSURLErrorDomain && ns.code == NSURLErrorTimedOut {
            loadFailureMessage = String(localized: String.LocalizationValue(LocalizationKey.articleLoadTimeout))
            return
        }
        loadFailureMessage = String(localized: String.LocalizationValue(LocalizationKey.articleLoadFailed))
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
            if lastFlushedLoadKey == key, webView.isLoading {
                return
            }
            lastFlushedLoadKey = key
            webView.load(Self.urlRequest(forArticle: url))
        case .loadFile(let fileURL):
            pendingCommand = .none
            let key = Self.flushKey(forFile: fileURL)
            if lastFlushedLoadKey == key, webView.isLoading {
                return
            }
            lastFlushedLoadKey = key
            let directory = fileURL.deletingLastPathComponent()
            webView.loadFileURL(fileURL, allowingReadAccessTo: directory)
        case .goBack:
            pendingCommand = .none
            lastFlushedLoadKey = nil
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
