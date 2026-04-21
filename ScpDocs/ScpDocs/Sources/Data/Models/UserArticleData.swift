import Foundation

/// 1 報告書あたりのユーザー状態（永続化は `ArticleRepository` が `UserDefaults` へ投影）。
struct UserArticleData: Equatable, Sendable {
    /// 0.0 は未評価（未接触）。既読は `ratingScore > 0` で定義する。
    var ratingScore: Double

    static let unrated: Double = 0.0
    static let minScore: Double = 0.0
    static let maxScore: Double = 5.0
    static let ratingStep: Double = 0.1

    var isRead: Bool { ratingScore > Self.unrated }

    static func clampedRating(_ value: Double) -> Double {
        let stepped = (value / ratingStep).rounded() * ratingStep
        return min(maxScore, max(minScore, stepped))
    }
}
