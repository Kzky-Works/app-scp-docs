import Foundation
import WebKit

/// `WKWebView` の構成と、バンドル化された注入スクリプトの読み込み。
enum WebViewService {
    private static let cleanUIScriptFileName = "CleanUI"
    private static let cleanUIScriptExtension = "js"
    private static let cleanUIScriptSubdirectory = "Injections"

    /// `CleanUI.js` を読み込み終端で注入する構成を返す。
    static func makeConfiguration() -> WKWebViewConfiguration {
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
        guard
            let url = Bundle.main.url(
                forResource: cleanUIScriptFileName,
                withExtension: cleanUIScriptExtension,
                subdirectory: cleanUIScriptSubdirectory
            ),
            let data = try? Data(contentsOf: url),
            let text = String(data: data, encoding: .utf8)
        else {
            assertionFailure("Missing CleanUI.js in app bundle (expected Resources/Injections/CleanUI.js).")
            return ""
        }
        return text
    }

    /// 既定の `WKWebsiteDataStore` に蓄積されたキャッシュ・Cookie 等を消去する。
    @MainActor
    static func clearWebsiteData() async {
        let types = WKWebsiteDataStore.allWebsiteDataTypes()
        await WKWebsiteDataStore.default().removeData(ofTypes: types, modifiedSince: .distantPast)
    }
}
