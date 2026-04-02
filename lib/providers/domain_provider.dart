import 'package:flutter_riverpod/flutter_riverpod.dart';

/// デフォルトは日本語 Wiki（jp）。
const String kDefaultWikiDomain = 'scp-jp.wikidot.com';

/// 閲覧対象の Wikidot サブドメイン（例: `scp-jp.wikidot.com`）。
final domainProvider =
    NotifierProvider<DomainNotifier, String>(DomainNotifier.new);

class DomainNotifier extends Notifier<String> {
  @override
  String build() => kDefaultWikiDomain;

  void setDomain(String domain) {
    final trimmed = domain.trim();
    if (trimmed.isEmpty) return;
    state = trimmed;
  }
}
