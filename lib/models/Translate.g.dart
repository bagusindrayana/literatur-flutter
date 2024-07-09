// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Translate.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetTranslateCollection on Isar {
  IsarCollection<Translate> get translates => this.collection();
}

const TranslateSchema = CollectionSchema(
  name: r'Translate',
  id: 3217352911699210959,
  properties: {
    r'bookId': PropertySchema(
      id: 0,
      name: r'bookId',
      type: IsarType.long,
    ),
    r'fromLanguage': PropertySchema(
      id: 1,
      name: r'fromLanguage',
      type: IsarType.string,
    ),
    r'lastReadPosition': PropertySchema(
      id: 2,
      name: r'lastReadPosition',
      type: IsarType.string,
    ),
    r'prePrompt': PropertySchema(
      id: 3,
      name: r'prePrompt',
      type: IsarType.string,
    ),
    r'toLanguage': PropertySchema(
      id: 4,
      name: r'toLanguage',
      type: IsarType.string,
    )
  },
  estimateSize: _translateEstimateSize,
  serialize: _translateSerialize,
  deserialize: _translateDeserialize,
  deserializeProp: _translateDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _translateGetId,
  getLinks: _translateGetLinks,
  attach: _translateAttach,
  version: '3.1.0+1',
);

int _translateEstimateSize(
  Translate object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.fromLanguage;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.lastReadPosition;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.prePrompt;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.toLanguage;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _translateSerialize(
  Translate object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.bookId);
  writer.writeString(offsets[1], object.fromLanguage);
  writer.writeString(offsets[2], object.lastReadPosition);
  writer.writeString(offsets[3], object.prePrompt);
  writer.writeString(offsets[4], object.toLanguage);
}

Translate _translateDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Translate();
  object.bookId = reader.readLong(offsets[0]);
  object.fromLanguage = reader.readStringOrNull(offsets[1]);
  object.id = id;
  object.lastReadPosition = reader.readStringOrNull(offsets[2]);
  object.prePrompt = reader.readStringOrNull(offsets[3]);
  object.toLanguage = reader.readStringOrNull(offsets[4]);
  return object;
}

P _translateDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _translateGetId(Translate object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _translateGetLinks(Translate object) {
  return [];
}

void _translateAttach(IsarCollection<dynamic> col, Id id, Translate object) {
  object.id = id;
}

extension TranslateQueryWhereSort
    on QueryBuilder<Translate, Translate, QWhere> {
  QueryBuilder<Translate, Translate, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension TranslateQueryWhere
    on QueryBuilder<Translate, Translate, QWhereClause> {
  QueryBuilder<Translate, Translate, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<Translate, Translate, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<Translate, Translate, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Translate, Translate, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Translate, Translate, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension TranslateQueryFilter
    on QueryBuilder<Translate, Translate, QFilterCondition> {
  QueryBuilder<Translate, Translate, QAfterFilterCondition> bookIdEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bookId',
        value: value,
      ));
    });
  }

  QueryBuilder<Translate, Translate, QAfterFilterCondition> bookIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'bookId',
        value: value,
      ));
    });
  }

  QueryBuilder<Translate, Translate, QAfterFilterCondition> bookIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'bookId',
        value: value,
      ));
    });
  }

  QueryBuilder<Translate, Translate, QAfterFilterCondition> bookIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'bookId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Translate, Translate, QAfterFilterCondition>
      fromLanguageIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'fromLanguage',
      ));
    });
  }

  QueryBuilder<Translate, Translate, QAfterFilterCondition>
      fromLanguageIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'fromLanguage',
      ));
    });
  }

  QueryBuilder<Translate, Translate, QAfterFilterCondition> fromLanguageEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fromLanguage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Translate, Translate, QAfterFilterCondition>
      fromLanguageGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fromLanguage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Translate, Translate, QAfterFilterCondition>
      fromLanguageLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fromLanguage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Translate, Translate, QAfterFilterCondition> fromLanguageBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fromLanguage',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Translate, Translate, QAfterFilterCondition>
      fromLanguageStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'fromLanguage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Translate, Translate, QAfterFilterCondition>
      fromLanguageEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'fromLanguage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Translate, Translate, QAfterFilterCondition>
      fromLanguageContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'fromLanguage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Translate, Translate, QAfterFilterCondition> fromLanguageMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'fromLanguage',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Translate, Translate, QAfterFilterCondition>
      fromLanguageIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fromLanguage',
        value: '',
      ));
    });
  }

  QueryBuilder<Translate, Translate, QAfterFilterCondition>
      fromLanguageIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'fromLanguage',
        value: '',
      ));
    });
  }

  QueryBuilder<Translate, Translate, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Translate, Translate, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Translate, Translate, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Translate, Translate, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Translate, Translate, QAfterFilterCondition>
      lastReadPositionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastReadPosition',
      ));
    });
  }

  QueryBuilder<Translate, Translate, QAfterFilterCondition>
      lastReadPositionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastReadPosition',
      ));
    });
  }

  QueryBuilder<Translate, Translate, QAfterFilterCondition>
      lastReadPositionEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastReadPosition',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Translate, Translate, QAfterFilterCondition>
      lastReadPositionGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastReadPosition',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Translate, Translate, QAfterFilterCondition>
      lastReadPositionLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastReadPosition',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Translate, Translate, QAfterFilterCondition>
      lastReadPositionBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastReadPosition',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Translate, Translate, QAfterFilterCondition>
      lastReadPositionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'lastReadPosition',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Translate, Translate, QAfterFilterCondition>
      lastReadPositionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'lastReadPosition',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Translate, Translate, QAfterFilterCondition>
      lastReadPositionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'lastReadPosition',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Translate, Translate, QAfterFilterCondition>
      lastReadPositionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'lastReadPosition',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Translate, Translate, QAfterFilterCondition>
      lastReadPositionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastReadPosition',
        value: '',
      ));
    });
  }

  QueryBuilder<Translate, Translate, QAfterFilterCondition>
      lastReadPositionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'lastReadPosition',
        value: '',
      ));
    });
  }

  QueryBuilder<Translate, Translate, QAfterFilterCondition> prePromptIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'prePrompt',
      ));
    });
  }

  QueryBuilder<Translate, Translate, QAfterFilterCondition>
      prePromptIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'prePrompt',
      ));
    });
  }

  QueryBuilder<Translate, Translate, QAfterFilterCondition> prePromptEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'prePrompt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Translate, Translate, QAfterFilterCondition>
      prePromptGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'prePrompt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Translate, Translate, QAfterFilterCondition> prePromptLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'prePrompt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Translate, Translate, QAfterFilterCondition> prePromptBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'prePrompt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Translate, Translate, QAfterFilterCondition> prePromptStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'prePrompt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Translate, Translate, QAfterFilterCondition> prePromptEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'prePrompt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Translate, Translate, QAfterFilterCondition> prePromptContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'prePrompt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Translate, Translate, QAfterFilterCondition> prePromptMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'prePrompt',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Translate, Translate, QAfterFilterCondition> prePromptIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'prePrompt',
        value: '',
      ));
    });
  }

  QueryBuilder<Translate, Translate, QAfterFilterCondition>
      prePromptIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'prePrompt',
        value: '',
      ));
    });
  }

  QueryBuilder<Translate, Translate, QAfterFilterCondition> toLanguageIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'toLanguage',
      ));
    });
  }

  QueryBuilder<Translate, Translate, QAfterFilterCondition>
      toLanguageIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'toLanguage',
      ));
    });
  }

  QueryBuilder<Translate, Translate, QAfterFilterCondition> toLanguageEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'toLanguage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Translate, Translate, QAfterFilterCondition>
      toLanguageGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'toLanguage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Translate, Translate, QAfterFilterCondition> toLanguageLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'toLanguage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Translate, Translate, QAfterFilterCondition> toLanguageBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'toLanguage',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Translate, Translate, QAfterFilterCondition>
      toLanguageStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'toLanguage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Translate, Translate, QAfterFilterCondition> toLanguageEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'toLanguage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Translate, Translate, QAfterFilterCondition> toLanguageContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'toLanguage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Translate, Translate, QAfterFilterCondition> toLanguageMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'toLanguage',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Translate, Translate, QAfterFilterCondition>
      toLanguageIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'toLanguage',
        value: '',
      ));
    });
  }

  QueryBuilder<Translate, Translate, QAfterFilterCondition>
      toLanguageIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'toLanguage',
        value: '',
      ));
    });
  }
}

extension TranslateQueryObject
    on QueryBuilder<Translate, Translate, QFilterCondition> {}

extension TranslateQueryLinks
    on QueryBuilder<Translate, Translate, QFilterCondition> {}

extension TranslateQuerySortBy on QueryBuilder<Translate, Translate, QSortBy> {
  QueryBuilder<Translate, Translate, QAfterSortBy> sortByBookId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bookId', Sort.asc);
    });
  }

  QueryBuilder<Translate, Translate, QAfterSortBy> sortByBookIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bookId', Sort.desc);
    });
  }

  QueryBuilder<Translate, Translate, QAfterSortBy> sortByFromLanguage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fromLanguage', Sort.asc);
    });
  }

  QueryBuilder<Translate, Translate, QAfterSortBy> sortByFromLanguageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fromLanguage', Sort.desc);
    });
  }

  QueryBuilder<Translate, Translate, QAfterSortBy> sortByLastReadPosition() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReadPosition', Sort.asc);
    });
  }

  QueryBuilder<Translate, Translate, QAfterSortBy>
      sortByLastReadPositionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReadPosition', Sort.desc);
    });
  }

  QueryBuilder<Translate, Translate, QAfterSortBy> sortByPrePrompt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'prePrompt', Sort.asc);
    });
  }

  QueryBuilder<Translate, Translate, QAfterSortBy> sortByPrePromptDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'prePrompt', Sort.desc);
    });
  }

  QueryBuilder<Translate, Translate, QAfterSortBy> sortByToLanguage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'toLanguage', Sort.asc);
    });
  }

  QueryBuilder<Translate, Translate, QAfterSortBy> sortByToLanguageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'toLanguage', Sort.desc);
    });
  }
}

extension TranslateQuerySortThenBy
    on QueryBuilder<Translate, Translate, QSortThenBy> {
  QueryBuilder<Translate, Translate, QAfterSortBy> thenByBookId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bookId', Sort.asc);
    });
  }

  QueryBuilder<Translate, Translate, QAfterSortBy> thenByBookIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bookId', Sort.desc);
    });
  }

  QueryBuilder<Translate, Translate, QAfterSortBy> thenByFromLanguage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fromLanguage', Sort.asc);
    });
  }

  QueryBuilder<Translate, Translate, QAfterSortBy> thenByFromLanguageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fromLanguage', Sort.desc);
    });
  }

  QueryBuilder<Translate, Translate, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Translate, Translate, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Translate, Translate, QAfterSortBy> thenByLastReadPosition() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReadPosition', Sort.asc);
    });
  }

  QueryBuilder<Translate, Translate, QAfterSortBy>
      thenByLastReadPositionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReadPosition', Sort.desc);
    });
  }

  QueryBuilder<Translate, Translate, QAfterSortBy> thenByPrePrompt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'prePrompt', Sort.asc);
    });
  }

  QueryBuilder<Translate, Translate, QAfterSortBy> thenByPrePromptDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'prePrompt', Sort.desc);
    });
  }

  QueryBuilder<Translate, Translate, QAfterSortBy> thenByToLanguage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'toLanguage', Sort.asc);
    });
  }

  QueryBuilder<Translate, Translate, QAfterSortBy> thenByToLanguageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'toLanguage', Sort.desc);
    });
  }
}

extension TranslateQueryWhereDistinct
    on QueryBuilder<Translate, Translate, QDistinct> {
  QueryBuilder<Translate, Translate, QDistinct> distinctByBookId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bookId');
    });
  }

  QueryBuilder<Translate, Translate, QDistinct> distinctByFromLanguage(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fromLanguage', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Translate, Translate, QDistinct> distinctByLastReadPosition(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastReadPosition',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Translate, Translate, QDistinct> distinctByPrePrompt(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'prePrompt', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Translate, Translate, QDistinct> distinctByToLanguage(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'toLanguage', caseSensitive: caseSensitive);
    });
  }
}

extension TranslateQueryProperty
    on QueryBuilder<Translate, Translate, QQueryProperty> {
  QueryBuilder<Translate, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Translate, int, QQueryOperations> bookIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bookId');
    });
  }

  QueryBuilder<Translate, String?, QQueryOperations> fromLanguageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fromLanguage');
    });
  }

  QueryBuilder<Translate, String?, QQueryOperations>
      lastReadPositionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastReadPosition');
    });
  }

  QueryBuilder<Translate, String?, QQueryOperations> prePromptProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'prePrompt');
    });
  }

  QueryBuilder<Translate, String?, QQueryOperations> toLanguageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'toLanguage');
    });
  }
}
