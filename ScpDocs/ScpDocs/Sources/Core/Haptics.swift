import UIKit

enum Haptics {
    static func light() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    static func medium() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    /// 連続値 UI（レーティングスライダーなど）の細かい刻み。
    static func selection() {
        UISelectionFeedbackGenerator().selectionChanged()
    }

    /// 0.5 刻みなど少し強い区切り。
    static func selectionAccent() {
        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
    }
}
