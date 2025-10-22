import 'package:isar/isar.dart';
import 'dart:io';
import '../models/document.dart';
import '../models/organization.dart';
import '../models/funding_models.dart';
import '../models/active_period.dart';
import '../models/deduction_entity.dart';
import '../models/deduction_record.dart';
import '../models/document_draft.dart';
import '../models/final_document.dart';

class DatabaseService {
  static late Isar isar;
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    // تخزين قاعدة البيانات في مجلد المشروع
    final dir = Directory.current;
    final dbPath = '${dir.path}/database';

    // إنشاء مجلد قاعدة البيانات إذا لم يكن موجوداً
    final dbDir = Directory(dbPath);
    if (!await dbDir.exists()) {
      await dbDir.create(recursive: true);
    }

    isar = await Isar.open(
      [
        DocumentSchema,
        PrintBatchSchema,
        PrintSettingsSchema,
        OrganizationSchema,
        FundingCategorySchema,
        InstitutionSchema,
        InstitutionFundingSchema,
        FundingAttachmentSchema,
        FundingArchiveSchema,
        FundingTransactionSchema,
        ActivePeriodSchema,
        DeductionEntitySchema,
        DeductionRecordSchema,
        DocumentDraftSchema,
        FinalDocumentSchema,
      ],
      directory: dbPath,
      name: 'financial_documents',
    );
    print('Database path: $dbPath');

    // إنشاء إعدادات افتراضية إذا لم تكن موجودة
    await _initializeDefaultSettings();
    _isInitialized = true;
  }

  static Future<void> _initializeDefaultSettings() async {
    final existingSettings = await isar.printSettings.where().findFirst();
    if (existingSettings == null) {
      final defaultSettings = PrintSettings()
        ..currentOutgoingNumber = 1
        ..departmentName = 'اسم الدائرة'
        ..bankName = 'اسم المصرف'
        ..directorName = 'اسم مدير المؤسسة'
        ..jobTitle = 'العنوان الوظيفي'
        ..assignedWork = 'العمل المكلف به'
        ..positionType = 'مدير عام'
        ..requirePreview = true
        ..autoIncrement = true
        ..copiesCount = 2
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now();

      await isar.writeTxn(() async {
        await isar.printSettings.put(defaultSettings);
      });
    }
  }

  // Document operations
  static Future<List<Document>> getAllDocuments() async {
    return await isar.documents.where().findAll();
  }

  static Future<Document?> getDocumentById(int id) async {
    return await isar.documents.get(id);
  }

  static Future<Document?> getDocumentByOutgoingNumber(
    int outgoingNumber,
  ) async {
    return await isar.documents
        .filter()
        .outgoingNumberEqualTo(outgoingNumber)
        .findFirst();
  }

  static Future<List<Document>> getDocumentsByStatus(
    DocumentStatus status,
  ) async {
    return await isar.documents.filter().statusEqualTo(status).findAll();
  }

  static Future<void> saveDocument(Document document) async {
    await isar.writeTxn(() async {
      document.updatedAt = DateTime.now();
      if (document.createdAt == null) {
        document.createdAt = DateTime.now();
      }
      await isar.documents.put(document);
    });
  }

  static Future<void> saveDocuments(List<Document> documents) async {
    await isar.writeTxn(() async {
      final now = DateTime.now();
      for (var document in documents) {
        document.updatedAt = now;
        if (document.createdAt == null) {
          document.createdAt = now;
        }
      }
      await isar.documents.putAll(documents);
    });
  }

  static Future<void> deleteDocument(int id) async {
    await isar.writeTxn(() async {
      await isar.documents.delete(id);
    });
  }

  static Future<void> updateDocumentStatus(
    int id,
    DocumentStatus status, {
    String? bankNotificationNumber,
    DateTime? uploadedDate,
  }) async {
    await isar.writeTxn(() async {
      final document = await isar.documents.get(id);
      if (document != null) {
        document.status = status;
        document.updatedAt = DateTime.now();

        if (status == DocumentStatus.uploaded) {
          document.bankNotificationNumber = bankNotificationNumber;
          document.uploadDate = uploadedDate ?? DateTime.now();
        }

        await isar.documents.put(document);
      }
    });
  }

  // PrintBatch operations
  static Future<List<PrintBatch>> getAllPrintBatches() async {
    return await isar.printBatchs.where().findAll();
  }

  static Future<PrintBatch?> getPrintBatchById(int id) async {
    return await isar.printBatchs.get(id);
  }

  static Future<void> savePrintBatch(PrintBatch batch) async {
    await isar.writeTxn(() async {
      await isar.printBatchs.put(batch);
    });
  }

  static Future<void> updatePrintBatchStatus(
    int id,
    PrintBatchStatus status,
  ) async {
    await isar.writeTxn(() async {
      final batch = await isar.printBatchs.get(id);
      if (batch != null) {
        batch.status = status;
        if (status == PrintBatchStatus.completed) {
          batch.completedDate = DateTime.now();
        }
        await isar.printBatchs.put(batch);
      }
    });
  }

  // PrintSettings operations
  static Future<PrintSettings?> getSettings() async {
    return await isar.printSettings.where().findFirst();
  }

  static Future<void> saveSettings(PrintSettings settings) async {
    await isar.writeTxn(() async {
      settings.updatedAt = DateTime.now();
      await isar.printSettings.put(settings);
    });
  }

  static Future<int> getNextOutgoingNumber() async {
    final settings = await getSettings();
    if (settings != null) {
      final nextNumber = settings.currentOutgoingNumber + 1;
      settings.currentOutgoingNumber = nextNumber;
      await saveSettings(settings);
      return nextNumber;
    }
    return 1;
  }

  static Future<void> updateCurrentOutgoingNumber(int number) async {
    final settings = await getSettings();
    if (settings != null) {
      settings.currentOutgoingNumber = number;
      await saveSettings(settings);
    }
  }

  // Search operations
  static Future<List<Document>> searchDocuments(String query) async {
    return await isar.documents
        .filter()
        .group(
          (q) => q
              .documentDetailsContains(query, caseSensitive: false)
              .or()
              .amountInWordsContains(query, caseSensitive: false)
              .or()
              .recipientAddressContains(query, caseSensitive: false),
        )
        .findAll();
  }

  static Future<List<Document>> getDocumentsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    return await isar.documents
        .filter()
        .documentDateBetween(start, end)
        .findAll();
  }

  // Statistics
  static Future<Map<DocumentStatus, int>> getDocumentStatusCounts() async {
    final counts = <DocumentStatus, int>{};

    for (final status in DocumentStatus.values) {
      final count = await isar.documents.filter().statusEqualTo(status).count();
      counts[status] = count;
    }

    return counts;
  }

  static Future<int> getTotalDocumentsCount() async {
    return await isar.documents.count();
  }

  // Organization operations
  static Future<List<Organization>> getAllOrganizations() async {
    return await isar.organizations.where().findAll();
  }

  static Future<Organization?> getOrganizationById(int id) async {
    return await isar.organizations.get(id);
  }

  static Future<Organization?> getMainOrganization() async {
    final orgs = await isar.organizations.where().findAll();
    return orgs.isNotEmpty ? orgs.first : null;
  }

  static Future<void> saveOrganization(Organization organization) async {
    await isar.writeTxn(() async {
      organization.updatedAt = DateTime.now();
      if (organization.createdAt == null) {
        organization.createdAt = DateTime.now();
      }
      await isar.organizations.put(organization);
    });
  }

  static Future<void> deleteOrganization(int id) async {
    await isar.writeTxn(() async {
      await isar.organizations.delete(id);
    });
  }

  // Additional utility functions
  static Future<double> getTotalAmountByStatus(DocumentStatus status) async {
    final documents = await getDocumentsByStatus(status);
    double total = 0;
    for (var doc in documents) {
      if (doc.amount != null) {
        total += doc.amount!;
      }
    }
    return total;
  }

  static Future<List<Document>> getDocumentsByBatch(String batchId) async {
    return await isar.documents.filter().batchIdEqualTo(batchId).findAll();
  }

  static Future<void> clearAllData() async {
    await isar.writeTxn(() async {
      await isar.clear();
    });
  }

  static Future<void> close() async {
    if (_isInitialized) {
      await isar.close();
      _isInitialized = false;
    }
  }

  // =============================================
  // دوال إدارة الأبواب التمويلية (Funding Categories)
  // =============================================

  /// إضافة باب تمويلي جديد
  static Future<int> addFundingCategory(FundingCategory category) async {
    category.createdAt = DateTime.now();
    category.updatedAt = DateTime.now();

    return await isar.writeTxn(() async {
      return await isar.fundingCategorys.put(category);
    });
  }

  /// الحصول على جميع الأبواب التمويلية
  static Future<List<FundingCategory>> getAllFundingCategories() async {
    return await isar.fundingCategorys.where().findAll();
  }

  /// الحصول على الأبواب الرئيسية (بدون باب أعلى)
  static Future<List<FundingCategory>> getMainFundingCategories() async {
    return await isar.fundingCategorys.filter().parentIdIsNull().findAll();
  }

  /// الحصول على الأبواب الفرعية لباب رئيسي
  static Future<List<FundingCategory>> getSubFundingCategories(
    int parentId,
  ) async {
    return await isar.fundingCategorys
        .filter()
        .parentIdEqualTo(parentId)
        .findAll();
  }

  /// الحصول على باب تمويلي بالمعرف
  static Future<FundingCategory?> getFundingCategoryById(int id) async {
    return await isar.fundingCategorys.get(id);
  }

  /// تحديث باب تمويلي
  static Future<int> updateFundingCategory(FundingCategory category) async {
    category.updatedAt = DateTime.now();

    return await isar.writeTxn(() async {
      return await isar.fundingCategorys.put(category);
    });
  }

  /// حذف باب تمويلي
  static Future<bool> deleteFundingCategory(int id) async {
    return await isar.writeTxn(() async {
      return await isar.fundingCategorys.delete(id);
    });
  }

  /// البحث في الأبواب التمويلية بالاسم
  static Future<List<FundingCategory>> searchFundingCategories(
    String searchTerm,
  ) async {
    return await isar.fundingCategorys
        .filter()
        .nameContains(searchTerm, caseSensitive: false)
        .findAll();
  }

  // =============================================
  // دوال إدارة المؤسسات (Institutions)
  // =============================================

  /// إضافة مؤسسة جديدة
  static Future<int> addInstitution(Institution institution) async {
    return await isar.writeTxn(() async {
      return await isar.institutions.put(institution);
    });
  }

  /// الحصول على جميع المؤسسات
  static Future<List<Institution>> getAllInstitutions() async {
    return await isar.institutions.where().findAll();
  }

  /// الحصول على مؤسسة بالمعرف
  static Future<Institution?> getInstitutionById(int id) async {
    return await isar.institutions.get(id);
  }

  /// الحصول على مؤسسة بالكود
  static Future<Institution?> getInstitutionByCode(String code) async {
    return await isar.institutions.filter().codeEqualTo(code).findFirst();
  }

  /// تحديث مؤسسة
  static Future<int> updateInstitution(Institution institution) async {
    return await isar.writeTxn(() async {
      return await isar.institutions.put(institution);
    });
  }

  /// حذف مؤسسة
  static Future<bool> deleteInstitution(int id) async {
    return await isar.writeTxn(() async {
      return await isar.institutions.delete(id);
    });
  }

  /// البحث في المؤسسات بالاسم
  static Future<List<Institution>> searchInstitutions(String searchTerm) async {
    return await isar.institutions
        .filter()
        .nameContains(searchTerm, caseSensitive: false)
        .findAll();
  }

  // =============================================
  // دوال إدارة تمويل المؤسسات (Institution Funding)
  // =============================================

  /// إضافة تمويل مؤسسة جديد
  static Future<int> addInstitutionFunding(InstitutionFunding funding) async {
    funding.createdAt = DateTime.now();
    funding.updatedAt = DateTime.now();

    return await isar.writeTxn(() async {
      return await isar.institutionFundings.put(funding);
    });
  }

  /// الحصول على جميع تمويلات المؤسسات
  static Future<List<InstitutionFunding>> getAllInstitutionFunding() async {
    return await isar.institutionFundings.where().findAll();
  }

  /// الحصول على تمويلات مؤسسة معينة
  static Future<List<InstitutionFunding>> getInstitutionFundingByInstitution(
    int institutionId,
  ) async {
    return await isar.institutionFundings
        .filter()
        .institutionIdEqualTo(institutionId)
        .findAll();
  }

  /// الحصول على تمويلات باب معين
  static Future<List<InstitutionFunding>> getInstitutionFundingByCategory(
    int categoryId,
  ) async {
    return await isar.institutionFundings
        .filter()
        .categoryIdEqualTo(categoryId)
        .findAll();
  }

  /// الحصول على تمويلات سنة معينة
  static Future<List<InstitutionFunding>> getInstitutionFundingByYear(
    int year,
  ) async {
    return await isar.institutionFundings.filter().yearEqualTo(year).findAll();
  }

  /// الحصول على تمويلات شهر وسنة معينة
  static Future<List<InstitutionFunding>> getInstitutionFundingByYearMonth(
    int year,
    int month,
  ) async {
    return await isar.institutionFundings
        .filter()
        .yearEqualTo(year)
        .and()
        .monthEqualTo(month)
        .findAll();
  }

  /// الحصول على تمويل مؤسسة بباب معين
  static Future<InstitutionFunding?>
  getInstitutionFundingByInstitutionAndCategory(
    int institutionId,
    int categoryId,
    int year,
    int month,
  ) async {
    return await isar.institutionFundings
        .filter()
        .institutionIdEqualTo(institutionId)
        .and()
        .categoryIdEqualTo(categoryId)
        .and()
        .yearEqualTo(year)
        .and()
        .monthEqualTo(month)
        .findFirst();
  }

  /// تحديث تمويل مؤسسة
  static Future<int> updateInstitutionFunding(
    InstitutionFunding funding,
  ) async {
    funding.updatedAt = DateTime.now();

    return await isar.writeTxn(() async {
      return await isar.institutionFundings.put(funding);
    });
  }

  /// حذف تمويل مؤسسة
  static Future<bool> deleteInstitutionFunding(int id) async {
    return await isar.writeTxn(() async {
      return await isar.institutionFundings.delete(id);
    });
  }

  /// حساب إجمالي المبالغ المخصصة لمؤسسة في سنة معينة
  static Future<double> getTotalAllocatedAmountForInstitution(
    int institutionId,
    int year,
  ) async {
    final fundings = await isar.institutionFundings
        .filter()
        .institutionIdEqualTo(institutionId)
        .and()
        .yearEqualTo(year)
        .findAll();

    double total = 0.0;
    for (final funding in fundings) {
      total += funding.allocatedAmount;
    }
    return total;
  }

  /// حساب إجمالي المبالغ المصروفة لمؤسسة في سنة معينة
  static Future<double> getTotalSpentAmountForInstitution(
    int institutionId,
    int year,
  ) async {
    final fundings = await isar.institutionFundings
        .filter()
        .institutionIdEqualTo(institutionId)
        .and()
        .yearEqualTo(year)
        .findAll();

    double total = 0.0;
    for (final funding in fundings) {
      total += funding.spentAmount;
    }
    return total;
  }

  /// حساب إجمالي المبالغ المتبقية لمؤسسة في سنة معينة
  static Future<double> getTotalRemainingAmountForInstitution(
    int institutionId,
    int year,
  ) async {
    final fundings = await isar.institutionFundings
        .filter()
        .institutionIdEqualTo(institutionId)
        .and()
        .yearEqualTo(year)
        .findAll();

    double total = 0.0;
    for (final funding in fundings) {
      total += funding.remainingAmount;
    }
    return total;
  }

  /// حساب إجمالي المبالغ المخصصة لباب تمويلي في سنة معينة
  static Future<double> getTotalAllocatedAmountForCategory(
    int categoryId,
    int year,
  ) async {
    final fundings = await isar.institutionFundings
        .filter()
        .categoryIdEqualTo(categoryId)
        .and()
        .yearEqualTo(year)
        .findAll();

    double total = 0.0;
    for (final funding in fundings) {
      total += funding.allocatedAmount;
    }
    return total;
  }

  // ==================== إدارة المرفقات ====================

  /// إضافة مرفق جديد
  static Future<FundingAttachment> addFundingAttachment(
    FundingAttachment attachment,
  ) async {
    await isar.writeTxn(() async {
      attachment.uploadedAt ??= DateTime.now();
      await isar.fundingAttachments.put(attachment);
    });
    return attachment;
  }

  /// الحصول على جميع مرفقات تمويل معين
  static Future<List<FundingAttachment>> getAttachmentsByFunding(
    int fundingId,
  ) async {
    return await isar.fundingAttachments
        .filter()
        .fundingIdEqualTo(fundingId)
        .sortByUploadedAtDesc()
        .findAll();
  }

  /// الحصول على مرفق بواسطة المعرف
  static Future<FundingAttachment?> getFundingAttachment(Id id) async {
    return await isar.fundingAttachments.get(id);
  }

  /// تحديث مرفق موجود
  static Future<FundingAttachment> updateFundingAttachment(
    FundingAttachment attachment,
  ) async {
    await isar.writeTxn(() async {
      await isar.fundingAttachments.put(attachment);
    });
    return attachment;
  }

  /// حذف مرفق
  static Future<bool> deleteFundingAttachment(Id id) async {
    bool deleted = false;
    await isar.writeTxn(() async {
      deleted = await isar.fundingAttachments.delete(id);
    });
    return deleted;
  }

  /// حذف جميع مرفقات تمويل معين
  static Future<int> deleteAttachmentsByFunding(int fundingId) async {
    int count = 0;
    await isar.writeTxn(() async {
      final attachments = await isar.fundingAttachments
          .filter()
          .fundingIdEqualTo(fundingId)
          .findAll();

      for (final attachment in attachments) {
        await isar.fundingAttachments.delete(attachment.id);
        count++;
      }
    });
    return count;
  }

  /// البحث في المرفقات بالاسم أو النوع
  static Future<List<FundingAttachment>> searchAttachments(String query) async {
    return await isar.fundingAttachments
        .filter()
        .group(
          (q) => q
              .fileNameContains(query, caseSensitive: false)
              .or()
              .fileTypeContains(query, caseSensitive: false)
              .or()
              .descriptionContains(query, caseSensitive: false),
        )
        .sortByUploadedAtDesc()
        .findAll();
  }

  /// إحصائيات المرفقات
  static Future<Map<String, dynamic>> getAttachmentsStats() async {
    final allAttachments = await isar.fundingAttachments.where().findAll();
    final Map<String, int> typeStats = {};

    for (final attachment in allAttachments) {
      final type = attachment.fileType ?? 'غير محدد';
      typeStats[type] = (typeStats[type] ?? 0) + 1;
    }

    return {
      'totalAttachments': allAttachments.length,
      'typeStats': typeStats,
      'recentCount': await isar.fundingAttachments
          .filter()
          .uploadedAtGreaterThan(DateTime.now().subtract(Duration(days: 30)))
          .count(),
    };
  }

  // FundingArchive operations
  /// الحصول على جميع سجلات الأرشيف
  static Future<List<FundingArchive>> getAllFundingArchives() async {
    return await isar.fundingArchives.where().findAll();
  }

  /// الحصول على سجلات الأرشيف لتمويل معين
  static Future<List<FundingArchive>> getFundingArchivesByFundingId(
    int fundingId,
  ) async {
    return await isar.fundingArchives
        .filter()
        .fundingIdEqualTo(fundingId)
        .findAll();
  }

  /// الحصول على سجلات الأرشيف لمؤسسة معينة
  static Future<List<FundingArchive>> getFundingArchivesByInstitution(
    int institutionId,
  ) async {
    return await isar.fundingArchives
        .filter()
        .institutionIdEqualTo(institutionId)
        .findAll();
  }

  /// الحصول على سجلات الأرشيف لباب معين
  static Future<List<FundingArchive>> getFundingArchivesByCategory(
    int categoryId,
  ) async {
    return await isar.fundingArchives
        .filter()
        .categoryIdEqualTo(categoryId)
        .findAll();
  }

  /// الحصول على سجلات الأرشيف لسنة معينة
  static Future<List<FundingArchive>> getFundingArchivesByYear(int year) async {
    return await isar.fundingArchives.filter().yearEqualTo(year).findAll();
  }

  /// الحصول على سجلات الأرشيف لنوع عملية معين
  static Future<List<FundingArchive>> getFundingArchivesByOperationType(
    String operationType,
  ) async {
    return await isar.fundingArchives
        .filter()
        .operationTypeEqualTo(operationType)
        .findAll();
  }

  /// حفظ سجل أرشيف جديد
  static Future<void> saveFundingArchive(FundingArchive archive) async {
    await isar.writeTxn(() async {
      archive.updatedAt = DateTime.now();
      await isar.fundingArchives.put(archive);
    });
  }

  /// حذف سجل أرشيف
  static Future<void> deleteFundingArchive(int id) async {
    await isar.writeTxn(() async {
      await isar.fundingArchives.delete(id);
    });
  }

  // FundingTransaction operations
  /// الحصول على جميع المعاملات
  static Future<List<FundingTransaction>> getAllFundingTransactions() async {
    return await isar.fundingTransactions.where().findAll();
  }

  /// الحصول على المعاملات لتمويل معين
  static Future<List<FundingTransaction>> getFundingTransactionsByFundingId(
    int fundingId,
  ) async {
    return await isar.fundingTransactions
        .filter()
        .fundingIdEqualTo(fundingId)
        .findAll();
  }

  /// الحصول على المعاملات لمؤسسة معينة
  static Future<List<FundingTransaction>> getFundingTransactionsByInstitution(
    int institutionId,
  ) async {
    return await isar.fundingTransactions
        .filter()
        .institutionIdEqualTo(institutionId)
        .findAll();
  }

  /// الحصول على المعاملات حسب الحالة
  static Future<List<FundingTransaction>> getFundingTransactionsByStatus(
    ReservationStatus status,
  ) async {
    return await isar.fundingTransactions
        .filter()
        .statusEqualTo(
          ReservationStatus.values.firstWhere((s) => s.toString().split('.').last == status),
        )
        .findAll();
  }

  /// الحصول على طلبات الحجز المعلقة (محجوز)
  static Future<List<FundingTransaction>> getPendingReservations() async {
    return await isar.fundingTransactions
        .filter()
        .statusEqualTo(ReservationStatus.reserved)
        .findAll();
  }

  /// الحصول على الحجوزات المعتمدة (جاهزة للصرف)
  static Future<List<FundingTransaction>> getApprovedReservations() async {
    return await isar.fundingTransactions
        .filter()
        .statusEqualTo(ReservationStatus.approved)
        .findAll();
  }

  /// الحصول على المعاملات المنفذة (مصروفة)
  static Future<List<FundingTransaction>> getExecutedTransactions() async {
    return await isar.fundingTransactions
        .filter()
        .statusEqualTo(ReservationStatus.spent)
        .findAll();
  }

  /// حفظ معاملة جديدة
  static Future<void> saveFundingTransaction(
    FundingTransaction transaction,
  ) async {
    await isar.writeTxn(() async {
      transaction.updatedAt = DateTime.now();
      await isar.fundingTransactions.put(transaction);
    });
  }

  /// تحديث معاملة موجودة
  static Future<void> updateFundingTransaction(
    FundingTransaction transaction,
  ) async {
    await isar.writeTxn(() async {
      transaction.updatedAt = DateTime.now();
      await isar.fundingTransactions.put(transaction);
    });
  }

  /// حذف معاملة
  static Future<void> deleteFundingTransaction(int id) async {
    await isar.writeTxn(() async {
      await isar.fundingTransactions.delete(id);
    });
  }

  /// تنفيذ الصرف لطلب حجز
  static Future<bool> executeTransaction(
    int transactionId,
    double executedAmount,
    String? executionDescription,
    String? executionAttachmentPath,
    DateTime executionDate,
  ) async {
    try {
      await isar.writeTxn(() async {
        // الحصول على المعاملة
        final transaction = await isar.fundingTransactions.get(transactionId);
        if (transaction == null) {
          print('خطأ: لم يتم العثور على المعاملة بالرقم $transactionId');
          return;
        }

        // تحديث المعاملة
        final updatedTransaction = transaction.copyWith(
          status: ReservationStatus.spent,
          executedAmount: executedAmount,
          executionDescription: executionDescription,
          executionAttachmentPath: executionAttachmentPath,
          executionDate: executionDate,
          updatedAt: DateTime.now(),
        );

        await isar.fundingTransactions.put(updatedTransaction);

        // تحديث التمويل الأساسي
        if (transaction.fundingId != null) {
          final funding = await isar.institutionFundings.get(
            transaction.fundingId!,
          );
          if (funding != null) {
            final updatedFunding = funding.copyWith(
              reservedAmount:
                  funding.reservedAmount - transaction.requestedAmount,
              spentAmount: funding.spentAmount + executedAmount,
              updatedAt: DateTime.now(),
            );
            await isar.institutionFundings.put(updatedFunding);
          }
        }

        // إنشاء سجل في الأرشيف
        final archiveRecord = FundingArchive()
          ..fundingId = transaction.fundingId
          ..institutionId = transaction.institutionId
          ..categoryId = transaction.categoryId
          ..operationType = 'صرف'
          ..amount = executedAmount
          ..description = executionDescription
          ..executionAttachmentPath = executionAttachmentPath
          ..year = transaction.year
          ..month = transaction.month
          ..executedAt = executionDate
          ..createdAt = DateTime.now()
          ..updatedAt = DateTime.now();

        await isar.fundingArchives.put(archiveRecord);
      });
      return true;
    } catch (e) {
      print('خطأ في تنفيذ الصرف: $e');
      return false;
    }
  }

  /// تنظيف جميع البيانات المالية
  static Future<void> clearAllFundingData() async {
    try {
      await isar.writeTxn(() async {
        await isar.institutionFundings.clear();
        await isar.fundingArchives.clear();
        await isar.fundingTransactions.clear();
        await isar.fundingAttachments.clear();
        await isar.fundingCategorys.clear();
        await isar.institutions.clear();
      });
      print('تم تنظيف جميع البيانات المالية');
    } catch (e) {
      print('خطأ في تنظيف البيانات: $e');
    }
  }

  /// إنشاء محاكاة شاملة للنظام المالي
  static Future<void> createCompleteFundingSimulation() async {
    try {
      // تنظيف البيانات القديمة
      await clearAllFundingData();

      await isar.writeTxn(() async {
        // 1. إنشاء الفئات الرئيسية
        final salariesCategory = FundingCategory()
          ..name = 'الرواتب والأجور'
          ..description = 'جميع مصاريف الرواتب والأجور'
          ..parentId = null
          ..createdAt = DateTime.now()
          ..updatedAt = DateTime.now();

        final suppliesCategory = FundingCategory()
          ..name = 'المستلزمات والخدمات'
          ..description = 'المستلزمات المكتبية والخدمات العامة'
          ..parentId = null
          ..createdAt = DateTime.now()
          ..updatedAt = DateTime.now();

        final fuelCategory = FundingCategory()
          ..name = 'الوقود والمحروقات'
          ..description = 'وقود السيارات والمولدات'
          ..parentId = null
          ..createdAt = DateTime.now()
          ..updatedAt = DateTime.now();

        final maintenanceCategory = FundingCategory()
          ..name = 'الصيانة والإصلاح'
          ..description = 'صيانة الأجهزة والمباني'
          ..parentId = null
          ..createdAt = DateTime.now()
          ..updatedAt = DateTime.now();

        await isar.fundingCategorys.putAll([
          salariesCategory,
          suppliesCategory,
          fuelCategory,
          maintenanceCategory,
        ]);

        // 2. إنشاء الفئات الفرعية
        final basicSalaries = FundingCategory()
          ..name = 'الرواتب الأساسية'
          ..description = 'رواتب الموظفين الثابتة'
          ..parentId = salariesCategory.id
          ..createdAt = DateTime.now()
          ..updatedAt = DateTime.now();

        final overtimePay = FundingCategory()
          ..name = 'أجور العمل الإضافي'
          ..description = 'أجور ساعات العمل الإضافية'
          ..parentId = salariesCategory.id
          ..createdAt = DateTime.now()
          ..updatedAt = DateTime.now();

        final allowances = FundingCategory()
          ..name = 'البدلات والمكافآت'
          ..description = 'بدلات السفر والمكافآت'
          ..parentId = salariesCategory.id
          ..createdAt = DateTime.now()
          ..updatedAt = DateTime.now();

        final officeSupplies = FundingCategory()
          ..name = 'القرطاسية المكتبية'
          ..description = 'أوراق، أقلام، مستلزمات مكتبية'
          ..parentId = suppliesCategory.id
          ..createdAt = DateTime.now()
          ..updatedAt = DateTime.now();

        final utilities = FundingCategory()
          ..name = 'الخدمات العامة'
          ..description = 'كهرباء، ماء، إنترنت'
          ..parentId = suppliesCategory.id
          ..createdAt = DateTime.now()
          ..updatedAt = DateTime.now();

        final vehicleFuel = FundingCategory()
          ..name = 'وقود السيارات'
          ..description = 'وقود للمركبات الحكومية'
          ..parentId = fuelCategory.id
          ..createdAt = DateTime.now()
          ..updatedAt = DateTime.now();

        final generatorFuel = FundingCategory()
          ..name = 'وقود المولدات'
          ..description = 'وقود لتشغيل المولدات'
          ..parentId = fuelCategory.id
          ..createdAt = DateTime.now()
          ..updatedAt = DateTime.now();

        await isar.fundingCategorys.putAll([
          basicSalaries,
          overtimePay,
          allowances,
          officeSupplies,
          utilities,
          vehicleFuel,
          generatorFuel,
        ]);

        // 3. إنشاء مؤسسة تجريبية
        final testInstitution = Institution()
          ..name = 'دائرة التربية المركزية'
          ..code = 'EDU001'
          ..address = 'بغداد - الكرخ';

        await isar.institutions.put(testInstitution);

        // 4. إنشاء تخصيصات نموذجية للسنة الحالية
        final currentYear = DateTime.now().year;
        final currentMonth = DateTime.now().month;

        // تخصيصات سنوية للفئات الرئيسية
        final annualAllocations = [
          InstitutionFunding()
            ..institutionId = testInstitution.id
            ..categoryId = salariesCategory.id
            ..fundingType = 'سنوي'
            ..allocatedAmount =
                500000000 // 500 مليون
            ..reservedAmount =
                150000000 // 150 مليون محجوز
            ..spentAmount =
                100000000 // 100 مليون مصروف
            ..year = currentYear
            ..month = null
            ..createdAt = DateTime.now()
            ..updatedAt = DateTime.now(),

          InstitutionFunding()
            ..institutionId = testInstitution.id
            ..categoryId = suppliesCategory.id
            ..fundingType = 'سنوي'
            ..allocatedAmount =
                75000000 // 75 مليون
            ..reservedAmount =
                25000000 // 25 مليون محجوز
            ..spentAmount =
                15000000 // 15 مليون مصروف
            ..year = currentYear
            ..month = null
            ..createdAt = DateTime.now()
            ..updatedAt = DateTime.now(),

          InstitutionFunding()
            ..institutionId = testInstitution.id
            ..categoryId = fuelCategory.id
            ..fundingType = 'سنوي'
            ..allocatedAmount =
                120000000 // 120 مليون
            ..reservedAmount =
                40000000 // 40 مليون محجوز
            ..spentAmount =
                30000000 // 30 مليون مصروف
            ..year = currentYear
            ..month = null
            ..createdAt = DateTime.now()
            ..updatedAt = DateTime.now(),

          InstitutionFunding()
            ..institutionId = testInstitution.id
            ..categoryId = maintenanceCategory.id
            ..fundingType = 'سنوي'
            ..allocatedAmount =
                50000000 // 50 مليون
            ..reservedAmount = 0
            ..spentAmount = 0
            ..year = currentYear
            ..month = null
            ..createdAt = DateTime.now()
            ..updatedAt = DateTime.now(),
        ];

        await isar.institutionFundings.putAll(annualAllocations);

        // تخصيصات شهرية للفئات الرئيسية (الشهر الحالي)
        final monthlyAllocations = [
          InstitutionFunding()
            ..institutionId = testInstitution.id
            ..categoryId = salariesCategory.id
            ..fundingType = 'شهري'
            ..allocatedAmount =
                50000000 // 50 مليون شهرياً للرواتب
            ..reservedAmount =
                45000000 // 45 مليون محجوز
            ..spentAmount =
                35000000 // 35 مليون مصروف
            ..year = currentYear
            ..month = currentMonth
            ..createdAt = DateTime.now()
            ..updatedAt = DateTime.now(),

          InstitutionFunding()
            ..institutionId = testInstitution.id
            ..categoryId = suppliesCategory.id
            ..fundingType = 'شهري'
            ..allocatedAmount =
                10000000 // 10 مليون شهرياً للمستلزمات
            ..reservedAmount =
                8000000 // 8 مليون محجوز
            ..spentAmount =
                3000000 // 3 مليون مصروف
            ..year = currentYear
            ..month = currentMonth
            ..createdAt = DateTime.now()
            ..updatedAt = DateTime.now(),

          InstitutionFunding()
            ..institutionId = testInstitution.id
            ..categoryId = fuelCategory.id
            ..fundingType = 'شهري'
            ..allocatedAmount =
                15000000 // 15 مليون شهرياً للوقود
            ..reservedAmount =
                10000000 // 10 مليون محجوز
            ..spentAmount =
                7000000 // 7 مليون مصروف
            ..year = currentYear
            ..month = currentMonth
            ..createdAt = DateTime.now()
            ..updatedAt = DateTime.now(),

          InstitutionFunding()
            ..institutionId = testInstitution.id
            ..categoryId = maintenanceCategory.id
            ..fundingType = 'شهري'
            ..allocatedAmount =
                5000000 // 5 مليون شهرياً للصيانة
            ..reservedAmount =
                2000000 // 2 مليون محجوز
            ..spentAmount =
                1000000 // 1 مليون مصروف
            ..year = currentYear
            ..month = currentMonth
            ..createdAt = DateTime.now()
            ..updatedAt = DateTime.now(),
        ];

        await isar.institutionFundings.putAll(monthlyAllocations);

        // تخصيصات للشهر السابق (للاختبار)
        final previousMonth = currentMonth > 1 ? currentMonth - 1 : 12;
        final previousYear = currentMonth > 1 ? currentYear : currentYear - 1;

        final previousMonthAllocations = [
          InstitutionFunding()
            ..institutionId = testInstitution.id
            ..categoryId = salariesCategory.id
            ..fundingType = 'شهري'
            ..allocatedAmount = 50000000
            ..reservedAmount = 50000000
            ..spentAmount =
                48000000 // مصروف معظم المبلغ
            ..year = previousYear
            ..month = previousMonth
            ..createdAt = DateTime.now()
            ..updatedAt = DateTime.now(),

          InstitutionFunding()
            ..institutionId = testInstitution.id
            ..categoryId = suppliesCategory.id
            ..fundingType = 'شهري'
            ..allocatedAmount = 10000000
            ..reservedAmount = 10000000
            ..spentAmount = 9500000
            ..year = previousYear
            ..month = previousMonth
            ..createdAt = DateTime.now()
            ..updatedAt = DateTime.now(),
        ];

        await isar.institutionFundings.putAll(previousMonthAllocations);
      });

      print('تم إنشاء محاكاة شاملة للنظام المالي:');
      print('✅ 4 فئات رئيسية');
      print('✅ 7 فئات فرعية');
      print('✅ مؤسسة تجريبية');
      print('✅ تخصيصات سنوية وشهرية');
      print('✅ بيانات للشهر الحالي والسابق');
    } catch (e) {
      print('خطأ في إنشاء المحاكاة: $e');
    }
  }

  /// إنشاء بيانات تجريبية للفئات المالية
  static Future<void> createSampleFundingCategories() async {
    try {
      // التحقق من وجود فئات موجودة
      final existingCategories = await isar.fundingCategorys.where().findAll();
      if (existingCategories.isNotEmpty) {
        print('فئات موجودة مسبقاً: ${existingCategories.length}');
        return;
      }

      // استخدام المحاكاة الشاملة بدلاً من البيانات البسيطة
      await createCompleteFundingSimulation();
    } catch (e) {
      print('خطأ في إنشاء البيانات التجريبية: $e');
    }
  }

  // ================== إدارة جهات الاستقطاع ==================

  /// جلب جميع جهات الاستقطاع
  static Future<List<dynamic>> getAllDeductionEntities() async {
    try {
      if (!_isInitialized) {
        await initialize();
      }
      final entities = await isar.deductionEntitys.where().findAll();
      // Keep existing behaviour (JSON list) for callers that expect maps.
      return entities.map((entity) => entity.toJson()).toList();
    } catch (e) {
      print('خطأ في جلب جهات الاستقطاع: $e');
      return [];
    }
  }

  /// جلب جميع جهات الاستقطاع ككائنات DeductionEntity (للمستهلكين الذين يحتاجون للوصول للخصائص مباشرة)
  static Future<List<DeductionEntity>> getAllDeductionEntitiesAsObjects() async {
    try {
      if (!_isInitialized) {
        await initialize();
      }
      final entities = await isar.deductionEntitys.where().findAll();
      return entities;
    } catch (e) {
      print('خطأ في جلب جهات الاستقطاع ككائنات: $e');
      return <DeductionEntity>[];
    }
  }

  /// جلب جهات الاستقطاع النشطة فقط
  static Future<List<dynamic>> getActiveDeductionEntities() async {
    try {
      if (!_isInitialized) {
        await initialize();
      }
      final entities = await isar.deductionEntitys.filter().isActiveEqualTo(true).findAll();
      return entities.map((entity) => entity.toJson()).toList();
    } catch (e) {
      print('خطأ في جلب جهات الاستقطاع النشطة: $e');
      return [];
    }
  }

  /// إضافة جهة استقطاع جديدة
  static Future<bool> addDeductionEntity(Map<String, dynamic> entityData) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }
      
      final entity = DeductionEntity.fromJson(entityData);
      await isar.writeTxn(() async {
        await isar.deductionEntitys.put(entity);
      });
      
      return true;
    } catch (e) {
      print('خطأ في إضافة جهة الاستقطاع: $e');
      return false;
    }
  }

  /// تحديث جهة استقطاع
  static Future<bool> updateDeductionEntity(Map<String, dynamic> entityData) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }
      
      final entity = DeductionEntity.fromJson(entityData);
      await isar.writeTxn(() async {
        await isar.deductionEntitys.put(entity);
      });
      
      return true;
    } catch (e) {
      print('خطأ في تحديث جهة الاستقطاع: $e');
      return false;
    }
  }

  /// حذف جهة استقطاع
  static Future<bool> deleteDeductionEntity(int id) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }
      
      await isar.writeTxn(() async {
        await isar.deductionEntitys.delete(id);
      });
      
      return true;
    } catch (e) {
      print('خطأ في حذف جهة الاستقطاع: $e');
      return false;
    }
  }

  /// إنشاء جهات استقطاع افتراضية
  static Future<void> createDefaultDeductionEntities() async {
    try {
      final defaultEntities = [
        {
          'name': 'التأمينات الاجتماعية',
          'description': 'هيئة التأمينات الاجتماعية',
          'contactInfo': 'info@sis.gov.iq',
          'isActive': true,
        },
        {
          'name': 'الضرائب',
          'description': 'الهيئة العامة للضرائب',
          'contactInfo': 'info@tax.gov.iq',
          'isActive': true,
        },
        {
          'name': 'التقاعد',
          'description': 'هيئة التقاعد الوطنية',
          'contactInfo': 'info@retirement.gov.iq',
          'isActive': true,
        },
        {
          'name': 'التأمين الصحي',
          'description': 'دائرة التأمين الصحي',
          'contactInfo': 'info@health-insurance.gov.iq',
          'isActive': true,
        },
      ];

      for (final entityData in defaultEntities) {
        await addDeductionEntity(entityData);
      }

      print('تم إنشاء جهات الاستقطاع الافتراضية');
    } catch (e) {
      print('خطأ في إنشاء جهات الاستقطاع الافتراضية: $e');
    }
  }

  // ================== إدارة سجلات الاستقطاع ==================

  /// إضافة سجل استقطاع جديد
  static Future<bool> addDeductionRecord(Map<String, dynamic> recordData) async {
    try {
      // سيتم تحديث هذا عند إنشاء الجداول
      return true;
    } catch (e) {
      print('خطأ في إضافة سجل الاستقطاع: $e');
      return false;
    }
  }

  /// جلب سجلات الاستقطاع لموظف معين
  static Future<List<dynamic>> getEmployeeDeductionRecords(String employeeId) async {
    try {
      // سيتم تحديث هذا عند إنشاء الجداول
      return [];
    } catch (e) {
      print('خطأ في جلب سجلات الاستقطاع للموظف: $e');
      return [];
    }
  }

  /// جلب سجلات الاستقطاع لجهة معينة
  static Future<List<dynamic>> getEntityDeductionRecords(int entityId) async {
    try {
      // سيتم تحديث هذا عند إنشاء الجداول
      return [];
    } catch (e) {
      print('خطأ في جلب سجلات الاستقطاع للجهة: $e');
      return [];
    }
  }

  /// جلب سجلات الاستقطاع لفترة معينة
  static Future<List<dynamic>> getDeductionRecordsByPeriod(
    int year,
    int month,
  ) async {
    try {
      // سيتم تحديث هذا عند إنشاء الجداول
      return [];
    } catch (e) {
      print('خطأ في جلب سجلات الاستقطاع للفترة: $e');
      return [];
    }
  }

  /// حساب إجمالي الاستقطاعات لجهة معينة
  static Future<double> calculateEntityTotalDeductions(int entityId) async {
    try {
      // سيتم تحديث هذا عند إنشاء الجداول
      return 0.0;
    } catch (e) {
      print('خطأ في حساب إجمالي الاستقطاعات: $e');
      return 0.0;
    }
  }

  // Document Draft Methods
  
  /// إضافة مسودة مستند جديدة
  static Future<void> addDocumentDraft(DocumentDraft draft) async {
    try {
      await isar.writeTxn(() async {
        await isar.documentDrafts.put(draft);
      });
      print('تم إضافة المسودة بنجاح');
    } catch (e) {
      print('خطأ في إضافة المسودة: $e');
      throw e;
    }
  }

  /// جلب جميع مسودات المستندات
  static Future<List<DocumentDraft>> getAllDocumentDrafts() async {
    try {
      return await isar.documentDrafts.where().findAll();
    } catch (e) {
      print('خطأ في جلب المسودات: $e');
      return [];
    }
  }

  /// جلب مسودات المستندات مع فلترة
  static Future<List<DocumentDraft>> getDocumentDrafts({
    String? documentType,
    int? month,
    int? year,
    DocumentDraftStatus? status,
  }) async {
    try {
      final allDrafts = await isar.documentDrafts.where().findAll();
      
      return allDrafts.where((draft) {
        if (documentType != null && draft.documentType != documentType) {
          return false;
        }
        if (month != null && draft.month != month) {
          return false;
        }
        if (year != null && draft.year != year) {
          return false;
        }
        if (status != null && draft.status != status) {
          return false;
        }
        return true;
      }).toList();
    } catch (e) {
      print('خطأ في جلب المسودات المفلترة: $e');
      return [];
    }
  }

  /// تحديث مسودة مستند
  static Future<void> updateDocumentDraft(DocumentDraft draft) async {
    try {
      draft.updatedAt = DateTime.now();
      await isar.writeTxn(() async {
        await isar.documentDrafts.put(draft);
      });
      print('تم تحديث المسودة بنجاح');
    } catch (e) {
      print('خطأ في تحديث المسودة: $e');
      throw e;
    }
  }

  /// حذف مسودة مستند
  static Future<void> deleteDocumentDraft(int id) async {
    try {
      await isar.writeTxn(() async {
        await isar.documentDrafts.delete(id);
      });
      print('تم حذف المسودة بنجاح');
    } catch (e) {
      print('خطأ في حذف المسودة: $e');
      throw e;
    }
  }

  /// جلب مسودة بالمعرف
  static Future<DocumentDraft?> getDocumentDraftById(int id) async {
    try {
      return await isar.documentDrafts.get(id);
    } catch (e) {
      print('خطأ في جلب المسودة: $e');
      return null;
    }
  }

  // Final Document Methods
  
  /// إضافة مستند نهائي جديد
  static Future<void> addFinalDocument(FinalDocument document) async {
    try {
      await isar.writeTxn(() async {
        await isar.finalDocuments.put(document);
      });
      print('تم إضافة المستند النهائي بنجاح');
    } catch (e) {
      print('خطأ في إضافة المستند النهائي: $e');
      throw e;
    }
  }

  /// جلب جميع المستندات النهائية
  static Future<List<FinalDocument>> getAllFinalDocuments() async {
    try {
      return await isar.finalDocuments.where().findAll();
    } catch (e) {
      print('خطأ في جلب المستندات النهائية: $e');
      return [];
    }
  }

  /// جلب المستندات النهائية مع فلترة
  static Future<List<FinalDocument>> getFinalDocuments({
    String? documentType,
    int? month,
    int? year,
    FinalDocumentStatus? status,
  }) async {
    try {
      final allDocs = await isar.finalDocuments.where().findAll();
      
      return allDocs.where((doc) {
        if (documentType != null && doc.documentType != documentType) {
          return false;
        }
        if (month != null && doc.month != month) {
          return false;
        }
        if (year != null && doc.year != year) {
          return false;
        }
        if (status != null && doc.status != status) {
          return false;
        }
        return true;
      }).toList();
    } catch (e) {
      print('خطأ في جلب المستندات النهائية المفلترة: $e');
      return [];
    }
  }

  /// تحديث مستند نهائي
  static Future<void> updateFinalDocument(FinalDocument document) async {
    try {
      await isar.writeTxn(() async {
        await isar.finalDocuments.put(document);
      });
      print('تم تحديث المستند النهائي بنجاح');
    } catch (e) {
      print('خطأ في تحديث المستند النهائي: $e');
      throw e;
    }
  }

  /// حذف مستند نهائي
  static Future<void> deleteFinalDocument(int id) async {
    try {
      await isar.writeTxn(() async {
        await isar.finalDocuments.delete(id);
      });
      print('تم حذف المستند النهائي بنجاح');
    } catch (e) {
      print('خطأ في حذف المستند النهائي: $e');
      throw e;
    }
  }

  /// جلب مستند نهائي بالمعرف
  static Future<FinalDocument?> getFinalDocumentById(int id) async {
    try {
      return await isar.finalDocuments.get(id);
    } catch (e) {
      print('خطأ في جلب المستند النهائي: $e');
      return null;
    }
  }

  /// جلب مستند نهائي برقم المستند
  static Future<FinalDocument?> getFinalDocumentByNumber(String documentNumber) async {
    try {
      final allDocs = await isar.finalDocuments.where().findAll();
      
      for (final doc in allDocs) {
        if (doc.documentNumber == documentNumber) {
          return doc;
        }
      }
      
      return null;
    } catch (e) {
      print('خطأ في جلب المستند برقم المستند: $e');
      return null;
    }
  }

  /// تحويل مسودة إلى مستند نهائي
  static Future<FinalDocument?> convertDraftToFinalDocument(
    DocumentDraft draft, 
    String documentNumber,
    String amountInWords,
  ) async {
    try {
      // إنشاء المستند النهائي
      final finalDoc = FinalDocument.fromDraft(
        draftId: draft.id,
        documentNumber: documentNumber,
        entityName: draft.entityName,
        entityIban: draft.entityIban ?? '',
        amount: draft.amount,
        amountInWords: amountInWords,
        organizationBankName: draft.organizationBankName ?? '',
        documentType: draft.documentType,
        month: draft.month,
        year: draft.year,
        entityEmail: draft.entityEmail,
        entityPhone: draft.entityPhone,
        entityAddress: draft.entityAddress,
        purpose: draft.purpose,
        notes: draft.notes,
      );

      // حفظ المستند النهائي
      await addFinalDocument(finalDoc);

      // تحديث حالة المسودة
      draft.status = DocumentDraftStatus.printed;
      draft.finalDocumentId = documentNumber;
      await updateDocumentDraft(draft);

      return finalDoc;
    } catch (e) {
      print('خطأ في تحويل المسودة إلى مستند نهائي: $e');
      throw e;
    }
  }

  /// توليد رقم مستند جديد
  static Future<String> generateDocumentNumber({
    required String documentType,
    required int year,
  }) async {
    try {
      // جلب جميع المستندات للنوع والسنة وفرزها
      final allDocs = await isar.finalDocuments.where().findAll();
      
      final filteredDocs = allDocs.where((doc) => 
          doc.documentType == documentType && doc.year == year).toList();
      
      // ترتيب حسب رقم المستند تنازلياً
      filteredDocs.sort((a, b) => b.documentNumber.compareTo(a.documentNumber));
      
      int nextNumber = 1;
      if (filteredDocs.isNotEmpty) {
        // استخراج الرقم من رقم المستند
        final parts = filteredDocs.first.documentNumber.split('/');
        if (parts.isNotEmpty) {
          final lastNumber = int.tryParse(parts[0]) ?? 0;
          nextNumber = lastNumber + 1;
        }
      }

      // تنسيق الرقم
      final prefix = _getDocumentTypePrefix(documentType);
      return '$nextNumber/$prefix/$year';
    } catch (e) {
      print('خطأ في توليد رقم المستند: $e');
      return '1/${_getDocumentTypePrefix(documentType)}/$year';
    }
  }

  /// الحصول على بادئة نوع المستند
  static String _getDocumentTypePrefix(String documentType) {
    switch (documentType.toLowerCase()) {
      case 'deductions':
        return 'استقطاع';
      case 'payments':
        return 'دفع';
      case 'transfers':
        return 'تحويل';
      default:
        return 'مستند';
    }
  }
}
