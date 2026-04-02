import 'package:isar_community/isar.dart';

part 'article_record.g.dart';

/// Wiki 記事の既読・レビュー・お気に入りを保持する。
///
/// `url` は論理主キーとして一意インデックスを付与（Isar の `Id` は内部用）。
@collection
class ArticleRecord {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String url;

  String title = '';

  /// 0.0〜5.0（0.1 刻みは UI 側で制御）
  double rating = 0;

  bool isFavorited = false;

  String memo = '';

  DateTime lastRead = DateTime.now();
}
