import SwiftUI

struct SeriesBrowserView: View {
    let item: ScpJpSeriesItem

    var body: some View {
        WikiWebView(url: item.url)
            .navigationTitle(item.label)
            .navigationBarTitleDisplayMode(.inline)
    }
}
