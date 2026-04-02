// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'article_record.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetArticleRecordCollection on Isar {
  IsarCollection<ArticleRecord> get articleRecords => this.collection();
}

const ArticleRecordSchema = CollectionSchema(
  name: r'ArticleRecord',
  id: -4023429322039861048,
  properties: {
    r'isFavorited': PropertySchema(
      id: 0,
      name: r'isFavorited',
      type: IsarType.bool,
    ),
    r'lastRead': PropertySchema(
      id: 1,
      name: r'lastRead',
      type: IsarType.dateTime,
    ),
    r'memo': PropertySchema(id: 2, name: r'memo', type: IsarType.string),
    r'rating': PropertySchema(id: 3, name: r'rating', type: IsarType.double),
    r'title': PropertySchema(id: 4, name: r'title', type: IsarType.string),
    r'url': PropertySchema(id: 5, name: r'url', type: IsarType.string),
  },

  estimateSize: _articleRecordEstimateSize,
  serialize: _articleRecordSerialize,
  deserialize: _articleRecordDeserialize,
  deserializeProp: _articleRecordDeserializeProp,
  idName: r'id',
  indexes: {
    r'url': IndexSchema(
      id: -5756857009679432345,
      name: r'url',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'url',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _articleRecordGetId,
  getLinks: _articleRecordGetLinks,
  attach: _articleRecordAttach,
  version: '3.3.2',
);

int _articleRecordEstimateSize(
  ArticleRecord object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.memo.length * 3;
  bytesCount += 3 + object.title.length * 3;
  bytesCount += 3 + object.url.length * 3;
  return bytesCount;
}

void _articleRecordSerialize(
  ArticleRecord object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.isFavorited);
  writer.writeDateTime(offsets[1], object.lastRead);
  writer.writeString(offsets[2], object.memo);
  writer.writeDouble(offsets[3], object.rating);
  writer.writeString(offsets[4], object.title);
  writer.writeString(offsets[5], object.url);
}

ArticleRecord _articleRecordDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ArticleRecord();
  object.id = id;
  object.isFavorited = reader.readBool(offsets[0]);
  object.lastRead = reader.readDateTime(offsets[1]);
  object.memo = reader.readString(offsets[2]);
  object.rating = reader.readDouble(offsets[3]);
  object.title = reader.readString(offsets[4]);
  object.url = reader.readString(offsets[5]);
  return object;
}

P _articleRecordDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBool(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readDouble(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _articleRecordGetId(ArticleRecord object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _articleRecordGetLinks(ArticleRecord object) {
  return [];
}

void _articleRecordAttach(
  IsarCollection<dynamic> col,
  Id id,
  ArticleRecord object,
) {
  object.id = id;
}

extension ArticleRecordByIndex on IsarCollection<ArticleRecord> {
  Future<ArticleRecord?> getByUrl(String url) {
    return getByIndex(r'url', [url]);
  }

  ArticleRecord? getByUrlSync(String url) {
    return getByIndexSync(r'url', [url]);
  }

  Future<bool> deleteByUrl(String url) {
    return deleteByIndex(r'url', [url]);
  }

  bool deleteByUrlSync(String url) {
    return deleteByIndexSync(r'url', [url]);
  }

  Future<List<ArticleRecord?>> getAllByUrl(List<String> urlValues) {
    final values = urlValues.map((e) => [e]).toList();
    return getAllByIndex(r'url', values);
  }

  List<ArticleRecord?> getAllByUrlSync(List<String> urlValues) {
    final values = urlValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'url', values);
  }

  Future<int> deleteAllByUrl(List<String> urlValues) {
    final values = urlValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'url', values);
  }

  int deleteAllByUrlSync(List<String> urlValues) {
    final values = urlValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'url', values);
  }

  Future<Id> putByUrl(ArticleRecord object) {
    return putByIndex(r'url', object);
  }

  Id putByUrlSync(ArticleRecord object, {bool saveLinks = true}) {
    return putByIndexSync(r'url', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByUrl(List<ArticleRecord> objects) {
    return putAllByIndex(r'url', objects);
  }

  List<Id> putAllByUrlSync(
    List<ArticleRecord> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'url', objects, saveLinks: saveLinks);
  }
}

extension ArticleRecordQueryWhereSort
    on QueryBuilder<ArticleRecord, ArticleRecord, QWhere> {
  QueryBuilder<ArticleRecord, ArticleRecord, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ArticleRecordQueryWhere
    on QueryBuilder<ArticleRecord, ArticleRecord, QWhereClause> {
  QueryBuilder<ArticleRecord, ArticleRecord, QAfterWhereClause> idEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<ArticleRecord, ArticleRecord, QAfterWhereClause> idNotEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<ArticleRecord, ArticleRecord, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ArticleRecord, ArticleRecord, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ArticleRecord, ArticleRecord, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<ArticleRecord, ArticleRecord, QAfterWhereClause> urlEqualTo(
    String url,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'url', value: [url]),
      );
    });
  }

  QueryBuilder<ArticleRecord, ArticleRecord, QAfterWhereClause> urlNotEqualTo(
    String url,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'url',
                lower: [],
                upper: [url],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'url',
                lower: [url],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'url',
                lower: [url],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'url',
                lower: [],
                upper: [url],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension ArticleRecordQueryFilter
    on QueryBuilder<ArticleRecord, ArticleRecord, QFilterCondition> {
  QueryBuilder<ArticleRecord, ArticleRecord, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<ArticleRecord, ArticleRecord, QAfterFilterCondition>
  idGreaterThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ArticleRecord, ArticleRecord, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ArticleRecord, ArticleRecord, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<ArticleRecord, ArticleRecord, QAfterFilterCondition>
  isFavoritedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isFavorited', value: value),
      );
    });
  }

  QueryBuilder<ArticleRecord, ArticleRecord, QAfterFilterCondition>
  lastReadEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lastRead', value: value),
      );
    });
  }

  QueryBuilder<ArticleRecord, ArticleRecord, QAfterFilterCondition>
  lastReadGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'lastRead',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ArticleRecord, ArticleRecord, QAfterFilterCondition>
  lastReadLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'lastRead',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ArticleRecord, ArticleRecord, QAfterFilterCondition>
  lastReadBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'lastRead',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<ArticleRecord, ArticleRecord, QAfterFilterCondition> memoEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'memo',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ArticleRecord, ArticleRecord, QAfterFilterCondition>
  memoGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'memo',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ArticleRecord, ArticleRecord, QAfterFilterCondition>
  memoLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'memo',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ArticleRecord, ArticleRecord, QAfterFilterCondition> memoBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'memo',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ArticleRecord, ArticleRecord, QAfterFilterCondition>
  memoStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'memo',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ArticleRecord, ArticleRecord, QAfterFilterCondition>
  memoEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'memo',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ArticleRecord, ArticleRecord, QAfterFilterCondition>
  memoContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'memo',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ArticleRecord, ArticleRecord, QAfterFilterCondition> memoMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'memo',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ArticleRecord, ArticleRecord, QAfterFilterCondition>
  memoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'memo', value: ''),
      );
    });
  }

  QueryBuilder<ArticleRecord, ArticleRecord, QAfterFilterCondition>
  memoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'memo', value: ''),
      );
    });
  }

  QueryBuilder<ArticleRecord, ArticleRecord, QAfterFilterCondition>
  ratingEqualTo(double value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'rating',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<ArticleRecord, ArticleRecord, QAfterFilterCondition>
  ratingGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'rating',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<ArticleRecord, ArticleRecord, QAfterFilterCondition>
  ratingLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'rating',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<ArticleRecord, ArticleRecord, QAfterFilterCondition>
  ratingBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'rating',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<ArticleRecord, ArticleRecord, QAfterFilterCondition>
  titleEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ArticleRecord, ArticleRecord, QAfterFilterCondition>
  titleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ArticleRecord, ArticleRecord, QAfterFilterCondition>
  titleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ArticleRecord, ArticleRecord, QAfterFilterCondition>
  titleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'title',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ArticleRecord, ArticleRecord, QAfterFilterCondition>
  titleStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ArticleRecord, ArticleRecord, QAfterFilterCondition>
  titleEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ArticleRecord, ArticleRecord, QAfterFilterCondition>
  titleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ArticleRecord, ArticleRecord, QAfterFilterCondition>
  titleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'title',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ArticleRecord, ArticleRecord, QAfterFilterCondition>
  titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'title', value: ''),
      );
    });
  }

  QueryBuilder<ArticleRecord, ArticleRecord, QAfterFilterCondition>
  titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'title', value: ''),
      );
    });
  }

  QueryBuilder<ArticleRecord, ArticleRecord, QAfterFilterCondition> urlEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'url',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ArticleRecord, ArticleRecord, QAfterFilterCondition>
  urlGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'url',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ArticleRecord, ArticleRecord, QAfterFilterCondition> urlLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'url',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ArticleRecord, ArticleRecord, QAfterFilterCondition> urlBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'url',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ArticleRecord, ArticleRecord, QAfterFilterCondition>
  urlStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'url',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ArticleRecord, ArticleRecord, QAfterFilterCondition> urlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'url',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ArticleRecord, ArticleRecord, QAfterFilterCondition> urlContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'url',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ArticleRecord, ArticleRecord, QAfterFilterCondition> urlMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'url',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ArticleRecord, ArticleRecord, QAfterFilterCondition>
  urlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'url', value: ''),
      );
    });
  }

  QueryBuilder<ArticleRecord, ArticleRecord, QAfterFilterCondition>
  urlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'url', value: ''),
      );
    });
  }
}

extension ArticleRecordQueryObject
    on QueryBuilder<ArticleRecord, ArticleRecord, QFilterCondition> {}

extension ArticleRecordQueryLinks
    on QueryBuilder<ArticleRecord, ArticleRecord, QFilterCondition> {}

extension ArticleRecordQuerySortBy
    on QueryBuilder<ArticleRecord, ArticleRecord, QSortBy> {
  QueryBuilder<ArticleRecord, ArticleRecord, QAfterSortBy> sortByIsFavorited() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFavorited', Sort.asc);
    });
  }

  QueryBuilder<ArticleRecord, ArticleRecord, QAfterSortBy>
  sortByIsFavoritedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFavorited', Sort.desc);
    });
  }

  QueryBuilder<ArticleRecord, ArticleRecord, QAfterSortBy> sortByLastRead() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastRead', Sort.asc);
    });
  }

  QueryBuilder<ArticleRecord, ArticleRecord, QAfterSortBy>
  sortByLastReadDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastRead', Sort.desc);
    });
  }

  QueryBuilder<ArticleRecord, ArticleRecord, QAfterSortBy> sortByMemo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'memo', Sort.asc);
    });
  }

  QueryBuilder<ArticleRecord, ArticleRecord, QAfterSortBy> sortByMemoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'memo', Sort.desc);
    });
  }

  QueryBuilder<ArticleRecord, ArticleRecord, QAfterSortBy> sortByRating() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rating', Sort.asc);
    });
  }

  QueryBuilder<ArticleRecord, ArticleRecord, QAfterSortBy> sortByRatingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rating', Sort.desc);
    });
  }

  QueryBuilder<ArticleRecord, ArticleRecord, QAfterSortBy> sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<ArticleRecord, ArticleRecord, QAfterSortBy> sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<ArticleRecord, ArticleRecord, QAfterSortBy> sortByUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'url', Sort.asc);
    });
  }

  QueryBuilder<ArticleRecord, ArticleRecord, QAfterSortBy> sortByUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'url', Sort.desc);
    });
  }
}

extension ArticleRecordQuerySortThenBy
    on QueryBuilder<ArticleRecord, ArticleRecord, QSortThenBy> {
  QueryBuilder<ArticleRecord, ArticleRecord, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ArticleRecord, ArticleRecord, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ArticleRecord, ArticleRecord, QAfterSortBy> thenByIsFavorited() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFavorited', Sort.asc);
    });
  }

  QueryBuilder<ArticleRecord, ArticleRecord, QAfterSortBy>
  thenByIsFavoritedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFavorited', Sort.desc);
    });
  }

  QueryBuilder<ArticleRecord, ArticleRecord, QAfterSortBy> thenByLastRead() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastRead', Sort.asc);
    });
  }

  QueryBuilder<ArticleRecord, ArticleRecord, QAfterSortBy>
  thenByLastReadDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastRead', Sort.desc);
    });
  }

  QueryBuilder<ArticleRecord, ArticleRecord, QAfterSortBy> thenByMemo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'memo', Sort.asc);
    });
  }

  QueryBuilder<ArticleRecord, ArticleRecord, QAfterSortBy> thenByMemoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'memo', Sort.desc);
    });
  }

  QueryBuilder<ArticleRecord, ArticleRecord, QAfterSortBy> thenByRating() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rating', Sort.asc);
    });
  }

  QueryBuilder<ArticleRecord, ArticleRecord, QAfterSortBy> thenByRatingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rating', Sort.desc);
    });
  }

  QueryBuilder<ArticleRecord, ArticleRecord, QAfterSortBy> thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<ArticleRecord, ArticleRecord, QAfterSortBy> thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<ArticleRecord, ArticleRecord, QAfterSortBy> thenByUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'url', Sort.asc);
    });
  }

  QueryBuilder<ArticleRecord, ArticleRecord, QAfterSortBy> thenByUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'url', Sort.desc);
    });
  }
}

extension ArticleRecordQueryWhereDistinct
    on QueryBuilder<ArticleRecord, ArticleRecord, QDistinct> {
  QueryBuilder<ArticleRecord, ArticleRecord, QDistinct>
  distinctByIsFavorited() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isFavorited');
    });
  }

  QueryBuilder<ArticleRecord, ArticleRecord, QDistinct> distinctByLastRead() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastRead');
    });
  }

  QueryBuilder<ArticleRecord, ArticleRecord, QDistinct> distinctByMemo({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'memo', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ArticleRecord, ArticleRecord, QDistinct> distinctByRating() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'rating');
    });
  }

  QueryBuilder<ArticleRecord, ArticleRecord, QDistinct> distinctByTitle({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ArticleRecord, ArticleRecord, QDistinct> distinctByUrl({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'url', caseSensitive: caseSensitive);
    });
  }
}

extension ArticleRecordQueryProperty
    on QueryBuilder<ArticleRecord, ArticleRecord, QQueryProperty> {
  QueryBuilder<ArticleRecord, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ArticleRecord, bool, QQueryOperations> isFavoritedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isFavorited');
    });
  }

  QueryBuilder<ArticleRecord, DateTime, QQueryOperations> lastReadProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastRead');
    });
  }

  QueryBuilder<ArticleRecord, String, QQueryOperations> memoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'memo');
    });
  }

  QueryBuilder<ArticleRecord, double, QQueryOperations> ratingProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'rating');
    });
  }

  QueryBuilder<ArticleRecord, String, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }

  QueryBuilder<ArticleRecord, String, QQueryOperations> urlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'url');
    });
  }
}
