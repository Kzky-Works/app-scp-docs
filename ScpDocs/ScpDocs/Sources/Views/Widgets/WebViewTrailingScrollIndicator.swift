import SwiftUI
import UIKit
import WebKit

/// `WKWebView` の `scrollView` に追従する右端の縦スクロールインジケータ（常時表示）。
struct WebViewTrailingScrollIndicator: UIViewRepresentable {
    @Bindable var viewModel: WebViewModel

    func makeUIView(context: Context) -> TrailingScrollBarUIView {
        TrailingScrollBarUIView()
    }

    func updateUIView(_ uiView: TrailingScrollBarUIView, context: Context) {
        uiView.bind(to: viewModel.webView)
    }
}

// MARK: - UIKit

final class TrailingScrollBarUIView: UIView {
    private let thumbLayer = CALayer()
    private weak var scrollView: UIScrollView?
    private var observations: [NSKeyValueObservation] = []

    private let thumbWidth: CGFloat = 4
    private let trailingMargin: CGFloat = 3
    private let minimumThumbHeight: CGFloat = 36

    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
        backgroundColor = .clear
        thumbLayer.cornerRadius = thumbWidth / 2
        layer.addSublayer(thumbLayer)
        applyThumbColor()
        registerForTraitChanges([UITraitUserInterfaceStyle.self]) { [weak self] (_: TrailingScrollBarUIView, _: UITraitCollection) in
            self?.applyThumbColor()
            self?.refresh()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        observations.removeAll()
    }

    func bind(to webView: WKWebView?) {
        observations.removeAll()
        scrollView = webView?.scrollView
        guard let sv = scrollView else {
            thumbLayer.isHidden = true
            return
        }

        let opts: NSKeyValueObservingOptions = [.initial, .new]
        observations = [
            sv.observe(\.contentOffset, options: opts) { [weak self] _, _ in
                self?.scheduleRefresh()
            },
            sv.observe(\.contentSize, options: opts) { [weak self] _, _ in
                self?.scheduleRefresh()
            },
            sv.observe(\.bounds, options: opts) { [weak self] _, _ in
                self?.scheduleRefresh()
            }
        ]
        refresh()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        refresh()
    }

    private func scheduleRefresh() {
        DispatchQueue.main.async { [weak self] in
            self?.refresh()
        }
    }

    private func applyThumbColor() {
        thumbLayer.backgroundColor = AppTheme.accentPrimaryUIKit
            .resolvedColor(with: traitCollection)
            .withAlphaComponent(0.5)
            .cgColor
    }

    private func refresh() {
        guard let sv = scrollView else {
            thumbLayer.isHidden = true
            return
        }

        let contentH = sv.contentSize.height
        let visibleH = sv.bounds.height
        let naturalScrollable = max(contentH - visibleH, 0)
        let bottomChrome = sv.adjustedContentInset.bottom
        let scrollable = max(naturalScrollable + bottomChrome, 0)
        guard scrollable > 0.5 else {
            thumbLayer.isHidden = true
            return
        }

        let scrollableForProgress = max(scrollable, 1)
        let progress = min(max(sv.contentOffset.y / scrollableForProgress, 0), 1)
        let thumbH = max(minimumThumbHeight, bounds.height * (visibleH / contentH))
        let maxY = max(bounds.height - thumbH, 0)
        let y = progress * maxY
        let x = bounds.width - thumbWidth - trailingMargin

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        thumbLayer.frame = CGRect(x: x, y: y, width: thumbWidth, height: thumbH)
        CATransaction.commit()
        thumbLayer.isHidden = false
    }
}
