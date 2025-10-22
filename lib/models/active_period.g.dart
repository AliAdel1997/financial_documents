// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'active_period.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetActivePeriodCollection on Isar {
  IsarCollection<ActivePeriod> get activePeriods => this.collection();
}

const ActivePeriodSchema = CollectionSchema(
  name: r'ActivePeriod',
  id: 484185606487900958,
  properties: {
    r'activeMonth': PropertySchema(
      id: 0,
      name: r'activeMonth',
      type: IsarType.long,
    ),
    r'activeYear': PropertySchema(
      id: 1,
      name: r'activeYear',
      type: IsarType.long,
    ),
    r'closedAt': PropertySchema(
      id: 2,
      name: r'closedAt',
      type: IsarType.dateTime,
    ),
    r'closedBy': PropertySchema(
      id: 3,
      name: r'closedBy',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 4,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'isActive': PropertySchema(
      id: 5,
      name: r'isActive',
      type: IsarType.bool,
    ),
    r'notes': PropertySchema(
      id: 6,
      name: r'notes',
      type: IsarType.string,
    ),
    r'openedAt': PropertySchema(
      id: 7,
      name: r'openedAt',
      type: IsarType.dateTime,
    ),
    r'openedBy': PropertySchema(
      id: 8,
      name: r'openedBy',
      type: IsarType.string,
    ),
    r'periodText': PropertySchema(
      id: 9,
      name: r'periodText',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 10,
      name: r'updatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _activePeriodEstimateSize,
  serialize: _activePeriodSerialize,
  deserialize: _activePeriodDeserialize,
  deserializeProp: _activePeriodDeserializeProp,
  idName: r'id',
  indexes: {
    r'activeYear': IndexSchema(
      id: 5324754263347749379,
      name: r'activeYear',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'activeYear',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'activeMonth': IndexSchema(
      id: 4976589277201837756,
      name: r'activeMonth',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'activeMonth',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _activePeriodGetId,
  getLinks: _activePeriodGetLinks,
  attach: _activePeriodAttach,
  version: '3.1.0+1',
);

int _activePeriodEstimateSize(
  ActivePeriod object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.closedBy;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.notes;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.openedBy;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.periodText.length * 3;
  return bytesCount;
}

void _activePeriodSerialize(
  ActivePeriod object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.activeMonth);
  writer.writeLong(offsets[1], object.activeYear);
  writer.writeDateTime(offsets[2], object.closedAt);
  writer.writeString(offsets[3], object.closedBy);
  writer.writeDateTime(offsets[4], object.createdAt);
  writer.writeBool(offsets[5], object.isActive);
  writer.writeString(offsets[6], object.notes);
  writer.writeDateTime(offsets[7], object.openedAt);
  writer.writeString(offsets[8], object.openedBy);
  writer.writeString(offsets[9], object.periodText);
  writer.writeDateTime(offsets[10], object.updatedAt);
}

ActivePeriod _activePeriodDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ActivePeriod();
  object.activeMonth = reader.readLong(offsets[0]);
  object.activeYear = reader.readLong(offsets[1]);
  object.closedAt = reader.readDateTimeOrNull(offsets[2]);
  object.closedBy = reader.readStringOrNull(offsets[3]);
  object.createdAt = reader.readDateTimeOrNull(offsets[4]);
  object.id = id;
  object.isActive = reader.readBool(offsets[5]);
  object.notes = reader.readStringOrNull(offsets[6]);
  object.openedAt = reader.readDateTimeOrNull(offsets[7]);
  object.openedBy = reader.readStringOrNull(offsets[8]);
  object.updatedAt = reader.readDateTimeOrNull(offsets[10]);
  return object;
}

P _activePeriodDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 5:
      return (reader.readBool(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readDateTimeOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _activePeriodGetId(ActivePeriod object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _activePeriodGetLinks(ActivePeriod object) {
  return [];
}

void _activePeriodAttach(
    IsarCollection<dynamic> col, Id id, ActivePeriod object) {
  object.id = id;
}

extension ActivePeriodQueryWhereSort
    on QueryBuilder<ActivePeriod, ActivePeriod, QWhere> {
  QueryBuilder<ActivePeriod, ActivePeriod, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterWhere> anyActiveYear() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'activeYear'),
      );
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterWhere> anyActiveMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'activeMonth'),
      );
    });
  }
}

extension ActivePeriodQueryWhere
    on QueryBuilder<ActivePeriod, ActivePeriod, QWhereClause> {
  QueryBuilder<ActivePeriod, ActivePeriod, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterWhereClause> idNotEqualTo(
      Id id) {
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

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterWhereClause> idBetween(
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

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterWhereClause> activeYearEqualTo(
      int activeYear) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'activeYear',
        value: [activeYear],
      ));
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterWhereClause>
      activeYearNotEqualTo(int activeYear) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'activeYear',
              lower: [],
              upper: [activeYear],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'activeYear',
              lower: [activeYear],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'activeYear',
              lower: [activeYear],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'activeYear',
              lower: [],
              upper: [activeYear],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterWhereClause>
      activeYearGreaterThan(
    int activeYear, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'activeYear',
        lower: [activeYear],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterWhereClause>
      activeYearLessThan(
    int activeYear, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'activeYear',
        lower: [],
        upper: [activeYear],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterWhereClause> activeYearBetween(
    int lowerActiveYear,
    int upperActiveYear, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'activeYear',
        lower: [lowerActiveYear],
        includeLower: includeLower,
        upper: [upperActiveYear],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterWhereClause>
      activeMonthEqualTo(int activeMonth) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'activeMonth',
        value: [activeMonth],
      ));
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterWhereClause>
      activeMonthNotEqualTo(int activeMonth) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'activeMonth',
              lower: [],
              upper: [activeMonth],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'activeMonth',
              lower: [activeMonth],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'activeMonth',
              lower: [activeMonth],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'activeMonth',
              lower: [],
              upper: [activeMonth],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterWhereClause>
      activeMonthGreaterThan(
    int activeMonth, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'activeMonth',
        lower: [activeMonth],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterWhereClause>
      activeMonthLessThan(
    int activeMonth, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'activeMonth',
        lower: [],
        upper: [activeMonth],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterWhereClause>
      activeMonthBetween(
    int lowerActiveMonth,
    int upperActiveMonth, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'activeMonth',
        lower: [lowerActiveMonth],
        includeLower: includeLower,
        upper: [upperActiveMonth],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension ActivePeriodQueryFilter
    on QueryBuilder<ActivePeriod, ActivePeriod, QFilterCondition> {
  QueryBuilder<ActivePeriod, ActivePeriod, QAfterFilterCondition>
      activeMonthEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'activeMonth',
        value: value,
      ));
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterFilterCondition>
      activeMonthGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'activeMonth',
        value: value,
      ));
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterFilterCondition>
      activeMonthLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'activeMonth',
        value: value,
      ));
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterFilterCondition>
      activeMonthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'activeMonth',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterFilterCondition>
      activeYearEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'activeYear',
        value: value,
      ));
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterFilterCondition>
      activeYearGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'activeYear',
        value: value,
      ));
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterFilterCondition>
      activeYearLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'activeYear',
        value: value,
      ));
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterFilterCondition>
      activeYearBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'activeYear',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterFilterCondition>
      closedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'closedAt',
      ));
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterFilterCondition>
      closedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'closedAt',
      ));
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterFilterCondition>
      closedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'closedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterFilterCondition>
      closedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'closedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterFilterCondition>
      closedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'closedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterFilterCondition>
      closedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'closedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterFilterCondition>
      closedByIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'closedBy',
      ));
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterFilterCondition>
      closedByIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'closedBy',
      ));
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterFilterCondition>
      closedByEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'closedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterFilterCondition>
      closedByGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'closedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterFilterCondition>
      closedByLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'closedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterFilterCondition>
      closedByBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'closedBy',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterFilterCondition>
      closedByStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'closedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterFilterCondition>
      closedByEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'closedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterFilterCondition>
      closedByContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'closedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterFilterCondition>
      closedByMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'closedBy',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterFilterCondition>
      closedByIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'closedBy',
        value: '',
      ));
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterFilterCondition>
      closedByIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'closedBy',
        value: '',
      ));
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterFilterCondition>
      createdAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'createdAt',
      ));
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterFilterCondition>
      createdAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'createdAt',
      ));
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterFilterCondition>
      createdAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterFilterCondition>
      createdAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterFilterCondition>
      createdAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterFilterCondition> idBetween(
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

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterFilterCondition>
      isActiveEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isActive',
        value: value,
      ));
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterFilterCondition>
      notesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterFilterCondition>
      notesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterFilterCondition> notesEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterFilterCondition>
      notesGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterFilterCondition> notesLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterFilterCondition> notesBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'notes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterFilterCondition>
      notesStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterFilterCondition> notesEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterFilterCondition> notesContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterFilterCondition> notesMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'notes',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterFilterCondition>
      notesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterFilterCondition>
      notesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterFilterCondition>
      openedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'openedAt',
      ));
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterFilterCondition>
      openedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'openedAt',
      ));
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterFilterCondition>
      openedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'openedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterFilterCondition>
      openedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'openedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterFilterCondition>
      openedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'openedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterFilterCondition>
      openedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'openedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterFilterCondition>
      openedByIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'openedBy',
      ));
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterFilterCondition>
      openedByIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'openedBy',
      ));
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterFilterCondition>
      openedByEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'openedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterFilterCondition>
      openedByGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'openedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterFilterCondition>
      openedByLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'openedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterFilterCondition>
      openedByBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'openedBy',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterFilterCondition>
      openedByStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'openedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterFilterCondition>
      openedByEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'openedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterFilterCondition>
      openedByContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'openedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterFilterCondition>
      openedByMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'openedBy',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterFilterCondition>
      openedByIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'openedBy',
        value: '',
      ));
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterFilterCondition>
      openedByIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'openedBy',
        value: '',
      ));
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterFilterCondition>
      periodTextEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'periodText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterFilterCondition>
      periodTextGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'periodText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterFilterCondition>
      periodTextLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'periodText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterFilterCondition>
      periodTextBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'periodText',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterFilterCondition>
      periodTextStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'periodText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterFilterCondition>
      periodTextEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'periodText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterFilterCondition>
      periodTextContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'periodText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterFilterCondition>
      periodTextMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'periodText',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterFilterCondition>
      periodTextIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'periodText',
        value: '',
      ));
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterFilterCondition>
      periodTextIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'periodText',
        value: '',
      ));
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterFilterCondition>
      updatedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'updatedAt',
      ));
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterFilterCondition>
      updatedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'updatedAt',
      ));
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterFilterCondition>
      updatedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterFilterCondition>
      updatedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterFilterCondition>
      updatedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterFilterCondition>
      updatedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'updatedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension ActivePeriodQueryObject
    on QueryBuilder<ActivePeriod, ActivePeriod, QFilterCondition> {}

extension ActivePeriodQueryLinks
    on QueryBuilder<ActivePeriod, ActivePeriod, QFilterCondition> {}

extension ActivePeriodQuerySortBy
    on QueryBuilder<ActivePeriod, ActivePeriod, QSortBy> {
  QueryBuilder<ActivePeriod, ActivePeriod, QAfterSortBy> sortByActiveMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeMonth', Sort.asc);
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterSortBy>
      sortByActiveMonthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeMonth', Sort.desc);
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterSortBy> sortByActiveYear() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeYear', Sort.asc);
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterSortBy>
      sortByActiveYearDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeYear', Sort.desc);
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterSortBy> sortByClosedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'closedAt', Sort.asc);
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterSortBy> sortByClosedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'closedAt', Sort.desc);
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterSortBy> sortByClosedBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'closedBy', Sort.asc);
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterSortBy> sortByClosedByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'closedBy', Sort.desc);
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterSortBy> sortByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.asc);
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterSortBy> sortByIsActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.desc);
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterSortBy> sortByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterSortBy> sortByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterSortBy> sortByOpenedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'openedAt', Sort.asc);
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterSortBy> sortByOpenedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'openedAt', Sort.desc);
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterSortBy> sortByOpenedBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'openedBy', Sort.asc);
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterSortBy> sortByOpenedByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'openedBy', Sort.desc);
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterSortBy> sortByPeriodText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'periodText', Sort.asc);
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterSortBy>
      sortByPeriodTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'periodText', Sort.desc);
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterSortBy> sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension ActivePeriodQuerySortThenBy
    on QueryBuilder<ActivePeriod, ActivePeriod, QSortThenBy> {
  QueryBuilder<ActivePeriod, ActivePeriod, QAfterSortBy> thenByActiveMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeMonth', Sort.asc);
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterSortBy>
      thenByActiveMonthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeMonth', Sort.desc);
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterSortBy> thenByActiveYear() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeYear', Sort.asc);
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterSortBy>
      thenByActiveYearDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeYear', Sort.desc);
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterSortBy> thenByClosedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'closedAt', Sort.asc);
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterSortBy> thenByClosedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'closedAt', Sort.desc);
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterSortBy> thenByClosedBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'closedBy', Sort.asc);
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterSortBy> thenByClosedByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'closedBy', Sort.desc);
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterSortBy> thenByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.asc);
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterSortBy> thenByIsActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.desc);
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterSortBy> thenByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterSortBy> thenByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterSortBy> thenByOpenedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'openedAt', Sort.asc);
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterSortBy> thenByOpenedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'openedAt', Sort.desc);
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterSortBy> thenByOpenedBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'openedBy', Sort.asc);
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterSortBy> thenByOpenedByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'openedBy', Sort.desc);
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterSortBy> thenByPeriodText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'periodText', Sort.asc);
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterSortBy>
      thenByPeriodTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'periodText', Sort.desc);
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QAfterSortBy> thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension ActivePeriodQueryWhereDistinct
    on QueryBuilder<ActivePeriod, ActivePeriod, QDistinct> {
  QueryBuilder<ActivePeriod, ActivePeriod, QDistinct> distinctByActiveMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'activeMonth');
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QDistinct> distinctByActiveYear() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'activeYear');
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QDistinct> distinctByClosedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'closedAt');
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QDistinct> distinctByClosedBy(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'closedBy', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QDistinct> distinctByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isActive');
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QDistinct> distinctByNotes(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notes', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QDistinct> distinctByOpenedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'openedAt');
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QDistinct> distinctByOpenedBy(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'openedBy', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QDistinct> distinctByPeriodText(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'periodText', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ActivePeriod, ActivePeriod, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension ActivePeriodQueryProperty
    on QueryBuilder<ActivePeriod, ActivePeriod, QQueryProperty> {
  QueryBuilder<ActivePeriod, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ActivePeriod, int, QQueryOperations> activeMonthProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'activeMonth');
    });
  }

  QueryBuilder<ActivePeriod, int, QQueryOperations> activeYearProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'activeYear');
    });
  }

  QueryBuilder<ActivePeriod, DateTime?, QQueryOperations> closedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'closedAt');
    });
  }

  QueryBuilder<ActivePeriod, String?, QQueryOperations> closedByProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'closedBy');
    });
  }

  QueryBuilder<ActivePeriod, DateTime?, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<ActivePeriod, bool, QQueryOperations> isActiveProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isActive');
    });
  }

  QueryBuilder<ActivePeriod, String?, QQueryOperations> notesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notes');
    });
  }

  QueryBuilder<ActivePeriod, DateTime?, QQueryOperations> openedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'openedAt');
    });
  }

  QueryBuilder<ActivePeriod, String?, QQueryOperations> openedByProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'openedBy');
    });
  }

  QueryBuilder<ActivePeriod, String, QQueryOperations> periodTextProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'periodText');
    });
  }

  QueryBuilder<ActivePeriod, DateTime?, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
