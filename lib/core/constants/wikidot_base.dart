/// SCP-JP Wikidot のベース URL（HTTP。サイト側の HTTPS 制限回避用）。
const String kWikidotJpBase = 'http://scp-jp.wikidot.com';

String wikidotAbsoluteUrl(String hrefOrUrl) {
  if (hrefOrUrl.startsWith('http://') || hrefOrUrl.startsWith('https://')) {
    return hrefOrUrl;
  }
  if (hrefOrUrl.startsWith('/')) {
    return '$kWikidotJpBase$hrefOrUrl';
  }
  return '$kWikidotJpBase/$hrefOrUrl';
}
