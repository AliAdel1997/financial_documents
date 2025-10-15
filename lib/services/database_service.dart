import 'package:isar/isar.dart';
import 'dart:io';
import '../models/document.dart';
import '../models/organization.dart';
import '../models/funding_models.dart';

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
    
    isar = await Isar.open([
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
    ], directory: dbPath, name: 'financial_documents');
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
  static Future<List<FundingCategory>> getSubFundingCategories(int parentId) async {
    return await isar.fundingCategorys.filter().parentIdEqualTo(parentId).findAll();
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
  static Future<List<FundingCategory>> searchFundingCategories(String searchTerm) async {
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
  static Future<List<InstitutionFunding>> getInstitutionFundingByInstitution(int institutionId) async {
    return await isar.institutionFundings.filter().institutionIdEqualTo(institutionId).findAll();
  }

  /// الحصول على تمويلات باب معين
  static Future<List<InstitutionFunding>> getInstitutionFundingByCategory(int categoryId) async {
    return await isar.institutionFundings.filter().categoryIdEqualTo(categoryId).findAll();
  }

  /// الحصول على تمويلات سنة معينة
  static Future<List<InstitutionFunding>> getInstitutionFundingByYear(int year) async {
    return await isar.institutionFundings.filter().yearEqualTo(year).findAll();
  }

  /// الحصول على تمويلات شهر وسنة معينة
  static Future<List<InstitutionFunding>> getInstitutionFundingByYearMonth(int year, int month) async {
    return await isar.institutionFundings.filter()
        .yearEqualTo(year)
        .and()
        .monthEqualTo(month)
        .findAll();
  }

  /// الحصول على تمويل مؤسسة بباب معين
  static Future<InstitutionFunding?> getInstitutionFundingByInstitutionAndCategory(
      int institutionId, int categoryId, int year, int month) async {
    return await isar.institutionFundings.filter()
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
  static Future<int> updateInstitutionFunding(InstitutionFunding funding) async {
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
  static Future<double> getTotalAllocatedAmountForInstitution(int institutionId, int year) async {
    final fundings = await isar.institutionFundings.filter()
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
  static Future<double> getTotalSpentAmountForInstitution(int institutionId, int year) async {
    final fundings = await isar.institutionFundings.filter()
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
  static Future<double> getTotalRemainingAmountForInstitution(int institutionId, int year) async {
    final fundings = await isar.institutionFundings.filter()
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
  static Future<double> getTotalAllocatedAmountForCategory(int categoryId, int year) async {
    final fundings = await isar.institutionFundings.filter()
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
  static Future<FundingAttachment> addFundingAttachment(FundingAttachment attachment) async {
    await isar.writeTxn(() async {
      attachment.uploadedAt ??= DateTime.now();
      await isar.fundingAttachments.put(attachment);
    });
    return attachment;
  }

  /// الحصول على جميع مرفقات تمويل معين
  static Future<List<FundingAttachment>> getAttachmentsByFunding(int fundingId) async {
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
  static Future<FundingAttachment> updateFundingAttachment(FundingAttachment attachment) async {
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
        .group((q) => q
            .fileNameContains(query, caseSensitive: false)
            .or()
            .fileTypeContains(query, caseSensitive: false)
            .or()
            .descriptionContains(query, caseSensitive: false))
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
  static Future<List<FundingArchive>> getFundingArchivesByFundingId(int fundingId) async {
    return await isar.fundingArchives.filter().fundingIdEqualTo(fundingId).findAll();
  }

  /// الحصول على سجلات الأرشيف لمؤسسة معينة
  static Future<List<FundingArchive>> getFundingArchivesByInstitution(int institutionId) async {
    return await isar.fundingArchives.filter().institutionIdEqualTo(institutionId).findAll();
  }

  /// الحصول على سجلات الأرشيف لباب معين
  static Future<List<FundingArchive>> getFundingArchivesByCategory(int categoryId) async {
    return await isar.fundingArchives.filter().categoryIdEqualTo(categoryId).findAll();
  }

  /// الحصول على سجلات الأرشيف لسنة معينة
  static Future<List<FundingArchive>> getFundingArchivesByYear(int year) async {
    return await isar.fundingArchives.filter().yearEqualTo(year).findAll();
  }

  /// الحصول على سجلات الأرشيف لنوع عملية معين
  static Future<List<FundingArchive>> getFundingArchivesByOperationType(String operationType) async {
    return await isar.fundingArchives.filter().operationTypeEqualTo(operationType).findAll();
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
  static Future<List<FundingTransaction>> getFundingTransactionsByFundingId(int fundingId) async {
    return await isar.fundingTransactions.filter().fundingIdEqualTo(fundingId).findAll();
  }

  /// الحصول على المعاملات لمؤسسة معينة
  static Future<List<FundingTransaction>> getFundingTransactionsByInstitution(int institutionId) async {
    return await isar.fundingTransactions.filter().institutionIdEqualTo(institutionId).findAll();
  }

  /// الحصول على المعاملات حسب الحالة
  static Future<List<FundingTransaction>> getFundingTransactionsByStatus(String status) async {
    return await isar.fundingTransactions.filter().statusEqualTo(status).findAll();
  }

  /// الحصول على طلبات الحجز المعلقة
  static Future<List<FundingTransaction>> getPendingReservations() async {
    return await isar.fundingTransactions.filter().statusEqualTo('pending').findAll();
  }

  /// الحصول على المعاملات المنفذة
  static Future<List<FundingTransaction>> getExecutedTransactions() async {
    return await isar.fundingTransactions.filter().statusEqualTo('executed').findAll();
  }

  /// حفظ معاملة جديدة
  static Future<void> saveFundingTransaction(FundingTransaction transaction) async {
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
        if (transaction == null) return;

        // تحديث المعاملة
        final updatedTransaction = transaction.copyWith(
          status: 'executed',
          executedAmount: executedAmount,
          executionDescription: executionDescription,
          executionAttachmentPath: executionAttachmentPath,
          executionDate: executionDate,
          updatedAt: DateTime.now(),
        );

        await isar.fundingTransactions.put(updatedTransaction);

        // تحديث التمويل الأساسي
        final funding = await isar.institutionFundings.get(transaction.fundingId!);
        if (funding != null) {
          final updatedFunding = funding.copyWith(
            reservedAmount: funding.reservedAmount - transaction.requestedAmount,
            spentAmount: funding.spentAmount + executedAmount,
            updatedAt: DateTime.now(),
          );
          await isar.institutionFundings.put(updatedFunding);
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

  /// إنشاء بيانات تجريبية للفئات المالية
  static Future<void> createSampleFundingCategories() async {
    try {
      // التحقق من وجود فئات موجودة
      final existingCategories = await isar.fundingCategorys.where().findAll();
      if (existingCategories.isNotEmpty) {
        print('فئات موجودة مسبقاً: ${existingCategories.length}');
        return;
      }

      await isar.writeTxn(() async {
        // فئات رئيسية (بدون ربط بنوع التمويل)
        final cat1 = FundingCategory()
          ..name = 'الرواتب والأجور'
          ..description = 'رواتب الموظفين والأجور الإضافية'
          ..parentId = null
          ..createdAt = DateTime.now()
          ..updatedAt = DateTime.now();
        
        final cat2 = FundingCategory()
          ..name = 'المستلزمات المكتبية'
          ..description = 'القرطاسية والمواد المكتبية'
          ..parentId = null
          ..createdAt = DateTime.now()
          ..updatedAt = DateTime.now();

        final cat3 = FundingCategory()
          ..name = 'الوقود والمحروقات'
          ..description = 'وقود السيارات والمولدات'
          ..parentId = null
          ..createdAt = DateTime.now()
          ..updatedAt = DateTime.now();

        await isar.fundingCategorys.putAll([cat1, cat2, cat3]);
        
        // فئات فرعية
        final subCat1 = FundingCategory()
          ..name = 'رواتب الموظفين'
          ..description = 'الرواتب الأساسية للموظفين'
          ..parentId = cat1.id
          ..createdAt = DateTime.now()
          ..updatedAt = DateTime.now();

        final subCat2 = FundingCategory()
          ..name = 'أجور العمل الإضافي'
          ..description = 'أجور ساعات العمل الإضافية'
          ..parentId = cat1.id
          ..createdAt = DateTime.now()
          ..updatedAt = DateTime.now();

        await isar.fundingCategorys.putAll([subCat1, subCat2]);
      });

      print('تم إنشاء بيانات تجريبية للفئات المالية');
    } catch (e) {
      print('خطأ في إنشاء البيانات التجريبية: $e');
    }
  }
}
