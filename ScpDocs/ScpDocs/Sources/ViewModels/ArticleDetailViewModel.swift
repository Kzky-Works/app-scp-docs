import Foundation
import Observation
import UIKit

/// 記事詳細のレーティング・自動アーカイブ（スクロール深度は View / `WebViewModel` から渡す）。
@MainActor
@Observable
final class ArticleDetailViewModel {
    private let articleRepository: ArticleRepository
    private let articleURL: URL

    /// 自動 L3.0 を一度だけ適用するためのフラグ（同一セッション内で二重適用しない）。
    private var didApplyAutoArchive = false

    /// トースト用（ローカライズキーではなく本文を保持しない — View がキーから組み立てる）。
    var transientToastToken: UInt64 = 0
    /// 自動 L3.0 適用時に評価バーを開くための通知。
    var ratingBarRevealToken: UInt64 = 0

    init(articleRepository: ArticleRepository, articleURL: URL) {
        self.articleRepository = articleRepository
        self.articleURL = articleURL
    }

    /// WebView のスクロール進捗（0...1）。85% 到達かつ未評価なら L3.0（既読）を書き込み、触覚・トースト・評価バーを促す。
    func handleScrollDepthFraction(_ fraction: Double) {
        guard !didApplyAutoArchive else { return }
        guard fraction >= ArticleDetailViewModel.autoReadCompletionThreshold else { return }
        guard articleRepository.ratingScore(for: articleURL) == UserArticleData.unrated else { return }

        didApplyAutoArchive = true
        articleRepository.setRatingScore(3.0, for: articleURL)
        Haptics.medium()
        transientToastToken += 1
        ratingBarRevealToken += 1
    }

    /// Step 3: 自動読了（収容完了）しきい値。ネイティブ `UIScrollView` の進捗と一致。
    static let autoReadCompletionThreshold: Double = 0.85
}
