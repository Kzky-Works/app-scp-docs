import SwiftUI

/// タブ内でナビ／スクロール領域と **レイヤーを分離** した広告専用帯。
/// `safeAreaInset` ではなく `VStack` の最下段に置くことで、SwiftUI のレイアウト計算と UIKit バナーの重なりを防ぐ。
struct AdBannerStripeContainer: View {
    var body: some View {
        ZStack {
            AppTheme.backgroundPrimary
            AdBannerView()
                .frame(height: AppTheme.adBannerContentHeight)
                .frame(maxWidth: .infinity)
                .clipped()
        }
        .frame(height: AppTheme.adBannerStripeHeight)
        .frame(maxWidth: .infinity)
        .compositingGroup()
        .clipped()
        .accessibilityElement(children: .contain)
    }
}
