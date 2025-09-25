import 'package:isar/isar.dart';

part 'document.g.dart';

@collection
class Document {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  int? outgoingNumber; // رقم الصادر

  DateTime? documentDate; // تاريخ المستند

  double? amount; // المبلغ (رقماً)
  
  String? amountInWords; // المبلغ (كتابة)

  String? departmentIban; // ايبان الدائرة

  String? recipientIban; // ايبان الجهة المراد التحويل اليها

  String? recipientAddress; // عنوان الجهة

  String? documentDetails; // تفاصيل الكتاب

  @Enumerated(EnumType.name)
  DocumentStatus status = DocumentStatus.notUploaded; // مرفوع او غير مرفوع

  DateTime? uploadDate; // تاريخ الرفع
  
  String? bankNotificationNumber; // رقم الإشعار البنكي

  String? qrCodeData; // بيانات QR Code

  bool isEncrypted = false; // هل المستند مشفر

  String? encryptedContent; // المحتوى المشفر

  // للطباعة المتعددة
  String? batchId; // معرف الدفعة

  DateTime? printedDate; // تاريخ الطباعة

  bool isPrinted = false; // هل تم طباعته

  // للتتبع
  DateTime? createdAt; // تاريخ الإنشاء

  DateTime? updatedAt; // آخر تعديل

  String? remarks; // ملاحظات إضافية

  Document({
    this.outgoingNumber,
    this.documentDate,
    this.amount,
    this.amountInWords,
    this.departmentIban,
    this.recipientIban,
    this.recipientAddress,
    this.documentDetails,
    this.status = DocumentStatus.notUploaded,
    this.uploadDate,
    this.bankNotificationNumber,
    this.qrCodeData,
    this.isEncrypted = false,
    this.encryptedContent,
    this.batchId,
    this.printedDate,
    this.isPrinted = false,
    this.createdAt,
    this.updatedAt,
    this.remarks,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'outgoingNumber': outgoingNumber,
      'documentDate': documentDate?.toIso8601String(),
      'amount': amount,
      'amountInWords': amountInWords,
      'departmentIban': departmentIban,
      'recipientIban': recipientIban,
      'recipientAddress': recipientAddress,
      'documentDetails': documentDetails,
      'status': status.name,
      'uploadDate': uploadDate?.toIso8601String(),
      'bankNotificationNumber': bankNotificationNumber,
      'qrCodeData': qrCodeData,
      'isEncrypted': isEncrypted,
      'encryptedContent': encryptedContent,
      'batchId': batchId,
      'printedDate': printedDate?.toIso8601String(),
      'isPrinted': isPrinted,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'remarks': remarks,
    };
  }

  static Document fromJson(Map<String, dynamic> json) {
    return Document(
      outgoingNumber: json['outgoingNumber'],
      documentDate: json['documentDate'] != null 
          ? DateTime.parse(json['documentDate']) 
          : null,
      amount: json['amount']?.toDouble(),
      amountInWords: json['amountInWords'],
      departmentIban: json['departmentIban'],
      recipientIban: json['recipientIban'],
      recipientAddress: json['recipientAddress'],
      documentDetails: json['documentDetails'],
      status: DocumentStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => DocumentStatus.notUploaded,
      ),
      uploadDate: json['uploadDate'] != null 
          ? DateTime.parse(json['uploadDate']) 
          : null,
      bankNotificationNumber: json['bankNotificationNumber'],
      qrCodeData: json['qrCodeData'],
      isEncrypted: json['isEncrypted'] ?? false,
      encryptedContent: json['encryptedContent'],
      batchId: json['batchId'],
      printedDate: json['printedDate'] != null 
          ? DateTime.parse(json['printedDate']) 
          : null,
      isPrinted: json['isPrinted'] ?? false,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
      remarks: json['remarks'],
    );
  }
}

enum DocumentStatus {
  draft, // مسودة
  printed, // مطبوع
  uploaded, // مرفوع
  notUploaded, // غير مرفوع
  archived // مؤرشف
}

@collection
class PrintBatch {
  Id id = Isar.autoIncrement;

  late String batchId; // معرف فريد للدفعة

  late DateTime createdDate; // تاريخ إنشاء الدفعة

  late int startNumber; // رقم البداية

  late int endNumber; // رقم النهاية

  late int totalDocuments; // إجمالي المستندات

  @Enumerated(EnumType.name)
  late PrintBatchStatus status; // حالة الدفعة

  DateTime? completedDate; // تاريخ الانتهاء

  String? remarks; // ملاحظات
}

enum PrintBatchStatus {
  created, // تم الإنشاء
  printing, // جاري الطباعة
  completed, // مكتمل
  cancelled // ملغي
}

@collection
class PrintSettings {
  Id id = Isar.autoIncrement;

  late int currentOutgoingNumber; // آخر رقم صادر مستخدم

  // معلومات المؤسسة
  String? departmentName; // اسم الدائرة
  String? bankAccount; // الحساب المصرفي
  String? iban; // الايبان
  String? accountNumber; // رقم الحساب
  String? bankName; // اسم المصرف
  String? directorName; // اسم مدير المؤسسة
  String? jobTitle; // عنوانه الوظيفي
  String? assignedWork; // العمل المكلف به
  String? positionType; // مدير عام او مخول بالصلاحيات

  String? logoPath; // مسار اللوجو

  // إعدادات التشفير
  String? encryptionKey; // مفتاح التشفير

  // إعدادات الطباعة
  bool requirePreview = true; // يتطلب معاينة

  bool autoIncrement = true; // زيادة تلقائية للأرقام

  int copiesCount = 2; // عدد النسخ الافتراضي

  DateTime? createdAt; // تاريخ الإنشاء

  DateTime? updatedAt; // آخر تحديث
}