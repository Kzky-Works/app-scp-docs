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

    private enum PendingCommand: Equatable {
        case none
        case load(URL)
        case goBack
    }

    private var pendingCommand: PendingCommand = .none

    func load(url: URL) {
        currentURL = url
        pageTitle = nil
        pendingCommand = .load(url)
    }

    func goBack() {
        pendingCommand = .goBack
    }

    /// `UIViewRepresentable.updateUIView` から呼び出し、保留中のナビゲーションを適用する。
    func flushPendingCommands(into webView: WKWebView) {
        switch pendingCommand {
        case .none:
            break
        case .load(let url):
            pendingCommand = .none
            webView.load(URLRequest(url: url))
        case .goBack:
            pendingCommand = .none
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
