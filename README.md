# SCP docs

SCP財団ドキュメント閲覧アプリ（**Swift / SwiftUI・iOS**）。Flutter は使用しません。

## プロジェクト構成


| パス                | 内容                                            |
| ----------------- | --------------------------------------------- |
| `ScpDocs/`        | Xcode プロジェクト（`ScpDocs.xcodeproj`）と iOS アプリソース |
| `ScpDocsAndroid/` | 将来の Android（Kotlin）用の予約ディレクトリ（現時点ではコードなし）     |


## ビルドと実行

1. Xcode で `ScpDocs/ScpDocs.xcodeproj` を開く。
2. スキーム **ScpDocs**、実行先をシミュレータまたは実機に選び、Run（⌘R）。

コマンドライン例（シミュレータ向けビルド）:

```bash
cd ScpDocs
xcodebuild -scheme ScpDocs -destination 'generic/platform=iOS Simulator' -configuration Debug build
```

- **ターゲット名:** `ScpDocs`
- **最低 iOS:** 17.0

## 言語切り替え（l10n の確認）

`Localizable.strings` は `en`（英語）と `ja`（日本語）のバリアントです。**シミュレータ:** Settings → General → Language & Region → **iPhone Language** を English または 日本語に変更してアプリを再起動すると、ホーム画面のタイトルや支部名などの文言が切り替わります。

## ライセンス

（未設定）