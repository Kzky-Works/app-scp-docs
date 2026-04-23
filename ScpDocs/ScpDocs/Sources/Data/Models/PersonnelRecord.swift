import Foundation
import SwiftData

/// 職員ダッシュボード用: 記事 URL（`ArticleRepository.storageKey` と同一キー）に紐づく閲覧セッション。
@Model
final class PersonnelRecord {
    @Attribute(.unique) var normalizedURLKey: String
    var lastAccessedAt: Date
    /// 0...1 のスクロール進捗（読了率）。既定では 95% 未満を「続きから読む」候補とする。
    var scrollProgress: Double
    /// 当該ページの累計滞在秒（セッション終了時に加算）。
    var totalReadingTimeSeconds: Double

    init(
        normalizedURLKey: String,
        lastAccessedAt: Date,
        scrollProgress: Double,
        totalReadingTimeSeconds: Double = 0
    ) {
        self.normalizedURLKey = normalizedURLKey
        self.lastAccessedAt = lastAccessedAt
        self.scrollProgress = scrollProgress
        self.totalReadingTimeSeconds = totalReadingTimeSeconds
    }
}
