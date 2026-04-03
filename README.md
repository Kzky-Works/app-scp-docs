# SCP Docs / SCP Reader

リポジトリには **ネイティブ版**（`native/`）と、ルート直下の **SCP Reader プロトタイプ**（Flutter）が共存します。

## SCP Reader プロトタイプ（ルートの Flutter）

スプラッシュ → 7 カテゴリ → サブメニュー → `webview_flutter` で Wikidot 表示（ヘッダー／サイドバー非表示の JS 注入）、`Provider` + `shared_preferences` でお気に入り、`google_fonts`（Noto Sans JP）。

```bash
cd /Volumes/SSD_External/AppDev/Projects/scp_docs   # リポジトリルート
flutter pub get
flutter run
```

主なコード: `lib/main.dart`, `lib/screens/`, `lib/widgets/`, `lib/data/category_catalog.dart`

---

## SCP Docs（ネイティブ）

SCP-JP のシリーズ一覧をダークテーマで表示し、**アプリ内ブラウザ（WebView）** または **外部ブラウザ** で Wikidot を開く、**iOS / Android 向けのネイティブ**構成です。

## 構成

| ディレクトリ | 内容 |
|-------------|------|
| `native/ios/` | SwiftUI + `WKWebView`（Xcode プロジェクト） |
| `native/android/` | Jetpack Compose + `WebView`（Gradle プロジェクト） |

## iOS

1. `native/ios/ScpDocs.xcodeproj` を Xcode で開く。
2. 署名: ターゲット **ScpDocs** → **Signing & Capabilities** で Development Team を選択（実機の場合）。
3. 実行: シミュレータまたは実機を選び **Run**（⌘R）。

デプロイ目安: **iOS 16** 以上。

## Android

1. [Android Studio](https://developer.android.com/studio) で `native/android` フォルダを開く。
2. JDK 17 を使用（Android Studio 同梱で可）。
3. **Run** でエミュレータまたは実機にインストール。

ビルド例（ターミナル）:

```bash
cd native/android
./gradlew assembleDebug
```

## 注意

- Wikidot の一覧 URL は **HTTP** のため、両 OS で該当ドメイン向けの設定（ATS / Network Security Config）を入れています。
- シリーズ VI・VII は JP 専用の `scp-series-jp-6` が無いため、同サイト上の `scp-series-6` / `scp-series-7` を開きます。
