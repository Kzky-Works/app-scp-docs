import SwiftUI

struct ContentView: View {
    @State private var sheetItem: ScpJpSeriesItem?
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                Color.black.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(ScpJpSeriesCatalog.items) { item in
                            seriesRow(item)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 20)
                }
            }
            .navigationTitle("SCP Docs")
            .toolbarBackground(.black, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .navigationDestination(for: ScpJpSeriesItem.self) { item in
                SeriesBrowserView(item: item)
            }
            .sheet(item: $sheetItem) { item in
                OpenChoiceSheet(
                    item: item,
                    onInApp: {
                        sheetItem = nil
                        path.append(item)
                    },
                    onExternal: {
                        UIApplication.shared.open(item.url)
                        sheetItem = nil
                    },
                    onDismiss: { sheetItem = nil }
                )
                .presentationDetents([.medium])
            }
        }
        .preferredColorScheme(.dark)
    }

    @ViewBuilder
    private func seriesRow(_ item: ScpJpSeriesItem) -> some View {
        Button {
            sheetItem = item
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text(item.label)
                        .font(.headline)
                        .foregroundStyle(.white)
                    Text(item.rangeDescription)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.7))
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(Color(white: 0.45))
            }
            .padding(18)
            .background(Color(white: 0.11))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}

private struct OpenChoiceSheet: View {
    let item: ScpJpSeriesItem
    let onInApp: () -> Void
    let onExternal: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text(item.label)
                    .font(.title3.weight(.semibold))
                Text(item.rangeDescription)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(item.url.absoluteString)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .textSelection(.enabled)

                VStack(spacing: 10) {
                    Button(action: onInApp) {
                        Label("アプリ内の WebView で開く", systemImage: "safari")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color(white: 0.35))

                    Button(action: onExternal) {
                        Label("外部ブラウザで開く", systemImage: "arrow.up.right.square")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.top, 8)

                Spacer(minLength: 0)
            }
            .padding()
            .navigationTitle("開き方")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("閉じる", action: onDismiss)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
