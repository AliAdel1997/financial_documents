// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'final_document.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetFinalDocumentCollection on Isar {
  IsarCollection<FinalDocument> get finalDocuments => this.collection();
}

const FinalDocumentSchema = CollectionSchema(
  name: r'FinalDocument',
  id: 7914759456987368976,
  properties: {
    r'amount': PropertySchema(
      id: 0,
      name: r'amount',
      type: IsarType.double,
    ),
    r'amountInWords': PropertySchema(
      id: 1,
      name: r'amountInWords',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 2,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'digitalSignature': PropertySchema(
      id: 3,
      name: r'digitalSignature',
      type: IsarType.string,
    ),
    r'documentNumber': PropertySchema(
      id: 4,
      name: r'documentNumber',
      type: IsarType.string,
    ),
    r'documentType': PropertySchema(
      id: 5,
      name: r'documentType',
      type: IsarType.string,
    ),
    r'draftId': PropertySchema(
      id: 6,
      name: r'draftId',
      type: IsarType.long,
    ),
    r'entityAddress': PropertySchema(
      id: 7,
      name: r'entityAddress',
      type: IsarType.string,
    ),
    r'entityEmail': PropertySchema(
      id: 8,
      name: r'entityEmail',
      type: IsarType.string,
    ),
    r'entityIban': PropertySchema(
      id: 9,
      name: r'entityIban',
      type: IsarType.string,
    ),
    r'entityName': PropertySchema(
      id: 10,
      name: r'entityName',
      type: IsarType.string,
    ),
    r'entityPhone': PropertySchema(
      id: 11,
      name: r'entityPhone',
      type: IsarType.string,
    ),
    r'formattedAmount': PropertySchema(
      id: 12,
      name: r'formattedAmount',
      type: IsarType.string,
    ),
    r'formattedDocumentNumber': PropertySchema(
      id: 13,
      name: r'formattedDocumentNumber',
      type: IsarType.string,
    ),
    r'formattedIssueDate': PropertySchema(
      id: 14,
      name: r'formattedIssueDate',
      type: IsarType.string,
    ),
    r'issueDate': PropertySchema(
      id: 15,
      name: r'issueDate',
      type: IsarType.dateTime,
    ),
    r'month': PropertySchema(
      id: 16,
      name: r'month',
      type: IsarType.long,
    ),
    r'notes': PropertySchema(
      id: 17,
      name: r'notes',
      type: IsarType.string,
    ),
    r'organizationAddress': PropertySchema(
      id: 18,
      name: r'organizationAddress',
      type: IsarType.string,
    ),
    r'organizationBankName': PropertySchema(
      id: 19,
      name: r'organizationBankName',
      type: IsarType.string,
    ),
    r'organizationName': PropertySchema(
      id: 20,
      name: r'organizationName',
      type: IsarType.string,
    ),
    r'printCount': PropertySchema(
      id: 21,
      name: r'printCount',
      type: IsarType.long,
    ),
    r'printedAt': PropertySchema(
      id: 22,
      name: r'printedAt',
      type: IsarType.dateTime,
    ),
    r'purpose': PropertySchema(
      id: 23,
      name: r'purpose',
      type: IsarType.string,
    ),
    r'qrCodeData': PropertySchema(
      id: 24,
      name: r'qrCodeData',
      type: IsarType.string,
    ),
    r'status': PropertySchema(
      id: 25,
      name: r'status',
      type: IsarType.string,
      enumMap: _FinalDocumentstatusEnumValueMap,
    ),
    r'verificationHash': PropertySchema(
      id: 26,
      name: r'verificationHash',
      type: IsarType.string,
    ),
    r'year': PropertySchema(
      id: 27,
      name: r'year',
      type: IsarType.long,
    )
  },
  estimateSize: _finalDocumentEstimateSize,
  serialize: _finalDocumentSerialize,
  deserialize: _finalDocumentDeserialize,
  deserializeProp: _finalDocumentDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _finalDocumentGetId,
  getLinks: _finalDocumentGetLinks,
  attach: _finalDocumentAttach,
  version: '3.1.0+1',
);

int _finalDocumentEstimateSize(
  FinalDocument object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.amountInWords.length * 3;
  {
    final value = object.digitalSignature;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.documentNumber.length * 3;
  bytesCount += 3 + object.documentType.length * 3;
  {
    final value = object.entityAddress;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.entityEmail;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.entityIban.length * 3;
  bytesCount += 3 + object.entityName.length * 3;
  {
    final value = object.entityPhone;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.formattedAmount.length * 3;
  bytesCount += 3 + object.formattedDocumentNumber.length * 3;
  bytesCount += 3 + object.formattedIssueDate.length * 3;
  {
    final value = object.notes;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.organizationAddress;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.organizationBankName.length * 3;
  {
    final value = object.organizationName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.purpose;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.qrCodeData.length * 3;
  bytesCount += 3 + object.status.name.length * 3;
  {
    final value = object.verificationHash;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _finalDocumentSerialize(
  FinalDocument object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.amount);
  writer.writeString(offsets[1], object.amountInWords);
  writer.writeDateTime(offsets[2], object.createdAt);
  writer.writeString(offsets[3], object.digitalSignature);
  writer.writeString(offsets[4], object.documentNumber);
  writer.writeString(offsets[5], object.documentType);
  writer.writeLong(offsets[6], object.draftId);
  writer.writeString(offsets[7], object.entityAddress);
  writer.writeString(offsets[8], object.entityEmail);
  writer.writeString(offsets[9], object.entityIban);
  writer.writeString(offsets[10], object.entityName);
  writer.writeString(offsets[11], object.entityPhone);
  writer.writeString(offsets[12], object.formattedAmount);
  writer.writeString(offsets[13], object.formattedDocumentNumber);
  writer.writeString(offsets[14], object.formattedIssueDate);
  writer.writeDateTime(offsets[15], object.issueDate);
  writer.writeLong(offsets[16], object.month);
  writer.writeString(offsets[17], object.notes);
  writer.writeString(offsets[18], object.organizationAddress);
  writer.writeString(offsets[19], object.organizationBankName);
  writer.writeString(offsets[20], object.organizationName);
  writer.writeLong(offsets[21], object.printCount);
  writer.writeDateTime(offsets[22], object.printedAt);
  writer.writeString(offsets[23], object.purpose);
  writer.writeString(offsets[24], object.qrCodeData);
  writer.writeString(offsets[25], object.status.name);
  writer.writeString(offsets[26], object.verificationHash);
  writer.writeLong(offsets[27], object.year);
}

FinalDocument _finalDocumentDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = FinalDocument();
  object.amount = reader.readDouble(offsets[0]);
  object.amountInWords = reader.readString(offsets[1]);
  object.createdAt = reader.readDateTime(offsets[2]);
  object.digitalSignature = reader.readStringOrNull(offsets[3]);
  object.documentNumber = reader.readString(offsets[4]);
  object.documentType = reader.readString(offsets[5]);
  object.draftId = reader.readLong(offsets[6]);
  object.entityAddress = reader.readStringOrNull(offsets[7]);
  object.entityEmail = reader.readStringOrNull(offsets[8]);
  object.entityIban = reader.readString(offsets[9]);
  object.entityName = reader.readString(offsets[10]);
  object.entityPhone = reader.readStringOrNull(offsets[11]);
  object.id = id;
  object.issueDate = reader.readDateTime(offsets[15]);
  object.month = reader.readLong(offsets[16]);
  object.notes = reader.readStringOrNull(offsets[17]);
  object.organizationAddress = reader.readStringOrNull(offsets[18]);
  object.organizationBankName = reader.readString(offsets[19]);
  object.organizationName = reader.readStringOrNull(offsets[20]);
  object.printCount = reader.readLong(offsets[21]);
  object.printedAt = reader.readDateTimeOrNull(offsets[22]);
  object.purpose = reader.readStringOrNull(offsets[23]);
  object.qrCodeData = reader.readString(offsets[24]);
  object.status =
      _FinalDocumentstatusValueEnumMap[reader.readStringOrNull(offsets[25])] ??
          FinalDocumentStatus.issued;
  object.verificationHash = reader.readStringOrNull(offsets[26]);
  object.year = reader.readLong(offsets[27]);
  return object;
}

P _finalDocumentDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader.readStringOrNull(offset)) as P;
    case 12:
      return (reader.readString(offset)) as P;
    case 13:
      return (reader.readString(offset)) as P;
    case 14:
      return (reader.readString(offset)) as P;
    case 15:
      return (reader.readDateTime(offset)) as P;
    case 16:
      return (reader.readLong(offset)) as P;
    case 17:
      return (reader.readStringOrNull(offset)) as P;
    case 18:
      return (reader.readStringOrNull(offset)) as P;
    case 19:
      return (reader.readString(offset)) as P;
    case 20:
      return (reader.readStringOrNull(offset)) as P;
    case 21:
      return (reader.readLong(offset)) as P;
    case 22:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 23:
      return (reader.readStringOrNull(offset)) as P;
    case 24:
      return (reader.readString(offset)) as P;
    case 25:
      return (_FinalDocumentstatusValueEnumMap[
              reader.readStringOrNull(offset)] ??
          FinalDocumentStatus.issued) as P;
    case 26:
      return (reader.readStringOrNull(offset)) as P;
    case 27:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _FinalDocumentstatusEnumValueMap = {
  r'issued': r'issued',
  r'printed': r'printed',
  r'delivered': r'delivered',
  r'archived': r'archived',
  r'cancelled': r'cancelled',
};
const _FinalDocumentstatusValueEnumMap = {
  r'issued': FinalDocumentStatus.issued,
  r'printed': FinalDocumentStatus.printed,
  r'delivered': FinalDocumentStatus.delivered,
  r'archived': FinalDocumentStatus.archived,
  r'cancelled': FinalDocumentStatus.cancelled,
};

Id _finalDocumentGetId(FinalDocument object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _finalDocumentGetLinks(FinalDocument object) {
  return [];
}

void _finalDocumentAttach(
    IsarCollection<dynamic> col, Id id, FinalDocument object) {
  object.id = id;
}

extension FinalDocumentQueryWhereSort
    on QueryBuilder<FinalDocument, FinalDocument, QWhere> {
  QueryBuilder<FinalDocument, FinalDocument, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension FinalDocumentQueryWhere
    on QueryBuilder<FinalDocument, FinalDocument, QWhereClause> {
  QueryBuilder<FinalDocument, FinalDocument, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<FinalDocument, FinalDocument, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterWhereClause> idBetween(
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

extension FinalDocumentQueryFilter
    on QueryBuilder<FinalDocument, FinalDocument, QFilterCondition> {
  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      amountEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'amount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      amountGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'amount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      amountLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'amount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      amountBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'amount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      amountInWordsEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'amountInWords',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      amountInWordsGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'amountInWords',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      amountInWordsLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'amountInWords',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      amountInWordsBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'amountInWords',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      amountInWordsStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'amountInWords',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      amountInWordsEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'amountInWords',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      amountInWordsContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'amountInWords',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      amountInWordsMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'amountInWords',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      amountInWordsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'amountInWords',
        value: '',
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      amountInWordsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'amountInWords',
        value: '',
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime value, {
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

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      createdAtLessThan(
    DateTime value, {
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

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      createdAtBetween(
    DateTime lower,
    DateTime upper, {
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

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      digitalSignatureIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'digitalSignature',
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      digitalSignatureIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'digitalSignature',
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      digitalSignatureEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'digitalSignature',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      digitalSignatureGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'digitalSignature',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      digitalSignatureLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'digitalSignature',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      digitalSignatureBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'digitalSignature',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      digitalSignatureStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'digitalSignature',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      digitalSignatureEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'digitalSignature',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      digitalSignatureContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'digitalSignature',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      digitalSignatureMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'digitalSignature',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      digitalSignatureIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'digitalSignature',
        value: '',
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      digitalSignatureIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'digitalSignature',
        value: '',
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      documentNumberEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'documentNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      documentNumberGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'documentNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      documentNumberLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'documentNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      documentNumberBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'documentNumber',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      documentNumberStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'documentNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      documentNumberEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'documentNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      documentNumberContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'documentNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      documentNumberMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'documentNumber',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      documentNumberIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'documentNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      documentNumberIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'documentNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      documentTypeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'documentType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      documentTypeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'documentType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      documentTypeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'documentType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      documentTypeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'documentType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      documentTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'documentType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      documentTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'documentType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      documentTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'documentType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      documentTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'documentType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      documentTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'documentType',
        value: '',
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      documentTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'documentType',
        value: '',
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      draftIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'draftId',
        value: value,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      draftIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'draftId',
        value: value,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      draftIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'draftId',
        value: value,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      draftIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'draftId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      entityAddressIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'entityAddress',
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      entityAddressIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'entityAddress',
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      entityAddressEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'entityAddress',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      entityAddressGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'entityAddress',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      entityAddressLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'entityAddress',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      entityAddressBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'entityAddress',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      entityAddressStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'entityAddress',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      entityAddressEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'entityAddress',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      entityAddressContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'entityAddress',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      entityAddressMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'entityAddress',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      entityAddressIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'entityAddress',
        value: '',
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      entityAddressIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'entityAddress',
        value: '',
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      entityEmailIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'entityEmail',
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      entityEmailIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'entityEmail',
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      entityEmailEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'entityEmail',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      entityEmailGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'entityEmail',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      entityEmailLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'entityEmail',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      entityEmailBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'entityEmail',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      entityEmailStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'entityEmail',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      entityEmailEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'entityEmail',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      entityEmailContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'entityEmail',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      entityEmailMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'entityEmail',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      entityEmailIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'entityEmail',
        value: '',
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      entityEmailIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'entityEmail',
        value: '',
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      entityIbanEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'entityIban',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      entityIbanGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'entityIban',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      entityIbanLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'entityIban',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      entityIbanBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'entityIban',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      entityIbanStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'entityIban',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      entityIbanEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'entityIban',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      entityIbanContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'entityIban',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      entityIbanMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'entityIban',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      entityIbanIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'entityIban',
        value: '',
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      entityIbanIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'entityIban',
        value: '',
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      entityNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'entityName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      entityNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'entityName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      entityNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'entityName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      entityNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'entityName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      entityNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'entityName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      entityNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'entityName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      entityNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'entityName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      entityNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'entityName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      entityNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'entityName',
        value: '',
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      entityNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'entityName',
        value: '',
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      entityPhoneIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'entityPhone',
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      entityPhoneIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'entityPhone',
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      entityPhoneEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'entityPhone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      entityPhoneGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'entityPhone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      entityPhoneLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'entityPhone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      entityPhoneBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'entityPhone',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      entityPhoneStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'entityPhone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      entityPhoneEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'entityPhone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      entityPhoneContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'entityPhone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      entityPhoneMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'entityPhone',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      entityPhoneIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'entityPhone',
        value: '',
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      entityPhoneIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'entityPhone',
        value: '',
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      formattedAmountEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'formattedAmount',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      formattedAmountGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'formattedAmount',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      formattedAmountLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'formattedAmount',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      formattedAmountBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'formattedAmount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      formattedAmountStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'formattedAmount',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      formattedAmountEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'formattedAmount',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      formattedAmountContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'formattedAmount',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      formattedAmountMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'formattedAmount',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      formattedAmountIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'formattedAmount',
        value: '',
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      formattedAmountIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'formattedAmount',
        value: '',
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      formattedDocumentNumberEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'formattedDocumentNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      formattedDocumentNumberGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'formattedDocumentNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      formattedDocumentNumberLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'formattedDocumentNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      formattedDocumentNumberBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'formattedDocumentNumber',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      formattedDocumentNumberStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'formattedDocumentNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      formattedDocumentNumberEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'formattedDocumentNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      formattedDocumentNumberContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'formattedDocumentNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      formattedDocumentNumberMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'formattedDocumentNumber',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      formattedDocumentNumberIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'formattedDocumentNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      formattedDocumentNumberIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'formattedDocumentNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      formattedIssueDateEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'formattedIssueDate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      formattedIssueDateGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'formattedIssueDate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      formattedIssueDateLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'formattedIssueDate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      formattedIssueDateBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'formattedIssueDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      formattedIssueDateStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'formattedIssueDate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      formattedIssueDateEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'formattedIssueDate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      formattedIssueDateContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'formattedIssueDate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      formattedIssueDateMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'formattedIssueDate',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      formattedIssueDateIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'formattedIssueDate',
        value: '',
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      formattedIssueDateIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'formattedIssueDate',
        value: '',
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      idGreaterThan(
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

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition> idBetween(
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

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      issueDateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'issueDate',
        value: value,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      issueDateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'issueDate',
        value: value,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      issueDateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'issueDate',
        value: value,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      issueDateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'issueDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      monthEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'month',
        value: value,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      monthGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'month',
        value: value,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      monthLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'month',
        value: value,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      monthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'month',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      notesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      notesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      notesEqualTo(
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

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
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

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      notesLessThan(
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

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      notesBetween(
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

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
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

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      notesEndsWith(
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

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      notesContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      notesMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'notes',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      notesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      notesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      organizationAddressIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'organizationAddress',
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      organizationAddressIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'organizationAddress',
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      organizationAddressEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'organizationAddress',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      organizationAddressGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'organizationAddress',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      organizationAddressLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'organizationAddress',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      organizationAddressBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'organizationAddress',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      organizationAddressStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'organizationAddress',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      organizationAddressEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'organizationAddress',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      organizationAddressContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'organizationAddress',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      organizationAddressMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'organizationAddress',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      organizationAddressIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'organizationAddress',
        value: '',
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      organizationAddressIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'organizationAddress',
        value: '',
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      organizationBankNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'organizationBankName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      organizationBankNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'organizationBankName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      organizationBankNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'organizationBankName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      organizationBankNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'organizationBankName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      organizationBankNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'organizationBankName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      organizationBankNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'organizationBankName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      organizationBankNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'organizationBankName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      organizationBankNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'organizationBankName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      organizationBankNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'organizationBankName',
        value: '',
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      organizationBankNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'organizationBankName',
        value: '',
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      organizationNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'organizationName',
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      organizationNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'organizationName',
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      organizationNameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'organizationName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      organizationNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'organizationName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      organizationNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'organizationName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      organizationNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'organizationName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      organizationNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'organizationName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      organizationNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'organizationName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      organizationNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'organizationName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      organizationNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'organizationName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      organizationNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'organizationName',
        value: '',
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      organizationNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'organizationName',
        value: '',
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      printCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'printCount',
        value: value,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      printCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'printCount',
        value: value,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      printCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'printCount',
        value: value,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      printCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'printCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      printedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'printedAt',
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      printedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'printedAt',
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      printedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'printedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      printedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'printedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      printedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'printedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      printedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'printedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      purposeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'purpose',
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      purposeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'purpose',
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      purposeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'purpose',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      purposeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'purpose',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      purposeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'purpose',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      purposeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'purpose',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      purposeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'purpose',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      purposeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'purpose',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      purposeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'purpose',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      purposeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'purpose',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      purposeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'purpose',
        value: '',
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      purposeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'purpose',
        value: '',
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      qrCodeDataEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'qrCodeData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      qrCodeDataGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'qrCodeData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      qrCodeDataLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'qrCodeData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      qrCodeDataBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'qrCodeData',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      qrCodeDataStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'qrCodeData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      qrCodeDataEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'qrCodeData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      qrCodeDataContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'qrCodeData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      qrCodeDataMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'qrCodeData',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      qrCodeDataIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'qrCodeData',
        value: '',
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      qrCodeDataIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'qrCodeData',
        value: '',
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      statusEqualTo(
    FinalDocumentStatus value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      statusGreaterThan(
    FinalDocumentStatus value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      statusLessThan(
    FinalDocumentStatus value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      statusBetween(
    FinalDocumentStatus lower,
    FinalDocumentStatus upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'status',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      statusStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      statusEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      statusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      statusMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'status',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      verificationHashIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'verificationHash',
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      verificationHashIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'verificationHash',
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      verificationHashEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'verificationHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      verificationHashGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'verificationHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      verificationHashLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'verificationHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      verificationHashBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'verificationHash',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      verificationHashStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'verificationHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      verificationHashEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'verificationHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      verificationHashContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'verificationHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      verificationHashMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'verificationHash',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      verificationHashIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'verificationHash',
        value: '',
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      verificationHashIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'verificationHash',
        value: '',
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition> yearEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'year',
        value: value,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      yearGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'year',
        value: value,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition>
      yearLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'year',
        value: value,
      ));
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterFilterCondition> yearBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'year',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension FinalDocumentQueryObject
    on QueryBuilder<FinalDocument, FinalDocument, QFilterCondition> {}

extension FinalDocumentQueryLinks
    on QueryBuilder<FinalDocument, FinalDocument, QFilterCondition> {}

extension FinalDocumentQuerySortBy
    on QueryBuilder<FinalDocument, FinalDocument, QSortBy> {
  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy> sortByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.asc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy> sortByAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.desc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy>
      sortByAmountInWords() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amountInWords', Sort.asc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy>
      sortByAmountInWordsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amountInWords', Sort.desc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy>
      sortByDigitalSignature() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'digitalSignature', Sort.asc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy>
      sortByDigitalSignatureDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'digitalSignature', Sort.desc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy>
      sortByDocumentNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documentNumber', Sort.asc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy>
      sortByDocumentNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documentNumber', Sort.desc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy>
      sortByDocumentType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documentType', Sort.asc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy>
      sortByDocumentTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documentType', Sort.desc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy> sortByDraftId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'draftId', Sort.asc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy> sortByDraftIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'draftId', Sort.desc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy>
      sortByEntityAddress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityAddress', Sort.asc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy>
      sortByEntityAddressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityAddress', Sort.desc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy> sortByEntityEmail() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityEmail', Sort.asc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy>
      sortByEntityEmailDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityEmail', Sort.desc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy> sortByEntityIban() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityIban', Sort.asc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy>
      sortByEntityIbanDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityIban', Sort.desc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy> sortByEntityName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityName', Sort.asc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy>
      sortByEntityNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityName', Sort.desc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy> sortByEntityPhone() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityPhone', Sort.asc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy>
      sortByEntityPhoneDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityPhone', Sort.desc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy>
      sortByFormattedAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'formattedAmount', Sort.asc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy>
      sortByFormattedAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'formattedAmount', Sort.desc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy>
      sortByFormattedDocumentNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'formattedDocumentNumber', Sort.asc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy>
      sortByFormattedDocumentNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'formattedDocumentNumber', Sort.desc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy>
      sortByFormattedIssueDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'formattedIssueDate', Sort.asc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy>
      sortByFormattedIssueDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'formattedIssueDate', Sort.desc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy> sortByIssueDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'issueDate', Sort.asc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy>
      sortByIssueDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'issueDate', Sort.desc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy> sortByMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'month', Sort.asc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy> sortByMonthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'month', Sort.desc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy> sortByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy> sortByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy>
      sortByOrganizationAddress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'organizationAddress', Sort.asc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy>
      sortByOrganizationAddressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'organizationAddress', Sort.desc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy>
      sortByOrganizationBankName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'organizationBankName', Sort.asc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy>
      sortByOrganizationBankNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'organizationBankName', Sort.desc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy>
      sortByOrganizationName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'organizationName', Sort.asc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy>
      sortByOrganizationNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'organizationName', Sort.desc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy> sortByPrintCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'printCount', Sort.asc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy>
      sortByPrintCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'printCount', Sort.desc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy> sortByPrintedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'printedAt', Sort.asc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy>
      sortByPrintedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'printedAt', Sort.desc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy> sortByPurpose() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'purpose', Sort.asc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy> sortByPurposeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'purpose', Sort.desc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy> sortByQrCodeData() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'qrCodeData', Sort.asc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy>
      sortByQrCodeDataDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'qrCodeData', Sort.desc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy> sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy> sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy>
      sortByVerificationHash() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verificationHash', Sort.asc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy>
      sortByVerificationHashDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verificationHash', Sort.desc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy> sortByYear() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'year', Sort.asc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy> sortByYearDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'year', Sort.desc);
    });
  }
}

extension FinalDocumentQuerySortThenBy
    on QueryBuilder<FinalDocument, FinalDocument, QSortThenBy> {
  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy> thenByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.asc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy> thenByAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.desc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy>
      thenByAmountInWords() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amountInWords', Sort.asc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy>
      thenByAmountInWordsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amountInWords', Sort.desc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy>
      thenByDigitalSignature() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'digitalSignature', Sort.asc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy>
      thenByDigitalSignatureDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'digitalSignature', Sort.desc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy>
      thenByDocumentNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documentNumber', Sort.asc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy>
      thenByDocumentNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documentNumber', Sort.desc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy>
      thenByDocumentType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documentType', Sort.asc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy>
      thenByDocumentTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documentType', Sort.desc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy> thenByDraftId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'draftId', Sort.asc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy> thenByDraftIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'draftId', Sort.desc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy>
      thenByEntityAddress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityAddress', Sort.asc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy>
      thenByEntityAddressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityAddress', Sort.desc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy> thenByEntityEmail() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityEmail', Sort.asc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy>
      thenByEntityEmailDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityEmail', Sort.desc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy> thenByEntityIban() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityIban', Sort.asc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy>
      thenByEntityIbanDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityIban', Sort.desc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy> thenByEntityName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityName', Sort.asc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy>
      thenByEntityNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityName', Sort.desc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy> thenByEntityPhone() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityPhone', Sort.asc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy>
      thenByEntityPhoneDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityPhone', Sort.desc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy>
      thenByFormattedAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'formattedAmount', Sort.asc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy>
      thenByFormattedAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'formattedAmount', Sort.desc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy>
      thenByFormattedDocumentNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'formattedDocumentNumber', Sort.asc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy>
      thenByFormattedDocumentNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'formattedDocumentNumber', Sort.desc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy>
      thenByFormattedIssueDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'formattedIssueDate', Sort.asc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy>
      thenByFormattedIssueDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'formattedIssueDate', Sort.desc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy> thenByIssueDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'issueDate', Sort.asc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy>
      thenByIssueDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'issueDate', Sort.desc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy> thenByMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'month', Sort.asc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy> thenByMonthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'month', Sort.desc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy> thenByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy> thenByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy>
      thenByOrganizationAddress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'organizationAddress', Sort.asc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy>
      thenByOrganizationAddressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'organizationAddress', Sort.desc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy>
      thenByOrganizationBankName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'organizationBankName', Sort.asc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy>
      thenByOrganizationBankNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'organizationBankName', Sort.desc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy>
      thenByOrganizationName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'organizationName', Sort.asc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy>
      thenByOrganizationNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'organizationName', Sort.desc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy> thenByPrintCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'printCount', Sort.asc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy>
      thenByPrintCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'printCount', Sort.desc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy> thenByPrintedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'printedAt', Sort.asc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy>
      thenByPrintedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'printedAt', Sort.desc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy> thenByPurpose() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'purpose', Sort.asc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy> thenByPurposeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'purpose', Sort.desc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy> thenByQrCodeData() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'qrCodeData', Sort.asc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy>
      thenByQrCodeDataDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'qrCodeData', Sort.desc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy> thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy> thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy>
      thenByVerificationHash() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verificationHash', Sort.asc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy>
      thenByVerificationHashDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verificationHash', Sort.desc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy> thenByYear() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'year', Sort.asc);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QAfterSortBy> thenByYearDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'year', Sort.desc);
    });
  }
}

extension FinalDocumentQueryWhereDistinct
    on QueryBuilder<FinalDocument, FinalDocument, QDistinct> {
  QueryBuilder<FinalDocument, FinalDocument, QDistinct> distinctByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'amount');
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QDistinct> distinctByAmountInWords(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'amountInWords',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QDistinct>
      distinctByDigitalSignature({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'digitalSignature',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QDistinct>
      distinctByDocumentNumber({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'documentNumber',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QDistinct> distinctByDocumentType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'documentType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QDistinct> distinctByDraftId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'draftId');
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QDistinct> distinctByEntityAddress(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'entityAddress',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QDistinct> distinctByEntityEmail(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'entityEmail', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QDistinct> distinctByEntityIban(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'entityIban', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QDistinct> distinctByEntityName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'entityName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QDistinct> distinctByEntityPhone(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'entityPhone', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QDistinct>
      distinctByFormattedAmount({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'formattedAmount',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QDistinct>
      distinctByFormattedDocumentNumber({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'formattedDocumentNumber',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QDistinct>
      distinctByFormattedIssueDate({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'formattedIssueDate',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QDistinct> distinctByIssueDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'issueDate');
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QDistinct> distinctByMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'month');
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QDistinct> distinctByNotes(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notes', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QDistinct>
      distinctByOrganizationAddress({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'organizationAddress',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QDistinct>
      distinctByOrganizationBankName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'organizationBankName',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QDistinct>
      distinctByOrganizationName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'organizationName',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QDistinct> distinctByPrintCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'printCount');
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QDistinct> distinctByPrintedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'printedAt');
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QDistinct> distinctByPurpose(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'purpose', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QDistinct> distinctByQrCodeData(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'qrCodeData', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QDistinct> distinctByStatus(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QDistinct>
      distinctByVerificationHash({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'verificationHash',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FinalDocument, FinalDocument, QDistinct> distinctByYear() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'year');
    });
  }
}

extension FinalDocumentQueryProperty
    on QueryBuilder<FinalDocument, FinalDocument, QQueryProperty> {
  QueryBuilder<FinalDocument, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<FinalDocument, double, QQueryOperations> amountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'amount');
    });
  }

  QueryBuilder<FinalDocument, String, QQueryOperations>
      amountInWordsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'amountInWords');
    });
  }

  QueryBuilder<FinalDocument, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<FinalDocument, String?, QQueryOperations>
      digitalSignatureProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'digitalSignature');
    });
  }

  QueryBuilder<FinalDocument, String, QQueryOperations>
      documentNumberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'documentNumber');
    });
  }

  QueryBuilder<FinalDocument, String, QQueryOperations> documentTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'documentType');
    });
  }

  QueryBuilder<FinalDocument, int, QQueryOperations> draftIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'draftId');
    });
  }

  QueryBuilder<FinalDocument, String?, QQueryOperations>
      entityAddressProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'entityAddress');
    });
  }

  QueryBuilder<FinalDocument, String?, QQueryOperations> entityEmailProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'entityEmail');
    });
  }

  QueryBuilder<FinalDocument, String, QQueryOperations> entityIbanProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'entityIban');
    });
  }

  QueryBuilder<FinalDocument, String, QQueryOperations> entityNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'entityName');
    });
  }

  QueryBuilder<FinalDocument, String?, QQueryOperations> entityPhoneProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'entityPhone');
    });
  }

  QueryBuilder<FinalDocument, String, QQueryOperations>
      formattedAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'formattedAmount');
    });
  }

  QueryBuilder<FinalDocument, String, QQueryOperations>
      formattedDocumentNumberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'formattedDocumentNumber');
    });
  }

  QueryBuilder<FinalDocument, String, QQueryOperations>
      formattedIssueDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'formattedIssueDate');
    });
  }

  QueryBuilder<FinalDocument, DateTime, QQueryOperations> issueDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'issueDate');
    });
  }

  QueryBuilder<FinalDocument, int, QQueryOperations> monthProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'month');
    });
  }

  QueryBuilder<FinalDocument, String?, QQueryOperations> notesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notes');
    });
  }

  QueryBuilder<FinalDocument, String?, QQueryOperations>
      organizationAddressProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'organizationAddress');
    });
  }

  QueryBuilder<FinalDocument, String, QQueryOperations>
      organizationBankNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'organizationBankName');
    });
  }

  QueryBuilder<FinalDocument, String?, QQueryOperations>
      organizationNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'organizationName');
    });
  }

  QueryBuilder<FinalDocument, int, QQueryOperations> printCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'printCount');
    });
  }

  QueryBuilder<FinalDocument, DateTime?, QQueryOperations> printedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'printedAt');
    });
  }

  QueryBuilder<FinalDocument, String?, QQueryOperations> purposeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'purpose');
    });
  }

  QueryBuilder<FinalDocument, String, QQueryOperations> qrCodeDataProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'qrCodeData');
    });
  }

  QueryBuilder<FinalDocument, FinalDocumentStatus, QQueryOperations>
      statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<FinalDocument, String?, QQueryOperations>
      verificationHashProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'verificationHash');
    });
  }

  QueryBuilder<FinalDocument, int, QQueryOperations> yearProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'year');
    });
  }
}
