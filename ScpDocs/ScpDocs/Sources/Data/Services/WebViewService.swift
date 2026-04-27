import Foundation
import OSLog
import WebKit

/// `WKWebView` の構成と、バンドル化された注入スクリプトの読み込み。
enum WebViewService {
    private static let log = Logger(subsystem: Bundle.main.bundleIdentifier ?? "ScpDocs", category: "WebViewService")

    private static let cleanUIScriptFileName = "CleanUI"
    private static let cleanUIScriptExtension = "js"
    private static let cleanUIScriptSubdirectory = "Injections"

    /// `CleanUI.js` を読み込み終端で注入する構成を返す。テーマは `palette` と同期する。
    static func makeConfiguration(palette: WebContentPalette) -> WKWebViewConfiguration {
        if WebViewDiagnostics.usesMinimalWebViewConfiguration {
            let configuration = WKWebViewConfiguration()
            configuration.defaultWebpagePreferences.allowsContentJavaScript = true
            return configuration
        }

        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences.allowsContentJavaScript = true

        let paletteBootstrap = WKUserScript(
            source: paletteBootstrapSource(palette: palette),
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

    private static func paletteBootstrapSource(palette: WebContentPalette) -> String {
        """
        (function(){
          window.__SCPDOCS_THEME__ = {
            background: '\(palette.backgroundHex)',
            text: '\(palette.textHex)',
            link: '\(palette.linkHex)',
            linkHover: '\(palette.linkHoverHex)',
            container: '\(palette.containerHex)',
            inset: '\(palette.insetSurfaceHex)'
          };
          var r=document.documentElement;
          if(!r){return;}
          r.style.backgroundColor=window.__SCPDOCS_THEME__.background;
          r.style.color=window.__SCPDOCS_THEME__.text;
          var head=document.head;
          if(head && !head.querySelector('meta[name="viewport"]')){
            var m=document.createElement('meta');
            m.name='viewport';
            m.content='width=device-width, initial-scale=1, viewport-fit=cover';
            head.insertBefore(m, head.firstChild);
          }
        })();
        """
    }

    private static func loadCleanUIScript() -> String {
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
