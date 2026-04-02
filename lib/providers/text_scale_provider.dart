import 'package:flutter_riverpod/flutter_riverpod.dart';

/// WebView 内の文字サイズ（WebKit テキストサイズ調整のパーセント）。
final textScalePercentProvider =
    NotifierProvider<TextScaleNotifier, double>(TextScaleNotifier.new);

class TextScaleNotifier extends Notifier<double> {
  @override
  double build() => 100;

  void setPercent(double percent) {
    state = percent.clamp(75, 200);
  }
}
