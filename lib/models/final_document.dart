import 'package:isar/isar.dart';

part 'final_document.g.dart';

@Collection()
class FinalDocument {
  Id id = Isar.autoIncrement;

  // معلومات المصدر (من المسودة)
  late int draftId; // معرف المسودة الأصلية
  
  // معلومات المستند الرسمي
  late String documentNumber; // رقم الصادر
  late DateTime issueDate; // تاريخ الصادر
  
  // معلومات الجهة
  late String entityName; // اسم الجهة
  late String entityIban; // رقم الحساب
  String? entityEmail; // البريد الإلكتروني
  String? entityPhone; // رقم الهاتف
  String? entityAddress; // العنوان
  
  // معلومات المبلغ
  late double amount; // المبلغ رقماً
  late String amountInWords; // المبلغ كتابةً (التفقيط)
  
  // معلومات المؤسسة
  late String organizationBankName; // اسم المصرف الخاص بالمؤسسة
  String? organizationName; // اسم المؤسسة
  String? organizationAddress; // عنوان المؤسسة
  
  // معلومات المستند
  late String documentType; // نوع المستند
  late int month; // الشهر
  late int year; // السنة
  String? purpose; // الغرض
  String? notes; // ملاحظات
  
  // QR Code ومعلومات التشفير
  late String qrCodeData; // البيانات المشفرة في QR
  String? digitalSignature; // التوقيع الرقمي
  String? verificationHash; // هاش التحقق
  
  // معلومات التتبع
  DateTime createdAt = DateTime.now();
  DateTime? printedAt; // تاريخ الطباعة
  int printCount = 0; // عدد مرات الطباعة
  
  // حالة المستند
  @Enumerated(EnumType.name)
  FinalDocumentStatus status = FinalDocumentStatus.issued;
  
  // Constructor
  FinalDocument();
  
  // Named constructor from draft
  FinalDocument.fromDraft({
    required this.draftId,
    required this.documentNumber,
    required this.entityName,
    required this.entityIban,
    required this.amount,
    required this.amountInWords,
    required this.organizationBankName,
    required this.documentType,
    required this.month,
    required this.year,
    this.entityEmail,
    this.entityPhone,
    this.entityAddress,
    this.organizationName,
    this.organizationAddress,
    this.purpose,
    this.notes,
    DateTime? issueDate,
  }) {
    this.issueDate = issueDate ?? DateTime.now();
    _generateQRCodeData();
    _generateVerificationHash();
  }
  
  // Generate QR Code data
  void _generateQRCodeData() {
    final data = {
      'docNum': documentNumber,
      'entity': entityName,
      'amount': amount,
      'date': issueDate.toIso8601String(),
      'type': documentType,
      'org': organizationName ?? '',
    };
    
    // Convert to compact string for QR code
    qrCodeData = data.entries
        .map((e) => '${e.key}:${e.value}')
        .join('|');
  }
  
  // Generate verification hash
  void _generateVerificationHash() {
    final hashData = '$documentNumber$entityName$amount${issueDate.millisecondsSinceEpoch}';
    verificationHash = hashData.hashCode.toString();
  }
  
  // Update print information
  void markAsPrinted() {
    printedAt = DateTime.now();
    printCount++;
    status = FinalDocumentStatus.printed;
  }
  
  // Validate document
  bool isValid() {
    return documentNumber.isNotEmpty &&
           entityName.isNotEmpty &&
           entityIban.isNotEmpty &&
           amount > 0 &&
           amountInWords.isNotEmpty &&
           organizationBankName.isNotEmpty &&
           documentType.isNotEmpty &&
           qrCodeData.isNotEmpty;
  }
  
  // Get formatted document number
  String get formattedDocumentNumber {
    return 'صادر رقم: $documentNumber';
  }
  
  // Get formatted issue date
  String get formattedIssueDate {
    return 'التاريخ: ${issueDate.day}/${issueDate.month}/${issueDate.year}';
  }
  
  // Get formatted amount
  String get formattedAmount {
    return amount.toStringAsFixed(2) + ' ريال';
  }
  
  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'draftId': draftId,
      'documentNumber': documentNumber,
      'issueDate': issueDate.toIso8601String(),
      'entityName': entityName,
      'entityIban': entityIban,
      'entityEmail': entityEmail,
      'entityPhone': entityPhone,
      'entityAddress': entityAddress,
      'amount': amount,
      'amountInWords': amountInWords,
      'organizationBankName': organizationBankName,
      'organizationName': organizationName,
      'organizationAddress': organizationAddress,
      'documentType': documentType,
      'month': month,
      'year': year,
      'purpose': purpose,
      'notes': notes,
      'qrCodeData': qrCodeData,
      'digitalSignature': digitalSignature,
      'verificationHash': verificationHash,
      'createdAt': createdAt.toIso8601String(),
      'printedAt': printedAt?.toIso8601String(),
      'printCount': printCount,
      'status': status.toString().split('.').last,
    };
  }
  
  // Create from JSON
  static FinalDocument fromJson(Map<String, dynamic> json) {
    final doc = FinalDocument();
    doc.id = json['id'] ?? Isar.autoIncrement;
    doc.draftId = json['draftId'] ?? 0;
    doc.documentNumber = json['documentNumber'] ?? '';
    doc.issueDate = json['issueDate'] != null 
        ? DateTime.parse(json['issueDate'])
        : DateTime.now();
    doc.entityName = json['entityName'] ?? '';
    doc.entityIban = json['entityIban'] ?? '';
    doc.entityEmail = json['entityEmail'];
    doc.entityPhone = json['entityPhone'];
    doc.entityAddress = json['entityAddress'];
    doc.amount = (json['amount'] ?? 0).toDouble();
    doc.amountInWords = json['amountInWords'] ?? '';
    doc.organizationBankName = json['organizationBankName'] ?? '';
    doc.organizationName = json['organizationName'];
    doc.organizationAddress = json['organizationAddress'];
    doc.documentType = json['documentType'] ?? '';
    doc.month = json['month'] ?? 1;
    doc.year = json['year'] ?? DateTime.now().year;
    doc.purpose = json['purpose'];
    doc.notes = json['notes'];
    doc.qrCodeData = json['qrCodeData'] ?? '';
    doc.digitalSignature = json['digitalSignature'];
    doc.verificationHash = json['verificationHash'];
    doc.createdAt = json['createdAt'] != null 
        ? DateTime.parse(json['createdAt'])
        : DateTime.now();
    doc.printedAt = json['printedAt'] != null 
        ? DateTime.parse(json['printedAt'])
        : null;
    doc.printCount = json['printCount'] ?? 0;
    doc.status = FinalDocumentStatus.values.firstWhere(
      (e) => e.toString().split('.').last == json['status'],
      orElse: () => FinalDocumentStatus.issued,
    );
    return doc;
  }
}

enum FinalDocumentStatus {
  issued,    // صادر
  printed,   // مطبوع
  delivered, // مسلم
  archived,  // مؤرشف
  cancelled  // ملغي
}

// Extension for Arabic translations
extension FinalDocumentExtension on FinalDocument {
  String get monthNameArabic {
    const arabicMonths = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];
    return month >= 1 && month <= 12 ? arabicMonths[month - 1] : '';
  }
  
  String get statusNameArabic {
    switch (status) {
      case FinalDocumentStatus.issued:
        return 'صادر';
      case FinalDocumentStatus.printed:
        return 'مطبوع';
      case FinalDocumentStatus.delivered:
        return 'مسلم';
      case FinalDocumentStatus.archived:
        return 'مؤرشف';
      case FinalDocumentStatus.cancelled:
        return 'ملغي';
    }
  }
  
  String get documentTypeArabic {
    switch (documentType.toLowerCase()) {
      case 'deductions':
        return 'استقطاعات';
      case 'payments':
        return 'مدفوعات';
      case 'transfers':
        return 'تحويلات';
      default:
        return documentType;
    }
  }
  
  // Get full document title for PDF
  String get documentTitle {
    return 'مستند ${documentTypeArabic} - $monthNameArabic $year';
  }
  
  // Get verification URL (for QR code scanning)
  String get verificationUrl {
    return 'https://verify.example.com/doc/$documentNumber?hash=$verificationHash';
  }
}