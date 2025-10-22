import 'package:isar/isar.dart';

part 'deduction_record.g.dart';

/// أنواع الاستقطاعات
enum DeductionType {
  socialInsurance('تأمينات اجتماعية'),
  tax('ضرائب'),
  retirement('تقاعد'),
  healthInsurance('تأمين صحي'),
  other('أخرى');

  const DeductionType(this.displayName);
  final String displayName;
}

/// سجل استقطاع فردي
@collection
class DeductionRecord {
  Id id = Isar.autoIncrement;

  @Index()
  int? entityId; // جهة الاستقطاع

  @Index()
  late String employeeName; // اسم الموظف

  late String employeeId; // رقم الموظف

  @Enumerated(EnumType.name)
  late DeductionType type; // نوع الاستقطاع

  late double amount; // مبلغ الاستقطاع

  String? description; // وصف إضافي

  @Index()
  late int year; // السنة

  @Index()
  late int month; // الشهر

  @Index()
  late DateTime deductionDate; // تاريخ الاستقطاع

  DateTime createdAt = DateTime.now();
  DateTime? updatedAt;

  DeductionRecord({
    this.id = Isar.autoIncrement,
    this.entityId,
    required this.employeeName,
    required this.employeeId,
    required this.type,
    required this.amount,
    this.description,
    required this.year,
    required this.month,
    required this.deductionDate,
    this.updatedAt,
  });

  // تحويل إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'entityId': entityId,
      'employeeName': employeeName,
      'employeeId': employeeId,
      'type': type.toString().split('.').last,
      'amount': amount,
      'description': description,
      'year': year,
      'month': month,
      'deductionDate': deductionDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // إنشاء من JSON
  factory DeductionRecord.fromJson(Map<String, dynamic> json) {
    return DeductionRecord(
      id: json['id'] ?? Isar.autoIncrement,
      entityId: json['entityId'],
      employeeName: json['employeeName'] ?? '',
      employeeId: json['employeeId'] ?? '',
      type: DeductionType.values.firstWhere(
        (t) => t.toString().split('.').last == json['type'],
        orElse: () => DeductionType.other,
      ),
      amount: (json['amount'] ?? 0.0).toDouble(),
      description: json['description'],
      year: json['year'] ?? DateTime.now().year,
      month: json['month'] ?? DateTime.now().month,
      deductionDate: json['deductionDate'] != null
          ? DateTime.parse(json['deductionDate'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    )..createdAt = json['createdAt'] != null
        ? DateTime.parse(json['createdAt'])
        : DateTime.now();
  }

  @override
  String toString() => '$employeeName - ${type.displayName}: $amount د.ع';
}