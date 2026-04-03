/// Wikidot 閲覧用: ヘッダー・サイドバーを隠し、本文エリアを広げる。
class WikiReadabilityScript {
  WikiReadabilityScript._();

  /// 読み込み完了後に [WebViewController.runJavaScript] で実行する。
  static String inject() => '''
(function(){
  var hid = 'scp-reader-hide-chrome';
  if (document.getElementById(hid)) return;
  var style = document.createElement('style');
  style.id = hid;
  style.textContent = '#header,#side-bar{display:none!important;}';
  document.head.appendChild(style);
  var main = document.querySelector('#main-content');
  if (main) {
    main.style.margin = '0';
    main.style.padding = '12px';
    main.style.maxWidth = '100%';
    main.style.boxSizing = 'border-box';
  }
})();
''';
}
