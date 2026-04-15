import 'dart:convert';

import 'package:http/http.dart' as http;

/// Wikidot ページ HTML を取得する（UTF-8）。
Future<String> fetchWikidotHtml(String url) async {
  final uri = Uri.parse(url);
  final res = await http.get(
    uri,
    headers: const {
      'User-Agent': 'SCP-Reader/1.0 (+https://github.com/kzkymr-afk/SCP_docs)',
      'Accept': 'text/html,application/xhtml+xml',
    },
  );
  if (res.statusCode != 200) {
    throw WikidotFetchException(
      'HTTP ${res.statusCode}',
      statusCode: res.statusCode,
    );
  }
  return utf8.decode(res.bodyBytes, allowMalformed: true);
}

class WikidotFetchException implements Exception {
  WikidotFetchException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'WikidotFetchException: $message';
}
