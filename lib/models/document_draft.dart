import 'package:isar/isar.dart';

part 'document_draft.g.dart';

@Collection()
class DocumentDraft {
  Id id = Isar.autoIncrement;

  // معلومات أساسية
  late String entityName; // اسم الجهة
  late double amount; // المبلغ
  late String documentType; // نوع المستند (استقطاعات، مدفوعات، etc.)
  late int month; // الشهر
  late int year; // السنة
  
  // معلومات إضافية من Excel
  String? purpose; // الغرض (اختياري)
  String? notes; // ملاحظات
  
  // معلومات الجهة (ستُجلب من جدول الجهات)
  String? entityIban;
  String? entityEmail;
  String? entityPhone;
  String? entityAddress;
  
  // معلومات المؤسسة
  String? organizationBankName; // اسم المصرف الخاص بالمؤسسة
  
  // معلومات التتبع
  DateTime createdAt = DateTime.now();
  DateTime? updatedAt;
  
  // حالة المسودة
  @Enumerated(EnumType.name)
  DocumentDraftStatus status = DocumentDraftStatus.draft;
  
  // معرف المستند النهائي (إذا تم تحويله)
  String? finalDocumentId;
  
  // Constructor
  DocumentDraft();
  
  // Named constructor
  DocumentDraft.create({
    required this.entityName,
    required this.amount,
    required this.documentType,
    required this.month,
    required this.year,
    this.purpose,
    this.notes,
    this.organizationBankName,
  });
  
  // Method to update entity information
  void updateEntityInfo({
    String? iban,
    String? email,
    String? phone,
    String? address,
  }) {
    entityIban = iban;
    entityEmail = email;
    entityPhone = phone;
    entityAddress = address;
    updatedAt = DateTime.now();
  }
  
  // Method to get amount in words (Arabic)
  String getAmountInWords() {
    // سيتم تنفيذها في خدمة التفقيط
    return '';
  }
  
  // Method to validate draft
  bool isValid() {
    return entityName.isNotEmpty && 
           amount > 0 && 
           documentType.isNotEmpty &&
           month >= 1 && month <= 12 &&
           year > 0;
  }
  
  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'entityName': entityName,
      'amount': amount,
      'documentType': documentType,
      'month': month,
      'year': year,
      'purpose': purpose,
      'notes': notes,
      'entityIban': entityIban,
      'entityEmail': entityEmail,
      'entityPhone': entityPhone,
      'entityAddress': entityAddress,
      'organizationBankName': organizationBankName,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'status': status.toString().split('.').last,
      'finalDocumentId': finalDocumentId,
    };
  }
  
  // Create from JSON
  static DocumentDraft fromJson(Map<String, dynamic> json) {
    final draft = DocumentDraft();
    draft.id = json['id'] ?? Isar.autoIncrement;
    draft.entityName = json['entityName'] ?? '';
    draft.amount = (json['amount'] ?? 0).toDouble();
    draft.documentType = json['documentType'] ?? '';
    draft.month = json['month'] ?? 1;
    draft.year = json['year'] ?? DateTime.now().year;
    draft.purpose = json['purpose'];
    draft.notes = json['notes'];
    draft.entityIban = json['entityIban'];
    draft.entityEmail = json['entityEmail'];
    draft.entityPhone = json['entityPhone'];
    draft.entityAddress = json['entityAddress'];
    draft.organizationBankName = json['organizationBankName'];
    draft.createdAt = json['createdAt'] != null 
        ? DateTime.parse(json['createdAt'])
        : DateTime.now();
    draft.updatedAt = json['updatedAt'] != null 
        ? DateTime.parse(json['updatedAt'])
        : null;
    draft.status = DocumentDraftStatus.values.firstWhere(
      (e) => e.toString().split('.').last == json['status'],
      orElse: () => DocumentDraftStatus.draft,
    );
    draft.finalDocumentId = json['finalDocumentId'];
    return draft;
  }
}

enum DocumentDraftStatus {
  draft,     // مسودة
  reviewed,  // مراجعة
  approved,  // معتمدة
  printed,   // مطبوعة
  archived   // مؤرشفة
}

// Extension for Arabic month names
extension DocumentDraftExtension on DocumentDraft {
  String get monthNameArabic {
    const arabicMonths = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];
    return month >= 1 && month <= 12 ? arabicMonths[month - 1] : '';
  }
  
  String get statusNameArabic {
    switch (status) {
      case DocumentDraftStatus.draft:
        return 'مسودة';
      case DocumentDraftStatus.reviewed:
        return 'قيد المراجعة';
      case DocumentDraftStatus.approved:
        return 'معتمدة';
      case DocumentDraftStatus.printed:
        return 'مطبوعة';
      case DocumentDraftStatus.archived:
        return 'مؤرشفة';
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
}