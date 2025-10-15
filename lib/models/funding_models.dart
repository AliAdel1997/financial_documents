import 'package:isar/isar.dart';

part 'funding_models.g.dart';

/// نموذج الباب التمويلي (الرئيسي أو الفرعي)
@collection
class FundingCategory {
  Id id = Isar.autoIncrement;
  
  @Index()
  late String name;
  
  int? parentId; // يشير إلى الباب الأعلى
  
  String? description; // وصف الباب (اختياري)
  
  DateTime? createdAt;
  DateTime? updatedAt;

  FundingCategory();

  /// إنشاء نسخة محدثة من الكائن
  FundingCategory copyWith({
    Id? id,
    String? name,
    int? parentId,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FundingCategory()
      ..id = id ?? this.id
      ..name = name ?? this.name
      ..parentId = parentId ?? this.parentId
      ..description = description ?? this.description
      ..createdAt = createdAt ?? this.createdAt
      ..updatedAt = updatedAt ?? this.updatedAt;
  }

  @override
  String toString() {
    return 'FundingCategory{id: $id, name: $name, parentId: $parentId, description: $description}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FundingCategory &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// نموذج المؤسسة (المستشفى أو المؤسسة)
@collection
class Institution {
  Id id = Isar.autoIncrement;
  
  @Index()
  late String name;
  
  String? address;
  
  @Index()
  String? code;

  Institution();

  /// إنشاء نسخة محدثة من الكائن
  Institution copyWith({
    Id? id,
    String? name,
    String? address,
    String? code,
  }) {
    final institution = Institution()
      ..id = id ?? this.id
      ..name = name ?? this.name
      ..address = address ?? this.address
      ..code = code ?? this.code;
    return institution;
  }

  @override
  String toString() {
    return 'Institution{id: $id, name: $name, code: $code}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Institution &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// نموذج ربط المؤسسة بالباب التمويلي
@collection
class InstitutionFunding {
  Id id = Isar.autoIncrement;
  
  @Index()
  int institutionId = 0;
  
  @Index()
  int categoryId = 0;
  
  @Index()
  String fundingType = ''; // 'سنوي' أو 'شهري'
  
  double allocatedAmount = 0.0; // المبلغ المخصص
  double reservedAmount = 0.0; // المبلغ المحجوز
  double spentAmount = 0.0; // المبلغ المصروف
    
  String? executionAttachmentPath; // مسار مرفق تنفيذ الصرف (PDF)
  
  @Index()
  int year = 0;
  
  int? month; // الشهر (اختياري - فقط للتمويل الشهري)
  
  DateTime? createdAt;
  DateTime? updatedAt;

  InstitutionFunding();

  /// المبلغ المتبقي (محسوب تلقائياً)
  double get remainingAmount => allocatedAmount - reservedAmount - spentAmount;

  /// الحصول على اسم الشهر بالعربية
  String get monthName {
    if (month == null) return '';
    const monthNames = [
      '', 'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];
    return month! > 0 && month! <= 12 ? monthNames[month!] : '';
  }

  /// نص التمويل الكامل (النوع + السنة + الشهر)
  String get fundingPeriodText {
    if (fundingType == 'شهري' && month != null) {
      return '$fundingType - $monthName $year';
    }
    return '$fundingType - $year';
  }

  /// إنشاء نسخة محدثة من الكائن
  InstitutionFunding copyWith({
    Id? id,
    int? institutionId,
    int? categoryId,
    String? fundingType,
    double? allocatedAmount,
    double? reservedAmount,
    double? spentAmount,
    String? executionAttachmentPath,
    int? year,
    int? month,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final funding = InstitutionFunding()
      ..id = id ?? this.id
      ..institutionId = institutionId ?? this.institutionId
      ..categoryId = categoryId ?? this.categoryId
      ..fundingType = fundingType ?? this.fundingType
      ..allocatedAmount = allocatedAmount ?? this.allocatedAmount
      ..reservedAmount = reservedAmount ?? this.reservedAmount
      ..spentAmount = spentAmount ?? this.spentAmount
      ..executionAttachmentPath = executionAttachmentPath ?? this.executionAttachmentPath
      ..year = year ?? this.year
      ..month = month ?? this.month
      ..createdAt = createdAt ?? this.createdAt
      ..updatedAt = updatedAt ?? this.updatedAt;
    return funding;
  }

  @override
  String toString() {
    return 'InstitutionFunding{id: $id, institutionId: $institutionId, categoryId: $categoryId, '
        'allocatedAmount: $allocatedAmount, reservedAmount: $reservedAmount, spentAmount: $spentAmount, '
        'remainingAmount: $remainingAmount, year: $year, month: $month, fundingType: $fundingType}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InstitutionFunding &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// نموذج المرفقات المتعلقة بالتمويل
@collection
class FundingAttachment {
  Id id = Isar.autoIncrement;

  @Index()
  int? fundingId; // يرتبط بسجل InstitutionFunding
  
  String? fileName; // اسم الملف
  String? filePath; // المسار المحلي أو رابط التحميل
  String? fileType; // نوع الملف (pdf, jpg, docx...)
  
  @Index()
  DateTime? uploadedAt; // وقت الرفع
  
  String? description; // وصف أو ملاحظات عن الملف

  FundingAttachment();

  /// إنشاء نسخة محدثة من الكائن
  FundingAttachment copyWith({
    Id? id,
    int? fundingId,
    String? fileName,
    String? filePath,
    String? fileType,
    DateTime? uploadedAt,
    String? description,
  }) {
    final attachment = FundingAttachment()
      ..id = id ?? this.id
      ..fundingId = fundingId ?? this.fundingId
      ..fileName = fileName ?? this.fileName
      ..filePath = filePath ?? this.filePath
      ..fileType = fileType ?? this.fileType
      ..uploadedAt = uploadedAt ?? this.uploadedAt
      ..description = description ?? this.description;
    return attachment;
  }

  @override
  String toString() {
    return 'FundingAttachment{id: $id, fundingId: $fundingId, fileName: $fileName, fileType: $fileType, uploadedAt: $uploadedAt}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FundingAttachment &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// نموذج أرشفة عمليات الصرف والحجز
@collection
class FundingArchive {
  Id id = Isar.autoIncrement;

  @Index()
  int? fundingId; // يرتبط بسجل InstitutionFunding
  
  @Index()
  int? institutionId; // المؤسسة
  
  @Index()
  int? categoryId; // الباب
  
  late String operationType; // 'صرف' أو 'حجز'
  late double amount; // المبلغ
  
  String? description; // وصف العملية
  String? executionAttachmentPath; // مسار مرفق التنفيذ (PDF)
  
  @Index()
  late int year; // السنة
  
  @Index()
  late int month; // الشهر
  
  @Index()
  DateTime? executedAt; // وقت التنفيذ
  
  DateTime? createdAt;
  DateTime? updatedAt;

  FundingArchive();

  /// إنشاء نسخة محدثة من الكائن
  FundingArchive copyWith({
    Id? id,
    int? fundingId,
    int? institutionId,
    int? categoryId,
    String? operationType,
    double? amount,
    String? description,
    String? executionAttachmentPath,
    int? year,
    int? month,
    DateTime? executedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final archive = FundingArchive()
      ..id = id ?? this.id
      ..fundingId = fundingId ?? this.fundingId
      ..institutionId = institutionId ?? this.institutionId
      ..categoryId = categoryId ?? this.categoryId
      ..operationType = operationType ?? this.operationType
      ..amount = amount ?? this.amount
      ..description = description ?? this.description
      ..executionAttachmentPath = executionAttachmentPath ?? this.executionAttachmentPath
      ..year = year ?? this.year
      ..month = month ?? this.month
      ..executedAt = executedAt ?? this.executedAt
      ..createdAt = createdAt ?? this.createdAt
      ..updatedAt = updatedAt ?? this.updatedAt;
    return archive;
  }

  @override
  String toString() {
    return 'FundingArchive{id: $id, fundingId: $fundingId, operationType: $operationType, amount: $amount, executedAt: $executedAt}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FundingArchive &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// نموذج معاملة التمويل (طلب الحجز وتنفيذ الصرف)
@collection
class FundingTransaction {
  Id id = Isar.autoIncrement;

  @Index()
  int? fundingId; // يرتبط بسجل InstitutionFunding
  
  @Index()
  int? institutionId; // المؤسسة
  
  @Index()
  int? categoryId; // الباب
  
  @Index()
  late String status; // 'pending' (طلب حجز), 'executed' (منفذ), 'cancelled' (ملغي)
  
  late double requestedAmount; // المبلغ المطلوب حجزه
  double? executedAmount; // المبلغ المنفذ فعلياً (قد يختلف عن المطلوب)
  
  String? requestDescription; // وصف طلب الحجز
  String? executionDescription; // وصف تنفيذ الصرف
  
  String? reservationAttachmentPath; // مرفق طلب الحجز (PDF)
  String? executionAttachmentPath; // مرفق تنفيذ الصرف (PDF)
  
  @Index()
  DateTime? requestDate; // تاريخ طلب الحجز
  
  @Index()
  DateTime? executionDate; // تاريخ تنفيذ الصرف
  
  @Index()
  late int year; // السنة
  
  @Index()
  late int month; // الشهر
  
  DateTime? createdAt;
  DateTime? updatedAt;

  FundingTransaction();

  /// إنشاء نسخة محدثة من الكائن
  FundingTransaction copyWith({
    Id? id,
    int? fundingId,
    int? institutionId,
    int? categoryId,
    String? status,
    double? requestedAmount,
    double? executedAmount,
    String? requestDescription,
    String? executionDescription,
    String? reservationAttachmentPath,
    String? executionAttachmentPath,
    DateTime? requestDate,
    DateTime? executionDate,
    int? year,
    int? month,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final transaction = FundingTransaction()
      ..id = id ?? this.id
      ..fundingId = fundingId ?? this.fundingId
      ..institutionId = institutionId ?? this.institutionId
      ..categoryId = categoryId ?? this.categoryId
      ..status = status ?? this.status
      ..requestedAmount = requestedAmount ?? this.requestedAmount
      ..executedAmount = executedAmount ?? this.executedAmount
      ..requestDescription = requestDescription ?? this.requestDescription
      ..executionDescription = executionDescription ?? this.executionDescription
      ..reservationAttachmentPath = reservationAttachmentPath ?? this.reservationAttachmentPath
      ..executionAttachmentPath = executionAttachmentPath ?? this.executionAttachmentPath
      ..requestDate = requestDate ?? this.requestDate
      ..executionDate = executionDate ?? this.executionDate
      ..year = year ?? this.year
      ..month = month ?? this.month
      ..createdAt = createdAt ?? this.createdAt
      ..updatedAt = updatedAt ?? this.updatedAt;
    return transaction;
  }

  /// نص الحالة بالعربية
  String get statusText {
    switch (status) {
      case 'pending':
        return 'طلب حجز';
      case 'executed':
        return 'منفذ';
      case 'cancelled':
        return 'ملغي';
      default:
        return 'غير محدد';
    }
  }

  @override
  String toString() {
    return 'FundingTransaction{id: $id, fundingId: $fundingId, status: $status, requestedAmount: $requestedAmount, requestDate: $requestDate}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FundingTransaction &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}