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
    /// メイン `UIScrollView` の縦スクロール進捗 0...1（本文下端に近いほど 1）。
    private(set) var scrollDepthFraction: Double = 0
    weak var webView: WKWebView?
    /// 記事本文の相対スケール（`SettingsRepository` と同期。既定 1.0）。
    var readerFontSizeMultiplier: Double = 1.0
    /// `-webkit-text-size-adjust` 適用前は本文の誤スケールが見えないよう Web を隠し、ローディングに切り替える。
    private(set) var isReaderSurfaceConcealed: Bool = false

    private let offlineStore: OfflineStore

    private enum PendingCommand: Equatable {
        case none
        case load(URL)
        case loadFile(URL)
        case goBack
    }

    private var pendingCommand: PendingCommand = .none

    /// 初回表示時に `ArticleRepository` の保存深度へスクロールを戻す（`WKNavigationDelegate.didFinish` で適用）。
    private var pendingScrollRestoreFraction: Double?
    private var scrollRestoreAttemptCount: Int = 0

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
        scrollRestoreAttemptCount = 0

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
    private static let articleRequestTimeout: TimeInterval = 300

    private static func urlRequest(forArticle url: URL) -> URLRequest {
        if WebViewDiagnostics.usesMinimalWebViewConfiguration {
            return URLRequest(url: url)
        }
        var request = URLRequest(url: url)
        request.timeoutInterval = articleRequestTimeout
        return request
    }

    func clearLoadFailure() {
        loadFailureMessage = nil
    }

    /// 記事画面の `.task` で、ネットワーク読み込み前に呼ぶ。極端な値は無視する。
    func prepareScrollRestoreFromPersistedDepth(_ fraction: Double) {
        let c = min(1, max(0, fraction))
        if c >= 0.02, c < 0.998 {
            pendingScrollRestoreFraction = c
        } else {
            pendingScrollRestoreFraction = nil
        }
        scrollRestoreAttemptCount = 0
    }

    /// `SCPWebView` の `didFinish`（および遅延リトライ）から呼ぶ。本文高さが確定したら適用して `pending` を消す。
    func attemptApplyScrollRestore(on webView: WKWebView) {
        guard let fraction = pendingScrollRestoreFraction else { return }
        let sv = webView.scrollView
        let contentH = sv.contentSize.height
        let visibleH = sv.bounds.height
        let naturalScrollable = max(contentH - visibleH, 0)
        let bottomChrome = sv.adjustedContentInset.bottom
        let scrollable = naturalScrollable + bottomChrome
        guard scrollable > 1 else {
            scrollRestoreAttemptCount += 1
            if scrollRestoreAttemptCount >= 5 {
                pendingScrollRestoreFraction = nil
                scrollRestoreAttemptCount = 0
            }
            return
        }
        let y = CGFloat(fraction) * scrollable
        sv.setContentOffset(CGPoint(x: 0, y: y), animated: false)
        updateScrollDepthFraction(fraction)
        pendingScrollRestoreFraction = nil
        scrollRestoreAttemptCount = 0
    }

    /// WebView 内の本文に `-webkit-text-size-adjust` 等を適用する（読み込み完了後や倍率変更時に呼ぶ）。
    /// 外観モード変更時に、既に読み込み済みの DOM へ CleanUI テーマを再適用する。
    /// `WKNavigationDelegate` の本読み込み開始。注入による文字サイズ適用前のチラつきを隠す。
    func markReaderSurfaceConcealedForPendingTypography() {
        guard !WebViewDiagnostics.usesMinimalWebViewConfiguration else { return }
        isReaderSurfaceConcealed = true
    }

    /// 失敗画面や最小構成では本文を隠し続けない。
    func revealReaderSurface() {
        isReaderSurfaceConcealed = false
    }

    func applyWebContentPalette(_ palette: WebContentPalette) {
        guard let webView, !WebViewDiagnostics.usesMinimalWebViewConfiguration else { return }
        let js = """
        (function(){
          if (window.__SCPDOCS_applyCleanUITheme) {
            window.__SCPDOCS_applyCleanUITheme({
              background: '\(palette.backgroundHex)',
              text: '\(palette.textHex)',
              link: '\(palette.linkHex)',
              linkHover: '\(palette.linkHoverHex)',
              container: '\(palette.containerHex)',
              inset: '\(palette.insetSurfaceHex)'
            });
          }
        })();
        """
        webView.evaluateJavaScript(js, completionHandler: nil)
    }

    /// - Parameters:
    ///   - endsReaderTypographyConceal: 遷移完了後の初回適用で `true`（ローディングの解除）。スライダー等の手動調整は `false`。
    ///   - onApplied: 本文への JS 適用後（失敗を含まない完了時。本文レイアウト基準の後処理用）。
    func applyReaderFontPresentation(endsReaderTypographyConceal: Bool = true, onApplied: (() -> Void)? = nil) {
        guard let webView else {
            if endsReaderTypographyConceal { isReaderSurfaceConcealed = false }
            onApplied?()
            return
        }
        if WebViewDiagnostics.usesMinimalWebViewConfiguration {
            if endsReaderTypographyConceal { isReaderSurfaceConcealed = false }
            onApplied?()
            return
        }
        let pct = Int(round(readerFontSizeMultiplier * 100))
        let js = """
        (function(){
          var y = window.pageYOffset || document.documentElement.scrollTop || 0;
          var p = \(pct);
          var root = document.documentElement;
          if (root && root.style) {
            root.style.webkitTextSizeAdjust = p + '%';
          }
          var b = document.body;
          if (b && b.style) {
            b.style.webkitTextSizeAdjust = p + '%';
          }
          window.scrollTo(0, y);
          if (window.requestAnimationFrame) {
            window.requestAnimationFrame(function() { window.scrollTo(0, y); });
          }
        })();
        """
        webView.evaluateJavaScript(js) { [weak self] _, _ in
            Task { @MainActor in
                guard let self else {
                    onApplied?()
                    return
                }
                if endsReaderTypographyConceal { self.isReaderSurfaceConcealed = false }
                onApplied?()
            }
        }
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
            scrollDepthFraction = 0
        }
        isLoading = value
    }

    /// `SCPWebView` のスクロール観測（および復元）から更新する。
    func updateScrollDepthFraction(_ value: Double) {
        let clamped = min(1, max(0, value))
        guard scrollDepthFraction != clamped else { return }
        scrollDepthFraction = clamped
    }

    /// 本文付近の最初の `img` の `src` を解決する（ホームの続きから読むサムネ用。失敗時は `nil`）。
    func probeFirstContentImageURL(completion: @escaping (URL?) -> Void) {
        guard let webView else {
            Task { @MainActor in completion(nil) }
            return
        }
        let base = webView.url ?? currentURL
        let js = """
        (function(){
          var root = document.getElementById('page-content')
            || document.getElementById('main-content')
            || document.body;
          if (!root) { return null; }
          var imgs = root.getElementsByTagName('img');
          for (var i = 0; i < imgs.length; i++) {
            var src = imgs[i].getAttribute('src');
            if (!src) { continue; }
            if (src.indexOf('data:') === 0) { continue; }
            return src;
          }
          return null;
        })();
        """
        webView.evaluateJavaScript(js) { result, _ in
            Task { @MainActor in
                guard let raw = result as? String else {
                    completion(nil)
                    return
                }
                let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmed.isEmpty else {
                    completion(nil)
                    return
                }
                if let absolute = URL(string: trimmed, relativeTo: base)?.absoluteURL {
                    completion(absolute)
                } else {
                    completion(nil)
                }
            }
        }
    }
}
