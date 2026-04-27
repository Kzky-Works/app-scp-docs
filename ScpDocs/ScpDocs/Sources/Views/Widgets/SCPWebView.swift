import Foundation
import SwiftUI
import UIKit
import WebKit

/// `WKWebView` の SwiftUI ラッパー。`WebViewModel` と `Coordinator` で状態を同期する。
struct SCPWebView: UIViewRepresentable {
    @Bindable var viewModel: WebViewModel
    /// 設定時のみ、Wikidot 内部リンクの遷移をキャンセルしてアプリ側ナビへ委譲する。
    var navigationRouter: NavigationRouter? = nil
    /// 記事画面で右端のカスタムスクロールバーを使うときは `false` にし、二重表示を避ける。
    var showsNativeVerticalScrollIndicator: Bool = true
    /// 記事の下部リーダーナビを展開した状態で、本文（Web）をタップしたときに閉じる処理。`nil` のときは無効。
    var onReaderChromeDismissTap: (() -> Void)? = nil

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> WKWebView {
        let scheme = context.environment.colorScheme
        let palette = AppTheme.webContentPalette(isDark: scheme == .dark)
        let configuration = WebViewService.makeConfiguration(palette: palette)
        let webView = WKWebView(frame: .zero, configuration: configuration)
        if !WebViewDiagnostics.usesMinimalWebViewConfiguration {
            webView.customUserAgent = Self.mobileSafariLikeUserAgent()
        }
        webView.navigationDelegate = context.coordinator
        webView.isOpaque = false
        Self.applyChromeColors(to: webView)
        // 本文が数 px でもビューポートより広いと横バウンド・横スクロールが発生し「左右にブレる」ように見える。
        webView.scrollView.alwaysBounceHorizontal = false
        webView.scrollView.showsHorizontalScrollIndicator = false
        webView.scrollView.showsVerticalScrollIndicator = showsNativeVerticalScrollIndicator
        webView.scrollView.clipsToBounds = true
        context.coordinator.colorScheme = scheme
        context.coordinator.prepare(webView: webView, viewModel: viewModel)
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        webView.scrollView.showsVerticalScrollIndicator = showsNativeVerticalScrollIndicator
        context.coordinator.viewModel = viewModel
        context.coordinator.navigationRouter = navigationRouter
        viewModel.webView = webView
        let scheme = context.environment.colorScheme
        if context.coordinator.colorScheme != scheme {
            context.coordinator.colorScheme = scheme
            Self.applyChromeColors(to: webView)
            let palette = AppTheme.webContentPalette(isDark: scheme == .dark)
            viewModel.applyWebContentPalette(palette)
        }
        viewModel.flushPendingCommands(into: webView)
        context.coordinator.syncNavigationChrome(for: webView)
        context.coordinator.syncReaderChromeDismissTap(on: webView, handler: onReaderChromeDismissTap)
    }

    private static func applyChromeColors(to webView: WKWebView) {
        webView.backgroundColor = AppTheme.backgroundPrimaryUIKit
        webView.scrollView.backgroundColor = AppTheme.backgroundPrimaryUIKit
        if #available(iOS 15.0, *) {
            webView.underPageBackgroundColor = AppTheme.backgroundPrimaryUIKit
        }
    }

    static func dismantleUIView(_ uiView: WKWebView, coordinator: Coordinator) {
        coordinator.viewModel?.webView = nil
        coordinator.teardown()
    }

    /// モバイル Safari に近い UA（OS バージョンは実行環境に合わせる）。
    private static func mobileSafariLikeUserAgent() -> String {
        let version = UIDevice.current.systemVersion
        let vUnder = version.replacingOccurrences(of: ".", with: "_")
        let major = version.split(separator: ".").first.map(String.init) ?? "17"
        return "Mozilla/5.0 (iPhone; CPU iPhone OS \(vUnder) like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/\(major).0 Mobile/15E148 Safari/604.1"
    }

    @MainActor
    final class Coordinator: NSObject, WKNavigationDelegate, UIGestureRecognizerDelegate {
        private weak var webView: WKWebView?
        weak var viewModel: WebViewModel?
        weak var navigationRouter: NavigationRouter?
        var colorScheme: ColorScheme = .light

        private var edgeBackGesture: UIScreenEdgePanGestureRecognizer?
        private var readerChromeDismissTapGesture: UITapGestureRecognizer?
        /// `syncReaderChromeDismissTap` で更新。ジェスチャーは参照だけで、実行時に最新のクロージャを呼ぶ。
        private var readerChromeDismissTapHandler: (() -> Void)?
        private weak var trackedNavigationController: UINavigationController?
        private var originalPopGestureDelegate: UIGestureRecognizerDelegate?

        private var isObservingWebView = false
        private var scrollObservations: [NSKeyValueObservation] = []

        func prepare(webView: WKWebView, viewModel: WebViewModel) {
            self.webView = webView
            self.viewModel = viewModel

            scrollObservations.removeAll()
            let sv = webView.scrollView
            scrollObservations = [
                sv.observe(\.contentOffset, options: [.new]) { [weak self] scrollView, _ in
                    guard let self else { return }
                    Task { @MainActor in
                        self.publishScrollDepth(from: scrollView)
                    }
                },
                sv.observe(\.contentSize, options: [.new]) { [weak self] scrollView, _ in
                    guard let self else { return }
                    Task { @MainActor in
                        self.publishScrollDepth(from: scrollView)
                    }
                },
                sv.observe(\.bounds, options: [.new]) { [weak self] scrollView, _ in
                    guard let self else { return }
                    Task { @MainActor in
                        self.publishScrollDepth(from: scrollView)
                    }
                }
            ]
            publishScrollDepth(from: sv)

            if !isObservingWebView {
                webView.addObserver(
                    self,
                    forKeyPath: #keyPath(WKWebView.canGoBack),
                    options: [.new],
                    context: nil
                )
                webView.addObserver(
                    self,
                    forKeyPath: #keyPath(WKWebView.url),
                    options: [.new],
                    context: nil
                )
                isObservingWebView = true
            }

            if edgeBackGesture == nil {
                let gesture = UIScreenEdgePanGestureRecognizer(
                    target: self,
                    action: #selector(handleEdgeBack(_:))
                )
                gesture.edges = .left
                gesture.delegate = self
                webView.addGestureRecognizer(gesture)
                edgeBackGesture = gesture
            }

            viewModel.updateStateFromWebView(webView)
            syncNavigationChrome(for: webView)
        }

        func syncReaderChromeDismissTap(on webView: WKWebView, handler: (() -> Void)?) {
            readerChromeDismissTapHandler = handler

            let scrollView = webView.scrollView

            if handler == nil {
                if let tap = readerChromeDismissTapGesture {
                    scrollView.removeGestureRecognizer(tap)
                    readerChromeDismissTapGesture = nil
                }
                return
            }

            if readerChromeDismissTapGesture == nil {
                let tap = UITapGestureRecognizer(target: self, action: #selector(handleReaderChromeDismissTap(_:)))
                tap.cancelsTouchesInView = false
                tap.delegate = self
                scrollView.addGestureRecognizer(tap)
                readerChromeDismissTapGesture = tap
            }
        }

        @objc private func handleReaderChromeDismissTap(_ gesture: UITapGestureRecognizer) {
            guard gesture.state == .ended else { return }
            guard let webView else { return }
            let point = gesture.location(in: webView)
            guard webView.point(inside: point, with: nil) else { return }
            readerChromeDismissTapHandler?()
        }

        func teardown() {
            guard let attachedWebView = webView else {
                scrollObservations.removeAll()
                readerChromeDismissTapGesture = nil
                readerChromeDismissTapHandler = nil
                edgeBackGesture = nil
                restorePopGestureDelegate()
                viewModel = nil
                return
            }

            if isObservingWebView {
                attachedWebView.removeObserver(self, forKeyPath: #keyPath(WKWebView.canGoBack))
                attachedWebView.removeObserver(self, forKeyPath: #keyPath(WKWebView.url))
                isObservingWebView = false
            }

            if let readerChromeDismissTapGesture {
                attachedWebView.scrollView.removeGestureRecognizer(readerChromeDismissTapGesture)
            }
            readerChromeDismissTapGesture = nil
            readerChromeDismissTapHandler = nil

            if let edgeBackGesture {
                attachedWebView.removeGestureRecognizer(edgeBackGesture)
            }
            edgeBackGesture = nil

            scrollObservations.removeAll()
            restorePopGestureDelegate()
            webView = nil
            viewModel = nil
        }

        /// `UIScrollView` の KVO で進捗を算出（毎ピクセルの JS 橋渡しより軽量）。閾値判定は Swift 側（`ArticleDetailViewModel`）。
        private func publishScrollDepth(from scrollView: UIScrollView) {
            guard let viewModel else { return }
            let contentH = scrollView.contentSize.height
            let visibleH = scrollView.bounds.height
            let scrollable = max(contentH - visibleH, 0)
            let fraction: Double
            if scrollable <= 1 {
                // レイアウト前は contentSize が小さく、未スクロールで 100% 扱いになると評価バーが誤表示される。
                if viewModel.isLoading || viewModel.isReaderSurfaceConcealed {
                    fraction = 0
                } else if contentH < 200 {
                    fraction = 0
                } else {
                    // 本文がビューポートに収まる短いページのみ「下端到達」扱い。
                    fraction = 1
                }
            } else {
                fraction = min(max(Double(scrollView.contentOffset.y / scrollable), 0), 1)
            }
            viewModel.updateScrollDepthFraction(fraction)
        }

        func syncNavigationChrome(for webView: WKWebView) {
            let navigationController = owningNavigationController(from: webView)
            if navigationController !== trackedNavigationController {
                restorePopGestureDelegate()
                trackedNavigationController = navigationController
                if let pop = navigationController?.interactivePopGestureRecognizer {
                    originalPopGestureDelegate = pop.delegate
                    pop.delegate = self
                }
            }

            edgeBackGesture?.isEnabled = webView.canGoBack
        }

        private func owningNavigationController(from webView: WKWebView) -> UINavigationController? {
            var responder: UIResponder? = webView
            while let current = responder {
                if let viewController = current as? UIViewController {
                    if let navigationController = viewController.navigationController {
                        return navigationController
                    }
                }
                responder = current.next
            }
            return nil
        }

        private func restorePopGestureDelegate() {
            trackedNavigationController?.interactivePopGestureRecognizer?.delegate = originalPopGestureDelegate
            trackedNavigationController = nil
            originalPopGestureDelegate = nil
        }

        @objc private func handleEdgeBack(_ gesture: UIScreenEdgePanGestureRecognizer) {
            guard let webView, webView.canGoBack else { return }
            guard gesture.state == .ended else { return }
            let translation = gesture.translation(in: webView)
            let velocity = gesture.velocity(in: webView)
            if translation.x > 72 || velocity.x > 420 {
                webView.goBack()
            }
        }

        // MARK: - WKNavigationDelegate

        func webView(
            _ webView: WKWebView,
            decidePolicyFor navigationAction: WKNavigationAction,
            decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
        ) {
            guard
                navigationAction.navigationType == .linkActivated,
                navigationAction.targetFrame?.isMainFrame != false,
                let url = navigationAction.request.url,
                let router = navigationRouter
            else {
                decisionHandler(.allow)
                return
            }

            guard Self.isInternalSCPJapanLink(url) else {
                decisionHandler(.allow)
                return
            }

            if Self.isSameDocumentFragmentChange(webView: webView, target: url) {
                decisionHandler(.allow)
                return
            }

            Task { @MainActor in
                router.pushArticle(url: url)
            }
            decisionHandler(.cancel)
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            viewModel?.clearLoadFailure()
            viewModel?.markReaderSurfaceConcealedForPendingTypography()
            viewModel?.setLoading(true)
            viewModel?.updateStateFromWebView(webView)
            syncNavigationChrome(for: webView)
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            viewModel?.clearLoadFailure()
            viewModel?.setLoading(false)
            viewModel?.updateStateFromWebView(webView)
            viewModel?.applyReaderFontPresentation(endsReaderTypographyConceal: true) { [weak webView, weak viewModel] in
                guard let webView, let viewModel else { return }
                viewModel.attemptApplyScrollRestore(on: webView)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) { [weak webView, weak viewModel] in
                    guard let webView, let viewModel else { return }
                    viewModel.attemptApplyScrollRestore(on: webView)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.95) { [weak webView, weak viewModel] in
                    guard let webView, let viewModel else { return }
                    viewModel.attemptApplyScrollRestore(on: webView)
                }
            }
            syncNavigationChrome(for: webView)
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            viewModel?.setLoading(false)
            viewModel?.revealReaderSurface()
            viewModel?.recordNavigationFailure(error)
            viewModel?.updateStateFromWebView(webView)
            syncNavigationChrome(for: webView)
        }

        func webView(
            _ webView: WKWebView,
            didFailProvisionalNavigation navigation: WKNavigation!,
            withError error: Error
        ) {
            viewModel?.setLoading(false)
            viewModel?.revealReaderSurface()
            viewModel?.recordNavigationFailure(error)
            viewModel?.updateStateFromWebView(webView)
            syncNavigationChrome(for: webView)
        }

        // MARK: - UIGestureRecognizerDelegate

        func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
            guard let webView else { return true }

            if gestureRecognizer === edgeBackGesture {
                return webView.canGoBack
            }

            if
                let navigation = trackedNavigationController,
                gestureRecognizer === navigation.interactivePopGestureRecognizer
            {
                return !webView.canGoBack
            }

            return true
        }

        func gestureRecognizer(
            _ gestureRecognizer: UIGestureRecognizer,
            shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
        ) -> Bool {
            guard let dismissTap = readerChromeDismissTapGesture else { return false }
            return gestureRecognizer === dismissTap || otherGestureRecognizer === dismissTap
        }

        // MARK: - KVO

        override func observeValue(
            forKeyPath keyPath: String?,
            of object: Any?,
            change: [NSKeyValueChangeKey: Any]?,
            context: UnsafeMutableRawPointer?
        ) {
            guard let webView = object as? WKWebView, webView === self.webView else {
                super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
                return
            }

            if keyPath == #keyPath(WKWebView.canGoBack) || keyPath == #keyPath(WKWebView.url) {
                Task { @MainActor in
                    self.viewModel?.updateStateFromWebView(webView)
                    self.edgeBackGesture?.isEnabled = webView.canGoBack
                    self.syncNavigationChrome(for: webView)
                }
            } else {
                super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            }
        }

        private static let scpJapanHost = "scp-jp.wikidot.com"

        private static func isInternalSCPJapanLink(_ url: URL) -> Bool {
            guard let scheme = url.scheme?.lowercased(), scheme == "https" || scheme == "http" else {
                return false
            }
            return url.host?.caseInsensitiveCompare(scpJapanHost) == .orderedSame
        }

        private static func isSameDocumentFragmentChange(webView: WKWebView, target: URL) -> Bool {
            guard let current = webView.url,
                  let targetComponents = URLComponents(url: target, resolvingAgainstBaseURL: true),
                  let currentComponents = URLComponents(url: current, resolvingAgainstBaseURL: true)
            else {
                return false
            }

            let sameScheme = targetComponents.scheme?.lowercased() == currentComponents.scheme?.lowercased()
            let sameHost = targetComponents.host?.lowercased() == currentComponents.host?.lowercased()
            let samePath = targetComponents.path == currentComponents.path
            let fragmentDiffers = targetComponents.fragment != currentComponents.fragment
            return sameScheme && sameHost && samePath && fragmentDiffers
        }
    }
}
