/// アプリ内アセットパス（[pubspec.yaml] の `flutter.assets` と一致させる）。
abstract final class AppAssets {
  AppAssets._();

  /// ホームタブ用 SCP ロゴ。差し替え時は同パスに PNG（推奨）または透過 PNG を置く。
  static const String scpHomeIcon = 'assets/images/scp_home_icon.png';
}
