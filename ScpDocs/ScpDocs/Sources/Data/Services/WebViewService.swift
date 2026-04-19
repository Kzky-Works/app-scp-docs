import Foundation
import OSLog
import WebKit

/// `WKWebView` の構成と、バンドル化された注入スクリプトの読み込み。
enum WebViewService {
    private static let log = Logger(subsystem: Bundle.main.bundleIdentifier ?? "ScpDocs", category: "WebViewService")

    private static let cleanUIScriptFileName = "CleanUI"
    private static let cleanUIScriptExtension = "js"
    private static let cleanUIScriptSubdirectory = "Injections"

    /// `CleanUI.js` を読み込み終端で注入する構成を返す。
    static func makeConfiguration() -> WKWebViewConfiguration {
        if WebViewDiagnostics.usesMinimalWebViewConfiguration {
            let configuration = WKWebViewConfiguration()
            configuration.defaultWebpagePreferences.allowsContentJavaScript = true
            return configuration
        }

        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences.allowsContentJavaScript = true

        let paletteBootstrap = WKUserScript(
            source: """
            (function(){
              var r=document.documentElement;
              if(!r){return;}
              r.style.backgroundColor='#121212';
              r.style.color='#C0C0C0';
            })();
            """,
            injectionTime: .atDocumentStart,
            forMainFrameOnly: true
        )
        configuration.userContentController.addUserScript(paletteBootstrap)

        let cleanSource = loadCleanUIScript()
        let cleanScript = WKUserScript(
            source: cleanSource,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: true
        )
        configuration.userContentController.addUserScript(cleanScript)

        return configuration
    }

    private static func loadCleanUIScript() -> String {
        // Xcode の「グループ」に置いたリソースはバンドル直下にコピーされることが多く、
        // `Injections/` サブフォルダは付かない。フォルダ参照で入れた場合はサブパスがある。
        let candidates: [URL?] = [
            Bundle.main.url(
                forResource: cleanUIScriptFileName,
                withExtension: cleanUIScriptExtension,
                subdirectory: cleanUIScriptSubdirectory
            ),
            Bundle.main.url(forResource: cleanUIScriptFileName, withExtension: cleanUIScriptExtension),
        ]
        for case let url? in candidates {
            if let data = try? Data(contentsOf: url), let text = String(data: data, encoding: .utf8) {
                return text
            }
        }
        log.error("Missing CleanUI.js in app bundle (tried Injections/ and bundle root).")
        return ""
    }

    /// 既定の `WKWebsiteDataStore` に蓄積されたキャッシュ・Cookie 等を消去する。
    @MainActor
    static func clearWebsiteData() async {
        let types = WKWebsiteDataStore.allWebsiteDataTypes()
        await WKWebsiteDataStore.default().removeData(ofTypes: types, modifiedSince: .distantPast)
    }
}
