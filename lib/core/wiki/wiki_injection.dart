/// Wikidot ページ向け JS/CSS 注入（スマホ閲覧用に UI を削る・文字サイズを変える）。
class WikiInjection {
  WikiInjection._();

  static const String hideSelectors =
      '#side-bar,#header,#footer,#license-area,.page-options-bottom';

  /// 初回ロード時にサイドバー等を非表示にする。
  static String hideChromeScript() => '''
(function(){
  var id = 'scp-docs-hide-ui';
  if (document.getElementById(id)) return;
  var style = document.createElement('style');
  style.id = id;
  style.textContent = '$hideSelectors{display:none!important;}';
  document.head.appendChild(style);
})();
''';

  /// `webkitTextSizeAdjust` で本文の文字サイズを変更（パーセント文字列）。
  static String textSizeScript(double percent) {
    final p = percent.clamp(75, 200).toStringAsFixed(0);
    return '''
(function(){
  var v = '$p%';
  if (document.body) document.body.style.webkitTextSizeAdjust = v;
  if (document.documentElement) document.documentElement.style.webkitTextSizeAdjust = v;
})();
''';
  }
}
