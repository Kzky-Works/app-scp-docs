import GoogleMobileAds
import SwiftUI
import UIKit

/// Google AdMob テストバナー。本番では `adUnitID` を AdMob コンソールの値に差し替える。
struct AdBannerView: UIViewRepresentable {
    var adUnitID: String = LocalizationKey.adMobBannerUnitIDTest

    func makeUIView(context: Context) -> GADBannerView {
        let view = GADBannerView(adSize: GADAdSizeBanner)
        view.adUnitID = adUnitID
        view.load(GADRequest())
        return view
    }

    func updateUIView(_ uiView: GADBannerView, context: Context) {
        if uiView.rootViewController == nil {
            uiView.rootViewController = UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap(\.windows)
                .first(where: \.isKeyWindow)?
                .rootViewController
        }
    }
}
