import Foundation

/// WKWebView の不具合を **段階的に切り分ける**ためのフラグと、`URLSession` による到達性テスト。
/// 値は `UserDefaults` に保存し、設定画面から切り替える。
enum WebViewDiagnostics {
    /// オンにすると **注入スクリプトなし・共有 processPool なし・customUserAgent なし**の最小 `WKWebViewConfiguration` を使う。
    static let minimalConfigurationDefaultsKey = "webview.diagnostics.minimal_configuration"

    static var usesMinimalWebViewConfiguration: Bool {
        UserDefaults.standard.bool(forKey: minimalConfigurationDefaultsKey)
    }

    /// `URLSession` による GET（WKWebView とは別プロセス・別スタック）。先にここが成功するか確認する。
    enum NetworkProbe {
        /// 日本支部トップ（ホーム「サイトトップ」と同系統の疎通確認用）。
        static let defaultProbeURL = URL(string: "https://scp-jp.wikidot.com/")!

        static func fetchStatusLine(for url: URL) async -> String {
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.timeoutInterval = 45
            let start = Date()
            do {
                let (_, response) = try await URLSession.shared.data(for: request)
                let elapsed = Date().timeIntervalSince(start)
                let code = (response as? HTTPURLResponse)?.statusCode ?? -1
                return "HTTP \(code) · \(String(format: "%.2f", elapsed))s"
            } catch {
                let ns = error as NSError
                return "\(ns.domain) \(ns.code): \(error.localizedDescription)"
            }
        }
    }
}
